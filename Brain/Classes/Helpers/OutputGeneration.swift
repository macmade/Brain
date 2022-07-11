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
    private init()
    {}
    
    public class func generateMovies( from source: URL, in directory: URL, world: World )
    {
        try? FileManager.default.createDirectory( at: directory, withIntermediateDirectories: true )
        
        let files = self.getFiles( in: source, fileExtension: "jpg" )
        let keys  = files.keys.sorted { $0.path.numericCaseInsensitiveCompare( $1.path ) == .orderedAscending }
        
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
    
    public class func generateSVGScriptsForDotFiles( from source: URL, in directory: URL )
    {
        try? FileManager.default.createDirectory( at: directory, withIntermediateDirectories: true )
        
        let files   = self.getFiles( in: source, fileExtension: "dot" )
        let keys    = files.keys.sorted { $0.path.numericCaseInsensitiveCompare( $1.path ) == .orderedAscending }
        var scripts = [ String ]()
        
        keys.forEach
        {
            key in guard let info = files[ key ] else
            {
                return
            }
            
            let name   = key.path.replacingOccurrences( of: source.path, with: "" )
            let dir    = directory.appendingPathComponent( name )
            let script = dir.appendingPathComponent( "generate" ).appendingPathExtension( "sh" )
            
            try? FileManager.default.createDirectory( at: dir, withIntermediateDirectories: true )
            
            var lines: [ String ] = info.map
            {
                let name = $0.deletingPathExtension().lastPathComponent
                let svg  = dir.appendingPathComponent( name ).appendingPathExtension( "svg" )
                
                return "/opt/homebrew/bin/dot -Tsvg -o\( svg.path ) \( $0.path )"
            }
            
            lines.insert( "#!/bin/sh", at: 0 )
            lines.insert( "", at: 1 )
            
            guard let data = lines.joined( separator: "\n" ).data( using: .utf8 ) else
            {
                return
            }
            
            do
            {
                try data.write( to: script )
                scripts.append( "sh \( script.path )" )
            }
            catch
            {}
        }
        
        scripts.insert( "#!/bin/sh", at: 0 )
        scripts.insert( "", at: 1 )
        
        try? scripts.joined( separator: "\n" ).data( using: .utf8 )?.write( to: directory.appendingPathComponent( "generate" ).appendingPathExtension( "sh" ) )
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
            
            try? FileManager.default.removeItem( at: url )
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
            $0.path.numericCaseInsensitiveCompare( $1.path ) == .orderedAscending
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
