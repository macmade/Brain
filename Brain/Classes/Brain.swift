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
    public private( set ) var inputs:  [ Input  ] = [ Input(), Input() ]
    public private( set ) var outputs: [ Output ] = [ Output(), Output(), Output() ]
    public private( set ) var neurons: [ Neuron ] = [ Neuron() ]
    
    public func getSource( of synapse: Synapse ) -> SynapseSource?
    {
        let values: [ SynapseSource ] = synapse.sourceType == .input ? self.inputs : self.neurons
        
        return self.getValue( id: synapse.sourceID, in: values )
    }
    
    public func getDestination( of synapse: Synapse ) -> SynapseDestination?
    {
        let values: [ SynapseDestination ] = synapse.destinationType == .output ? self.outputs : self.neurons
        
        return self.getValue( id: synapse.destinationID, in: values )
    }
    
    private func getValue< T >( id: UInt8, in values: [ T ] ) -> T?
    {
        if values.isEmpty
        {
            return nil
        }
        
        return values[ Int( id ) % values.count ]
    }
}
