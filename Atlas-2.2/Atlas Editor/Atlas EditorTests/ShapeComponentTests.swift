//
//  FlowNodeTests.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 5/14/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import XCTest
@testable import Atlas_Editor

class ShapeComponentTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBoundingBox() {
        let shape = ShapeComponent()
        XCTAssertNil(shape.boundingBox)
        
        // After a single node is added, the bounding box should be simply that node
        let tile = TileRect(left:10, right:10, up:10, down:10)
        shape.addNode(tile)
        var boundingBox = shape.boundingBox!
        XCTAssert(boundingBox == tile)
        
        // Increase the bounding box in one direction
        let tile2 = TileRect(left:9, right:10, up:10, down:10)
        shape.addNode(tile2)
        boundingBox = shape.boundingBox!
        XCTAssert(boundingBox == tile2)
        
        // Increase the bounding box in all directions
        let tile3 = TileRect(left:8, right:11, up:11, down:8)
        shape.addNode(tile3)
        boundingBox = shape.boundingBox!
        XCTAssert(boundingBox == tile3)
        
        // Should not change the bounding box
        let tile4 = TileRect(left:9, right:9, up:9, down:9)
        shape.addNode(tile4)
        boundingBox = shape.boundingBox!
        XCTAssert(boundingBox == tile3)
        
