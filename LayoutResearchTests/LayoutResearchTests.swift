//
//  LayoutResearchTests.swift
//  LayoutResearchTests
//
//  Created by Tassilo Bouwman on 09.09.17.
//  Copyright © 2017 Tassilo Bouwman. All rights reserved.
//

import XCTest
@testable import LayoutResearch

class LayoutResearchTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDistanceFunction() {
        let distanceGrid1 = itemDistanceWithEqualWhiteSpaceFor(layout: .grid, itemDistance: 1, itemDiameter: 50)
        let distanceHexa1 = itemDistanceWithEqualWhiteSpaceFor(layout: .horizontal, itemDistance: 1, itemDiameter: 50)
        
        XCTAssertNotEqual(distanceGrid1, distanceHexa1)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
