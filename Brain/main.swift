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

let inputs:   [ Input  ]  = [ Input(), Input(), Input(), Input(), Input() ]
let outputs:  [ Output ]  = [ Output(), Output(), Output(), Output(), Output() ]
let neurons:  [ Neuron ]  = [ Neuron(), Neuron(), Neuron() ]

/*
let synapses =
[
    Synapse( sourceType: .input,  sourceID: 0, destinationType: .neuron, destinationID: 0, weight: 0 ),
    Synapse( sourceType: .neuron, sourceID: 0, destinationType: .neuron, destinationID: 1, weight: 0 ),
    Synapse( sourceType: .neuron, sourceID: 1, destinationType: .neuron, destinationID: 2, weight: 0 ),
    Synapse( sourceType: .neuron, sourceID: 2, destinationType: .neuron, destinationID: 0, weight: 0 ),
    Synapse( sourceType: .neuron, sourceID: 2, destinationType: .output, destinationID: 0, weight: 0 ),
    Synapse( sourceType: .input,  sourceID: 1, destinationType: .neuron, destinationID: 0, weight: 0 ),
]
*/

var synapses: [ Synapse ] = []

for _ in 0 ..< 5
{
    let rand    = UInt32.random( in: 0 ... UInt32.max )
    let synapse = Synapse( from: rand )
    
    print( "\( String( format: "%08X", rand ) ) -> \( String( format: "%08X", synapse.encode() ) )" )
    synapses.append( synapse )
}

print( "==========" )

func mutate( synapse: Synapse ) -> Synapse
{
    let encoded = synapse.encode()
    let mutate  = UInt32( 1 ) << Int.random( in: 0 ..< encoded.bitWidth )
    let mutated = Synapse( from: encoded ^ mutate )
    
    print( synapse )
    print( mutated )
    print( "==========" )
    
    return mutated
}

var mutated     = synapses
let rand        = Int.random( in: 0 ..< synapses.count )
mutated[ rand ] = mutate( synapse: synapses[ rand ] )

guard let brain1 = Brain( inputs: inputs, outputs: outputs, neurons: neurons, synapses: synapses ),
      let brain2 = Brain( inputs: inputs, outputs: outputs, neurons: neurons, synapses: mutated )
else
{
    exit( -1 )
}

[ brain1, brain2 ].forEach
{
    $0.process()
    print( $0.synapses )
    print( "----------" )
    print( $0.network )
    print( "----------" )
    $0.neurons.forEach { print( $0.values ) }
    print( "----------" )
    $0.outputs.forEach { print( $0.values ) }
    $0.reset()
    print( "==========" )
}
