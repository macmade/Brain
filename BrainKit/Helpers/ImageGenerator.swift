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
    private let queue          = WaitableOperationQueue( label: "com.xs-labs.Brain.ImageGenerator", qos: .userInteractive )
    private var outputDirectory: URL
    
    public init( outputDirectory: URL )
    {
        self.outputDirectory = outputDirectory
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
        
        prepared.keys.sorted { $0 < $1 }.forEach
        {
            guard let images = prepared[ $0 ] else
            {
                return
            }
            
            let dir = self.outputDirectory.appendingPathComponent( "generation-\( $0 )" )
            
            try? FileManager.default.createDirectory( at: dir, withIntermediateDirectories: true )
            
            images.forEach
            {
                info in self.queue.run
                {
                    ImageGenerator.writeImage( for: info, world: world, to: dir.appendingPathComponent( "step-\( info.step ).jpg" ) )
                }
            }
            
            self.queue.wait()
            print( "    - generation-\( $0 )" )
        }
    }
    
    public func prepare( organisms: [ Organism ], generation: Int, step: Int )
    {
        self.prepared.append( ImageGeneratorInfo( generation: generation, step: step, organisms: organisms ) )
    }
    
    private class func writeImage( for info: ImageGeneratorInfo, world: World, to url: URL )
    {
        let scale = Double( world.settings.imageScaleFactor )
        let size  = NSSize( width: Double( world.size.width ) * scale, height: Double( world.size.height ) * scale )
        let image = NSImage( size: size )
        
        image.lockFocus()
        NSColor.black.setFill()
        NSRect( x: 0, y: 0, width: size.width, height: size.height ).fill()
        
        world.settings.surviveAreas.forEach
        {
            self.drawArea( rect: $0, scale: scale, color: NSColor.green.withAlphaComponent( 0.1 ) )
        }
        
        world.settings.killAreas.forEach
        {
            self.drawArea( rect: $0, scale: scale, color: NSColor.red.withAlphaComponent( 0.2 ) )
        }
        
        world.settings.barriers.forEach
        {
            self.drawArea( rect: $0, scale: scale, color: NSColor( calibratedHue: 0, saturation: 0, brightness: 0.1, alpha: 1 ) )
        }
        
        info.organisms.forEach
        {
            let path = NSBezierPath( ovalIn: NSRect( x: Double( $0.point.x ) * scale, y: Double( $0.point.y ) * scale, width: scale, height: scale ) )
            
            NSColor( rgba: $0.color ).setFill()
            path.fill()
        }
        
        image.unlockFocus()
        
        try? image.jpegRepresentation?.write( to: url )
    }
    
    private class func drawArea( rect: Rect, scale: Double, color: NSColor )
    {
        let rect = NSRect(
            x:      scale * Double( rect.origin.x ),
            y:      scale * Double( rect.origin.y ),
            width:  scale * Double( rect.size.width ),
            height: scale * Double( rect.size.height )
        )
        
        color.setFill()
        rect.fill()
    }
}
