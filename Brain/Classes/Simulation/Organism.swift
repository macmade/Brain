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

public class Organism
{
    public private( set ) weak var world: World?
    public private( set )      var brain: NeuralNetwork
    
    public var position = Point( x: 0, y: 0 )
    
    public class func defaultInputs() -> [ Input ]
    {
        [
            Age(),
            CloseToTopBorder(),
            CloseToBottomBorder(),
            CloseToLeftBorder(),
            CloseToRightBorder(),
        ]
    }
    
    public class func defaultOutputs() -> [ Output ]
    {
        [
            MoveX(),
            MoveY(),
        ]
    }
    
    public class func random( world: World ) -> Organism?
    {
        var neurons:  [ Neuron ]  = []
        var synapses: [ Synapse ] = []
        
        ( 0 ..< world.settings.numberOfNeurons ).forEach
        {
            _ in neurons.append( Neuron() )
        }
        
        ( 0 ..< world.settings.numberOfSynapses ).forEach
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
         * Level 2 (5): N[0]->N[1], N[0]->N[2], N[0]->O[0], N[1]->O[1], [N1]->N[2]
         * Level 3 (3): N[1]->O[1], N[1]->N[2], N[2]->O[2]
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
        
        guard let brain = NeuralNetwork( inputs: Organism.defaultInputs(), outputs: Organism.defaultOutputs(), neurons: neurons, synapses: synapses ) else
        {
            return nil
        }
        
        return Organism( world: world, brain: brain )
    }
    
    public init( world: World, brain: NeuralNetwork )
    {
        self.world = world
        self.brain = brain
        
        self.brain.inputs.forEach
        {
            $0.organism = self
        }
    }
    
    @discardableResult
    public func move( to point: Point ) -> Bool
    {
        if self.world?.locationIsAvailable( point ) ?? false
        {
            self.position = point
            
            return true
        }
        
        return false
    }
    
    public func replicate() -> Organism?
    {
        guard let world = self.world else
        {
            return nil
        }
        
        let synapses: [ Synapse ] = self.brain.synapses.compactMap
        {
            if Double.random( in: 0 ... 100 ) > world.settings.mutationChance
            {
                return $0.copy() as? Synapse
            }
            
            let encoded = $0.encode()
            let mutate  = UInt32( 1 ) << Int.random( in: 0 ..< encoded.bitWidth )
            
            return Synapse( from: encoded ^ mutate )
        }
        
        let inputs  = self.brain.inputs.compactMap  { $0.copy() as? Input }
        let outputs = self.brain.outputs.compactMap { $0.copy() as? Output }
        let neurons = self.brain.neurons.compactMap { $0.copy() as? Neuron }
        
        outputs.forEach { $0.reset() }
        neurons.forEach { $0.reset() }
        
        guard let brain = NeuralNetwork( inputs: inputs, outputs: outputs, neurons: neurons, synapses: synapses ) else
        {
            return nil
        }
        
        return Organism( world: world, brain: brain )
    }
    
    public func process()
    {
        self.brain.process()
        
        self.brain.outputs.forEach
        {
            $0.execute( with: self )
        }
        
        self.brain.reset()
    }
    
    public var color: NSColor
    {
        var rgb = self.brain.synapses.enumerated().reduce( into: [ Int32() ] )
        {
            let value = Int32( bitPattern: $1.element.encode() )
            let index = $1.offset % 3
            
            if index >= $0.count
            {
                $0.append( value )
            }
            else
            {
                $0[ index ] = $0[ index ] &+ value
            }
        }
        .map
        {
            UInt32( bitPattern: $0 )
        }
        
        while rgb.count < 3
        {
            rgb.append( 0 )
        }
        
        let r = Double( rgb[ 0 ] ) / Double( UInt32.max )
        let g = Double( rgb[ 1 ] ) / Double( UInt32.max )
        let b = Double( rgb[ 2 ] ) / Double( UInt32.max )
        
        return NSColor( calibratedRed: r, green: g, blue: b, alpha: 1 )
    }
}
