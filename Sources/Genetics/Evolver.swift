//  Evolver.swift
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

/// An error produced by an instances of `Evolver`.
public enum EvolverError: Error, CustomStringConvertible {
  
  public var description: String {
    switch self {
    case .populationCount:
      return "A population must have at least one member."
    case .crossoverPointCount(let count, let chromosomeLength):
      return "Crossover point count \(count) must be less than chromosome's length \(chromosomeLength)."
    case .elitismCount(let count, let populationSize):
      return "Elitism count \(count) must be less than or equal to populationSize \(populationSize)."
    }
  }
  
  /// An error thrown when attempting to evolve a population with no chromosomes.
  case populationCount
  
  /// An error thrown when a point crossover's count is not less than the number of elements in a chromosome.
  case crossoverPointCount(count: Int, chromosomeLength: Int)
  
  /// An error thrown when the elitism count is not less than or equal to the population size.
  case elitismCount(count: Int, populationSize: Int)
  
}

/// Evolves a population.
public final class Evolver {
  
  // MARK: Properties
  
  /// A fitness function evaluates a chromosome's fitness and returns the result.
  public typealias FitnessFunction = (_ chromosome: Chromosome) -> Double
  
  /// A mutation function mutates an element of a chromosome and returns the result.
  public typealias MutationFunction = (_ chromosome: Chromosome, _ index: Int) -> Double
  
  /// The evolver's configuration.
  public var configuration: EvolverConfiguration
  
  /// The evolver's fitness function.
  public var fitnessFunction: FitnessFunction
  
  /// The evolver's mutation function.
  public var mutationFunction: MutationFunction
  
  /// Whether or not the evolver should perform crossover.
  private var shouldCrossover: Bool {
    return Double(arc4random()) / Double(UInt32.max) <= configuration.crossoverRate
  }
  
  /// Whether or not the evolver should perform mutation.
  private var shouldMutate: Bool {
    return Double(arc4random()) / Double(UInt32.max) < configuration.mutationRate
  }
  
  // MARK: Initializers
  
  /// Initializes an `Evolver`.
  ///
  /// - Parameter configuration: The evolver's configuration.
  public init(configuration: EvolverConfiguration, fitnessFunction: @escaping FitnessFunction, mutationFunction: @escaping MutationFunction) {
    self.configuration = configuration
    self.fitnessFunction = fitnessFunction
    self.mutationFunction = mutationFunction
  }
  
}

extension Evolver {
  
  /// Evolves a population.
  ///
  /// - Parameters:
  ///   - population: The population to evolve.
  ///   - shouldContinue: This closure is called after each evolution cycle and returns whether or not the evolver should continue evolving the population.
  ///     Passing nil for this parameter evolves the population once.
  public func evolve(population: inout Population, shouldContinue: ((_ configuration: inout EvolverConfiguration, _ population: Population) -> Bool)? = nil) throws {
    guard population.populationSize > 0 else {
      throw EvolverError.populationCount
    }
    
    if case let CrossoverMethod.point(count) = configuration.crossoverMethod, count >= population.chromosomes[0].count {
      throw EvolverError.crossoverPointCount(count: count, chromosomeLength: population.chromosomes[0].count)
    }
    
    if case let ElitismType.apply(count) = configuration.elitism, count > population.populationSize {
      throw EvolverError.elitismCount(count: count, populationSize: population.populationSize)
    }
    
    calculateFitnesses(in: &population)
    
    repeat {
      let newChromosomes = breedSingleGeneration(from: &population)
      population.chromosomes = newChromosomes
      population.generation += 1
      
      calculateFitnesses(in: &population)
    } while shouldContinue == nil ? false : shouldContinue!(&configuration, population)
  }
  
}

extension Evolver {
  