        shape.removeNode(tile3)
        boundingBox = shape.boundingBox!
        XCTAssert(boundingBox == TileRect(left:9, right:10, up:10, down:9))
    }
    
    func testRipple() {
        
        var nodes = [TileRect]()
        nodes.append(TileRect(left:8, right:12, up:12, down:8))
        
        let emptySet = Set<DiscreteTileCoord>()
        
        let secondExtrusion = Set([
            DiscreteTileCoord(x:6, y:6),
            DiscreteTileCoord(x:7, y:6),
            DiscreteTileCoord(x:8, y:6),
            DiscreteTileCoord(x:9, y:6),
            DiscreteTileCoord(x:10, y:6),
            DiscreteTileCoord(x:11, y:6),
            DiscreteTileCoord(x:12, y:6),
            DiscreteTileCoord(x:13, y:6),
            DiscreteTileCoord(x:14, y:6),
            DiscreteTileCoord(x:14, y:7),
            DiscreteTileCoord(x:14, y:8),
            DiscreteTileCoord(x:14, y:9),
            DiscreteTileCoord(x:14, y:10),
            DiscreteTileCoord(x:14, y:11),
            DiscreteTileCoord(x:14, y:12),
            DiscreteTileCoord(x:14, y:13),
            DiscreteTileCoord(x:14, y:14),
            DiscreteTileCoord(x:13, y:14),
            DiscreteTileCoord(x:12, y:14),
            DiscreteTileCoord(x:11, y:14),
            DiscreteTileCoord(x:10, y:14),
            DiscreteTileCoord(x:9, y:14),
            DiscreteTileCoord(x:8, y:14),
            DiscreteTileCoord(x:7, y:14),
            DiscreteTileCoord(x:6, y:14),
            DiscreteTileCoord(x:6, y:13),
            DiscreteTileCoord(x:6, y:12),
            DiscreteTileCoord(x:6, y:11),
            DiscreteTileCoord(x:6, y:10),
            DiscreteTileCoord(x:6, y:9),
            DiscreteTileCoord(x:6, y:8),
            DiscreteTileCoord(x:6, y:7)
            ])
        
        let firstExtrusion = Set([
            DiscreteTileCoord(x:7, y:7),
            DiscreteTileCoord(x:8, y:7),
            DiscreteTileCoord(x:9, y:7),
            DiscreteTileCoord(x:10, y:7),
            DiscreteTileCoord(x:11, y:7),
            DiscreteTileCoord(x:12, y:7),
            DiscreteTileCoord(x:13, y:7),
            DiscreteTileCoord(x:13, y:8),
            DiscreteTileCoord(x:13, y:9),
            DiscreteTileCoord(x:13, y:10),
            DiscreteTileCoord(x:13, y:11),
            DiscreteTileCoord(x:13, y:12),
            DiscreteTileCoord(x:13, y:13),
            DiscreteTileCoord(x:12, y:13),
            DiscreteTileCoord(x:11, y:13),
            DiscreteTileCoord(x:10, y:13),
            DiscreteTileCoord(x:9, y:13),
            DiscreteTileCoord(x:8, y:13),
            DiscreteTileCoord(x:7, y:13),
            DiscreteTileCoord(x:7, y:12),
            DiscreteTileCoord(x:7, y:11),
            DiscreteTileCoord(x:7, y:10),
            DiscreteTileCoord(x:7, y:9),
            DiscreteTileCoord(x:7, y:8)
            ])
        
        let firstIntrusion = Set([
            DiscreteTileCoord(x:8, y:8),
            DiscreteTileCoord(x:9, y:8),
            DiscreteTileCoord(x:10, y:8),
            DiscreteTileCoord(x:11, y:8),
            DiscreteTileCoord(x:12, y:8),
            DiscreteTileCoord(x:12, y:9),
            DiscreteTileCoord(x:12, y:10),
            DiscreteTileCoord(x:12, y:11),
            DiscreteTileCoord(x:12, y:12),
            DiscreteTileCoord(x:11, y:12),
            DiscreteTileCoord(x:10, y:12),
            DiscreteTileCoord(x:9, y:12),
            DiscreteTileCoord(x:8, y:12),
            DiscreteTileCoord(x:8, y:11),
            DiscreteTileCoord(x:8, y:10),
            DiscreteTileCoord(x:8, y:9)
            ])
        
        let secondIntrusion = Set([
            DiscreteTileCoord(x:9, y:9),
            DiscreteTileCoord(x:10, y:9),
            DiscreteTileCoord(x:11, y:9),
            DiscreteTileCoord(x:11, y:10),
            DiscreteTileCoord(x:11, y:11),
            DiscreteTileCoord(x:10, y:11),
            DiscreteTileCoord(x:9, y:11),
            DiscreteTileCoord(x:9, y:10)
            ])
        
        let thirdIntrusion = Set([
            DiscreteTileCoord(x:10, y:10)
            ])
        
        let allIntrusions = firstIntrusion.union(secondIntrusion.union(thirdIntrusion))
        let allExtrusions = firstExtrusion.union(secondExtrusion)
        let superSet = allIntrusions.union(allExtrusions)
        
        // Should return the first intrusion + first, second extrusion
        rippleTestHelper(nodes, rStart:0, rEnd:2, expected:firstIntrusion.union(firstExtrusion.union(secondExtrusion)))
        // Should return the first extrusion + first, second intrusion
        rippleTestHelper(nodes, rStart:-1, rEnd:1, expected:firstExtrusion.union(firstIntrusion.union(secondIntrusion)))
        // Should return all intrusions
        rippleTestHelper(nodes, rStart:-2, rEnd:0, expected:allIntrusions)
        // Should return the superset
        rippleTestHelper(nodes, rStart:-2, rEnd:2, expected:superSet)
        
    }
    
    func testExtrusionRanges() {
        
        var nodes = [TileRect]()
        nodes.append(TileRect(left:9, right:10, up:9, down:9))
        nodes.append(TileRect(left:10, right:10, up:10, down:9))
        
        let emptySet = Set<DiscreteTileCoord>()
        let firstExtrusion = Set([DiscreteTileCoord(x:8, y:8),
            DiscreteTileCoord(x:9, y:8),
            DiscreteTileCoord(x:10, y:8),
            DiscreteTileCoord(x:11, y:8),
            DiscreteTileCoord(x:11, y:9),
            DiscreteTileCoord(x:11, y:10),
            DiscreteTileCoord(x:11, y:11),
            DiscreteTileCoord(x:10, y:11),
            DiscreteTileCoord(x:9, y:11),
            DiscreteTileCoord(x:9, y:10),
            DiscreteTileCoord(x:8, y:10),
            DiscreteTileCoord(x:8, y:9)])
        
        let secondExtrusion = Set([DiscreteTileCoord(x:7, y:7),
            DiscreteTileCoord(x:7, y:7),
            DiscreteTileCoord(x:8, y:7),
            DiscreteTileCoord(x:9, y:7),
            DiscreteTileCoord(x:10, y:7),
            DiscreteTileCoord(x:11, y:7),
            DiscreteTileCoord(x:12, y:7),
            DiscreteTileCoord(x:12, y:8),
            DiscreteTileCoord(x:12, y:9),
            DiscreteTileCoord(x:12, y:10),
            DiscreteTileCoord(x:12, y:11),
            DiscreteTileCoord(x:12, y:12),
            DiscreteTileCoord(x:11, y:12),
            DiscreteTileCoord(x:10, y:12),
            DiscreteTileCoord(x:9, y:12),
            DiscreteTileCoord(x:8, y:12),
            DiscreteTileCoord(x:8, y:11),
            DiscreteTileCoord(x:7, y:11),
            DiscreteTileCoord(x:7, y:10),
            DiscreteTileCoord(x:7, y:9),
            DiscreteTileCoord(x:7, y:8)])
        
        let thirdExtrusion = Set([DiscreteTileCoord(x:6, y:6),
            DiscreteTileCoord(x:7, y:6),
            DiscreteTileCoord(x:8, y:6),
            DiscreteTileCoord(x:9, y:6),
            DiscreteTileCoord(x:10, y:6),
            DiscreteTileCoord(x:11, y:6),
            DiscreteTileCoord(x:12, y:6),
            DiscreteTileCoord(x:13, y:6),
            DiscreteTileCoord(x:13, y:7),
            DiscreteTileCoord(x:13, y:8),
            DiscreteTileCoord(x:13, y:9),
            DiscreteTileCoord(x:13, y:10),
            DiscreteTileCoord(x:13, y:11),
            DiscreteTileCoord(x:13, y:12),
            DiscreteTileCoord(x:13, y:13),
            DiscreteTileCoord(x:12, y:13),
            DiscreteTileCoord(x:11, y:13),
            DiscreteTileCoord(x:10, y:13),
            DiscreteTileCoord(x:9, y:13),
            DiscreteTileCoord(x:8, y:13),
            DiscreteTileCoord(x:7, y:13),
            DiscreteTileCoord(x:7, y:12),
            DiscreteTileCoord(x:6, y:12),
            DiscreteTileCoord(x:6, y:11),
            DiscreteTileCoord(x:6, y:10),
            DiscreteTileCoord(x:6, y:9),
            DiscreteTileCoord(x:6, y:8),
            DiscreteTileCoord(x:6, y:7)
            ])
        
        // Should return nothing if start > end
        extrusionTestHelper(nodes, rStart:2, rEnd:1, expected:emptySet)
        // Should return nothing if start or end are negative
        extrusionTestHelper(nodes, rStart:-2, rEnd:-1, expected:emptySet)
        // Should return nothing if start is 0
        extrusionTestHelper(nodes, rStart:0, rEnd:1, expected:emptySet)
        // Should return only the first extrusion
        extrusionTestHelper(nodes, rStart:1, rEnd:1, expected:firstExtrusion)
        // Should return both the first and second extrusions
        extrusionTestHelper(nodes, rStart:1, rEnd:2, expected:firstExtrusion.union(secondExtrusion))
        // Should return only the second extrusion
        extrusionTestHelper(nodes, rStart:2, rEnd:2, expected:secondExtrusion)
        // Should return only the third extrusion
        extrusionTestHelper(nodes, rStart:3, rEnd:3, expected:thirdExtrusion)
        // Should return the first through third extrusions
        extrusionTestHelper(nodes, rStart:1, rEnd:3, expected:firstExtrusion.union(secondExtrusion.union(thirdExtrusion)))
        // Should return the second and third extrusions
        extrusionTestHelper(nodes, rStart:2, rEnd:3, expected:secondExtrusion.union(thirdExtrusion))
    }
    
    func testIntrusionRanges() {
        
        var nodes = [TileRect]()
        nodes.append(TileRect(left:5, right:9, up:12, down:8))
        nodes.append(TileRect(left:7, right:11, up:10, down:6))
        nodes.append(TileRect(left:8, right:12, up:12, down:8))
        nodes.append(TileRect(left:9, right:13, up:13, down:9))
        
        let emptySet = Set<DiscreteTileCoord>()
        
        let firstIntrusion = Set([DiscreteTileCoord(x:7, y:6),
            DiscreteTileCoord(x:8, y:6),
            DiscreteTileCoord(x:9, y:6),
            DiscreteTileCoord(x:10, y:6),
            DiscreteTileCoord(x:11, y:6),
            DiscreteTileCoord(x:11, y:7),
            DiscreteTileCoord(x:11, y:8),
            DiscreteTileCoord(x:12, y:8),
            DiscreteTileCoord(x:12, y:9),
            DiscreteTileCoord(x:13, y:9),
            DiscreteTileCoord(x:13, y:10),
            DiscreteTileCoord(x:13, y:11),
            DiscreteTileCoord(x:13, y:12),
            DiscreteTileCoord(x:13, y:13),
            DiscreteTileCoord(x:12, y:13),
            DiscreteTileCoord(x:11, y:13),
            DiscreteTileCoord(x:10, y:13),
            DiscreteTileCoord(x:9, y:13),
            DiscreteTileCoord(x:9, y:12),
            DiscreteTileCoord(x:8, y:12),
            DiscreteTileCoord(x:7, y:12),
            DiscreteTileCoord(x:6, y:12),
            DiscreteTileCoord(x:5, y:12),
            DiscreteTileCoord(x:5, y:11),
            DiscreteTileCoord(x:5, y:10),
            DiscreteTileCoord(x:5, y:9),
            DiscreteTileCoord(x:5, y:8),
            DiscreteTileCoord(x:6, y:8),
            DiscreteTileCoord(x:7, y:8),
            DiscreteTileCoord(x:7, y:7),
            ])
        
        let secondIntrusion = Set([DiscreteTileCoord(x:8, y:7),
            DiscreteTileCoord(x:9, y:7),
            DiscreteTileCoord(x:10, y:7),
            DiscreteTileCoord(x:10, y:8),
            DiscreteTileCoord(x:10, y:9),
            DiscreteTileCoord(x:11, y:9),
            DiscreteTileCoord(x:11, y:10),
            DiscreteTileCoord(x:12, y:10),
            DiscreteTileCoord(x:12, y:11),
            DiscreteTileCoord(x:12, y:12),
            DiscreteTileCoord(x:11, y:12),
            DiscreteTileCoord(x:10, y:12),
            DiscreteTileCoord(x:10, y:11),
            DiscreteTileCoord(x:9, y:11),
            DiscreteTileCoord(x:8, y:11),
            DiscreteTileCoord(x:7, y:11),
            DiscreteTileCoord(x:6, y:11),
            DiscreteTileCoord(x:6, y:10),
            DiscreteTileCoord(x:6, y:9),
            DiscreteTileCoord(x:7, y:9),
            DiscreteTileCoord(x:8, y:9),
            DiscreteTileCoord(x:8, y:8)
            ])
        
        let thirdIntrusion = Set([DiscreteTileCoord(x:7, y:10),
            DiscreteTileCoord(x:8, y:10),
            DiscreteTileCoord(x:9, y:10),
            DiscreteTileCoord(x:9, y:9),
            DiscreteTileCoord(x:9, y:8),
            DiscreteTileCoord(x:10, y:10),
            DiscreteTileCoord(x:11, y:11)
            ])
        
        // Should return nothing if start > end
        intrusionTestHelper(nodes, rStart:2, rEnd:1, expected:emptySet)
        // Should return nothing if start or end are negative
        intrusionTestHelper(nodes, rStart:-2, rEnd:-1, expected:emptySet)
        // Should return the first intrusion
        intrusionTestHelper(nodes, rStart:0, rEnd:0, expected:firstIntrusion)
        // Should return the second intrusion
        intrusionTestHelper(nodes, rStart:1, rEnd:1, expected:secondIntrusion)
        // Should return the first and second intrusions
        intrusionTestHelper(nodes, rStart:0, rEnd:1, expected:firstIntrusion.union(secondIntrusion))
        // Should return the third intrusion
        intrusionTestHelper(nodes, rStart:2, rEnd:2, expected:thirdIntrusion)
        // Should return the first through third intrusions
        intrusionTestHelper(nodes, rStart:0, rEnd:2, expected:firstIntrusion.union(secondIntrusion.union(thirdIntrusion)))
        // Should return the second and third intrusions
        intrusionTestHelper(nodes, rStart:1, rEnd:2, expected:secondIntrusion.union(thirdIntrusion))
        // Should return nothing if intrusion extends too far
        intrusionTestHelper(nodes, rStart:3, rEnd:3, expected:emptySet)
    }
    
    func intrusionTestHelper(nodes:[TileRect], rStart:Int, rEnd:Int, expected:Set<DiscreteTileCoord>) {
        
        let shape = ShapeComponent()
        for node in nodes
        {
            shape.addNode(node)
        }
        
        let pool = shape.intrusionPool(rStart, rEnd:rEnd)
        XCTAssert(pool == expected)
    }
    
    func extrusionTestHelper(nodes:[TileRect], rStart:Int, rEnd:Int, expected:Set<DiscreteTileCoord>) {
        
        let shape = ShapeComponent()
        for node in nodes
        {
            shape.addNode(node)
        }
        
        let pool = shape.extrusionPool(rStart, rEnd:rEnd)
        XCTAssert(pool == expected)
    }
    
    func rippleTestHelper(nodes:[TileRect], rStart:Int, rEnd:Int, expected:Set<DiscreteTileCoord>) {
        
        let shape = ShapeComponent()
        for node in nodes
        {
            shape.addNode(node)
        }
        
        let pool = shape.ripple(rStart, rEnd:rEnd)
        XCTAssert(pool == expected)
    }
}
