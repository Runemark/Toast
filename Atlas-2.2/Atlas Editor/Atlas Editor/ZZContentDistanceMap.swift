//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ZZContentDistanceMap : QQTask
{
    var density:DensityMap
    var densityBounds:TileRect
    var validSet:Set<Int>
    
    var content:Set<DiscreteTileCoord>
    var expandedContent:Set<DiscreteTileCoord>
    var leadingEdge:Set<DiscreteTileCoord>
    var currentDistance:Int = 0
    
    var initialized:Bool = false
    
    override init()
    {
        self.density = DensityMap(bounds:TileRect(left:0, right:0, up:0, down:0))
        self.densityBounds = TileRect(left:0, right:0, up:0, down:0)
        
        self.content = Set<DiscreteTileCoord>()
        self.expandedContent = Set<DiscreteTileCoord>()
        self.leadingEdge = Set<DiscreteTileCoord>()
        
        self.validSet = Set([0])
        
        super.init()
        
        ////////////////////////////////////////////////////////////
        // Input ()
        ////////////////////////////////////////////////////////////
        
        ////////////////////////////////////////////////////////////
        // Output ()
        ////////////////////////////////////////////////////////////
        context.defineOutput("distance", type:QQVariableType.ATOMICMAP)
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
                initializeStage()
            }
            else
            {
                expansionStage()
                
                
//                if (uncheckedCoordinates.count == 0)
//                {
//                    print("~~ Density: [Complete]")
//                    // ~Register~ the density
//                    
//                    let densityId = QQWorkingMemory.sharedInstance.registerDensityMap(density)
//                    context.initializeVariable("density", id:densityId)
//                    
//                    success = true
//                    
//                    complete()
//                }
            }
        }
    }
    
    func initializeStage()
    {
        if let canvas = canvas
        {
            densityBounds = canvas.canvasBounds()
            density = DensityMap(bounds:densityBounds)
            
            content = baseContent()
            
            leadingEdge = expandedContent.subtract(content)
            
            // The leading edge will have a strength of 1
            
            initialized = true
            
            print("~~ Distance: Initialized")
        }
    }
    
    func expansionStage()
    {
        // Increment the current distance
        currentDistance++
        
        // Expand once
        expandedContent = expandContent(content)
        // Take just the edges
        leadingEdge = expandedContent.subtract(content)
        
        // WARXING: Special case with no content, all "distances" will be zero
        // Is this a problem? Well, paired with the density map, it actually WONT be a problem.
        if (leadingEdge.count == 0)
        {
            print("~~ Distance: [Comlete]")
            
            let distanceId = QQWorkingMemory.sharedInstance.registerDensityMap(density)
            context.initializeVariable("distance", id:distanceId)
            
            success = true
            complete()
        }
        else
        {
            print("~~ Distance: Leading Edge @ \(currentDistance)")
            
            for coord in leadingEdge
            {
                density.setDensity(coord, density:currentDistance)
            }
            
            content = expandedContent
        }
    }
    
    func baseContent() -> Set<DiscreteTileCoord>
    {
        var content = Set<DiscreteTileCoord>()
        
        if let canvas = canvas
        {
            for x in densityBounds.left...densityBounds.right
            {
                for y in densityBounds.down...densityBounds.up
                {
                    let coord = DiscreteTileCoord(x:x, y:y)
                    let value = canvas.atomicValueAt(coord)
                    
                    if (value > 0)
                    {
                        content.insert(coord)
                    }
                }
            }
        }
        
        return content
    }
    
    func expandContent(content:Set<DiscreteTileCoord>) -> Set<DiscreteTileCoord>
    {
        var expanded = Set<DiscreteTileCoord>()
        
        for coord in content
        {
            let neighborhood = generateImmediateValidMooreNeighborhood(coord)
            expanded.unionInPlace(neighborhood)
        }
        
        return expanded
    }
    
    func generateImmediateValidMooreNeighborhood(center:DiscreteTileCoord) -> Set<DiscreteTileCoord>
    {
        var neighborhood = Set<DiscreteTileCoord>()
        
        for x in center.x-1...center.x+1
        {
            for y in center.y-1...center.y+1
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                if (densityBounds.contains(coord))
                {
                    neighborhood.insert(coord)
                }
            }
        }
        
        return neighborhood
    }
}