  /// Calculates the fitness of a chromosome and sets the chromosome's `fitness` and `weight` properties.
  ///
  /// - Parameter population: A population of chromosomes.
  private func calculateFitnesses(in population: inout Population) {
    for i in 0 ..< population.populationSize {
      let fitness = fitnessFunction(population.chromosomes[i])
      
      if fitness < 0.0 {
        print("Warning: negative fitness value \(fitness) may cause strange results.")
      }
      
      population.chromosomes[i].fitness = fitness
      population.chromosomes[i].weight = fitness
    }
    
    population.chromosomes.sort(by: { $0.fitness < $1.fitness })
  }
  
  /// Breeds a single generation of chromosomes.
  ///
  /// - Parameter population: A population of chromosomes.
  /// - Returns: A new generation of chromosomes.
  private func breedSingleGeneration(from population: inout Population) -> [Chromosome] {
    var newChromosomes = [Chromosome]()
    applyElitism(to: population, placeIn: &newChromosomes)
    
    for _ in newChromosomes.count ..< population.populationSize {
      newChromosomes.append(breedChild(from: &population))
    }
    
    return newChromosomes
  }
  
  /// Applies elitism to a population of chromosomes.
  ///
  /// - Parameters:
  ///   - population: A population of chromosomes.
  ///   - newChromosomes: The array to add the selected chromosomes to.
  private func applyElitism(to population: Population, placeIn newChromosomes: inout [Chromosome]) {
    guard case let ElitismType.apply(count) = configuration.elitism, count > 0 else {
      return
    }
    
    for i in 0 ..< count {
      newChromosomes.append(population.chromosomes[population.populationSize - i - 1])
    }
  }
  
  /// Breeds a child chromosome from a population.
  ///
  /// - Parameter population: A population of chromosomes.
  /// - Returns: A child chromosome.
  private func breedChild(from population: inout Population) -> Chromosome {
    var child: Chromosome
    
    if shouldCrossover {
      child = crossover(between: selectParent(from: &population), and: selectParent(from: &population))
    }
    else {
      child = selectParent(from: &population)
    }
    
    for i in 0 ..< child.count where shouldMutate {
      child[i] = mutationFunction(child, i)
    }
    
    return child
  }
  
  /// Selects a parent from a population for breeding.
  ///
  /// - Parameter population: A population of chromosomes.
  /// - Returns: A parent chromosome.
  private func selectParent(from population: inout Population) -> Chromosome {
    switch configuration.selectionMethod {
    case .custom(let function):
      return function(population.chromosomes)
    case .rank:
      return rankSelection(from: &population)
    case .roulette:
      return rouletteSelection(from: &population)
    case .tournament:
      return tournamentSelection(from: &population)
    }
  }
  
  /// Performs crossover between two chromosomes.
  ///
  /// - Note: Order does not matter.
  ///
  /// - Parameters:
  ///   - firstChromosome: The first chromosome.
  ///   - secondChromosome: The second chromosome.
  /// - Returns: A hybrid chromosome.
  private func crossover(between firstChromosome: Chromosome, and secondChromosome: Chromosome) -> Chromosome {
    switch configuration.crossoverMethod {
    case .custom(let function):
      return function(firstChromosome, secondChromosome)
    case .point(let count):
      return pointCrossover(between: firstChromosome, and: secondChromosome, points: count)
    case .uniform:
      return uniformCrossover(between: firstChromosome, and: secondChromosome)
    }
  }
  
}

// MARK: Selection functions

extension Evolver {
  
  /// Performs rank selection on a population.
  ///
  /// - Parameter population: A population of chromosomes.
  /// - Returns: A chromosome.
  private func rankSelection(from population: inout Population) -> Chromosome {
    for i in 0 ..< population.populationSize {
      population.chromosomes[i].weight = Double(i + 1)
    }
    
    let total = UInt32(population.chromosomes.map { $0.weight }.reduce(0, +))
    let rand = Double(arc4random_uniform(total))
    var sum: Double = 0.0
    
    for chromosome in population.chromosomes {
      sum += chromosome.weight
      if rand < sum {
        return chromosome
      }
    }
    
    return Chromosome()
  }
  
