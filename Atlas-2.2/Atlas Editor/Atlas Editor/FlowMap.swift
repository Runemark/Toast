//
//  FlowMap.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 4/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

enum RangeMatch
{
    case OVER, UNDER, WITHIN
}

enum FlowMapPropertyType
{
    case INTERNAL_COHESION, EXTERNAL_COHESION, ANGLE
}

struct FlowMapProperty
{
    var propertyType:FlowMapPropertyType
    var range:(min:Int, max:Int)
}

class FlowMap
{
    var nodes:[DiscreteTileCoord:FlowNode]
    var freeCoords:Set<DiscreteTileCoord>
    var bounds:TileRect
    var nodeProperties:[FlowMapProperty]
    var globalProperties:[FlowMapProperty]
    
    init(bounds:TileRect, nodeProperties:[FlowMapProperty], globalProperties:[FlowMapProperty])
    {
        self.bounds = bounds
        self.nodes = [DiscreteTileCoord:FlowNode]()
        self.freeCoords = Set<DiscreteTileCoord>()
        self.nodeProperties = nodeProperties
        self.globalProperties = globalProperties
        
        for coord in bounds.allCoords()
        {
            freeCoords.insert(coord)
        }
    }
    
    func freeCoordsWithinRect(rect:TileRect) -> [DiscreteTileCoord]
    {
        var freeRelevantCoords = [DiscreteTileCoord]()
        for coord in rect.allCoords()
        {
            if (freeCoords.contains(coord))
            {
                freeRelevantCoords.append(coord)
            }
        }
        
        return freeRelevantCoords
    }
    
    func unoccupiedRandomWithinRect(rect:TileRect) -> DiscreteTileCoord?
    {
        return freeCoordsWithinRect(rect).randomElement()
    }
    
    func unoccupiedRandom() -> DiscreteTileCoord?
    {
        return freeCoords.randomElement()
    }
    
    func generateUnoccupiedNodeWithinRect(strength:Int, rect:TileRect) -> FlowNode?
    {
        var generatedNode:FlowNode?
        if let center = unoccupiedRandomWithinRect(rect)
        {
            generatedNode = addNode(center, strength:strength)
        }
        else if let center = unoccupiedRandom()
        {
            generatedNode = addNode(center, strength:strength)
        }
        return generatedNode
    }
    
    func generateUnoccupiedNode(strength:Int) -> FlowNode?
    {
        var generatedNode:FlowNode?
        if let center = unoccupiedRandom()
        {
            generatedNode = addNode(center, strength:strength)
        }
        return generatedNode
    }
    
    func connectNode(a:FlowNode, b:FlowNode)
    {
        if (a.center != b.center)
        {
            a.connections.append(b)
            b.connections.append(a)
        }
    }
    
    func addNode(node:FlowNode) -> FlowNode?
    {
        var newNode:FlowNode?
        if let _ = nodes[node.center]
        {
            
        }
        else
        {
            newNode = node
            nodes[newNode!.center] = newNode!
            freeCoords.remove(newNode!.center)
        }
        return newNode
    }
    
    func addNode(center:DiscreteTileCoord, strength:Int) -> FlowNode?
    {
        var newNode:FlowNode?
        if let _ = nodes[center]
        {
            
        }
        else
        {
            newNode = FlowNode(center:center, strength:strength)
            nodes[center] = newNode
            freeCoords.remove(center)
        }
        return newNode
    }
    
    func nudgeNode(node:FlowNode)
    {
        let oldPos = node.center
        let areaOfInfluence = TileRect(left:oldPos.x-2, right:oldPos.x+2, up:oldPos.y+2, down:oldPos.y-2)
        if let newPos = unoccupiedRandomWithinRect(areaOfInfluence)
        {
            node.center = newPos
            nodes.removeValueForKey(oldPos)
            nodes[newPos] = node
            freeCoords.remove(newPos)
            freeCoords.insert(oldPos)
        }
    }
    
    func randomNode() -> FlowNode?
    {
        var node:FlowNode?
        if let nodeInfo = Array(nodes).randomElement()
        {
            node = nodeInfo.1
        }
        
        return node
    }
    
    func randomizedNodeCenters() -> [DiscreteTileCoord]
    {
        var keys = [DiscreteTileCoord]()
        for key in nodes.keys
        {
            keys.append(key)
        }
        
        keys.sortInPlace { (a, b) -> Bool in
            arc4random() % 2 == 0
        }
        
        return keys
    }
    
