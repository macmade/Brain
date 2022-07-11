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

public class ImageGenerator
{
    private var prepared       = [ ImageGeneratorInfo ]()
    private let queue          = DispatchQueue( label: "com.xs-labs.Brain.ImageGenerator", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil )
    private var cachesDirectory: URL
    
    public init( cachesDirectory: URL )
    {
        self.cachesDirectory = cachesDirectory
        
        try? FileManager.default.createDirectory( at: self.cachesDirectory, withIntermediateDirectories: true )
    }
    
    public func generate( world: World )
    {
        let prepared = self.prepared.reduce( into: [ Int : [ ImageGeneratorInfo ] ]() )
        {
            if $0[ $1.generation ] == nil
            {
               $0[ $1.generation ] = [ ImageGeneratorInfo ]()
            }
            
            $0[ $1.generation ]?.append( $1 )
        }
        
        self.prepared.removeAll()
        
        let keys = prepared.keys.sorted { $0 < $1 }
        
        keys.forEach
        {
            guard let images = prepared[ $0 ] else
            {
                return
            }
            
            let generation = $0
            var groups     = [ DispatchGroup ]()
            let dir        = self.cachesDirectory.appendingPathComponent( "generation-\( generation )" )
            let factor     = world.settings.imageScaleFactor
            let size       = NSSize( width: world.size.width * factor, height: world.size.height * factor )
            
            try? FileManager.default.createDirectory( at: dir, withIntermediateDirectories: true )
            
            images.forEach
            {
                info in
                
                let group = DispatchGroup()
                
                groups.append( group )
                group.enter()
                
                self.queue.async
                {
                    autoreleasepool
                    {
                        let url    = dir.appendingPathComponent( "step-\( info.step ).jpg" )
                        let image  = NSImage( size: size )
                        
                        image.lockFocus()
                        NSColor.black.setFill()
                        NSRect( x: 0, y: 0, width: size.width, height: size.height ).fill()
                        
                        info.organisms.forEach
                        {
                            let path       = NSBezierPath( ovalIn: NSRect( x: $0.point.x * factor, y: $0.point.y * factor, width: factor, height: factor ) )
                            path.lineWidth = Double( factor ) / 16
                            
                            NSColor( rgba: $0.color ).setFill()
                            NSColor.white.setStroke()
                            path.fill()
                            path.stroke()
                        }
                        
                        image.unlockFocus()
                        
                        try? image.jpegRepresentation?.write( to: url )
                        
                        group.leave()
                    }
                }
            }
            
            groups.forEach { $0.wait() }
            print( "    - generation-\( generation )" )
        }
    }
    
    public func prepare( organisms: [ Organism ], generation: Int, step: Int )
    {
        self.prepared.append( ImageGeneratorInfo( generation: generation, step: step, organisms: organisms ) )
    }
}
