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

public class BarrierRight: Input
{
    public override var name: String
    {
        "BrR"
    }
    
    public override func copy( with zone: NSZone? = nil ) -> Any
    {
        BarrierRight()
    }
    
    public override var value: Double
    {
        guard let organism = self.organism, let world = organism.world else
        {
            return 0
        }
        
        let distances = world.settings.barriers.filter
        {
            $0.origin.x > organism.position.x && $0.origin.y <= organism.position.y && $0.origin.y + $0.size.height >= organism.position.y
        }
        .map
        {
             $0.origin.x - organism.position.x
        }
        .sorted
        {
            $0 < $1
        }
        
        if let distance = distances.first
        {
            return Double( world.size.width - distance ) / Double( world.size.width - 1 )
        }
        
        return 0
    }
}
