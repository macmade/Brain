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
    public private( set ) var world: World
    
    private var dotGenerator:    DotGenerator?
    private var imageGenerator:  ImageGenerator?
    private var cachesDirectory: URL?
    
    public init( world: World )
    {
        OutputGeneration.clearAll()
        
        self.world = world
        
        if let caches = Bundle.main.cachesDirectory?.appendingPathComponent( "com.xs-labs.Brain-\( UUID().uuidString )" )
        {
            self.imageGenerator  = ImageGenerator( cachesDirectory: caches.appendingPathComponent( "jpg" ) )
            self.dotGenerator    = DotGenerator(   cachesDirectory: caches.appendingPathComponent( "dot" ) )
            self.cachesDirectory = caches
        }
    }
    
    public func run()
    {
        var survivors: [ Organism ] = []
        
        Benchmark.run
        {
            print( "Simulating \( self.world.settings.numberOfGenerations ) generations:" )
            
            for _ in 0 ..< self.world.settings.numberOfGenerations
            {
                autoreleasepool
                {
                    self.world.spawnNewGeneration( from: survivors )
                    
                    print( "Generation \( self.world.currentGeneration ):" )
                    
                    for _ in 0 ..< self.world.settings.stepsPerGeneration
                    {
                        autoreleasepool
                        {
                            if self.world.currentStep == 0
                            {
                                self.imageGenerator?.prepare( organisms: self.world.organisms, generation: self.world.currentGeneration, step: self.world.currentStep )
                            }
                            
                            self.world.step()
                            self.imageGenerator?.prepare( organisms: self.world.organisms, generation: self.world.currentGeneration , step: self.world.currentStep )
                        }
                    }
                    
                    
                    let surviveState = self.getSurviveState()
                    survivors        = surviveState.filter { $0.survive }.map { $0.organism }
                    let percent      = Int( ( Double( survivors.count ) / Double( self.world.settings.population ) ) * 100 )
                    
                    print( "    - \( survivors.count ) survivors out of \( self.world.organisms.count ): \( percent )%" )
                    
                    self.dotGenerator?.prepare( state: surviveState, generation: self.world.currentGeneration )
                    self.world.removeOrganisms { organism in survivors.contains { $0 === organism } == false }
                    self.imageGenerator?.prepare( organisms: self.world.organisms, generation: self.world.currentGeneration, step: self.world.currentStep + 1 )
                }
            }
        }
        finished:
        {
            print( "Finished processing in \( TimeTransformer.string( for: $0  ) )" )
        }
        
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
            print( "Generating images..." )
            self.imageGenerator?.generate( world: self.world )
        }
        finished:
        {
            print( "Done in \( TimeTransformer.string( for: $0 ) )" )
        }
        
        if let caches = self.cachesDirectory
        {
            OutputGeneration.generateSVGScriptsForDotFiles( from: caches.appendingPathComponent( "dot" ), in: caches.appendingPathComponent( "svg" ) )
            
            Benchmark.run
            {
                print( "Generating movies:" )
                OutputGeneration.generateMovies( from: caches.appendingPathComponent( "jpg" ), in: caches.appendingPathComponent( "mov" ), world: self.world )
            }
            finished:
            {
                print( "Done in \( TimeTransformer.string( for: $0 ) )" )
            }
            
            NSWorkspace.shared.selectFile( caches.path, inFileViewerRootedAtPath: caches.path )
        }
    }
    
    public func getSurviveState() -> [ SurviveState ]
    {
        let organisms = self.world.organisms.map { SurviveState( organism: $0 ) }
        
        self.world.settings.surviveAreas.forEach
        {
            rect in organisms.forEach { $0.survive = rect.contains( point: $0.organism.position ) }
        }
        
        self.world.settings.killAreas.forEach
        {
            rect in organisms.forEach { $0.survive = rect.contains( point: $0.organism.position ) ? false : $0.survive }
        }
        
        return organisms
    }
}
