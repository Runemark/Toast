//
//  Fenrir.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/26/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class Fenrir
{
    var analysisView:LKAnalysisView
    var bounds:TileRect
    var title:String
    
    init(title:String, analysisView:LKAnalysisView)
    {
        self.analysisView = analysisView
        self.bounds = TileRect(left:0, right:0, up:0, down:0)
        self.title = title
    }
    
    func isMatched(skeleton:SkeletonMap, center:DiscreteTileCoord, strength:Int) -> Bool
    {
        var matched = false
        if let rightNode = skeleton.nodes[center.right()]
        {
            if (rightNode.strength == strength)
            {
                matched = true
            }
        }
        return matched
    }
    
    func relevantConnections(connections:Set<LineSegment>, pointingAt:DiscreteTileCoord, excludingSources:[DiscreteTileCoord]) -> Array<LineSegment>
    {
        return connections.filter({
            ($0.a == pointingAt && !excludingSources.contains($0.b) ||
            $0.b == pointingAt && !excludingSources.contains($0.a))
        })
    }
    
    func nodeOfStrengthAt(coord:DiscreteTileCoord, strength:Int, allSkeletonNodes:[SkeletonNode]) -> Bool
    {
        var matchExists = false
        
        for node in allSkeletonNodes
        {
            if (node.center == coord && node.strength == strength)
            {
                matchExists = true
                break
            }
        }
        
        return matchExists
    }
    
    func getNodeForCenter(center:DiscreteTileCoord, nodes:Set<SkeletonNode>) -> SkeletonNode?
    {
        var finalNode:SkeletonNode?
        for node in nodes
        {
            if (node.center == center)
            {
                finalNode = node
                break
            }
        }
        
        return finalNode
    }
    
    func delta(a:Int, b:Int) -> Int {
        return abs(a - b)
    }
    
    func createStyleGuide() -> FRStyleGuide?
    {
        if let map = TileMapIO().importAtomicMap(title)
        {
            bounds = TileRect(left:0, right:map.xMax-1, up:map.yMax-1, down:0)
            analysisView.loadMapMetaData(bounds)
            
            let densityMap = FRDensityModule(base:map, densityBounds:bounds, validSet:Set([1,2])).activate()
            let skeleton = FRSkeletonModule(density:densityMap, bounds:bounds).activate()

            // Visualize the plain density map
            for x in densityMap.bounds.left...densityMap.bounds.right
            {
                for y in densityMap.bounds.down...densityMap.bounds.up
                {
                    let coord = DiscreteTileCoord(x:x, y:y)
                    analysisView.updateDensityNodeAt(coord, density:densityMap.density(coord))
                }
            }
            
            var allSkeletonNodes = [SkeletonNode]()
            for (_, node) in skeleton.nodes
            {
                allSkeletonNodes.append(node)
            }
            
            var filteredConnections = Set<LineSegment>()
            // [Strength : [Source : [Destinations]]]
            var filteredNodes = Set<SkeletonNode>()
            
            for a in allSkeletonNodes
            {
                // Find the potential connector nodes
                let aInfluence = a.influenceRect()
                var potentialConnections = [Int:[DiscreteTileCoord]]()
                
                for b in allSkeletonNodes
                {
                    if (a.center != b.center)
                    {
                        let bInfluence = b.influenceRect()
                        
                        if (aInfluence.intersectsWith(bInfluence) || aInfluence.adjacentTo(bInfluence))
                        {
                            if let _ = potentialConnections[b.strength]
                            {
                                potentialConnections[b.strength]!.append(b.center)
                            }
                            else
                            {
                                potentialConnections[b.strength] = [b.center]
                            }
                        }
                    }
                }
                
                var selectedConnections = Set<LineSegment>()
                for (strength, connections) in potentialConnections
                {
                    if (strength >= a.strength)
                    {
                        // Pick the nearest one(s)
                        var bestDistance = 10000.0
                        for endpoint in connections
                        {
                            let dist = a.center.absDistance(endpoint)
                            if (dist < bestDistance)
                            {
                                bestDistance = dist
                            }
                        }
                        
                        for endpoint in connections
                        {
//                            let dist = a.center.absDistance(endpoint)
//                            if (dist == bestDistance)
//                            {
                                selectedConnections.insert(LineSegment(a:a.center, b:endpoint))
                                filteredNodes.insert(a)
                                filteredNodes.insert(SkeletonNode(center:endpoint, strength:strength))
//                            }
                        }
                    }
                }
                
                filteredConnections = filteredConnections.union(selectedConnections)
            }
            
            var removedNodes = Set<SkeletonNode>()
            
            for a in filteredNodes
            {
                for b in filteredNodes
                {
                    if (!removedNodes.contains(a) && !removedNodes.contains(b))
                    {
                        if (a != b && a.strength > 1 && b.strength > 1 && a.strength == b.strength)
                        {
                            // b is directly ABOVE or to the RIGHT of a
                            if (a.center.up() == b.center || a.center.right() == b.center)
                            {
                                removedNodes.insert(b)
                                removedNodes.insert(a)
                                // Get every connection that USED to be connected to b
                                let oldConnections = relevantConnections(filteredConnections, pointingAt:b.center, excludingSources:[])
                                for oldConnection in oldConnections
                                {
                                    let oldEndpoint = (oldConnection.a == b.center) ? oldConnection.b : oldConnection.a
                                    // Remove the old connection
                                    filteredConnections.remove(oldConnection)
                                    // Rewire it into a
                                    if (a.center != oldEndpoint)
                                    {
                                        filteredConnections.insert(LineSegment(a:a.center, b:oldEndpoint))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            for removedNode in removedNodes
            {
                filteredNodes.remove(removedNode)
            }
            
            for connection in filteredConnections
            {
                analysisView.addConnection(connection)
            }
            
            

            return nil
        }
        else
        {
            print("ERROR: COULD NOT LOAD MAP")
            
            return nil
        }
    }
}