//
//  FlowNodeTests.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 5/14/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import XCTest
@testable import Atlas_Editor

class ComponentLayoutTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClusterCenter() {
        let layout = ComponentLayout()
        
        layout.addComponent(DiscreteTileCoord(x:0, y:0))
        layout.addComponent(DiscreteTileCoord(x:1, y:3))
        layout.addComponent(DiscreteTileCoord(x:3, y:1))
        layout.addComponent(DiscreteTileCoord(x:4, y:4))
        
        let clusterCenter = layout.componentClusterCenter()
        XCTAssertEqual(clusterCenter, DiscreteTileCoord(x:2, y:2))
    }
    
    func testComplexClusterCenter() {
        let layout = ComponentLayout()
        
        layout.addComponent(DiscreteTileCoord(x:0, y:0))
        layout.addComponent(DiscreteTileCoord(x:1, y:3))
        layout.addComponent(DiscreteTileCoord(x:3, y:1))
        layout.addComponent(DiscreteTileCoord(x:4, y:0))
        
        let clusterCenter = layout.componentClusterCenter()
        XCTAssertEqual(clusterCenter, DiscreteTileCoord(x:2, y:1))
    }
    
    // TODO: Test should not be based on histogram (should be based on raw stats)
    func testBasicAreaCenter() {
        let layout = ComponentLayout()
        let area = TileRect(left:0, right:4, up:4, down:0)
        
        layout.addComponent(DiscreteTileCoord(x:1, y:1))
        layout.addComponent(DiscreteTileCoord(x:3, y:1))
        layout.addComponent(DiscreteTileCoord(x:1, y:3))
        layout.addComponent(DiscreteTileCoord(x:3, y:3))
        
        let areaCenterStats = layout.evaluation_distanceFromAreaCenter(area).allBins()
        
        XCTAssertEqual(areaCenterStats.count, 5)
        XCTAssertEqual(areaCenterStats[0], 4)
        XCTAssertEqual(areaCenterStats[1], 0)
        XCTAssertEqual(areaCenterStats[2], 0)
        XCTAssertEqual(areaCenterStats[3], 0)
        XCTAssertEqual(areaCenterStats[4], 0)
    }
    
    // TODO: Test should not be based on histogram (should be based on raw stats)
    func testComplexAreaCenter() {
        let layout = ComponentLayout()
        let area = TileRect(left:0, right:6, up:4, down:0)
        
        layout.addComponent(DiscreteTileCoord(x:1, y:1))
        layout.addComponent(DiscreteTileCoord(x:3, y:1))
        layout.addComponent(DiscreteTileCoord(x:1, y:3))
        layout.addComponent(DiscreteTileCoord(x:3, y:3))
        
        let areaCenterStats = layout.evaluation_distanceFromAreaCenter(area).allBins()
        
        XCTAssertEqual(areaCenterStats.count, 5)
        XCTAssertEqual(areaCenterStats[0], 2)
        XCTAssertEqual(areaCenterStats[1], 0)
        XCTAssertEqual(areaCenterStats[2], 0)
        XCTAssertEqual(areaCenterStats[3], 0)
        XCTAssertEqual(areaCenterStats[4], 2)
    }
    
    // TODO: Test should not be based on histogram (should be based on raw stats)
    func testSimpleClusterCenter() {
        let layout = ComponentLayout()
        
        layout.addComponent(DiscreteTileCoord(x:1, y:1))
        layout.addComponent(DiscreteTileCoord(x:3, y:1))
        layout.addComponent(DiscreteTileCoord(x:1, y:3))
        layout.addComponent(DiscreteTileCoord(x:3, y:3))
        
        let areaCenterStats = layout.evaluation_distanceFromClusterCenter().allBins()
        
        XCTAssertEqual(areaCenterStats.count, 5)
        XCTAssertEqual(areaCenterStats[0], 4)
        XCTAssertEqual(areaCenterStats[1], 0)
        XCTAssertEqual(areaCenterStats[2], 0)
        XCTAssertEqual(areaCenterStats[3], 0)
        XCTAssertEqual(areaCenterStats[4], 0)
    }
    
    // TODO: Test should not be based on histogram (should be based on raw stats)
    func testSymmetricClusterCenter() {
        let layout = ComponentLayout()
        
        layout.addComponent(DiscreteTileCoord(x:0, y:0))
        layout.addComponent(DiscreteTileCoord(x:1, y:3))
        layout.addComponent(DiscreteTileCoord(x:3, y:1))
        layout.addComponent(DiscreteTileCoord(x:4, y:4))
        
        let areaCenterStats = layout.evaluation_distanceFromClusterCenter().allBins()
        
        XCTAssertEqual(areaCenterStats.count, 5)
        XCTAssertEqual(areaCenterStats[0], 2)
        XCTAssertEqual(areaCenterStats[1], 0)
        XCTAssertEqual(areaCenterStats[2], 0)
        XCTAssertEqual(areaCenterStats[3], 0)
        XCTAssertEqual(areaCenterStats[4], 2)
    }
    
    // TODO: Test should not be based on histogram (should be based on raw stats)
    func testAsymmetricClusterCenter() {
        let layout = ComponentLayout()
        
        layout.addComponent(DiscreteTileCoord(x:0, y:0))
        layout.addComponent(DiscreteTileCoord(x:1, y:3))
        layout.addComponent(DiscreteTileCoord(x:3, y:1))
        layout.addComponent(DiscreteTileCoord(x:4, y:0))
        
        let areaCenterStats = layout.evaluation_distanceFromClusterCenter().allBins()
        
        XCTAssertEqual(areaCenterStats.count, 5)
        XCTAssertEqual(areaCenterStats[0], 1)
        XCTAssertEqual(areaCenterStats[1], 0)
        XCTAssertEqual(areaCenterStats[2], 0)
        XCTAssertEqual(areaCenterStats[3], 0)
        XCTAssertEqual(areaCenterStats[4], 3)
    }
    
    func testSimpleLocalStats() {
        let layout = ComponentLayout()
        
        layout.addComponent(DiscreteTileCoord(x:1, y:1))
        layout.addComponent(DiscreteTileCoord(x:3, y:1))
        layout.addComponent(DiscreteTileCoord(x:1, y:3))
        layout.addComponent(DiscreteTileCoord(x:3, y:3))
        
        let stats = layout.localStats()
        
        XCTAssertEqual(countWithinList(0.0, list:stats.angles), 2)
        XCTAssertEqual(countWithinList(90.0, list:stats.angles), 2)
        XCTAssertEqual(countWithinList(180.0, list:stats.angles), 2)
        XCTAssertEqual(countWithinList(270.0, list:stats.angles), 2)
    }
    
    func countWithinList(member:Double, list:[Double]) -> Int
    {
        if (list.contains(member))
        {
            var count = 0
            for el in list
            {
                if (member == el)
                {
                    count += 1
                }
            }
            
            return count
        }
        else
        {
            return 0
        }
    }
}
