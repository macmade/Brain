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

import Foundation

public class World
{
    public private( set ) var settings:          Settings
    public private( set ) var size:              Size
    public private( set ) var organisms:         [ Organism ]
    public private( set ) var currentGeneration: Int
    public private( set ) var currentStep:       Int
    
    private var queue = WaitableOperationQueue( label: "com.xs-labs.Brain.World", qos: .userInteractive )
    
    public init( settings: Settings )
    {
        self.settings          = settings
        self.size              = Size( width: Int( settings.gridWidth ), height: Int( settings.gridHeight ) )
        self.organisms         = []
        self.currentGeneration = 0
        self.currentStep       = 0
    }
    
    public func spawnNewGeneration( from organisms: [ Organism ] )
    {
        self.currentGeneration += 1
        self.currentStep        = 0
        
        self.organisms = ( 0 ..< self.settings.population ).compactMap
        {
            _ in organisms.randomElement()?.replicate() ?? Organism.random( world: self )
        }
        
        self.organisms.forEach
        {
            var point = Point( x: 0, y: 0 )
            
            repeat
            {
                point.x = Int.random( in: 0 ..< size.width )
                point.y = Int.random( in: 0 ..< size.height )
            }
            while self.locationIsAvailable( point ) == false
            
            $0.position = point
        }
    }
    
    public func removeOrganisms( matching: ( Organism ) -> Bool )
    {
        self.organisms = self.organisms.filter { matching( $0 ) == false }
    }
    
    public func step()
    {
        self.currentStep += 1
        
        self.organisms.forEach
        {
            organism in self.queue.run
            {
                organism.brain.process()
                organism.brain.outputs.forEach
                {
                    $0.execute( with: organism )
                }
                organism.brain.reset()
            }
        }
        self.queue.wait()
        self.organisms.forEach
        {
            if let pos = $0.nextPosition, self.locationIsAvailable( pos )
            {
                $0.position = pos
            }
            
            $0.nextPosition = nil
        }
    }
    
    public func locationIsAvailable( _ point: Point ) -> Bool
    {
        if point.x < 0 || point.x >= self.size.width
        {
            return false
        }
        
        if point.y < 0 || point.y >= self.size.height
        {
            return false
        }
        
        if self.organisms.contains( where: { $0.position == point } )
        {
            return false
        }
        
        if self.settings.barriers.contains( where: { $0.contains( point: point ) } )
        {
            return false
        }
        
        return true
    }
}
