//
//  Coordinate.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/12/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

struct TileCoord:Hashable
{
    var x:Double
    var y:Double
    
    func roundDown() -> DiscreteTileCoord
    {
        return DiscreteTileCoord(x:Int(floor(x)), y:Int(floor(y)))
    }
    
    func roundUp() -> DiscreteTileCoord
    {
        return DiscreteTileCoord(x:Int(ceil(x)), y:Int(ceil(y)))
    }
    
    var hashValue:Int
        {
            return "(\(x), \(y))".hashValue
    }
}

struct DiscreteTileCoord:Hashable
{
    var x:Int
    var y:Int
    
    func makePrecise() -> TileCoord
    {
        return TileCoord(x:Double(x), y:Double(y))
    }
    
    func down() -> DiscreteTileCoord
    {
        return DiscreteTileCoord(x:x, y:y-1)
    }
    
    func up() -> DiscreteTileCoord
    {
        return DiscreteTileCoord(x:x, y:y+1)
    }
    
    func left() -> DiscreteTileCoord
    {
        return DiscreteTileCoord(x:x-1, y:y)
    }
    
    func right() -> DiscreteTileCoord
    {
        return DiscreteTileCoord(x:x+1, y:y)
    }
    
    var hashValue:Int
        {
            return "(\(x), \(y))".hashValue
    }
}

struct TileRect
{
    var left:Int
    var right:Int
    var up:Int
    var down:Int
    
    func contains(coord:DiscreteTileCoord) -> Bool
    {
        return (coord.x <= right && coord.x >= left && coord.y <= up && coord.y >= down)
    }
    
    func compare(other:TileRect) -> Bool
    {
        return (other.left == left && other.right == right && other.up == up && other.down == down)
    }
    
    func width() -> Int
    {
        return (right-left)+1
    }
    
    func height() -> Int
    {
        return (up-down)+1
    }
    
    func border() -> Set<DiscreteTileCoord>
    {
        var borderCoords = Set<DiscreteTileCoord>()
        
        for x in left...right
        {
            borderCoords.insert(DiscreteTileCoord(x:x, y:up))
            borderCoords.insert(DiscreteTileCoord(x:x, y:down))
        }
        
        for y in down...up
        {
            borderCoords.insert(DiscreteTileCoord(x:left, y:y))
            borderCoords.insert(DiscreteTileCoord(x:right, y:y))
        }
        
        return borderCoords
    }
    
    func borderContains(coord:DiscreteTileCoord) -> Bool
    {
        var isContainedOnBorder = false
        
        if (coord.x == left || coord.x == right) && (coord.y >= down && coord.y <= up)
        {
            isContainedOnBorder = true
        }
        else if (coord.y == down || coord.y == up) && (coord.x >= left && coord.x <= right)
        {
            isContainedOnBorder = true
        }
        
        return isContainedOnBorder
    }
    
    func innerRect() -> TileRect?
    {
        if (width() > 2 && height() > 2)
        {
            return TileRect(left:left+1, right:right-1, up:up-1, down:down+1)
        }
        else
        {
            return nil
        }
    }
    
    func outerRect() -> TileRect
    {
        return TileRect(left:left-1, right:right+1, up:up+1, down:down-1)
    }
    
    func lineBelowRect() -> TileRect
    {
        return TileRect(left:left, right:right, up:down-1, down:down-1)
    }
    
    func lineAboveRect() -> TileRect
    {
        return TileRect(left:left, right:right, up:up+1, down:up+1)
    }
    
    func expandBelow() -> TileRect
    {
        return TileRect(left:left, right:right, up:up, down:down-1)
    }
    
    func expandVertically() -> TileRect
    {
        return TileRect(left:left, right:right, up:up+1, down:down-1)
    }
    
    func allCoords() -> Set<DiscreteTileCoord>
    {
        var coords = Set<DiscreteTileCoord>()
        
        for x in left...right
        {
            for y in down...up
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                coords.insert(coord)
            }
        }
        
        return coords
    }
    
    func volume() -> Int
    {
        return width()*height()
    }
    
    // Higher negative fractions (up to 1) mean more vertical stretch
    // Higher positive fractions (up to 1) mean more horizontal stretch
    // Zero means a square
    func absoluteProportionality() -> Double
    {
        let w = Double(width())
        let h = Double(height())
        
        let verticalProportions = (w / h)
        let horizontalProportions = (h / w)
        
        var significantProportions = 0.0
        
        if (verticalProportions < horizontalProportions)
        {
            significantProportions = 1.0 - verticalProportions
        }
        else
        {
            significantProportions = 1.0 - horizontalProportions
        }
        
        return significantProportions
    }
}



