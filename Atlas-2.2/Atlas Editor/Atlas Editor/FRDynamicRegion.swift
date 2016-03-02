//
//  FRDynamicRegion.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/27/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class FRDynamicRegion
{
    var coords:Set<DiscreteTileCoord>
    var bounds:TileRect?
    
    init()
    {
        coords = Set<DiscreteTileCoord>()
    }
    
    func insertCoord(coord:DiscreteTileCoord)
    {
        coords.insert(coord)
        
        if let _ = bounds
        {
            if (coord.x > bounds!.right)
            {
                bounds!.right = coord.x
            }
            else if (coord.x < bounds!.left)
            {
                bounds!.left = coord.x
            }
            
            if (coord.y > bounds!.up)
            {
                bounds!.up = coord.y
            }
            else if (coord.y < bounds!.down)
            {
                bounds!.down = coord.y
            }
        }
        else
        {
            bounds = TileRect(left:coord.x, right:coord.x, up:coord.y, down:coord.y)
        }
    }
    
    func atomicMap() -> AtomicMap<Bool>
    {
        let width = (bounds != nil) ? bounds!.width() : 0
        let height = (bounds != nil) ? bounds!.height() : 0
        let x_offset = (bounds != nil) ? bounds!.left : 0
        let y_offset = (bounds != nil) ? bounds!.down : 0
        let offset = DiscreteTileCoord(x:x_offset, y:y_offset)
        
        let map = AtomicMap<Bool>(xMax:width, yMax:height, filler:false, offset:offset)
        
        for coord in coords
        {
            map[coord] = true
        }
        
        return map
    }
}