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

var organisms = [ organism1, organism2 ]

let start = Date()

( 0 ..< settings.numberOfGenerations ).forEach
{
    print( "##################################################" )
    print( "GENERATION \( $0 + 1 )" )
    print( "##################################################" )
    
    if $0 > 0
    {
        organisms = organisms.compactMap { $0.mutate() }
    }
    
    organisms.forEach
    {
        print( "Synapses:" )
        $0.brain.synapses.forEach { print( "    \( $0 )" ) }
        print( "Network:" )
        $0.brain.network.forEach { print( "    \( $0 )" ) }
        
        if $0 === organism1
        {
            print( "--------------------------------------------------" )
        }
    }

    ( 0 ..< settings.stepsPerGeneration ).forEach
    {
        print( "==================================================" )
        print( "STEP \( $0 + 1 )" )
        print( "==================================================" )
        
        organisms.forEach
        {
            $0.process()
            
            if $0 === organism1
            {
                print( "--------------------------------------------------" )
            }
        }
    }
}

let end = Date()

print( "**************************************************" )
print( "Generations:          \( settings.numberOfGenerations )" )
print( "Steps per generation: \( settings.stepsPerGeneration )" )
print( "Time:                 \( end.timeIntervalSince( start ) ) seconds" )
print( "**************************************************" )
