//
//  ShapeComponent.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 6/13/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ShapeComponent
{
    var boundingBox:TileRect?
    var nodes:Set<TileRect>
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // INITIALIZATION
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    init()
    {
        nodes = Set<TileRect>()
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // NODE MANIPULATION
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func addNode(node:TileRect)
    {
        nodes.insert(node)
        updateBoundingBoxWithAddedNode(node)
    }
    
    func removeNode(node:TileRect)
    {
        nodes.remove(node)
        recalculateBoundingBox()
    }
    
    func augmentWithRandomNodesOfRadius(nodeRadius:Int, nodeCount:Int)
    {
        let candidates = candidatesToAddMass(nodeRadius, tight:true)
        let selectedCandidates = candidates.randomSubset(nodeCount)
        
        for selected in selectedCandidates
        {
            let node = createNode(selected, radius:nodeRadius)
            addNode(node)
        }
    }
    
    func createNode(center:DiscreteTileCoord, radius:Int) -> TileRect
    {
        return TileRect(left:center.x-radius, right:center.x+radius, up:center.y+radius, down:center.y-radius)
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // EXTRUSION AND INTRUSION SETS
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // CANDIDATES TO ADD MASS
    func candidatesToAddMass(nodeRadius:Int, tight:Bool) -> Set<DiscreteTileCoord>
    {
        let candidates = Set<DiscreteTileCoord>()
        if (nodeRadius == 1)
        {
            return ripple(1, rEnd:1)
        }
        else if (nodeRadius > 1)
        {
            let min = 0 - (nodeRadius - 1)
            let max = (tight) ? (nodeRadius - 1) : nodeRadius
            
            return ripple(min, rEnd:max)
        }
        
        return candidates
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // SHAPE MASS
    func shapeMass() -> Set<DiscreteTileCoord>
    {
        var mass = Set<DiscreteTileCoord>()
        
        for node in nodes
        {
            mass.unionInPlace(node.allCoords())
        }
        
        return mass
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // RIPPLE POOL (INCLUDES BOTH EXTRUSIONS AND INTRUSIONS)
    // @param rStart Int the starting radius of inset. Must be 1 or more.
    //  -1: 1-tile inset
    //   0: actual edge of shape
    //   1: 1-tile offset
    func ripple(rStart:Int, rEnd:Int) -> Set<DiscreteTileCoord>
    {
        var pool = Set<DiscreteTileCoord>()
        
        if (rStart <= rEnd)
        {
            // is there an extrusion component?
            if (rStart > 0 || rEnd > 0)
            {
                let extrusionStart = max(1, rStart)
                let extrusionEnd = max(rStart, rEnd)
                
                pool.unionInPlace(extrusionPool(extrusionStart, rEnd:extrusionEnd))
            }
            
            // is there an intrusion component?
            if (rStart < 1 || rEnd < 1)
            {
                let intrusionStart = min(0, rEnd)
                let intrusionEnd = -1*min(rStart, rEnd)
                
                pool.unionInPlace(intrusionPool(intrusionStart, rEnd:intrusionEnd))
            }
        }
        
        return pool
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // EXTRUSION POOL
    // @param rStart Int the starting radius of inset. Must be 1 or more.
    //  1: 1-tile offset
    //  2: 2-tile offset...
    // @param rEnd Int the ending radius of the inset. Must be 1 or more.
    //  1: 1-tile offset
    //  2: 2-tile offset...
    func extrusionPool(rStart:Int, rEnd:Int) -> Set<DiscreteTileCoord>
    {
        var pool = Set<DiscreteTileCoord>()
        
        if (rStart <= rEnd && rStart > 0)
        {
            var mass = shapeMass()
            if (mass.count > 0)
            {
                for index in 1...rEnd
                {
                    for coord in mass
                    {
                        let neighborhood = coord.neighborhood().filter({ (neighbor) -> Bool in
                            return !mass.contains(neighbor)
                        })
                        pool.unionInPlace(neighborhood)
                    }
                    
                    if (index < rEnd)
                    {
                        mass.unionInPlace(pool)
                    }
                    
                    if (index < rStart)
                    {
                        pool.removeAll()
                    }
                }
            }
        }
        
        return pool
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // INTRUSION POOL
    // @param rStart Int the starting radius of inset. Must be 0 or more.
    //  0: actual edge of the shape
    //  1: 1-tile inset of the shape...
    // @param rEnd Int the ending radius of the inset. Must be 0 or more.
    //  1: 1-tile inset of the shape
    //  2: 2-tile inset of the shape...
    func intrusionPool(rStart:Int, rEnd:Int) -> Set<DiscreteTileCoord>
    {
        var pool = Set<DiscreteTileCoord>()
        var layerPool = Set<DiscreteTileCoord>()
        
        if (rStart <= rEnd && rStart >= 0)
        {
            var mass = shapeMass()
            if (mass.count > 0)
            {
                for index in 0...rEnd
                {
                    // All tiles within the mass which have an open edge
                    layerPool = Set(mass.filter({
                        $0.neighborhood().filter({
                            !mass.contains($0)
                        }).count > 0
                    }))
                    
                    if (index < rEnd)
                    {
                        mass.subtractInPlace(layerPool)
                    }
                    
                    if (index >= rStart)
                    {
                        pool.unionInPlace(layerPool)
                    }
                }
            }
        }
        
        return pool
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // BOUNDING BOX
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Recalculate Bounding Box
    //  recalculates the true bounding box from scratch
    func recalculateBoundingBox()
    {
        boundingBox = nil
        for node in nodes
        {
            updateBoundingBoxWithAddedNode(node)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Update Bounding Box with Added Node
    //  incrementally recalculates the bounding box using the newest added node
    func updateBoundingBoxWithAddedNode(node:TileRect)
    {
        if let _ = boundingBox
        {
            if (node.left < boundingBox!.left)
            {
                boundingBox!.left = node.left
            }
            if (node.right > boundingBox!.right)
            {
                boundingBox!.right = node.right
            }
            if (node.up > boundingBox!.up)
            {
                boundingBox!.up = node.up
            }
            if (node.down < boundingBox!.down)
            {
                boundingBox!.down = node.down
            }
        }
        else
        {
            boundingBox = node
        }
    }
}