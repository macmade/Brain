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

public struct Size: Codable, Equatable, CustomDebugStringConvertible
{
    public var width:  Int
    public var height: Int
    
    public init( width: Int, height: Int )
    {
        self.width  = width
        self.height = height
    }
    
    public var debugDescription: String
    {
        "{width: \( self.width ), height: \( self.height )}"
    }
    
    public func adjustingWidth( adding width: Int ) -> Size
    {
        Size( width: self.width + width, height: self.height )
    }
    
    public func adjustingWidth( to width: Int ) -> Size
    {
        Size( width: width, height: self.height )
    }
    
    public func adjustingHeight( adding height: Int ) -> Size
    {
        Size( width: self.width, height: self.height + height )
    }
    
    public func adjustingHeight( to height: Int ) -> Size
    {
        Size( width: self.width, height: height )
    }
}
