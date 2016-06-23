//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation


class GABuildLevel : QQTask
{
    var flowMap:Set<DiscreteTileCoord>
    
    override init()
    {
        flowMap = Set<DiscreteTileCoord>()
        super.init()
        
        ////////////////////////////////////////////////////////////
        // Input ()
        ////////////////////////////////////////////////////////////
        
        ////////////////////////////////////////////////////////////
        // Output ()
        ////////////////////////////////////////////////////////////
    }
    
    ////////////////////////////////////////////////////////////
    // Task
    override func apply()
    {
//        if let canvas = canvas
//        {
//            if flowMap.count > 0
//            {
//                mutate()
////                canvas.swapFlowNodes(flowMap)
//            }
//            else
//            {
//                randomGen()
////                canvas.swapFlowNodes(flowMap)
//            }
//        }
    }
    
    func randomGen()
    {
        if let canvas = canvas
        {
            let bounds = canvas.canvasBounds()
            
            flowMap.removeAll()
            
            for _ in 0...50
            {
                flowMap.insert(bounds.randomCoord())
            }
        }
    }
    
    func mutate()
    {
        if let canvas = canvas
        {
            let bounds = canvas.canvasBounds()
            
            var nodesToRemove = [DiscreteTileCoord]()
            var nodesToAdd = [DiscreteTileCoord]()
            
            for node in flowMap
            {
                if (!pointIsValid(node, bounds:bounds))
                {
                    // Randomly mutate
                    let new_x = node.x + randIntBetween(-1, stop:1)
                    let new_y = node.y + randIntBetween(-1, stop:1)
                    let newNode = DiscreteTileCoord(x:new_x, y:new_y)
                    
                    if (bounds.contains(newNode))
                    {
                        nodesToRemove.append(node)
                        nodesToAdd.append(newNode)
                        break
                    }
                }
            }
            
            for node in nodesToRemove
            {
                flowMap.remove(node)
            }
            
            for node in nodesToAdd
            {
                flowMap.insert(node)
            }
        }
    }
    
    func pointIsValid(center:DiscreteTileCoord, bounds:TileRect) -> Bool
    {
        var valid = false
        if (innerNeighborhoodIsClear(center, bounds:bounds))
        {
            if (outerNeighborhoodIsValid(center, bounds:bounds))
            {
                valid = true
            }
        }
        
        return valid
    }
    
    func outerNeighborhoodIsValid(center:DiscreteTileCoord, bounds:TileRect) -> Bool
    {
        let north = center.up().up()
        let east = center.right().right()
        let south = center.down().down()
        let west = center.left().left()
        
        let aligned = [north, east, south, west]
        
        var clear = true
        for neighbor in mooreNeighborhood(center, radius:2)
        {
            if bounds.contains(neighbor)
            {
                if (!aligned.contains(neighbor))
                {
                    if flowMap.contains(neighbor)
                    {
                        clear = false
                        break
                    }
                }
            }
        }
        
        if (clear)
        {
            clear = false
            for cardinal in aligned
            {
                if flowMap.contains(cardinal)
                {
                    clear = true
                }
            }
        }
        
        return clear
    }
    
    func innerNeighborhoodIsClear(center:DiscreteTileCoord, bounds:TileRect) -> Bool
    {
        var clear = true
        for neighbor in mooreNeighborhood(center, radius:1)
        {
            if bounds.contains(neighbor)
            {
                if flowMap.contains(neighbor)
                {
                    clear = false
                    break
                }
            }
        }
        
        return clear
    }
    
    func mooreNeighborhood(center:DiscreteTileCoord, radius:Int) -> Set<DiscreteTileCoord>
    {
        var neighborhood = Set<DiscreteTileCoord>()
        for x in center.x-radius...center.x+radius
        {
            for y in center.y-radius...center.y+radius
            {
                let neighbor = DiscreteTileCoord(x:x, y:y)
                if (radiusFromCenter(center, point:neighbor) > radius-1)
                {
                    neighborhood.insert(DiscreteTileCoord(x:x, y:y))
                }
            }
        }
        
        return neighborhood
    }
    
    func radiusFromCenter(center:DiscreteTileCoord, point:DiscreteTileCoord) -> Int
    {
        let delta_x = abs(center.x - point.x)
        let delta_y = abs(center.y - point.y)
        return max(delta_x, delta_y)
    }
}