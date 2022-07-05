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

public class Organism
{
    public private( set ) var brain:      Brain
    public private( set ) var generation: Int
    
    public var position = Point( x: 0, y: 0 )
    
    public class func random( settings: Settings, generation: Int ) -> Organism?
    {
        let inputs:   [ Input  ]  = [ Input(),  Input(),  Input(),  Input(),  Input() ]
        let outputs:  [ Output ]  = [ Output(), Output(), Output(), Output(), Output() ]
        var neurons:  [ Neuron ]  = []
        var synapses: [ Synapse ] = []
        
        ( 0 ..< settings.numberOfNeurons ).forEach
        {
            _ in neurons.append( Neuron() )
        }
        
        ( 0 ..< settings.numberOfSynapses ).forEach
        {
            _ in synapses.append( Synapse( from: UInt32.random( in: 0 ... UInt32.max ) ) )
        }
        
        /*
         * Inputs:  [ 0 ]     [ 1 ]     [ 2 ]-----\
         *            |  \      |                 |
         *            |   \     |                 |
         *          1 |  1 \  1 |                 |
         *            |     \   |                 |
         * Neurons: [ 0 ]--2--[ 1 ]-2,3-[ 2 ]     |
         *            |\        |        /|       |
         *            | \_______|_______/ |       |
         *            |     2   |         |       |
         *            | 2       | 2,3     | 3,4   | 1
         * Outputs: [ 0 ]     [ 1 ]     [ 2 ]-----/
         *
         * Level 1 (3): I[0]->N[0], I[0]->N[1], I[1]->N[1], I[2]->O[2]
         * Level 2 (5): N[0]->N[1], N[0]->N[2], N[0]->O[0], [N1]->N[2], N[1]->O[1]
         * Level 3 (3): N[1]->N[2], N[1]->O[1], N2[O2]
         * Level 4 (1): N[2]->O[2]
         */
        
        /*
        synapses.removeAll()
        synapses.append( Synapse( sourceType: .input,  sourceID: 0, destinationType: .neuron, destinationID: 0, weight: 1 ) )
        synapses.append( Synapse( sourceType: .input,  sourceID: 0, destinationType: .neuron, destinationID: 1, weight: 1 ) )
        synapses.append( Synapse( sourceType: .input,  sourceID: 1, destinationType: .neuron, destinationID: 1, weight: 1 ) )
        synapses.append( Synapse( sourceType: .input,  sourceID: 2, destinationType: .output, destinationID: 2, weight: 1 ) )
        synapses.append( Synapse( sourceType: .neuron, sourceID: 0, destinationType: .neuron, destinationID: 1, weight: 1 ) )
        synapses.append( Synapse( sourceType: .neuron, sourceID: 0, destinationType: .neuron, destinationID: 2, weight: 1 ) )
        synapses.append( Synapse( sourceType: .neuron, sourceID: 0, destinationType: .output, destinationID: 0, weight: 1 ) )
        synapses.append( Synapse( sourceType: .neuron, sourceID: 1, destinationType: .output, destinationID: 1, weight: 1 ) )
        synapses.append( Synapse( sourceType: .neuron, sourceID: 1, destinationType: .neuron, destinationID: 2, weight: 1 ) )
        synapses.append( Synapse( sourceType: .neuron, sourceID: 2, destinationType: .output, destinationID: 2, weight: 1 ) )
        */
        
        guard let brain = Brain( inputs: inputs, outputs: outputs, neurons: neurons, synapses: synapses ) else
        {
            return nil
        }
        
        return Organism( brain: brain, generation: generation )
    }
    
    public init( brain: Brain, generation: Int )
    {
        self.brain      = brain
        self.generation = generation
    }
    
    public func mutate() -> Organism?
    {
        let inputs        = self.brain.inputs.compactMap   { $0.copy() as? Input }
        let outputs       = self.brain.outputs.compactMap  { $0.copy() as? Output }
        let neurons       = self.brain.neurons.compactMap  { $0.copy() as? Neuron }
        var synapses      = self.brain.synapses.compactMap { $0.copy() as? Synapse }
        let index         = Int.random( in: 0 ..< synapses.count )
        let encoded       = synapses[ index ].encode()
        let mutate        = UInt32( 1 ) << Int.random( in: 0 ..< encoded.bitWidth )
        synapses[ index ] = Synapse( from: encoded ^ mutate )
        
        outputs.forEach { $0.reset() }
        neurons.forEach { $0.reset() }
        
        guard let brain = Brain( inputs: inputs, outputs: outputs, neurons: neurons, synapses: synapses ) else
        {
            return nil
        }
        
        return Organism( brain: brain, generation: self.generation + 1 )
    }
    
    public func process()
    {
        self.brain.process()
        
        print( "Neuron values:" )
        self.brain.neurons.forEach { print( "    \( $0.values )" ) }
        
        print( "Output values:" )
        self.brain.outputs.forEach { print( "    \( $0.values )" ) }
        
        self.brain.outputs.forEach
        {
            $0.execute( with: self )
        }
        
        self.brain.reset()
    }
}
