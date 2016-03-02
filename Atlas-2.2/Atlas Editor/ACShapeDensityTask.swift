//
//  ACCalculateShapeDensityTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/20/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

enum AnalysisPhase
{
    case UNINITIALIZED, DENSITY, SKELETON_PREP, SKELETON, WAIT, RESET
}

// Analyzes the BASE LAYER and creates a density map
class ACShapeDensityTask : ACTask
{
    var importantTiles:Set<Int>
    var densityMap:DensityMap?
    var coordinatesToInspect:Queue<DiscreteTileCoord>
    
    var skeletonMap:SkeletonMap
    
    var phase:AnalysisPhase = AnalysisPhase.UNINITIALIZED
    
    init(importantTiles:Set<Int>)
    {
        self.importantTiles = importantTiles
        self.coordinatesToInspect = Queue<DiscreteTileCoord>()
        // WARXING: BAD BOUNDS
        self.skeletonMap = SkeletonMap(bounds:TileRect(left:0, right:0, up:0, down:0))
        
        super.init()
    }
    
    override func apply()
    {
        if let canvas = canvas
        {
            if (phase == .UNINITIALIZED)
            {
                canvas.dimMapLayer()
                
                let bounds = canvas.modelMapLayerBounds()
                densityMap = DensityMap(bounds:bounds)
                let orderedCoordinateList = bounds.orderedCoordinateList()
                let orderedFilteredCoordinateList = orderedCoordinateList.filter({importantTiles.contains(canvas.terrainValueAt($0))})
                for coord in orderedFilteredCoordinateList
                {
                    coordinatesToInspect.enqueue(coord)
                }
                
                phase = .DENSITY
            }
            else if (phase == .DENSITY)
            {
                for _ in 1...10
                {
                    if let nextCoord = coordinatesToInspect.dequeue()
                    {
                        recalculateDensityAt(nextCoord)
                    }
                }
                
                if coordinatesToInspect.count == 0
                {
                    phase = .SKELETON_PREP
                    canvas.hideMapLayer()
                }
            }
            else if (phase == .SKELETON_PREP)
            {
                // Check the strengths, from highest to lowest
                for strength in densityMap!.orderedStrengths()
                {
                    // Check all coordinates with that strength
                    let coordinatesOfStrength = densityMap!.registry[strength]!
                    for coord in coordinatesOfStrength
                    {
                        coordinatesToInspect.enqueue(coord)
                    }
                }
                
                phase = .SKELETON
            }
            else if (phase == .SKELETON)
            {
                for _ in 1...5
                {
                    if let nextCoord = coordinatesToInspect.dequeue()
                    {
                        recalculateSkeletonAt(nextCoord)
                    }
                }
                
                if coordinatesToInspect.count == 0
                {
                    complete()
                }
            }
        }
    }
    
    func recalculateSkeletonAt(coord:DiscreteTileCoord)
    {
        if let canvas = canvas
        {
            let node = SkeletonNode(center:coord, strength:densityMap!.density(coord))
            if skeletonMap.addNode(node)
            {
                canvas.addSkeletonNode(node)
            }
        }
    }
    
    func recalculateDensityAt(coord:DiscreteTileCoord)
    {
        if let canvas = canvas
        {
            // Expand radially until no further match is found
            let maxIncrement = maxValidIncrement(coord, startingIncrement:0)
            let maxRadius = cornerIncrementToRadius(maxIncrement)
            
            if (maxRadius > 0)
            {
                densityMap!.setDensity(coord, density:maxRadius)
                canvas.setDensityAt(coord, density:maxRadius)
            }
        }
    }
    
    // Assumes that the provided startingIncrement is VALID
    func maxValidIncrement(center:DiscreteTileCoord, startingIncrement:Int) -> Int
    {
        var validity = true
        var maxValidIncrement = startingIncrement
        var currentIncrement = startingIncrement
        
        while (validity)
        {
            currentIncrement++
            
            if (validNeighborhood(center, increment:currentIncrement))
            {
                maxValidIncrement = currentIncrement
            }
            else
            {
                validity = false
            }
        }
        
        return maxValidIncrement
    }
    
    func cornerIncrementToRadius(increment:Int) -> Int
    {
        return 2*increment + 1
    }
    
    func radiusToCornerIncrement(radius:Int) -> Int
    {
        return Int(floor(Double(radius - 1) / 2.0))
    }
    
    func validNeighborhood(center:DiscreteTileCoord, increment:Int) -> Bool
    {
        if (increment == 0)
        {
            return validMatch(center)
        }
        else
        {
            var validity = true
            
            let corners = generateCorners(center, increment:increment)
            
            for corner in corners
            {
                if (!validMatch(corner))
                {
                    validity = false
                    break
                }
            }
            
            if (validity)
            {
                // So far the corners are all valid. Now check the non-corners in the neighborhood
                let neighborhood = generateCornerlessMooreNeighborhood(center, increment:increment)
                
                for neighbor in neighborhood
                {
                    if (!validMatch(neighbor))
                    {
                        validity = false
                        break
                    }
                }
            }
            
            return validity
        }
    }
    
    // Corners are always returned in the following order: [UpperLeft, UpperRight, LowerRight, LowerLeft]
    func generateCorners(center:DiscreteTileCoord, increment:Int) -> [DiscreteTileCoord]
    {
        var corners = [DiscreteTileCoord]()
        
        if (increment > 0)
        {
            let upperLeftCorner = DiscreteTileCoord(x:center.x - increment, y:center.y + increment)
            let upperRightCorner = DiscreteTileCoord(x:center.x + increment, y:center.y + increment)
            let lowerRightCorner = DiscreteTileCoord(x:center.x + increment, y:center.y - increment)
            let lowerLeftCorner = DiscreteTileCoord(x:center.x - increment, y:center.y - increment)
            
            corners.append(upperLeftCorner)
            corners.append(upperRightCorner)
            corners.append(lowerRightCorner)
            corners.append(lowerLeftCorner)
        }
        
        return corners
    }
    
    func generateCornerlessMooreNeighborhood(center:DiscreteTileCoord, increment:Int) -> [DiscreteTileCoord]
    {
        var cornerlessMooreNeighborhood = [DiscreteTileCoord]()
        
        let corners = generateCorners(center, increment:increment)
        if (corners.count == 4)
        {
            for x in corners[0].x+1..<corners[1].x
            {
                cornerlessMooreNeighborhood.append(DiscreteTileCoord(x:x, y:corners[0].y))
                cornerlessMooreNeighborhood.append(DiscreteTileCoord(x:x, y:corners[3].y))
            }
            
            for y in corners[2].y+1..<corners[1].y
            {
                cornerlessMooreNeighborhood.append(DiscreteTileCoord(x:corners[1].x, y:y))
                cornerlessMooreNeighborhood.append(DiscreteTileCoord(x:corners[3].x, y:y))
            }
        }
        
        return cornerlessMooreNeighborhood
    }
    
    func validMatch(coord:DiscreteTileCoord) -> Bool
    {
        var validity = false
        
        if (canvas!.modelMapLayerBounds().contains(coord))
        {
            let value = canvas!.terrainValueAt(coord)
            if importantTiles.contains(value)
            {
                validity = true
            }
        }
        
        return validity
    }
}