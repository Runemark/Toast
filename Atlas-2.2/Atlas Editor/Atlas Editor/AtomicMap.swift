//
//  Array2D.swift
//  Atlas
//
//  Created by Dusty Artifact on 10/2/15.
//  Copyright © 2015 Runemark Studios. All rights reserved.
//

import Foundation

////////////////////////////////////////////////////////////////////////////////
// Matrix2D
////////////////////////////////////////////////////////////////////////////////

public class AtomicMap<T>
{
    var xMax:Int = 0
    var yMax:Int = 0
    var matrix:[T]
    var filler:T
    var offset:DiscreteTileCoord
    
    init(xMax:Int, yMax:Int, filler:T, offset:DiscreteTileCoord)
    {
        self.xMax = xMax
        self.yMax = yMax
        self.filler = filler
        self.offset = offset
        matrix = Array<T>(count:xMax*yMax, repeatedValue:filler)
    }
    
    // The ABSOLUTE COORD desired
    subscript(coord:DiscreteTileCoord) -> T
    {
        get
        {
            let relativeCoord = coord - offset
            
            if (isWithinBounds(relativeCoord.x, y:relativeCoord.y))
            {
                return matrix[(xMax * relativeCoord.y) + relativeCoord.x]
            }
            else
            {
                return filler
            }
        }
        set
        {
            let relativeCoord = coord - offset
            
            if (isWithinBounds(relativeCoord.x, y:relativeCoord.y))
            {
                matrix[(xMax * relativeCoord.y) + relativeCoord.x] = newValue
            }
        }
    }
    
    // The RELATIVE position desired
    subscript(x:Int, y:Int) -> T
    {
        get
        {
            if (isWithinBounds(x, y:y))
            {
                return matrix[(xMax * y) + x]
            }
            else
            {
                return filler
            }
        }
        set
        {
            if (isWithinBounds(x, y:y))
            {
                matrix[(xMax * y) + x] = newValue
            }
        }
    }
    
    func reset()
    {
        matrix = Array<T>(count:xMax*yMax, repeatedValue:filler)
    }
    
    // ABSOLUTE position
    func isWithinBounds(coord:DiscreteTileCoord) -> Bool
    {
        let relativePosition = coord - offset
        return isWithinBounds(relativePosition.x, y:relativePosition.y)
    }
    
    // RELATIVE position
    func isWithinBounds(x:Int, y:Int) -> Bool
    {
        return (x >= 0 && y >= 0 && x < xMax && y < yMax)
    }
    
    // ABSOLUTE coordaintes
    func allCoords() -> Set<DiscreteTileCoord>
    {
        var coords = Set<DiscreteTileCoord>()
        
        for x in 0..<xMax
        {
            for y in 0..<yMax
            {
                let relativeCoord = DiscreteTileCoord(x:x, y:y)
                let absoluteCoord = relativeCoord + offset
                
                coords.insert(absoluteCoord)
            }
        }
        
        return coords
    }
}