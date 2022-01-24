//  EvolverTests.swift
//  GeneticsTests
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

@testable import Genetics
import XCTest

class EvolverTests: XCTestCase {
  
  var population: Population!
  var evolver: Evolver!

  override func setUp() {
    super.setUp()
    
    population = Population.generate(populationSize: 5, chromosomeLength: 2, generatingFunction: { (_, _) -> Double in
      return Double(arc4random()) / Double(uint32.max - 1)
    })
    
    let configuration = EvolverConfiguration(selectionMethod: .rank, crossoverMethod: .uniform, crossoverRate: 1.0, mutationFunction: mutationFunction, mutationRate: 1.0, fitnessFunction: fitnessFunction, elitism: .none)
    evolver = Evolver(configuration: configuration)
  }
  
  func testEvolveThrowsPopulationCount() {
    population.chromosomes.removeAll()
    XCTAssertThrowsError(try evolver.evolve(population: &population!), "Should throw EvolverERror.populationCount") { (error: Error) in
      print("Test passed: \(error)")
    }
  }
  
  func testEvolverThrowsCrossoverPointCount() {
    evolver.configuration.crossoverMethod = .point(count: 2)
    XCTAssertThrowsError(try evolver.evolve(population: &population!), "Should throw EvolverError.crossoverPointCount") { (error: Error) in
      print("Test passed: \(error)")
    }
  }
  
  func testEvolverThrowsElitismCount() {
    evolver.configuration.elitism = .apply(count: 6)
    XCTAssertThrowsError(try evolver.evolve(population: &population!), "Should throw EvolverError.elitismCount") { (error: Error) in
      print("Test passed: \(error)")
    }
  }
  
  func testRankSelectionMethodPerformance() {
    evolver.configuration.selectionMethod = .rank
    
    self.measure {
      do {
        for _ in 0 ..< 1000 {
          try evolver.evolve(population: &population!)
        }
      }
      catch _ {
        // Do nothing
      }
    }
  }
  
  func testRouletteSelectionMethodPerformance() {
    evolver.configuration.selectionMethod = .roulette
    
    self.measure {
      do {
        for _ in 0 ..< 1000 {
          try evolver.evolve(population: &population!)
        }
      }
      catch _ {
        // Do nothing
      }
    }
  }
  
  func testTournamentSelectionMethodPerformance() {
    evolver.configuration.selectionMethod = .tournament
    
    self.measure {
      do {
        for _ in 0 ..< 1000 {
          try evolver.evolve(population: &population!)
        }
      }
      catch _ {
        // Do nothing
      }
    }
  }
  
  static var allTests = [
    ("testEvolveThrowsPopulationCount", testEvolveThrowsPopulationCount),
    ("testEvolverThrowsCrossoverPointCount", testEvolverThrowsCrossoverPointCount),
    ("testEvolverThrowsElitismCount", testEvolverThrowsElitismCount),
    ("testRankSelectionMethodPerformance", testRankSelectionMethodPerformance),
    ("testRouletteSelectionMethodPerformance", testRouletteSelectionMethodPerformance),
    ("testTournamentSelectionMethodPerformance", testTournamentSelectionMethodPerformance),
  ]

}

extension EvolverTests {
  
  func fitnessFunction(chromosome: Chromosome) -> Double {
    return sin(Double.pi * chromosome[0]) * sin(Double.pi * chromosome[1])
  }
  
  func mutationFunction(chromosome: Chromosome) -> Chromosome {
    var chromosomeCopy = chromosome
    
    for index in 0 ..< chromosome.count {
      var value = chromosome[index]
      let step = 0.00001
      value += arc4random_uniform(2) == 0 ? step : -step
      
      if value < 0.0 {
        value = 0.0
      }
      else if value > 1.0 {
        value = 1.0
      }
      
      chromosomeCopy[index] = value
    }
    
    return chromosomeCopy
  }
  
}
