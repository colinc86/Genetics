//  main.swift
//  GeneticsExample
//
//  Copyright (c) 2018 Colin Campbell
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import Genetics

//
// This example shows how to use the Genetics package to find the local maximum, (0.5, 0.5), of the equation f(x, y) = sin(pi * x) * sin(pi * y)
//

//
// 1) Generate a population of random chromosomes (x, y), where x and y are in [0.0, 1.0]
//
var population = Population.generate(populationSize: 10, chromosomeLength: 1024) { (_, _) -> Double in
  return Double(arc4random()) / Double(UInt32.max - 1)
}

//
// 2) Create an EvolverConfiguration
//
let configuration = EvolverConfiguration(selectionMethod: .rank, crossoverMethod: .point(count: 1), crossoverRate: 0.1, mutationFunction: { chromosome, index in
  var chromosomeCopy = chromosome
  
  // We'll mutate a chromosome's index by either adding or subtracting our step size
  var value = chromosomeCopy[index]
  let step = 0.00001
  value += arc4random_uniform(2) == 0 ? step : -step
  
  // Let's make sure that the new element's value doesn't mutate to a value outside of the closed interval [0.0, 1.0]
  if value < 0.0 {
    value = 0.0
  }
  else if value > 1.0 {
    value = 1.0
  }
  
  // Give the evolver the new value
  chromosomeCopy[index] = value
  return chromosomeCopy
}, mutationRate: 0.1, fitnessFunction: { chromosome in
  // Use our fitness function to return the fitness of the chromosome
  return sin(Double.pi * chromosome[0]) * sin(Double.pi * chromosome[1])
}, elitism: .apply(count: 1))

//
// 3) Create an Evolver
//
let evolver = Evolver(configuration: configuration)

//
// 4) Evolve the population
//
do {
  try evolver.evolve(population: &population, shouldContinue: { (config: inout EvolverConfiguration, pop: Population) -> Bool in
    if pop.generation == 1000 {
      print(pop.description + "\n")
    }

    return pop.generation < 1000
  })
}
catch let error {
  print("\(error)")
}
