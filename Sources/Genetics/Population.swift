//  Population.swift
//  Genetics
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

/// A `Population` is a set of chromosomes.
public struct Population: CustomStringConvertible {
  
  // MARK: Properties
  
  /// The population's chromosomes.
  public var chromosomes: [Chromosome]
  
  /// The population's generation.
  public var generation: Int = 1
  
  /// The number of chromosomes in the population.
  public var populationSize: Int {
    return chromosomes.count
  }
  
  public var description: String {
    var des = "Generation: \(generation)"
    for chromosome in chromosomes {
      des += "\nChromosome: \(chromosome.description), fitness: \(chromosome.fitness)"
    }
    return des
  }
  
  // MARK: Initializers
  
  /// Initializes a `Population`.
  ///
  /// - Parameter chromosomes: The population's chromosomes.
  public init(_ chromosomes: [Chromosome]) {
    self.chromosomes = chromosomes
  }
  
}

// MARK: Internal functions

extension Population {
  
  /// Shuffles the population's chromosomes.
  internal mutating func shuffleChromosomes() {
    guard chromosomes.count > 1 else {
      return
    }
    
    // Use the Fisher-Yates algorithm
    for i in 0 ..< Int(chromosomes.count) - 1 {
      let j = Int(arc4random_uniform(UInt32(chromosomes.count) - UInt32(i))) + i
      
      if i == j {
        continue
      }
      
      chromosomes.swapAt(i, j)
    }
  }
  
}

extension Population {
  
  // MARK: Static functions
  
  /// Generates a population of chromosomes.
  ///
  /// - Parameters:
  ///   - populationSize: The number of chromosomes to generate.
  ///   - chromosomeLength: The length of each chromosome.
  ///   - generatingFunction: The generating function responsible for returning a value for each element in each chromosome.
  ///   - chromosomeIndex: The 0-based index of the current chromosome being generated.
  ///   - elementIndex: The 0-based index of the current element being generated.
  /// - Returns: An array of `Chromosome` objects.
  public static func generate(populationSize: Int, chromosomeLength: Int, generatingFunction: (_ chromosomeIndex: Int, _ elementIndex: Int) -> Double) -> Population {
    guard populationSize > 0 && chromosomeLength > 0 else {
      return Population([Chromosome()])
    }
    
    var chromosomes = [Chromosome]()
    for i in 0 ..< populationSize {
      var chromosome = Chromosome()
      for j in 0 ..< chromosomeLength {
        chromosome.append(generatingFunction(i, j))
      }
      chromosomes.append(chromosome)
    }
    
    return Population(chromosomes)
  }
  
}
