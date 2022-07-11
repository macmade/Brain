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

class BarrierInputs: XCTestCase
{
    func testBarrierLeft() throws
    {
        let settings        = Settings()
        settings.gridWidth  = 100
        settings.gridHeight = 100
        settings.barriers   = [ Rect( x: 0, y: 0, width: 10, height: 10 ) ]
        
        let world    = World( settings: settings )
        let organism = Organism.random( world: world )
        
        let sensor      = BarrierLeft()
        sensor.organism = organism
        
        organism?.position = Point( x: 11, y: 0 )
        XCTAssertGreaterThanOrEqual( sensor.value, 1 )
        XCTAssertLessThan( sensor.value, 1.01 )
        
        organism?.position = Point( x: 20, y: 0 )
        XCTAssertGreaterThanOrEqual( sensor.value, 0.9 )
        XCTAssertLessThan( sensor.value, 0.91 )
        
        organism?.position = Point( x: 30, y: 0 )
        XCTAssertGreaterThanOrEqual( sensor.value, 0.8 )
        XCTAssertLessThan( sensor.value, 0.81 )
        
        organism?.position = Point( x: 20, y: 20 )
        XCTAssertEqual( sensor.value, 0 )
    }
    
    func testBarrierRight() throws
    {
        let settings        = Settings()
        settings.gridWidth  = 100
        settings.gridHeight = 100
        settings.barriers   = [ Rect( x: 90, y: 0, width: 10, height: 10 ) ]
        
        let world    = World( settings: settings )
        let organism = Organism.random( world: world )
        
        let sensor      = BarrierRight()
        sensor.organism = organism
        
        organism?.position = Point( x: 89, y: 0 )
        XCTAssertGreaterThanOrEqual( sensor.value, 1 )
        XCTAssertLessThan( sensor.value, 1.01 )
        
        organism?.position = Point( x: 80, y: 0 )
        XCTAssertGreaterThanOrEqual( sensor.value, 0.9 )
        XCTAssertLessThan( sensor.value, 0.91 )
        
        organism?.position = Point( x: 70, y: 0 )
        XCTAssertGreaterThanOrEqual( sensor.value, 0.8 )
        XCTAssertLessThan( sensor.value, 0.81 )
        
        organism?.position = Point( x: 20, y: 20 )
        XCTAssertEqual( sensor.value, 0 )
    }
    
    func testBarrierDown() throws
    {
        let settings        = Settings()
        settings.gridWidth  = 100
        settings.gridHeight = 100
        settings.barriers   = [ Rect( x: 0, y: 0, width: 10, height: 10 ) ]
        
        let world    = World( settings: settings )
        let organism = Organism.random( world: world )
        
        let sensor      = BarrierDown()
        sensor.organism = organism
        
        organism?.position = Point( x: 0, y: 11 )
        XCTAssertGreaterThanOrEqual( sensor.value, 1 )
        XCTAssertLessThan( sensor.value, 1.01 )
        
        organism?.position = Point( x: 0, y: 20 )
        XCTAssertGreaterThanOrEqual( sensor.value, 0.9 )
        XCTAssertLessThan( sensor.value, 0.91 )
        
        organism?.position = Point( x: 0, y: 30 )
        XCTAssertGreaterThanOrEqual( sensor.value, 0.8 )
        XCTAssertLessThan( sensor.value, 0.81 )
        
        organism?.position = Point( x: 20, y: 20 )
        XCTAssertEqual( sensor.value, 0 )
    }
    
    func testBarrierUp() throws
    {
        let settings        = Settings()
        settings.gridWidth  = 100
        settings.gridHeight = 100
        settings.barriers   = [ Rect( x: 0, y: 90, width: 10, height: 10 ) ]
        
        let world    = World( settings: settings )
        let organism = Organism.random( world: world )
        
        let sensor      = BarrierUp()
        sensor.organism = organism
        
        organism?.position = Point( x: 0, y: 89 )
        XCTAssertGreaterThanOrEqual( sensor.value, 1 )
        XCTAssertLessThan( sensor.value, 1.01 )
        
        organism?.position = Point( x: 0, y: 80 )
        XCTAssertGreaterThanOrEqual( sensor.value, 0.9 )
        XCTAssertLessThan( sensor.value, 0.91 )
        
        organism?.position = Point( x: 0, y: 70 )
        XCTAssertGreaterThanOrEqual( sensor.value, 0.8 )
        XCTAssertLessThan( sensor.value, 0.81 )
        
        organism?.position = Point( x: 20, y: 20 )
        XCTAssertEqual( sensor.value, 0 )
    }
}