    func improveExternalCohesion(cohesion:(min:Int, max:Int)) -> Bool
    {
        for coord_a in randomizedNodeCenters()
        {
            if let node_a = nodes[coord_a]
            {
                // Get me the closest non-connected node
                var shortestNonConnectionDist = 10000;
                var shortestNonConnectionNode:FlowNode?
                let connectionSet = Set(node_a.connections.map({$0.center}))
                for (coord_b, node_b) in nodes
                {
                    // Non-self, Non-connection
                    if (coord_a != coord_b && !connectionSet.contains(coord_b))
                    {
                        let squareDist = node_a.edgeSquareDist(node_b)
                        if (squareDist < shortestNonConnectionDist)
                        {
                            shortestNonConnectionDist = squareDist
                            shortestNonConnectionNode = node_b
                        }
                    }
                }
                
                if let node_b = shortestNonConnectionNode
                {
                    let edgeSquareDist = node_a.edgeSquareDist(node_b)
                    var newPos = coord_a
                    if edgeSquareDist < cohesion.min
                    {
                        // Nudge it further
                        newPos = coord_a.farthestNeighborToPoint(node_b.center)
                    }
                    else if edgeSquareDist > cohesion.max
                    {
                        // Nudge it closer
                        newPos = coord_a.closestNeighborToPoint(node_b.center)
                    }
                    
                    if (!edgeSquareDist.inRange(cohesion))
                    {
                        if (freeCoords.contains(newPos))
                        {
                            node_a.center = newPos
                            nodes.removeValueForKey(coord_a)
                            nodes[newPos] = node_a
                            freeCoords.remove(newPos)
                            freeCoords.insert(coord_a)
                        }
                        else
                        {
                            nudgeNode(node_a)
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    func improveInternalCohesion(cohesion:(min:Int, max:Int)) -> Bool
    {
        // Look for a node with poor internal cohesion
        for coord_a in randomizedNodeCenters()
        {
            if let node_a = nodes[coord_a]
            {
                // Returns an array of tuples containing information about connections 
                // that fall outside of the cohesion range
                var greatestDelta = -1000
                var greatestDeltaInfo:(connection:FlowNode, direction:RangeMatch, delta:Int, angle:Int)?
                for mismatchInfo in node_a.internalCohesionMismatches(cohesion)
                {
                    if (mismatchInfo.delta > greatestDelta)
                    {
                        greatestDelta = mismatchInfo.delta
                        greatestDeltaInfo = mismatchInfo
                    }
                }
                
                let mismatches = node_a.internalCohesionMismatches(cohesion)
                if (mismatches.count > 0)
                {
                    let info = mismatches.first!
                    let direction = info.direction
                    let counterpoint = info.connection.center
                    
                    let newPos = (direction == RangeMatch.OVER) ? coord_a.closestNeighborToPoint(counterpoint) : coord_a.farthestNeighborToPoint(counterpoint)
                    if (freeCoords.contains(newPos))
                    {
                        node_a.center = newPos
                        nodes.removeValueForKey(coord_a)
                        nodes[newPos] = node_a
                        freeCoords.remove(newPos)
                        freeCoords.insert(coord_a)
                    }
                    else
                    {
                        nudgeNode(node_a)
                    }
                }
            }
            break
        }
        
        return true
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // FILTERS
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Internal Coehsion is the DISTANCE between CENTERS
    func nodeWithoutInternalCohesion(cohesion:(min:Int, max:Int)) -> FlowNode?
    {
        var offender:FlowNode?
        
        improveInternalCohesion(cohesion)
        
        for coord_a in randomizedNodeCenters()
        {
            if let node_a = nodes[coord_a]
            {
                if node_a.propertyValue(nodeProperties) < 1.0
                {
                    break
                }
            }
        }
        
        return offender
    }
    
    func validateExternalCohesion(node:FlowNode, cohesion:(min:Int, max:Int)) -> Bool
    {
        var shortestNonConnectionDist = 10000;
        let connectionSet = Set(node.connections.map({$0.center}))
        let coord_a = node.center
        for (coord_b, node_b) in nodes
        {
            // Non-self, Non-connection
            if (coord_a != coord_b && !connectionSet.contains(coord_b))
            {
                let squareDist = node.edgeSquareDist(node_b)
                if (squareDist < shortestNonConnectionDist)
                {
                    shortestNonConnectionDist = squareDist
                }
            }
        }
        
        return shortestNonConnectionDist.inRange(cohesion)
    }
    
    // External Cohesion is the EDGE-DISTANCE between VOLUMES:
    func nodeWithoutExternalCohesion(cohesion:(min:Int, max:Int)) -> FlowNode?
    {
        var offender:FlowNode?
        
        for coord_a in randomizedNodeCenters()
        {
            if let node_a = nodes[coord_a]
            {
                if (!validateExternalCohesion(node_a, cohesion:cohesion))
                {
                    offender = node_a
                    break
                }
            }
        }
        
        return offender
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // GENERATORS
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func populateWithUniformThread(count:Int, strength:Int)
    {
        if (bounds.volume() >= count)
        {
            var oldNode:FlowNode?
            for _ in 0..<count-1
            {
                if let newNode = generateUnoccupiedNode(strength)
                {
                    addNode(newNode)
                    
                    if let oldNode = oldNode
                    {
                        connectNode(oldNode, b:newNode)
                    }
                    
                    oldNode = newNode
                }
            }
        }
    }
    
    func populateWithRandomThreaded(count:Int)
    {
        var large = true
        
        if (bounds.volume() >= count)
        {
            var oldNode:FlowNode?
            for _ in 0..<count-1
            {
                let newStrength = (large) ? 1 : 2
                if let newNode = generateUnoccupiedNode(newStrength)
                {
                    addNode(newNode)
                    
                    if let oldNode = oldNode
                    {
                        connectNode(oldNode, b:newNode)
                    }
                    
                    oldNode = newNode
                }
                
                large = !large
            }
        }
    }
}