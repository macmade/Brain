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

public class OutputGeneration
{
    private static let queue = DispatchQueue( label: "com.xs-labs.Brain.OutputGeneration", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil )
    
    private init()
    {}
    
    public class func generateMovies( from source: URL, in directory: URL, world: World )
    {
        try? FileManager.default.createDirectory( at: directory, withIntermediateDirectories: true )
        
        let files = self.getFiles( in: source, fileExtension: "png" )
        let keys  = files.keys.sorted
        {
            $0.path.compare( $1.path, options: [ .numeric, .caseInsensitive ], range: nil, locale: nil ) == .orderedAscending
        }
        
        keys.forEach
        {
            key in guard let info = files[ key ] else
            {
                return
            }
            
            autoreleasepool
            {
                let name       = "\( key.lastPathComponent ).mov"
                let url        = directory.appendingPathComponent( name )
                let width      = world.size.width * world.settings.imageScaleFactor
                let height     = world.size.height * world.settings.imageScaleFactor
                let fps        = world.settings.videoFPS
                let processor  = VideoGenerator( images: info, size: NSSize( width: width, height: height ), destination: url, fps: fps, codec: .h264, fileType: .mov )
                
                processor.generate()
                print( "    - \( name )" )
            }
        }
    }
    
    @discardableResult
    public class func writeSVGScriptForDotFiles( from source: URL, in directory: URL ) -> Bool
    {
        guard let enumerator = FileManager.default.enumerator( atPath: source.path ) else
        {
            return false
        }
        
        try? FileManager.default.createDirectory( at: directory, withIntermediateDirectories: true )
        
        var lines: [ String ] = []
        
        enumerator.forEach
        {
            enumerator.skipDescendants()
            
            guard let name = $0 as? String else
            {
                return
            }
            
            let url = source.appendingPathComponent( name )
            var dir = ObjCBool( false )
            
            if FileManager.default.fileExists( atPath: url.path, isDirectory: &dir ), dir.boolValue
            {
                let directory = directory.appendingPathComponent( name )
                
                if self.writeSVGScriptForDotFiles( from: url, in: directory )
                {
                    lines.append( "sh \( directory.appendingPathComponent( "generate.sh" ).path )" )
                }
                
                return
            }
            
            if url.pathExtension != "dot"
            {
                return
            }
            
            let svg = directory.appendingPathComponent( name ).deletingPathExtension().appendingPathExtension( "svg" )
            
            lines.append( "/opt/homebrew/bin/dot -Tsvg -o\( svg.path ) \( url.path )" )
        }
        
        if lines.isEmpty
        {
            return false
        }
        
        lines.sort
        {
            $0.compare( $1, options: [ .numeric, .caseInsensitive ], range: nil, locale: nil ) == .orderedAscending
        }
        
        lines.insert( "#!/bin/sh", at: 0 )
        lines.insert( "", at: 1 )
        
        if let data = lines.joined( separator: "\n" ).data( using: .utf8 )
        {
            try? data.write( to: directory.appendingPathComponent( "generate.sh" ) )
        }
        
        return true
    }
    
    public class func clearAll()
    {
        guard let caches = Bundle.main.cachesDirectory else
        {
            return
        }
        
        guard let enumerator = FileManager.default.enumerator( atPath: caches.path ) else
        {
            return
        }
        
        enumerator.forEach
        {
            enumerator.skipDescendants()
            
            guard let name = $0 as? String, name.isEmpty == false else
            {
                return
            }
            
            let url = caches.appendingPathComponent( name )
            
            NSWorkspace.shared.recycle( [ url ] )
        }
    }
    
    private class func getFiles( in directory: URL, fileExtension: String ) -> [ URL : [ URL ] ]
    {
        guard let enumerator = FileManager.default.enumerator( atPath: directory.path ) else
        {
            return [ : ]
        }
        
        let files: [ URL ] = enumerator.compactMap
        {
            guard let name = $0 as? String else
            {
                return nil
            }
            
            let url = directory.appendingPathComponent( name )
            
            return url.pathExtension == fileExtension ? url : nil
        }
        .sorted
        {
            $0.path.compare( $1.path, options: [ .numeric, .caseInsensitive ], range: nil, locale: nil ) == .orderedAscending
        }
        
        return files.reduce( into: [ URL : [ URL ] ]() )
        {
            let dir = $1.deletingLastPathComponent()
            
            if $0[ dir ] == nil
            {
                $0[ dir ] = [ URL ]()
            }
            
            $0[ dir ]?.append( $1 )
        }
    }
}
