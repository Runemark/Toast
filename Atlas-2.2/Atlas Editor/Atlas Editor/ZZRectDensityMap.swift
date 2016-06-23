//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ZZRectDensityMap : QQTask
{
    var density:DensityMap
    var densityBounds:TileRect
    var uncheckedCoordinates:Queue<DiscreteTileCoord>
    var validSet:Set<Int>
    
    var waitingForVisuals:Bool = false
    
    var initialized:Bool = false
    
    override init()
    {
        self.density = DensityMap(bounds:TileRect(left:0, right:0, up:0, down:0))
        self.densityBounds = TileRect(left:0, right:0, up:0, down:0)
        self.uncheckedCoordinates = Queue<DiscreteTileCoord>()
        
        self.validSet = Set([0])
        
        super.init()
        
        ////////////////////////////////////////////////////////////
        // Input ()
        ////////////////////////////////////////////////////////////
        context.defineInput("rect", type:QQVariableType.RECT)
        
        ////////////////////////////////////////////////////////////
        // Output ()
        ////////////////////////////////////////////////////////////
        context.defineOutput("density", type:QQVariableType.DENSITYMAP)
    }
    
    ////////////////////////////////////////////////////////////
    // Task
    override func apply()
    {
        // Cannot proceed unless all inputs are initialized
        if (context.allInputsInitialized())
        {
            if (!initialized)
            {
                let rect = context.getLocalRect("rect")!
                
                densityBounds = rect
                density = DensityMap(bounds:densityBounds)
                
                for x in densityBounds.left...densityBounds.right
                {
                    for y in densityBounds.down...densityBounds.up
                    {
                        let coord = DiscreteTileCoord(x:x, y:y)
                        uncheckedCoordinates.enqueue(coord)
                    }
                }
                
                initialized = true
            }
            else
            {
                for _ in 1...30
                {
                    if let nextCoord = uncheckedCoordinates.dequeue()
                    {
                        recalculateDensityAt(nextCoord)
                    }
                }
                
                if (uncheckedCoordinates.count == 0)
                {
                    // ~Register~ the density
                    let densityId = context.setGlobalDensityMap(density)
                    context.initializeVariable("density", id:densityId)
                }
            }
        }
    }
    
    func recalculateDensityAt(coord:DiscreteTileCoord)
    {
        // Expand radially until no further match is found
        let maxIncrement = maxValidIncrement(coord, startingIncrement:0)
        let maxRadius = cornerIncrementToRadius(maxIncrement)
        
        if (maxRadius > 0)
        {
            density.setDensity(coord, density:maxRadius)
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
            currentIncrement += 1
            
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
        
        if (densityBounds.contains(coord))
        {
            // In a solid rect, we don't care about the content values (so long as it's within bounds)
            validity = true
        }
        
        return validity
    }
}