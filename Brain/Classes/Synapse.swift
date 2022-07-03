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

public class Synapse: CustomDebugStringConvertible
{
    public enum SourceType: UInt
    {
        case input
        case neuron
    }
    
    public enum DestinationType: UInt
    {
        case output
        case neuron
    }
    
    public private( set ) var sourceType:      SourceType
    public private( set ) var sourceID:        UInt8
    public private( set ) var destinationType: DestinationType
    public private( set ) var destinationID:   UInt8
    public private( set ) var weight:          Double
    
    public class func decode( from value: UInt32 ) -> Synapse
    {
        Synapse( from: value )
    }
    
    private init( from value: UInt32 )
    {
        let sourceType       = ( value >> 31 ) & 0x0001
        let sourceID         = ( value >> 24 ) & 0x007F
        let destinationType  = ( value >> 23 ) & 0x0001
        let destinationID    = ( value >> 16 ) & 0x007F
        let weight           = ( value >>  0 ) & 0xFFFF
        self.sourceType      = sourceType      == 0 ? .input  : .neuron
        self.destinationType = destinationType == 0 ? .output : .neuron
        self.sourceID        = UInt8( sourceID )
        self.destinationID   = UInt8( destinationID )
        self.weight          = ( Double( weight ) / ( Double( UInt16.max ) / 2.0 ) ) - 1.0
    }
    
    public func encode() -> UInt32
    {
        let floatWeight      = ( 1.0 + self.weight ) * ( Double( UInt16.max ) / 2.0 )
        let sourceType       = ( UInt32( self.sourceType.rawValue      ) & 0x0001 ) << 31
        let sourceID         = ( UInt32( self.sourceID                 ) & 0x007F ) << 24
        let destinationType  = ( UInt32( self.destinationType.rawValue ) & 0x0001 ) << 23
        let destinationID    = ( UInt32( self.destinationID            ) & 0x007F ) << 16
        let weight           = ( UInt32( floatWeight                   ) & 0xFFFF ) <<  0
        
        return sourceType | sourceID | destinationType | destinationID | weight
    }
    
    public var debugDescription: String
    {
        """
        Synapse
        {
            Source type:      \( self.sourceType )
            Source ID:        \( String( format: "%02X", self.sourceID ) )
            Destination type: \( self.destinationType )
            Destination ID:   \( String( format: "%02X", self.destinationID ) )
            Weight:           \( self.weight )
        }
        """
    }
}
