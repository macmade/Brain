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

public class BarrierLeft: Input
{
    public override var name: String
    {
        "BrL"
    }
    
    public override func copy( with zone: NSZone? = nil ) -> Any
    {
        BarrierLeft()
    }
    
    public override var value: Double
    {
        guard let organism = self.organism, let world = organism.world else
        {
            return 0
        }
        
        var point = organism.position
        
        while point.x > 0
        {
            if let barrier = world.settings.barriers.first( where: { $0.contains( point: point ) } )
            {
                let distance = point.x - barrier.origin.x
                
                return Double( world.size.width - distance ) / Double( world.size.width - 1 )
            }
            
            point.x -= 1
        }
        
        return 0
    }
}
