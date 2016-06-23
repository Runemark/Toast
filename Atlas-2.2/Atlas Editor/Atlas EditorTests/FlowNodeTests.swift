//
//  FlowNodeTests.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 5/14/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import XCTest
@testable import Atlas_Editor

class FlowNodeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAngle() {
        let node_a = FlowNode(center:DiscreteTileCoord(x:0, y:0), strength:1)
        let node_b = FlowNode(center:DiscreteTileCoord(x:1, y:0), strength:1)
        node_a.connections.append(node_b)
        let mismatches = node_a.internalCohesionMismatches((min:10, max:10))
        for mismatch in mismatches
        {
            print("mismatch found: angle:\(mismatch.direction), \(mismatch.delta), \(mismatch.angle)")
        }
        
    }
    
}
