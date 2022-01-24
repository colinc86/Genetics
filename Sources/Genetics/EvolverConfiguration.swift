//  EvolverConfiguration.swift
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

/// An evolver's selection method.
public enum SelectionMethod {
  
  /// A selection function takes an array of chromosomes and chooses one for breeding.
  public typealias SelectionFunction = (_ chromosomes: [Chromosome]) -> Chromosome
  
  /// The rank selection method.
  case rank
  
  /// The roulette selection method.
  case roulette
  
  /// The tournament selection method.
  case tournament
  
  /// A custom selection method.
  case custom(function: SelectionFunction)
  
}

/// An evolver's crossover method.
public enum CrossoverMethod {
  
  /// A crossover function takes two chromosomes and produces a new hybrid chromosome.
  public typealias CrossoverFunction = (_ firstChromosome: Chromosome, _ secondChromosome: Chromosome) -> Chromosome
  
  /// Point crossover.
  case point(count: Int)
  
  /// Uniform crossover.
  case uniform
  
  /// A custom crossover method.
  case custom(function: CrossoverFunction)
  
}

/// An evolver's elitism type.
public enum ElitismType {
  
  /// Don't apply elitism.
  case none
  
  /// Apply elitism by allowing a specified number of chromosomes to pass in to the next generation.
  case apply(count: Int)
}

/// An evolver's configuration.
public struct EvolverConfiguration {
  
  /// A fitness function evaluates a chromosome's fitness and returns the result.
  public typealias FitnessFunction = (_ chromosome: Chromosome) -> Double
  
  /// A mutation function mutates an element of a chromosome and returns the result.
  public typealias MutationFunction = (_ chromosome: Chromosome) -> Chromosome
  
  /// The selection method to use during evolution.
  public var selectionMethod: SelectionMethod
  
  /// The crossover method to use during evolution.
  public var crossoverMethod: CrossoverMethod
  
  /// The evolver's fitness function.
  public var fitnessFunction: FitnessFunction
  
  /// The evolver's mutation function.
  public var mutationFunction: MutationFunction
  
  /// The amount of elitism to apply.
  public var elitism: ElitismType
  
  /// The rate of crossover.
  public var crossoverRate: Double
  
  /// The rate of mutation.
  public var mutationRate: Double
  
  /// Initializes an `EvolverConfiguration`.
  ///
  /// - Parameters:
  ///   - selectionMethod: The selection method to use during evolution.
  ///   - crossoverMethod: The crossover method to use during evolution.
  ///   - crossoverRate: The rate of crossover.
  ///   - mutationFunction: The mutation function to use during evolution.
  ///   - mutationRate: The rate of mutation.
  ///   - fitnessFunction: The fitness function to use during evolution.
  ///   - elitism: The amount of elitisim to apply.
  public init(
    selectionMethod: SelectionMethod = .rank,
    crossoverMethod: CrossoverMethod = .point(count: 1),
    crossoverRate: Double = 0.5,
    mutationFunction: @escaping MutationFunction,
    mutationRate: Double = 0.5,
    fitnessFunction: @escaping FitnessFunction,
    elitism: ElitismType = .none)
  {
    self.selectionMethod = selectionMethod
    self.crossoverMethod = crossoverMethod
    self.crossoverRate = crossoverRate
    self.mutationFunction = mutationFunction
    self.mutationRate = mutationRate
    self.fitnessFunction = fitnessFunction
    self.elitism = elitism
  }
  
}
