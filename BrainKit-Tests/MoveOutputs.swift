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

class MoveOutputs: XCTestCase
{
    func testMoveX() throws
    {
        let settings        = Settings()
        settings.gridWidth  = 100
        settings.gridHeight = 100
        
        let world  = World( settings: settings )
        let action = MoveX()
        
        guard let organism = Organism.random( world: world ) else
        {
            return
        }
        
        organism.position = Point( x: 10, y: 10 )
        
        action.take( value: 1 )
        action.execute( with: organism )
        XCTAssertEqual( organism.position,     Point( x: 10, y: 10 ) )
        XCTAssertEqual( organism.nextPosition, Point( x: 11, y: 10 ) )
        
        action.take( value: -1 )
        action.execute( with: organism )
        XCTAssertEqual( organism.position,     Point( x: 10, y: 10 ) )
        XCTAssertEqual( organism.nextPosition, Point( x: 11, y: 10 ) )
        
        action.take( value: -1 )
        action.execute( with: organism )
        XCTAssertEqual( organism.position,     Point( x: 10, y: 10 ) )
        XCTAssertEqual( organism.nextPosition, Point( x: 10, y: 10 ) )
    }
    
    func testMoveY() throws
    {
        let settings        = Settings()
        settings.gridWidth  = 100
        settings.gridHeight = 100
        
        let world  = World( settings: settings )
        let action = MoveY()
        
        guard let organism = Organism.random( world: world ) else
        {
            return
        }
        
        organism.position = Point( x: 10, y: 10 )
        
        action.take( value: 1 )
        action.execute( with: organism )
        XCTAssertEqual( organism.position,     Point( x: 10, y: 10 ) )
        XCTAssertEqual( organism.nextPosition, Point( x: 10, y: 11 ) )
        
        action.take( value: -1 )
        action.execute( with: organism )
        XCTAssertEqual( organism.position,     Point( x: 10, y: 10 ) )
        XCTAssertEqual( organism.nextPosition, Point( x: 10, y: 11 ) )
        
        action.take( value: -1 )
        action.execute( with: organism )
        XCTAssertEqual( organism.position,     Point( x: 10, y: 10 ) )
        XCTAssertEqual( organism.nextPosition, Point( x: 10, y: 10 ) )
    }
    
    func testMoveXY() throws
    {
        let settings        = Settings()
        settings.gridWidth  = 100
        settings.gridHeight = 100
        
        let world   = World( settings: settings )
        let action1 = MoveX()
        let action2 = MoveY()
        
        guard let organism = Organism.random( world: world ) else
        {
            return
        }
        
        organism.position = Point( x: 10, y: 10 )
        
        action1.take( value:  1 )
        action2.take( value: -1 )
        action1.execute( with: organism )
        action2.execute( with: organism )
        XCTAssertEqual( organism.position,     Point( x: 10, y: 10 ) )
        XCTAssertEqual( organism.nextPosition, Point( x: 11, y:  9 ) )
        
        action1.take( value: -1 )
        action2.take( value:  1 )
        action1.execute( with: organism )
        action2.execute( with: organism )
        XCTAssertEqual( organism.position,     Point( x: 10, y: 10 ) )
        XCTAssertEqual( organism.nextPosition, Point( x: 11, y:  9 ) )
        
        action1.take( value: -1 )
        action2.take( value:  1 )
        action1.execute( with: organism )
        action2.execute( with: organism )
        XCTAssertEqual( organism.position,     Point( x: 10, y: 10 ) )
        XCTAssertEqual( organism.nextPosition, Point( x: 10, y: 10 ) )
    }
}
