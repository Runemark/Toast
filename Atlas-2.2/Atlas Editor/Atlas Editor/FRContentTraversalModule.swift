//
//  FRContentTraversalModule.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/27/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class FRContentTraversalModule
{
    var content:AtomicMap<Bool>
    var unexplored:Set<DiscreteTileCoord>
    
    var regions:[FRDynamicRegion]
    
    init(content:AtomicMap<Bool>)
    {
        self.content = content
        self.unexplored = Set<DiscreteTileCoord>()
        self.regions = [FRDynamicRegion]()
        
        for x in content.offset.x..<content.offset.x + content.xMax
        {
            for y in content.offset.y..<content.offset.y + content.yMax
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                unexplored.insert(coord)
            }
        }
    }
    
    func activate() -> [FRDynamicRegion]
    {
        // Traverse the content
        
        while (unexplored.count > 0)
        {
            // Pick a random, unexplored coordinate
            if let nextCoord = unexplored.randomElement()
            {
                traverseInNewRegion(nextCoord)
            }
        }
        
        return regions
    }
    
    func traverseInNewRegion(origin:DiscreteTileCoord)
    {
        var newRegion = FRDynamicRegion()
        
        traverse(origin, region:&newRegion)
        
        if (newRegion.coords.count > 0)
        {
            regions.append(newRegion)
        }
    }
    
    func traverse(origin:DiscreteTileCoord, inout region:FRDynamicRegion)
    {
        if (cellIsValid(origin))
        {
            unexplored.remove(origin)
            
            region.insertCoord(origin)
            
            traverse(origin.up(), region:&region)
            traverse(origin.right(), region:&region)
            traverse(origin.down(), region:&region)
            traverse(origin.left(), region:&region)
        }
        else
        {
            unexplored.remove(origin)
        }
    }
    
    func cellIsValid(origin:DiscreteTileCoord) -> Bool
    {
        return content.isWithinBounds(origin) && content[origin] && unexplored.contains(origin)
    }
}