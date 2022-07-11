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

import XCTest
import BrainKit

class AgeInput: XCTestCase
{
    func testAge() throws
    {
        let settings                = Settings()
        settings.gridWidth          = 100
        settings.gridHeight         = 100
        settings.population         = 1
        settings.stepsPerGeneration = 4
        
        let world = World( settings: settings )
        
        world.spawnNewGeneration( from: [] )
        
        guard let sensor = world.organisms.first?.brain.inputs.first( where: { $0 is Age } ) as? Age else
        {
            return
        }
        
        XCTAssertEqual( sensor.value, 0 )
        world.step()
        XCTAssertEqual( sensor.value, 0.25 )
        world.step()
        XCTAssertEqual( sensor.value, 0.5 )
        world.step()
        XCTAssertEqual( sensor.value, 0.75 )
        world.step()
        XCTAssertEqual( sensor.value, 1 )
    }
}
