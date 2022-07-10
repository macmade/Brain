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

public class ImageProcessor
{
    private let uuid           = UUID()
    private let queue          = DispatchQueue( label: "com.xs-labs.Brain.ImageProcessor", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil )
    private var groups         = [ DispatchGroup ]()
    private var prepared       = [ () -> Void ]()
    private var cachesDirectory: URL
    
    public init( cachesDirectory: URL )
    {
        self.cachesDirectory = cachesDirectory
        
        try? FileManager.default.createDirectory( at: self.cachesDirectory, withIntermediateDirectories: true )
    }
    
    public func wait()
    {
        self.groups.forEach { $0.wait() }
        self.groups.removeAll()
    }
    
    public func generate()
    {
        let prepared = self.prepared
        let group    = DispatchGroup()
        
        self.prepared.removeAll()
        self.groups.append( group )
        group.enter()
        
        self.queue.async
        {
            prepared.forEach
            {
                generate in autoreleasepool
                {
                    generate()
                }
            }
            group.leave()
        }
    }
    
    public func prepare( world: World, generation: Int, step: Int )
    {
        let organisms: [ ( position: Point, color: NSColor ) ] = world.organisms.map
        {
            ( position: $0.position, color: $0.color )
        }
        
        let dir = self.cachesDirectory.appendingPathComponent( "generation-\( generation )" )
        let url = dir.appendingPathComponent( "step-\( step ).png" )
        
        try? FileManager.default.createDirectory( at: dir, withIntermediateDirectories: true )
        
        let generate: () -> Void =
        {
            let factor = world.settings.imageScaleFactor
            let size   = NSSize( width: world.size.width * factor, height: world.size.height * factor )
            let image  = NSImage( size: size )
            
            image.lockFocus()
            NSColor.black.setFill()
            NSRect( x: 0, y: 0, width: size.width, height: size.height ).fill()
            
            organisms.forEach
            {
                let path       = NSBezierPath( ovalIn: NSRect( x: $0.position.x * factor, y: $0.position.y * factor, width: factor, height: factor ) )
                path.lineWidth = Double( factor ) / 16
                
                $0.color.setFill()
                NSColor.white.setStroke()
                path.fill()
                path.stroke()
            }
            
            image.unlockFocus()
            
            if let cgImage = image.cgImage( forProposedRect: nil, context: nil, hints: nil )
            {
                let rep  = NSBitmapImageRep( cgImage: cgImage )
                rep.size = image.size
                let png  = rep.representation( using: .png, properties: [:] )
                
                try? png?.write( to: url )
            }
        }
        
        self.prepared.append( generate )
    }
}
