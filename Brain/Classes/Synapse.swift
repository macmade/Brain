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

/*
 * Synapses are encoded using a 32-bits number:
 *
 * | 0 | 0000000 | 0 | 0000000 | 0000000000000000 |
 *   1         2   3         4                  5
 *
 *   1.  1 bit  (32):    Source type (0 = input, 1 = neuron)
 *   2.  7 bits (25-31): Source ID
 *   3.  1 bit  (24):    Destination type (0 = input, 1 = neuron)
 *   4.  7 bits (17-23): Destination ID
 *   5. 16 bits (1-16):  Weight
 */
public class Synapse: CustomDebugStringConvertible
{
    public enum SourceType: UInt
    {
        case input  = 0
        case neuron = 1
    }
    
    public enum DestinationType: UInt
    {
        case output = 0
        case neuron = 1
    }
    
    public private( set ) var sourceType:      SourceType
    public private( set ) var sourceID:        UInt8
    public private( set ) var destinationType: DestinationType
    public private( set ) var destinationID:   UInt8
    public private( set ) var weight:          Double
    
    public convenience init( from value: UInt32 )
    {
        let sourceType       = ( value >> 31 ) & 0x0001
        let sourceID         = ( value >> 24 ) & 0x007F
        let destinationType  = ( value >> 23 ) & 0x0001
        let destinationID    = ( value >> 16 ) & 0x007F
        let weight           = ( value >>  0 ) & 0xFFFF
        
        self.init(
            sourceType:      sourceType == 0 ? .input : .neuron,
            sourceID:        UInt8( sourceID ),
            destinationType: destinationType == 0 ? .output : .neuron,
            destinationID:   UInt8( destinationID ),
            weight:          Synapse.decodeWeight( weight )
        )
    }
    
    public init( sourceType: SourceType, sourceID: UInt8, destinationType: DestinationType, destinationID: UInt8, weight: Double )
    {
        self.sourceType      = sourceType
        self.destinationType = destinationType
        self.sourceID        = sourceID
        self.destinationID   = destinationID
        self.weight          = weight
    }
    
    public class func decodeWeight( _ value: UInt32 ) -> Double
    {
        ( Double( value ) / ( Double( UInt16.max ) / 2.0 ) ) - 1.0
    }
    
    public class func encodeWeight( _ value: Double ) -> UInt32
    {
        UInt32( ( 1.0 + value ) * ( Double( UInt16.max ) / 2.0 ) )
    }
    
    public func encode() -> UInt32
    {
        let sourceType       = ( UInt32( self.sourceType.rawValue      ) & 0x0001 ) << 31
        let sourceID         = ( UInt32( self.sourceID                 ) & 0x007F ) << 24
        let destinationType  = ( UInt32( self.destinationType.rawValue ) & 0x0001 ) << 23
        let destinationID    = ( UInt32( self.destinationID            ) & 0x007F ) << 16
        let weight           = ( Synapse.encodeWeight( self.weight     ) & 0xFFFF ) <<  0
        
        return sourceType | sourceID | destinationType | destinationID | weight
    }
    
    public var debugDescription: String
    {
        let weight      = String( format: "%.02f", self.weight )
        let source      = "\( self.sourceType )[\( self.sourceID )]"
        let destination = "\( self.destinationType )[\( self.destinationID )]"
        
        return "{\( source )->\( destination ):\( weight )}"
    }
}
