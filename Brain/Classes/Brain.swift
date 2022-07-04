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

public class Brain
{
    public private( set ) var inputs:   [ Input  ]
    public private( set ) var outputs:  [ Output ]
    public private( set ) var neurons:  [ Neuron ]
    public private( set ) var synapses: [ Synapse ]
    public private( set ) var network:  [ [ SynapseConnection ] ]
    
    public init?( inputs: [ Input ], outputs: [ Output ], neurons: [ Neuron ], synapses: [ Synapse ] )
    {
        if inputs.isEmpty || outputs.isEmpty || neurons.isEmpty || synapses.isEmpty
        {
            return nil
        }
        
        self.inputs   = inputs
        self.outputs  = outputs
        self.neurons  = neurons
        self.synapses = synapses
        
        // Gets all synapse connections
        let allConnections: [ SynapseConnection ] = self.synapses.map
        {
            // Remap the source and destination IDs so they correspond to the number of inputs, neurons or outputs.
            let sourceID       = Int( $0.sourceID      ) % ( $0.sourceType      == .neuron ? neurons.count : inputs.count )
            let destinationID  = Int( $0.destinationID ) % ( $0.destinationType == .neuron ? neurons.count : outputs.count )
            
            // Creates a new synapse with the remapped values.
            let synapse = Synapse( sourceType: $0.sourceType, sourceID: UInt8( sourceID ), destinationType: $0.destinationType, destinationID: UInt8( destinationID ), weight: $0.weight )
            
            // Gets the source and destination for the synapse.
            let source:      SynapseSource      = $0.sourceType      == .neuron ? neurons[ sourceID ]      : inputs[ sourceID ]
            let destination: SynapseDestination = $0.destinationType == .neuron ? neurons[ destinationID ] : outputs[ destinationID ]
            
            return SynapseConnection( source: source, destination: destination, synapse: synapse )
        }
        
        // Gets every connection originating from an input
        let inputNetwork: [ [ ( level: Int, connection: SynapseConnection ) ] ] = inputs.compactMap
        {
            var network = [ ( level: Int, connection: SynapseConnection ) ]()
            
            // Gets connections for the current input
            Brain.connections( for: $0, from: allConnections, network: &network, level: 0 )
            
            if network.isEmpty
            {
                return nil
            }
            
            // Sorts connections by level
            return network.sorted { $0.level < $1.level }
        }
        
        // Final network, sequenced by connection level
        self.network = inputNetwork.reduce( into: [ [ SynapseConnection ] ]() )
        {
            array, element in element.forEach
            {
                if $0.level >= array.count
                {
                    array.append( [ $0.connection ] )
                }
                else
                {
                    array[ $0.level ].append( $0.connection )
                }
            }
        }
    }
    
    private class func connections( for source: SynapseSource, from allConnections: [ SynapseConnection ], network: inout [ ( level: Int, connection: SynapseConnection ) ], level: Int )
    {
        // All connections for the current source
        allConnections.filter
        {
            $0.source === source
        }
        .filter // Avoids recursion if the connection has already been processed in the current network
        {
            connection in network.contains { $0.connection === connection } == false
        }
        .forEach
        {
            // Appends the current connection
            network.append( ( level: level, connection: $0 ) )
            
            // Gets all connections whose destination is also a source
            if let source = $0.destination as? SynapseSource
            {
                // Gets connections for the new source
                self.connections( for: source, from: allConnections, network: &network, level: level + 1 )
            }
        }
    }
    
    public func process()
    {
        self.network.forEach
        {
            $0.forEach
            {
                $0.destination.take( value: $0.source.value * $0.synapse.weight )
            }
        }
    }
    
    public func reset()
    {
        self.neurons.forEach { $0.reset() }
        self.outputs.forEach { $0.reset() }
    }
}
