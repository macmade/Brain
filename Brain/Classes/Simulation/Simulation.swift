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
    
    private var imageProcessor:  ImageProcessor?
    private var cachesDirectory: URL?
    
    public init( world: World )
    {
        OutputGeneration.clearAll()
        
        self.world = world
        
        if let caches = Bundle.main.cachesDirectory?.appendingPathComponent( "com.xs-labs.Brain-\( UUID().uuidString )" )
        {
            self.imageProcessor  = ImageProcessor( cachesDirectory: caches.appendingPathComponent( "png" ) )
            self.cachesDirectory = caches
        }
    }
    
    public func run()
    {
        let start = Date()
        
        print( "Simulating \( self.world.settings.numberOfGenerations ) generations:\n" )
        
        var survivors: [ Organism ] = []
        
        for _ in 0 ..< self.world.settings.numberOfGenerations
        {
            autoreleasepool
            {
                self.world.spawnNewGeneration( from: survivors )
                
                print( "Generation \( self.world.currentGeneration ):" )
                print( "    - Spawned \( self.world.organisms.count ) organisms" )
                
                for _ in 0 ..< self.world.settings.stepsPerGeneration
                {
                    autoreleasepool
                    {
                        if self.world.currentStep == 0
                        {
                            self.imageProcessor?.prepare( world: self.world, generation: self.world.currentGeneration, step: self.world.currentStep )
                        }
                        
                        self.world.step()
                        self.imageProcessor?.prepare( world: self.world, generation: self.world.currentGeneration , step: self.world.currentStep )
                    }
                }
                
                survivors = self.getSurvivors()
                
                print( "    - \( survivors.count ) survivors" )
                
                self.world.removeOrganisms { organism in survivors.contains { $0 === organism } == false }
                self.imageProcessor?.prepare( world: self.world, generation: self.world.currentGeneration, step: self.world.currentStep + 1 )
                self.imageProcessor?.generate()
                
                if let caches = self.cachesDirectory
                {
                    OutputGeneration.writeDotFiles( from: self.world.organisms.map { $0.brain }, in: caches.appendingPathComponent( "dot" ), generation: self.world.currentGeneration )
                }
            }
        }
        
        let end = Date()
        
        print( "Finished processing in \( TimeTransformer.string( for: end.timeIntervalSince( start ) ) )" )
        print( "Wating for images to finish processing..." )
        self.imageProcessor?.wait()
        
        if let caches = self.cachesDirectory
        {
            OutputGeneration.writeSVGScriptForDotFiles( from: caches.appendingPathComponent( "dot" ), in: caches.appendingPathComponent( "svg" ) )
            
            print( "Generating movies:" )
            OutputGeneration.generateMovies( from: caches.appendingPathComponent( "png" ), in: caches.appendingPathComponent( "mov" ), world: self.world )
            
            NSWorkspace.shared.selectFile( caches.path, inFileViewerRootedAtPath: caches.path )
        }
    }
    
    public func getSurvivors() -> [ Organism ]
    {
        let organisms   = self.world.organisms.map { SurviveState( organism: $0 ) }
        let rect        = Rect( origin: Point( x: 0, y: 0 ), size: Size( width: self.world.size.width / 3, height: self.world.size.height / 3 ) )
        let topLeft     = rect.adjustingY( to: ( self.world.size.height / 3 ) * 2 )
        let topRight    = rect.adjustingX( to: ( self.world.size.width / 3 ) * 2 ).adjustingY( to: ( self.world.size.height / 3 ) * 2 )
        let bottomLeft  = rect
        let bottomRight = rect.adjustingX( to: ( self.world.size.width / 3 ) * 2 )
        let center      = rect.adjustingX( to: self.world.size.width / 3 ).adjustingY( to: self.world.size.height / 3 )
        
        let predicates: [ Settings.Area : ( Organism ) -> Bool ] =
        [
            .leftBorder   : { $0.position.x == 0 },
            .bottomBorder : { $0.position.y == 0 },
            .rightBorder  : { $0.position.x == self.world.size.width  - 1 },
            .topBorder    : { $0.position.y == self.world.size.height - 1 },
            
            .leftHalf   : { $0.position.x < self.world.size.width  / 2 },
            .bottomHalf : { $0.position.y < self.world.size.height / 2 },
            .rightHalf  : { $0.position.x > self.world.size.width  / 2 },
            .topHalf    : { $0.position.y > self.world.size.height / 2 },
            
            .topLeftCorner     : { topLeft.contains( point: $0.position ) },
            .topRightCorner    : { topRight.contains( point: $0.position ) },
            .bottomLeftCorner  : { bottomLeft.contains( point: $0.position ) },
            .bottomRightCorner : { bottomRight.contains( point: $0.position ) },
            .center            : { center.contains( point: $0.position ) },
        ]
        
        predicates.forEach
        {
            predicate in if self.world.settings.surviveAreas.contains( predicate.key )
            {
                organisms.forEach { $0.survive = predicate.value( $0.organism ) }
            }
        }
        
        predicates.forEach
        {
            predicate in if self.world.settings.killAreas.contains( predicate.key )
            {
                organisms.forEach { $0.survive = predicate.value( $0.organism ) ? false : $0.survive }
            }
        }
        
        return organisms.filter { $0.survive }.map { $0.organism }
    }
}
