//  PopulationTests.swift
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

class PopulationTests: XCTestCase {

  func testPopulationGeneration() {
    let populationSize = 10
    let chromosomeLength = 20
    let population = Population.generate(populationSize: populationSize, chromosomeLength: chromosomeLength) { (chromosomeIndex: Int, elementIndex: Int) -> Double in
      return Double(chromosomeIndex * elementIndex)
    }
    
    XCTAssertEqual(population.populationSize, populationSize, "Population size \(population.populationSize) should be equal to \(populationSize).")
    
    for chromosome in population.chromosomes {
      XCTAssertEqual(chromosome.count, chromosomeLength, "Chromosome length \(chromosome.count) should be equal to \(chromosomeLength).")
    }
  }
  
  static var allTests = [
    ("testPopulationGeneration", testPopulationGeneration),
  ]

}
