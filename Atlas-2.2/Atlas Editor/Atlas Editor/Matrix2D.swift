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

public class Matrix2D<T>
{
    var xMax:Int = 0
    var yMax:Int = 0
    var matrix:[T]
    
    init(xMax:Int, yMax:Int, filler:T)
    {
        self.xMax = xMax
        self.yMax = yMax
        matrix = Array<T>(count:xMax*yMax, repeatedValue:filler)
    }
    
    subscript(coord:DiscreteTileCoord) -> T?
    {
        get
        {
            var value:T?
            
            if (isWithinBounds(coord.x, y:coord.y))
            {
                value = matrix[(xMax * coord.y) + coord.x]
            }
            
            return value
        }
        set
        {
            if (isWithinBounds(coord.x, y:coord.y))
            {
                matrix[(xMax * coord.y) + coord.x] = newValue!
            }
        }
    }
    
    subscript(x:Int, y:Int) -> T?
    {
        get
        {
            var value:T?
            
            if (isWithinBounds(x, y:y))
            {
                value = matrix[(xMax * y) + x]
            }
            
            return value
        }
        set
        {
            if (isWithinBounds(x, y:y))
            {
                matrix[(xMax * y) + x] = newValue!
            }
        }
    }
    
    func isWithinBounds(x:Int, y:Int) -> Bool
    {
        return (x >= 0 && y >= 0 && x < xMax && y < yMax)
    }
}