func +(lhs:TileCoord, rhs:TileCoord) -> TileCoord
{
    return TileCoord(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
}

func -(lhs:TileCoord, rhs:TileCoord) -> TileCoord
{
    return TileCoord(x:lhs.x - rhs.x, y:lhs.y - rhs.y)
}

func ==(lhs:TileCoord, rhs:TileCoord) -> Bool
{
    return (lhs.x == rhs.x) && (lhs.y == rhs.y)
}

func +=(inout lhs:TileCoord, rhs:TileCoord)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
}

func +(lhs:DiscreteTileCoord, rhs:DiscreteTileCoord) -> DiscreteTileCoord
{
    return DiscreteTileCoord(x:lhs.x + rhs.x, y:lhs.y + rhs.y)
}

func -(lhs:DiscreteTileCoord, rhs:DiscreteTileCoord) -> DiscreteTileCoord
{
    return DiscreteTileCoord(x:lhs.x - rhs.x, y:lhs.y - rhs.y)
}

func ==(lhs:DiscreteTileCoord, rhs:DiscreteTileCoord) -> Bool
{
    return (lhs.x == rhs.x) && (lhs.y == rhs.y)
}

func +=(inout lhs:DiscreteTileCoord, rhs:DiscreteTileCoord)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
}

func +(lhs:CGPoint, rhs:CGPoint) -> CGPoint
{
    return CGPointMake(lhs.x + rhs.x, lhs.y + rhs.y)
}

func -(lhs:CGPoint, rhs:CGPoint) -> CGPoint
{
    return CGPointMake(lhs.x - rhs.x, lhs.y - rhs.y)
}

func +=(inout lhs:CGPoint, rhs:CGPoint)
{
    lhs.x += rhs.x
    lhs.y += rhs.y
}

func *(lhs:CGSize, rhs:Double) -> CGSize
{
    return CGSizeMake(lhs.width*CGFloat(rhs), lhs.height*CGFloat(rhs))
}

func *(lhs:Double, rhs:CGSize) -> CGSize
{
    return CGSizeMake(rhs.width*CGFloat(lhs), rhs.height*CGFloat(lhs))
}



func screenDeltaForTileDelta(tileDelta:TileCoord, tileSize:CGSize) -> CGPoint
{
    return CGPointMake(CGFloat(tileDelta.x) * tileSize.width, CGFloat(tileDelta.y) * tileSize.height)
}

func screenCameraDeltaForCoord(coord:TileCoord, cameraInWorld:TileCoord, tileSize:CGSize) -> CGPoint
{
    let deltaInWorld = coord - cameraInWorld
    return CGPointMake(CGFloat(deltaInWorld.x) * tileSize.width, CGFloat(deltaInWorld.y) * tileSize.height)
}

func screenPosForCoord(coord:TileCoord, cameraInWorld:TileCoord, cameraOnScreen:CGPoint, tileSize:CGSize) -> CGPoint
{
    let screenCameraDelta = screenCameraDeltaForCoord(coord, cameraInWorld:cameraInWorld, tileSize:tileSize)
    return screenCameraDelta + cameraOnScreen
}

func screenPosForTileViewAtCoord(coord:TileCoord, cameraInWorld:TileCoord, cameraOnScreen:CGPoint, tileSize:CGSize) -> CGPoint
{
    let screenPos = screenPosForCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
    return screenPos + CGPointMake(CGFloat(Double(tileSize.width) / 2.0), CGFloat(Double(tileSize.height) / 2.0))
}

func screenPosForTileViewAtCoord(coord:DiscreteTileCoord, cameraInWorld:TileCoord, cameraOnScreen:CGPoint, tileSize:CGSize) -> CGPoint
{
    return screenPosForTileViewAtCoord(coord.makePrecise(), cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
}

func tileCoordForScreenPos(pos:CGPoint, cameraInWorld:TileCoord, cameraOnScreen:CGPoint, tileSize:CGSize) -> TileCoord
{
    let screenDelta = pos - cameraOnScreen
    let tileDelta = tileDeltaForScreenDelta(screenDelta, tileSize:tileSize)
    
    return cameraInWorld + tileDelta
}

func tileDeltaForScreenDelta(delta:CGPoint, tileSize:CGSize) -> TileCoord
{
    let tileDelta_x = Double(delta.x / tileSize.width)
    let tileDelta_y = Double(delta.y / tileSize.height)
    return TileCoord(x:tileDelta_x, y:tileDelta_y)
}


extension CGPoint
{
    func roundDown() -> CGPoint
    {
        return CGPointMake(floor(self.x), floor(self.y))
    }
}