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

public struct Rect: Codable, Equatable, CustomDebugStringConvertible
{
    public var origin: Point
    public var size:   Size
    
    public init( x: Int, y: Int, width: Int, height: Int )
    {
        self.init( origin: Point( x: x, y: y ), size: Size( width: width, height: height ) )
    }
    
    public init( origin: Point, size: Size )
    {
        self.origin = origin
        self.size   = size
    }
    
    public var debugDescription: String
    {
        "{x: \( self.origin.x ), y: \( self.origin.y ), width: \( self.size.width ), height: \( self.size.height )}"
    }
    
    public func contains( point: Point ) -> Bool
    {
        let x = point.x
        let y = point.y
        
        return x >= self.origin.x && y >= self.origin.y && x < self.origin.x + self.size.width && y < self.origin.y + self.size.height
    }
    
    public func adjustingX( adding x: Int ) -> Rect
    {
        Rect( origin: self.origin.adjustingX( adding: x ), size: self.size )
    }
    
    public func adjustingX( to x: Int ) -> Rect
    {
        Rect( origin: self.origin.adjustingX( to: x ), size: self.size )
    }
    
    public func adjustingY( adding y: Int ) -> Rect
    {
        Rect( origin: self.origin.adjustingY( adding: y ), size: self.size )
    }
    
    public func adjustingY( to y: Int ) -> Rect
    {
        Rect( origin: self.origin.adjustingY( to: y ), size: self.size )
    }
    
    public func adjustingWidth( adding width: Int ) -> Rect
    {
        Rect( origin: self.origin, size: self.size.adjustingWidth( adding: width ) )
    }
    
    public func adjustingWidth( to width: Int ) -> Rect
    {
        Rect( origin: self.origin, size: self.size.adjustingWidth( to: width ) )
    }
    
    public func adjustingHeight( adding height: Int ) -> Rect
    {
        Rect( origin: self.origin, size: self.size.adjustingHeight( adding: height ) )
    }
    
    public func adjustingHeight( to height: Int ) -> Rect
    {
        Rect( origin: self.origin, size: self.size.adjustingHeight( to: height ) )
    }
}
