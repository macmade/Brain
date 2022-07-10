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
    public init()
    {}
    
    public func prepare( networks: [ NeuralNetwork ], generation: Int )
    {}
    
    public func generate()
    {
    /*
    public class func writeDotFiles( from networks: [ NeuralNetwork ], in directory: URL, generation: Int )
    {
        let directory = directory.appendingPathComponent( "generation-\( generation )" )
        
        try? FileManager.default.createDirectory( at: directory, withIntermediateDirectories: true )
        
        networks.enumerated().forEach
        {
            let dot = DotGenerator.dot( for: $0.element )
            
            if dot.isEmpty == false, let data = dot.data( using: .utf8 )
            {
                let url = directory.appendingPathComponent( "organism-\( $0.offset ).dot" )
                
                try? data.write( to: url )
            }
        }
    }
     */
    }
    
    public class func dot( for network: NeuralNetwork ) -> String
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
            lines.append( "        \( self.name( of: $0, in: network ) ) [ shape = circle ]" )
        }
        lines.append( "    }" )
        lines.append( "    subgraph neurons" )
        lines.append( "    {" )
        neurons.forEach
        {
            lines.append( "        \( self.name( of: $0, in: network ) ) [ shape = diamond ]" )
        }
        lines.append( "    }" )
        lines.append( "    subgraph outputs" )
        lines.append( "    {" )
        outputs.forEach
        {
            lines.append( "        \( self.name( of: $0, in: network ) ) [ shape = square ]" )
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
                
                let n1     = self.name( of: connection.source, in: network )
                let n2     = self.name( of: connection.destination, in: network )
                let color  = connection.synapse.weight < 0 ? "red" : connection.synapse.weight > 0 ? "green" : "gray"
                let weight = String( format: "%.02f", connection.synapse.weight )
                
                lines.append( "    \( n1 ) -> \( n2 ) [ color = \( color ), fontcolor = \( color ), fontsize = 10, label = \"\( weight )\" ]" )
            }
        }
        
        lines.append( "}" )
        
        return lines.joined( separator: "\n" )
    }
    
    private class func name( of node: Any, in network: NeuralNetwork ) -> String
    {
        if let input = node as? Input, let index = network.inputs.firstIndex( where: { $0 === input } )
        {
            return input.name ?? "I\( index )"
        }
        else if let neuron = node as? Neuron, let index = network.neurons.firstIndex( where: { $0 === neuron } )
        {
            return neuron.name ?? "N\( index )"
        }
        else if let output = node as? Output, let index = network.outputs.firstIndex( where: { $0 === output } )
        {
            return output.name ?? "O\( index )"
        }
        
        return "<unknown>"
    }
}
