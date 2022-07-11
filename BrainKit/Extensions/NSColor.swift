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

import Cocoa

public extension NSColor
{
    convenience init( rgba: UInt32 )
    {
        let r32 = ( rgba >> 24 ) & 0xFF
        let g32 = ( rgba >> 16 ) & 0xFF
        let b32 = ( rgba >>  8 ) & 0xFF
        let a32 = ( rgba >>  0 ) & 0xFF
        
        let r = CGFloat( r32 ) / 255.0
        let g = CGFloat( g32 ) / 255.0
        let b = CGFloat( b32 ) / 255.0
        let a = CGFloat( a32 ) / 255.0
        
        self.init( srgbRed: r, green: g, blue: b, alpha: a )
    }
    
    var rgba: UInt32
    {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        self.usingColorSpace( .sRGB )?.getRed( &r, green: &g, blue: &b, alpha: &a )
        
        let r32 = UInt32( r * 255.0 )
        let g32 = UInt32( g * 255.0 )
        let b32 = UInt32( b * 255.0 )
        let a32 = UInt32( a * 255.0 )
        
        return ( r32 << 24 ) | ( g32 << 16 ) | ( b32 << 8 ) | a32
    }
}
