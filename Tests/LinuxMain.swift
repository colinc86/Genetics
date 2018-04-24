import XCTest
@testable import GeneticsTests

XCTMain([
    testCase(EvolverTests.allTests),
    testCase(PopulationTests.allTests),
])
