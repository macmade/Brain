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
    
    init( settings: Settings )
    {
        self.settings          = settings
        self.size              = Size( width: settings.gridWidth, height: settings.gridHeight )
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
        
        var points: [ Point ] = []
        
        self.organisms.forEach
        {
            organism in repeat
            {
                let x             = Int.random( in: 0 ..< size.width )
                let y             = Int.random( in: 0 ..< size.height )
                organism.position = Point( x: x, y: y )
            }
            while points.contains
            {
                $0 == organism.position
            }
            
            points.append( organism.position )
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
            $0.process()
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
        
        return self.organisms.contains { $0.position == point } == false
    }
}
