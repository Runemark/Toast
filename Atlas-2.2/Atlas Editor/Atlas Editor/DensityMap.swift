//
//  DensityMap.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/23/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class DensityMap
{
    var map:AtomicMap<Int>
    var registry:[Int:Set<DiscreteTileCoord>]
    var bounds:TileRect
    
    init(bounds:TileRect)
    {
        self.bounds = bounds
        
        map = AtomicMap(xMax:bounds.width(), yMax:bounds.height(), filler:0, offset:DiscreteTileCoord(x:0, y:0))
        registry = [Int:Set<DiscreteTileCoord>]()
    }
    
    func clearAll()
    {
        map.reset()
        registry.removeAll()
    }
    
    func orderedStrengths() -> [Int]
    {
        return Array(registry.keys).sort({ (a, b) -> Bool in
            return a > b
        })
    }
    
    func density(coord:DiscreteTileCoord) -> Int
    {
        if map.isWithinBounds(coord.x, y:coord.y)
        {
            return map[coord]
        }
        else
        {
            return 0
        }
    }
    
    func setDensity(coord:DiscreteTileCoord, density:Int)
    {
        let oldDensity = map[coord]
        
        if (oldDensity != density)
        {
            map[coord] = density
            
            if (density > 0)
            {
                if (oldDensity == 0)
                {
                    updateRegistry(coord, density:density)
                }
                else
                {
                    // WARXING: TODO
                }
            }
            else
            {
                // Changed to zero (WARXING: NEED TO REMOVE FROM DATA)
            }
        }
    }
    
    func updateRegistry(coord:DiscreteTileCoord, density:Int)
    {
        if (density > 0)
        {
            if let _ = registry[density]
            {
                registry[density]!.insert(coord)
            }
            else
            {
                registry[density] = Set([coord])
            }
        }
        else
        {
            // Density is zero, we need to remove it somehow? WARXING: PROBLEMS
        }
    }
}