//  Chromosome.swift
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

/// A `Chromosome` is an ordered set of elements which represent the solution to a problem.
public struct Chromosome: CustomStringConvertible, ExpressibleByArrayLiteral, MutableCollection, RangeReplaceableCollection {
  
  public typealias Index = Int
  
  public typealias ArrayLiteralElement = Double
  
  public subscript(index: Int) -> Double {
    get { return storage[index] }
    
    set { storage[index] = newValue }
  }
  
  // MARK: Properties
  
  public var description: String {
    return String(describing: storage)
  }
  
  public var startIndex: Int {
    return 0
  }
  
  public var endIndex: Int {
    return storage.count
  }
  
  /// The fitness of the chromosome expressed as an error.
  ///
  /// - Note: If the chromosome is part of a `Population` object, then this value is updated
  /// each time the population evolves. To prevent excessive calls to the `Evolver`'s `fitnessFunction`,
  /// this value is only updated _once_ immediately following evolution for each generation. Changing
  /// the value of this property before the next evolution will affect selection from the population.
  public var error: Double = 0.0
  
  /// The weight of the chromosome. For internal use when performing different selection techniques.
  internal var weight: Double = 0.0
  
  /// The `Chromosome`'s private storage
  private var storage: [Double]
  
  // MARK: Initializers
  
  /// Initializes an empty `Chromosome`.
  public init() {
    storage = [Double]()
  }
  
  /// Initializes a `Chromosome`.
  ///
  /// - Parameter elements: The elements of the chromosome.
  public init(arrayLiteral elements: Chromosome.ArrayLiteralElement...) {
    storage = elements
  }
  
}

// MARK: Public functions

extension Chromosome {
  
  public func index(after i: Int) -> Int {
    return i + 1
  }
  
  public mutating func replaceSubrange<C>(_ subrange: Range<Index>, with newElements: C) where C: Collection, Double == C.Element {
    storage.replaceSubrange(subrange, with: newElements)
  }
  
}
