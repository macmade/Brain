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
    public var numberOfNeurons:     UInt   = 2
    public var numberOfSynapses:    UInt   = 5
    public var population:          UInt   = 200
    public var numberOfGenerations: UInt   = 200
    public var stepsPerGeneration:  UInt   = 200
    public var mutationChance:      Double = 2
    public var gridWidth:           UInt   = 200
    public var gridHeight:          UInt   = 200
    public var imageScaleFactor:    UInt   = 2
    public var videoFPS:            UInt   = 10
    
    public var surviveAreas: [ Rect ] =
    [
        Rect( x: 0, y: 75, width: 50, height: 50 ),
    ]
    
    public var killAreas: [ Rect ] =
    [
        Rect( x: 0, y: 0, width: 1, height: 200 ),
    ]
    
    public var barriers =
    [
        Rect( x: 60, y:  15, width: 10, height: 20 ),
        Rect( x: 60, y:  45, width: 10, height: 20 ),
        Rect( x: 60, y:  75, width: 10, height: 20 ),
        Rect( x: 60, y: 105, width: 10, height: 20 ),
        Rect( x: 60, y: 135, width: 10, height: 20 ),
        Rect( x: 60, y: 165, width: 10, height: 20 ),
    ]
}
