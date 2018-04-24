# Genetics

[![Swift Version](https://img.shields.io/badge/swift-4.0-orange.svg?style=flat)](https://swift.org)
[![Genetics Version](https://img.shields.io/badge/version-1.0.0-lightgrey.svg?style=flat)](https://github.com/colinc86/Genetics)

A genetic algorithm library for Swift.

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## Features

#### Selection
- [x] Rank
- [x] Roulette
- [x] Tournament
- [ ] Stochastic
- [x] Custom

#### Crossover
- [x] N-Point
- [x] Uniform
- [x] Custom

## Installation

### Swift Package Manager

Add the following to the `dependencies` in your `Package.swift` file.

```swift
dependencies: [
  .package(url: "https://github.com/colinc86/Genetics.git, from: "1.0.0")
]
```

### Manually

1. Navigate to your project's directory and clone the Genetics repository.

  ```bash
  $ git clone https://github.com/colinc86/Genetics.git
  ```

2. Add `Genetics.xcodeproj` to your Xcode project.
3. Add the `Genetics` framework to your project.

## Usage

For a working example, see the [GeneticsExample](https://github.com/colinc86/Genetics/tree/master/Sources/GeneticsExample).

### Preparing for Evolution

A few things need to be set up before evolution can take place. We must have a population of chromosomes to evolve, and a set of parameters to guide the evolution of each generation. The `Chromosome`, `Population` and `EvolverConfiguration` objects are what we'll use.

#### Generating a Population of Chromosomes

The first thing you'll need to do is generate a population of chromosomes. The easiest way to do that is by using the static function `Population.generate(populationSize:chromosomeLength:generatingFunction:)`. The following example generates a `Population` of 4 chromosomes with length 2 by using the provided generating function.

```swift
var population = Population.generate(populationSize: 4, chromosomeLength: 2) { (_, _) -> Double in
  return arc4random_uniform(20)
}
```

You can also create chromosomes manually by initializing them with an array or an array literal.

```swift
let chromosomeA = Chromosome([1.0, 2.0, 3.0])
let chromosomeB = Chromosome(1.0, 2.0, 3.0)
```

Then, initialize a `Population` with an array of chromosomes.

```swift
let population = Population([chromosomeA, chromosomeB])
```

#### Creating an EvolverConfiguration

An instance of `EvolverConfiguration` contains parameters for use by an `Evolver` when performing evolution. Creating one is easy:

```swift
let configuration = EvolverConfiguration(selectionMethod: .rank, crossoverMethod: .point(count: 1), elitism: .none, crossoverRate: 0.1, mutationRate: 0.1)
```

### Evolution

The class responsible for evolving a population of chromosomes is the `Evolver`. You create an evolver by giving it a configuration, fitness function, and a mutation function. The fitness function is responsible for returning the fitness of a chromosome in the population, and the mutation function is responsible for mutating a single element of a chromosome.

#### Creating an Evolver

The following example creates an instance of `Evolver` with `configuration` and provides fitness and mutation functions. The fitness function divides 10.0 by the sum of all of the elements in the chromosome. The mutation function randomly adds or subtracts 1 from an element of the chromosome and returns the result. This will result in the fittest chromosomes having elements whos sum is near 10.0.

```swift
let evolver = Evolver(configuration: configuration, fitnessFunction: { (chromosome: Chromosome) -> Double in
  // Fitness function
  return 10.0 / chromosome.reduce(0, +)
}, mutationFunction: { (chromosome: Chromosome, index: Int) -> Double in
  // Mutation function
  var value = chromosome[index]  
  value += arc4random_uniform(2) == 0 ? -1.0 : 1.0
  
  return value
})
```

#### Evolving a Population

The easiest way to evolve a population is by using the evolver's `evolve(population:shouldContinue:)` function.

```swift
do {
  try evolver.evolve(population: &population, shouldContinue: { (config: inout EvolverConfiguration, pop: Population) -> Bool in
    return pop.generation < 100
  })
}
catch let error {
  print("\(error)")
}
```

The preceding example evolves the population 100 times. Notice that the `shouldContinue` closure takes an `inout EvolverConfiguration` parameter. The evolver gives you the chance to modify its configuration before the next evolution cycle.

You can also call `evolve` once without providing the `shouldContinue` closure.

```swift
do {
  for _ in 0 ..< 100 {
    try evolver.evolve(population: &population)
  }
}
catch let error {
  print("\(error)")
}
```

## License
Genetics is released under the MIT license.

See [LICENSE](https://github.com/colinc86/Genetics/blob/master/LICENSE).
