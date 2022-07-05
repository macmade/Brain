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

public class Grid
{
    public private( set ) var size:      Size
    public private( set ) var organisms: [ Organism ]
    
    init( settings: Settings )
    {
        self.size      = Size( width: settings.gridWidth, height: settings.gridHeight )
        self.organisms = ( 0 ..< settings.initialPopulation ).compactMap
        {
            _ in Organism.random( settings: settings, generation: 0 )
        }
        
        self.placeOrganisms()
    }
    
    private func placeOrganisms()
    {
        self.organisms.forEach
        {
            organism in repeat
            {
                let x             = Int.random( in: 0 ..< size.width )
                let y             = Int.random( in: 0 ..< size.height )
                organism.position = Point( x: x, y: y )
            }
            while organisms.contains
            {
                $0 !== organism && $0.position == organism.position
            }
        }
    }
    
    public func mutate()
    {
        self.organisms = self.organisms.compactMap
        {
            $0.mutate()
        }
        
        self.placeOrganisms()
    }
}
