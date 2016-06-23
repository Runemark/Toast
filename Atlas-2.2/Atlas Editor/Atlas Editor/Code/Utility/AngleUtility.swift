//
//  AngleUtility.swift
//  Hexed
//
//  Created by Martin Mumford on 10/31/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

func angleBetweenCoords(p1:DiscreteTileCoord, p2:DiscreteTileCoord) -> Double
{
    let cgPoint1 = CGPointMake(CGFloat(p1.x), CGFloat(p1.y))
    let cgPoint2 = CGPointMake(CGFloat(p2.x), CGFloat(p2.y))
    return angleBetweenPoints(cgPoint1, p2:cgPoint2)
}

func angleBetweenPoints(p1:CGPoint, p2:CGPoint) -> Double
{
    let deltaX = Double(p2.x - p1.x)
    let deltaY = Double(p2.y - p1.y)
    
    var angleInDegrees = atan2(deltaY, deltaX) * (180 / M_PI)
    
    if (angleInDegrees < 0.0)
    {
        angleInDegrees += 360
    }
    
    return angleInDegrees
}

func angleBetweenPoints(p1:DiscreteTileCoord, p2:DiscreteTileCoord) -> Double
{
    let point_1 = CGPointMake(CGFloat(p1.x), CGFloat(p1.y))
    let point_2 = CGPointMake(CGFloat(p2.x), CGFloat(p2.y))
    
    return angleBetweenPoints(point_1, p2:point_2)
}

func angleDifference(a1:Double, a2:Double) -> Double
{
    var diff = a2 - a1
    
    if (diff < 180)
    {
        diff += 360
    }
    else if (diff > 180)
    {
        diff -= 360
    }
    
    return diff
}

func radialDelta(angleInRad:Double, radius:Double) -> CGPoint
{
    let radialDeltaX = cos(angleInRad) * radius
    let radialDeltaY = sin(angleInRad) * radius
    
    return CGPointMake(CGFloat(radialDeltaX), CGFloat(radialDeltaY))
}

func degToRad(deg:Double) -> Double
{
    return deg * (M_PI / 180.0)
}

func radToDeg(rad:Double) -> Double
{
    return rad * (180.0 / M_PI)
}