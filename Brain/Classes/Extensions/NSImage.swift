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

public extension NSImage
{
    var bitmapImageRepresentation: NSBitmapImageRep?
    {
        guard let cgImage = self.cgImage( forProposedRect: nil, context: nil, hints: nil ) else
        {
            return nil
        }
        
        let rep  = NSBitmapImageRep( cgImage: cgImage )
        rep.size = self.size
        
        return rep
    }
    
    var pngRepresentation: Data?
    {
        self.bitmapImageRepresentation?.representation( using: .png, properties: [:] )
    }
    
    var bmpRepresentation: Data?
    {
        self.bitmapImageRepresentation?.representation( using: .bmp, properties: [:] )
    }
    
    var gifRepresentation: Data?
    {
        self.bitmapImageRepresentation?.representation( using: .gif, properties: [:] )
    }
    
    var jpegRepresentation: Data?
    {
        self.bitmapImageRepresentation?.representation( using: .jpeg, properties: [:] )
    }
    
    var jpeg2000Representation: Data?
    {
        self.bitmapImageRepresentation?.representation( using: .jpeg2000, properties: [:] )
    }
}
