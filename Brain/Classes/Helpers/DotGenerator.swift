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

public class DotGenerator
{
    private var prepared       = [ Int : [ String ] ]()
    private let queue          = DispatchQueue( label: "com.xs-labs.Brain.DotGenerator", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil )
    private var cachesDirectory: URL
    
    public init( cachesDirectory: URL )
    {
        self.cachesDirectory = cachesDirectory
        
        try? FileManager.default.createDirectory( at: self.cachesDirectory, withIntermediateDirectories: true )
    }
    
    public func prepare( networks: [ NeuralNetwork ], generation: Int )
    {
        if self.prepared[ generation ] == nil
        {
            self.prepared[ generation ] = []
        }
        
        self.prepared[ generation ]?.append( contentsOf: networks.map { DotGenerator.dot( for: $0 ) } )
    }
    
    public func generate()
    {
        let prepared = self.prepared
        let keys     = prepared.keys.sorted { $0 < $1 }
        
        self.prepared.removeAll()
        
        keys.forEach
        {
            generation in
            
            guard let graphs = prepared[ generation ] else
            {
                return
            }
            
            var groups = [ DispatchGroup ]()
            let dir    = self.cachesDirectory.appendingPathComponent( "generation-\( generation )" )
            
            try? FileManager.default.createDirectory( at: dir, withIntermediateDirectories: true )
            
            graphs.enumerated().forEach
            {
                graph in
                
                let group = DispatchGroup()
                
                groups.append( group )
                group.enter()
                
                self.queue.async
                {
                    autoreleasepool
                    {
                        guard let data = graph.element.data( using: .utf8 ) else
                        {
                            return
                        }
                        
                        try? data.write( to: dir.appendingPathComponent( "organism-\( graph.offset ).dot" ) )
                        group.leave()
                    }
                }
            }
            
            groups.forEach { $0.wait() }
            print( "    - generation-\( generation )" )
        }
    }
    
    private class func dot( for network: NeuralNetwork ) -> String
    {
        var lines:   [ String ] = []
        var inputs:  [ Input ]  = []
        var neurons: [ Neuron ] = []
        var outputs: [ Output ] = []
        
        network.network.flatMap
        {
            $0.flatMap { [ $0.source, $0.destination ] }
        }
        .forEach
        {
            if let input = $0 as? Input, inputs.contains( where: { $0 === input } ) == false
            {
                inputs.append( input )
            }
            else if let neuron = $0 as? Neuron, neurons.contains( where: { $0 === neuron } ) == false
            {
                neurons.append( neuron )
            }
            else if let output = $0 as? Output, outputs.contains( where: { $0 === output } ) == false
            {
                outputs.append( output )
            }
        }
        
        lines.append( "digraph" )
        lines.append( "{" )
        lines.append( "    rankdir = TB" )
        lines.append( "    rank    = same" )
        lines.append( "    subgraph inputs" )
        lines.append( "    {" )
        inputs.forEach
        {
            lines.append( "        \( $0.name ) [ shape = circle ]" )
        }
        lines.append( "    }" )
        lines.append( "    subgraph neurons" )
        lines.append( "    {" )
        neurons.forEach
        {
            lines.append( "        \( $0.name ) [ shape = diamond ]" )
        }
        lines.append( "    }" )
        lines.append( "    subgraph outputs" )
        lines.append( "    {" )
        outputs.forEach
        {
            lines.append( "        \( $0.name ) [ shape = square ]" )
        }
        lines.append( "    }" )
        
        var synapses: [ Synapse ] = []
        
        network.network.forEach
        {
            $0.forEach
            {
                connection in
                
                if synapses.contains( where: { $0 === connection.synapse } )
                {
                    return
                }
                
                synapses.append( connection.synapse )
                
                let n1     = connection.source.name
                let n2     = connection.destination.name
                let color  = connection.synapse.weight < 0 ? "red" : connection.synapse.weight > 0 ? "green" : "gray"
                let weight = String( format: "%.02f", connection.synapse.weight )
                
                lines.append( "    \( n1 ) -> \( n2 ) [ color = \( color ), fontcolor = \( color ), fontsize = 10, label = \"\( weight )\" ]" )
            }
        }
        
        lines.append( "}" )
        
        return lines.joined( separator: "\n" )
    }
}