  /// Performs roulette selection on a population.
  ///
  /// - Parameter population: A population of chromosomes.
  /// - Returns: A chromosome.
  private func rouletteSelection(from population: inout Population) -> Chromosome {
    let total = population.chromosomes.map { $0.weight }.reduce(0, +)
    for i in 0 ..< population.populationSize {
      population.chromosomes[i].weight = population.chromosomes[i].weight / total
    }
    
    let count = population.chromosomes.filter({ $0.weight < 0.0 }).count
    if count > 0 {
      print("Population contains \(count) chromosomes with fitness < 0.0 which may result in bad roulette selection.")
      
      guard let min = population.chromosomes.min(by: { $0.weight < $1.weight }) else {
        return Chromosome(repeatElement(0.0, count: population.chromosomes[0].count))
      }
      
      for i in 0 ..< population.populationSize {
        population.chromosomes[i].weight += min.weight
      }
    }
    
    let rand = Double(arc4random()) / Double(UInt32.max)
    var sum: Double = 0.0
    
    for chromosome in population.chromosomes {
      sum += chromosome.weight
      if rand < sum {
        return chromosome
      }
    }
    
    return population.chromosomes[0]
  }
  
  /// Performs tournament selection on a population.
  ///
  /// - Parameter population: A population of chromosomes.
  /// - Returns: A chromosome.
  private func tournamentSelection(from population: inout Population) -> Chromosome {
    population.shuffleChromosomes()
    let rand = arc4random_uniform(UInt32(population.chromosomes.count - 1)) + 1
    let tournamentGroup = [Chromosome](population.chromosomes[0 ..< Int(rand)])
    return tournamentGroup.max(by: { $0.weight < $1.weight })!
  }
  
}

// MARK: Crossover functions

extension Evolver {
  
  /// Performs point crossover between two chromosomes.
  ///
  /// - Note: Order does not matter.
  ///
  /// - Parameters:
  ///   - firstChromosome: The first chromosome.
  ///   - secondChromosome: The second chromosome.
  ///   - points: The number of crossover points.
  /// - Returns: A hybrid chromosome.
  private func pointCrossover(between firstChromosome: Chromosome, and secondChromosome: Chromosome, points: Int) -> Chromosome {
    var child = Chromosome(repeatElement(0.0, count: firstChromosome.count))
    var indexes = [Int](repeating: 0, count: firstChromosome.count - 1)
    
    for i in 0 ..< firstChromosome.count - 1 {
      indexes[i] = i + 1
    }
    
    if indexes.count > 1 {
      for i in 0 ..< Int(indexes.count) - 1 {
        let j = Int(arc4random_uniform(UInt32(indexes.count) - UInt32(i))) + i
        
        if i == j {
          continue
        }
        
        indexes.swapAt(i, j)
      }
    }
    
    var crossoverPoints = [Int](indexes[0 ..< points])
    crossoverPoints.sort(by: { $0 < $1 })
    crossoverPoints.insert(0, at: 0)
    crossoverPoints.append(firstChromosome.count)
    
    for i in 0 ..< crossoverPoints.count - 1 {
      for j in crossoverPoints[i] ..< crossoverPoints[i + 1] {
        child[j] = i % 2 == 0 ? firstChromosome[j] : secondChromosome[j]
      }
    }

    return child
  }
  
  /// Performs uniform crossover between two chromosomes.
  ///
  /// - Note: Order does not matter.
  ///
  /// - Parameters:
  ///   - firstChromosome: The first chromosome.
  ///   - secondCrossover: The second chromosome.
  /// - Returns: A hybrid chromosome.
  private func uniformCrossover(between firstChromosome: Chromosome, and secondCrossover: Chromosome) -> Chromosome {
    var child = Chromosome(repeatElement(0.0, count: firstChromosome.count))
    for i in 0 ..< firstChromosome.count {
      child[i] = arc4random_uniform(2) == 1 ? firstChromosome[i] : secondCrossover[i]
    }

    return child
  }
  
}
