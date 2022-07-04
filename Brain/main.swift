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

let settings = Settings()

guard let organism1 = Organism.random( settings: settings ),
      let organism2 = organism1.mutate()
else
{
    exit( -1 )
}

[ organism1, organism2 ].forEach
{
    print( "Synapses:" )
    $0.brain.synapses.forEach { print( "    \( $0 )" ) }
    print( "Linear Network:" )
    $0.brain.linearNetwork.forEach { print( "    \( $0 )" ) }
    print( "Sequential Network:" )
    $0.brain.sequentialNetwork.forEach { print( "    \( $0 )" ) }
    
    $0.brain.process()
    
    print( "Neuron values:" )
    $0.brain.neurons.forEach { print( "    \( $0.values )" ) }
    
    print( "Output values:" )
    $0.brain.outputs.forEach { print( "    \( $0.values )" ) }
    
    print( "--------------------------------------------------" )
}
