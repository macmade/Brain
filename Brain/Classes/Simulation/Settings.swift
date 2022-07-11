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

public class Settings: Codable
{
    public var numberOfNeurons     = 2
    public var numberOfSynapses    = 5
    public var population          = 200
    public var numberOfGenerations = 100
    public var stepsPerGeneration  = 200
    public var mutationChance      = 2.0
    public var gridWidth           = 200
    public var gridHeight          = 200
    public var imageScaleFactor    = 2
    public var videoFPS            = 10
    public var surviveAreas: Area  = [ .leftHalf ]
    public var killAreas:    Area  = [ .leftBorder ]
    
    public struct Area: OptionSet, Codable, Hashable
    {
        public let rawValue: UInt
        
        public init( rawValue: UInt )
        {
            self.rawValue = rawValue
        }
        
        public static let leftHalf          = Area( rawValue: 1 <<  0 )
        public static let topHalf           = Area( rawValue: 1 <<  1 )
        public static let rightHalf         = Area( rawValue: 1 <<  2 )
        public static let bottomHalf        = Area( rawValue: 1 <<  3 )
        public static let leftBorder        = Area( rawValue: 1 <<  4 )
        public static let topBorder         = Area( rawValue: 1 <<  5 )
        public static let rightBorder       = Area( rawValue: 1 <<  6 )
        public static let bottomBorder      = Area( rawValue: 1 <<  7 )
        public static let topLeftCorner     = Area( rawValue: 1 <<  8 )
        public static let topRightCorner    = Area( rawValue: 1 <<  9 )
        public static let bottomLeftCorner  = Area( rawValue: 1 << 10 )
        public static let bottomRightCorner = Area( rawValue: 1 << 11 )
        public static let center            = Area( rawValue: 1 << 12 )
    }
}
