//
//  SkeletonMap.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/23/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class SkeletonNode : Hashable
{
    var center:DiscreteTileCoord
    var strength:Int
    
    var hashValue:Int
    {
        return "\(center.hashValue),\(strength)".hashValue
    }
    
    init(center:DiscreteTileCoord, strength:Int)
    {
        self.center = center
        self.strength = strength
    }
    
    func influence() -> Set<DiscreteTileCoord>
    {
        let radius = Int(floor(Double(strength - 1)/2.0))
        
        var influenceCoordinates = Set<DiscreteTileCoord>()
        
        for x in center.x-radius...center.x+radius
        {
            for y in center.y-radius...center.y+radius
            {
                influenceCoordinates.insert(DiscreteTileCoord(x:x, y:y))
            }
        }
        
        return influenceCoordinates
    }
    
    func influenceRect() -> TileRect
    {
        let radius = Int(floor(Double(strength - 1)/2.0))
        
        return TileRect(left:center.x-radius, right:center.x+radius, up:center.y+radius, down:center.y-radius)
    }
}

func ==(lhs:SkeletonNode, rhs:SkeletonNode) -> Bool
{
    return lhs.center == rhs.center && lhs.strength == rhs.strength
}

class SkeletonMap
{
    var bounds:TileRect
    var nodes:[DiscreteTileCoord:SkeletonNode]
    var influences:[DiscreteTileCoord:Set<SkeletonNode>]
    
    init(bounds:TileRect)
    {
        self.bounds = bounds
        nodes = [DiscreteTileCoord:SkeletonNode]()
        influences = [DiscreteTileCoord:Set<SkeletonNode>]()
    }
    
    // Returns whether the node was successfully added
    func addNode(node:SkeletonNode) -> Bool
    {
        var success = false
        
        if let obstacleNode = nodes[node.center]
        {
            nodes[node.center] = node
            
            if (node.strength > obstacleNode.strength)
            {
                // Replace it
                removeNodeAt(node.center)
                
                nodes[node.center] = node
                addNodeToInfluences(node)
            }
        }
        else
        {
            if (shouldAddNode(node))
            {
                // Remove all nodes which are completely enclosed by the new node's influence
                for influenceCoord in node.influence()
                {
                    if let existingNode = nodes[influenceCoord]
                    {
                        if node.influenceRect().completelyContains(existingNode.influenceRect())
                        {
                            removeNodeAt(influenceCoord)
                        }
                    }
                }
                
                success = true
                // Add to skeleton
                nodes[node.center] = node
                // Add to influence map
                addNodeToInfluences(node)
            }
        }
        
        return success
    }
    
    func removeNodeAt(coord:DiscreteTileCoord)
    {
        if let existingNode = nodes[coord]
        {
            nodes.removeValueForKey(coord)
            removeInfluenceForNode(existingNode)
        }
    }
    
    func removeInfluenceForNode(node:SkeletonNode)
    {
        for influenceCoord in node.influence()
        {
            removeInfluence(node, coord:influenceCoord)
        }
    }
    
    func removeInfluence(node:SkeletonNode, coord:DiscreteTileCoord)
    {
        // If there ARE nodes influencing the target coord...
        if let _ = influences[coord]
        {
            // Remove the offending node, if it exists
            influences[coord]!.remove(node)
        }
    }
    
    func shouldAddNode(node:SkeletonNode) -> Bool
    {
        var shouldAdd = true
        // First thing, cehck to see if this node is overshadowed by some other existing node
        if let influencingNodes = influences[node.center]
        {
            let newRect = node.influenceRect()
            // influencingNodes is a list of nodes which influence the current position
            for influencingNode in influencingNodes
            {
                // Does it overshadow us?
                let existingRect = influencingNode.influenceRect()
                if (existingRect.completelyContains(newRect))
                {
                    shouldAdd = false
                    break
                }
            }
        }
        
        return shouldAdd
    }
    
    func addNodeToInfluences(node:SkeletonNode)
    {
        for influenceCoord in node.influence()
        {
            if let _ = influences[influenceCoord]
            {
                influences[influenceCoord]!.insert(node)
            }
            else
            {
                influences[influenceCoord] = Set([node])
            }
        }
    }
    
    // Lowest to highest
    func orderedStrengths() -> [Int]
    {
        var strengths = Set<Int>()
        
        for (_, node) in nodes
        {
            strengths.insert(node.strength)
        }
        
        return Array(strengths).sort()
    }
    
    // Will return all cells which are influenced by a node of strength GREATER THAN the threshold.
    // Valid cells will be set to true, all others will be set to false
    func dropoutMap(threshold:Int) -> AtomicMap<Bool>
    {
        let dropout = AtomicMap<Bool>(xMax:bounds.width(), yMax:bounds.height(), filler:false, offset:DiscreteTileCoord(x:0, y:0))
        
        for (_, node) in nodes
        {
            if (node.strength > threshold)
            {
                for coord in node.influence()
                {
                    dropout[coord] = true
                }
            }
        }
        
        return dropout
    }
}