/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2022 Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Cocoa

public class Simulation
{
    public private( set ) var settings: Settings
    
    private var dotGenerator:    DotGenerator?
    private var imageGenerator:  ImageGenerator?
    private var cachesDirectory: URL?
    
    public init( settings: Settings )
    {
        OutputGeneration.clearAll()
        
        self.settings = settings
        
        if let caches = Bundle.main.cachesDirectory?.appendingPathComponent( "com.xs-labs.Brain-\( UUID().uuidString )" )
        {
            self.cachesDirectory = caches
        }
    }
    
    public func run()
    {
        var survivability = 0.0
        var world:          World!
        
        repeat
        {
            autoreleasepool
            {
                world = World( settings: self.settings )
                
                if let caches = self.cachesDirectory
                {
                    self.imageGenerator  = ImageGenerator( cachesDirectory: caches.appendingPathComponent( "jpg" ) )
                    self.dotGenerator    = DotGenerator(   cachesDirectory: caches.appendingPathComponent( "dot" ) )
                    self.cachesDirectory = caches
                }
            }
            
            Benchmark.run
            {
                print( "Simulating \( self.settings.numberOfGenerations ) generations:" )
                
                var survivors = [ Organism ]()
                
                for _ in 0 ..< self.settings.numberOfGenerations
                {
                    Benchmark.run
                    {
                        survivors = self.runGeneration( from: survivors, in: world )
                    }
                    finished:
                    {
                        survivability = ( Double( survivors.count ) / Double( self.settings.population ) ) * 100.0
                        
                        print(
                            """
                            Generation \( world.currentGeneration ):
                                - \( survivors.count ) survivors out of \( self.settings.population ): \( Int( survivability ) )%"
                                - Time: \( TimeTransformer.string( for: $0 ) )
                            """
                        )
                    }
                }
            }
            finished:
            {
                print( "Finished processing in \( TimeTransformer.string( for: $0 ) )" )
            }
        }
        while survivability < self.settings.requiredSurvivability
        
        if let caches = self.cachesDirectory
        {
            Benchmark.run
            {
                print( "Generating graphs..." )
                self.dotGenerator?.generate()
            }
            finished:
            {
                print( "Done in \( TimeTransformer.string( for: $0 ) )" )
            }
            
            Benchmark.run
            {
                print( "Generating SVG scripts:" )
                OutputGeneration.generateSVGScriptsForDotFiles( from: caches.appendingPathComponent( "dot" ), in: caches.appendingPathComponent( "svg" ) )
            }
            finished:
            {
                print( "Done in \( TimeTransformer.string( for: $0 ) )" )
            }
            
            Benchmark.run
            {
                print( "Generating images..." )
                self.imageGenerator?.generate( world: world )
            }
            finished:
            {
                print( "Done in \( TimeTransformer.string( for: $0 ) )" )
            }
            
            Benchmark.run
            {
                print( "Generating movies:" )
                OutputGeneration.generateMovies( from: caches.appendingPathComponent( "jpg" ), in: caches.appendingPathComponent( "mov" ), world: world )
            }
            finished:
            {
                print( "Done in \( TimeTransformer.string( for: $0 ) )" )
            }
            
            NSWorkspace.shared.selectFile( caches.path, inFileViewerRootedAtPath: caches.path )
        }
    }
    
    private func runGeneration( from organisms: [ Organism ], in world: World ) -> [ Organism ]
    {
        world.spawnNewGeneration( from: organisms )
        
        for _ in 0 ..< self.settings.stepsPerGeneration
        {
            autoreleasepool
            {
                if world.currentStep == 0
                {
                    self.imageGenerator?.prepare( organisms: world.organisms, generation: world.currentGeneration, step: world.currentStep )
                }
                
                world.step()
                self.imageGenerator?.prepare( organisms: world.organisms, generation: world.currentGeneration , step: world.currentStep )
            }
        }
        
        let surviveState = self.getSurviveState( in: world )
        let survivors    = surviveState.filter { $0.survive }.map { $0.organism }
        
        self.dotGenerator?.prepare( state: surviveState, generation: world.currentGeneration )
        world.removeOrganisms { organism in survivors.contains { $0 === organism } == false }
        self.imageGenerator?.prepare( organisms: world.organisms, generation: world.currentGeneration, step: world.currentStep + 1 )
        
        return survivors
    }
    
    private func getSurviveState( in world: World ) -> [ SurviveState ]
    {
        let organisms = world.organisms.map { SurviveState( organism: $0 ) }
        
        self.settings.surviveAreas.forEach
        {
            rect in organisms.forEach { $0.survive = rect.contains( point: $0.organism.position ) }
        }
        
        self.settings.killAreas.forEach
        {
            rect in organisms.forEach { $0.survive = rect.contains( point: $0.organism.position ) ? false : $0.survive }
        }
        
        return organisms
    }
}
