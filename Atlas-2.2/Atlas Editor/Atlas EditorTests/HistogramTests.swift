//
//  FlowNodeTests.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 5/14/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import XCTest
@testable import Atlas_Editor

class HistogramTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleIntegerBins() {
        
        let values = [1.0, 2.0, 3.0, 4.0, 5.0]
        let hist = Histogram(values:values)
        hist.reBinValues(5, valueRange:nil)
        
        let bins = hist.allBins()
        
        XCTAssert(bins.count == 5)
        
        for index in 0..<5
        {
            XCTAssert(bins[index] == 1)
        }
    }
    
    func testComplexDoubleBins() {
        
        let values = [5.6, 2.1, 3.5, 10.2, 65.2, 100.8]
        let hist = Histogram(values:values)
        hist.reBinValues(5, valueRange:nil)
        
        let bins = hist.allBins()
        
        XCTAssert(bins.count == 5)
        XCTAssert(bins[0] == 4) // 5.6   - 24.64
        XCTAssert(bins[1] == 0) // 24.64 - 43.68
        XCTAssert(bins[2] == 0) // 43.68 - 62.72
        XCTAssert(bins[3] == 1) // 62.72 - 81.96
        XCTAssert(bins[4] == 1) // 81.96 - 100.8
    }
    
    func testCompareSameRange() {
        
        let values_a = [1.0, 2.0, 3.0, 4.0, 5.0]
        let values_b = [1.0, 2.0, 2.0, 3.0, 4.0, 5.0]
        
        let hist_a = Histogram(values:values_a)
        let hist_b = Histogram(values:values_b)
        
        let similarity = hist_a.compare(hist_b)
        XCTAssertEqual(similarity, 0.5)
    }
}
