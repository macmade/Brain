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

class BorderInputs: XCTestCase
{
    func testLeftBorder() throws
    {
        let settings        = Settings()
        settings.gridWidth  = 100
        settings.gridHeight = 100
        
        let world    = World( settings: settings )
        let organism = Organism.random( world: world )
        
        let sensor      = CloseToLeftBorder()
        sensor.organism = organism
        
        organism?.position = Point( x: 0, y: 0 )
        XCTAssertGreaterThanOrEqual( sensor.value, 1 )
        XCTAssertLessThan( sensor.value, 1.01 )
        
        organism?.position = Point( x: 50, y: 0 )
        XCTAssertGreaterThanOrEqual( sensor.value, 0.49 )
        XCTAssertLessThan( sensor.value, 0.51 )
        
        organism?.position = Point( x: 99, y: 0 )
        XCTAssertEqual( sensor.value, 0 )
    }
    
    func testRightBorder() throws
    {
        let settings        = Settings()
        settings.gridWidth  = 100
        settings.gridHeight = 100
        
        let world    = World( settings: settings )
        let organism = Organism.random( world: world )
        
        let sensor      = CloseToRightBorder()
        sensor.organism = organism
        
        organism?.position = Point( x: 0, y: 0 )
        XCTAssertEqual( sensor.value, 0 )
        
        organism?.position = Point( x: 50, y: 0 )
        XCTAssertGreaterThanOrEqual( sensor.value, 0.49 )
        XCTAssertLessThan( sensor.value, 0.51 )
        
        organism?.position = Point( x: 99, y: 0 )
        XCTAssertGreaterThanOrEqual( sensor.value, 1 )
        XCTAssertLessThan( sensor.value, 1.01 )
    }
    
    func testBottomBorder() throws
    {
        let settings        = Settings()
        settings.gridWidth  = 100
        settings.gridHeight = 100
        
        let world    = World( settings: settings )
        let organism = Organism.random( world: world )
        
        let sensor      = CloseToBottomBorder()
        sensor.organism = organism
        
        organism?.position = Point( x: 0, y: 0 )
        XCTAssertGreaterThanOrEqual( sensor.value, 1 )
        XCTAssertLessThan( sensor.value, 1.01 )
        
        organism?.position = Point( x: 0, y: 50 )
        XCTAssertGreaterThanOrEqual( sensor.value, 0.49 )
        XCTAssertLessThan( sensor.value, 0.51 )
        
        organism?.position = Point( x: 0, y: 99 )
        XCTAssertEqual( sensor.value, 0 )
    }
    
    func testTopBorder() throws
    {
        let settings        = Settings()
        settings.gridWidth  = 100
        settings.gridHeight = 100
        
        let world    = World( settings: settings )
        let organism = Organism.random( world: world )
        
        let sensor      = CloseToTopBorder()
        sensor.organism = organism
        
        organism?.position = Point( x: 0, y: 0 )
        XCTAssertEqual( sensor.value, 0 )
        
        organism?.position = Point( x: 0, y: 50 )
        XCTAssertGreaterThanOrEqual( sensor.value, 0.49 )
        XCTAssertLessThan( sensor.value, 0.51 )
        
        organism?.position = Point( x: 0, y: 99 )
        XCTAssertGreaterThanOrEqual( sensor.value, 1 )
        XCTAssertLessThan( sensor.value, 1.01 )
    }
}
