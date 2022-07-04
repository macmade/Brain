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
    public private( set ) var brain: Brain
    
    public class func random( settings: Settings ) -> Organism?
    {
        let inputs:   [ Input  ]  = [ Input(),  Input(),  Input(),  Input(),  Input() ]
        let outputs:  [ Output ]  = [ Output(), Output(), Output(), Output(), Output() ]
        var neurons:  [ Neuron ]  = []
        var synapses: [ Synapse ] = []
        
        ( 1 ..< settings.numberOfNeurons ).forEach
        {
            _ in neurons.append( Neuron() )
        }
        
        ( 0 ..< settings.numberOfSynapses ).forEach
        {
            _ in synapses.append( Synapse( from: UInt32.random( in: 0 ... UInt32.max ) ) )
        }
        
        guard let brain = Brain( inputs: inputs, outputs: outputs, neurons: neurons, synapses: synapses ) else
        {
            return nil
        }
        
        return Organism( brain: brain )
    }
    
    public init( brain: Brain )
    {
        self.brain = brain
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
        
        return Organism( brain: brain )
    }
}
