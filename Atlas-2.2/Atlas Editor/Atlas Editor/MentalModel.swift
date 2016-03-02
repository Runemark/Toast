//
//  MentalModel.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/4/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class Node : Hashable
{
    var center:DiscreteTileCoord
    var value:Int
    var strength:Int
    
    var hashValue:Int
    {
        return "(\(center):\(value):\(strength))".hashValue
    }
    
    init(center:DiscreteTileCoord, value:Int, strength:Int)
    {
        self.center = center
        self.value = value
        self.strength = strength
    }
    
    func area() -> TileRect
    {
        let radius = (strength - 1) / 2
        
        let left = center.x - radius
        let right = center.x + radius
        let up = center.y + radius
        let down = center.y - radius
        
        return TileRect(left:left, right:right, up:up, down:down)
    }
}

func ==(lhs:Node, rhs:Node) -> Bool
{
    return lhs.center == rhs.center && lhs.value == rhs.value && lhs.strength == rhs.strength
}

protocol MentalModelObserver
{
    func shapeNodeRemovedAt(coord:DiscreteTileCoord)
    func shapeNodeAddedAt(coord:DiscreteTileCoord, node:Node)
    func shapeStrengthChangedAt(coord:DiscreteTileCoord, strength:Int, oldStrength:Int)
}

class MentalModel
{
    var shapeInfluenceMap:[DiscreteTileCoord:Set<Node>]
    var shapeSkeleton:[DiscreteTileCoord:Node]
    var shapeMap:AtomicMap<Int> // Largest possible shape node strength for each tile
    var atomicMap:AtomicMap<Int> // Literal tile values
    
    var observer:MentalModelObserver?
    
    init(size:TileRectSize)
    {
        atomicMap = AtomicMap<Int>(xMax:size.width, yMax:size.height, filler:0, offset:DiscreteTileCoord(x:0, y:0))
        shapeMap = AtomicMap<Int>(xMax:size.width, yMax:size.height, filler:0, offset:DiscreteTileCoord(x:0, y:0))
        shapeSkeleton = [DiscreteTileCoord:Node]()
        shapeInfluenceMap = [DiscreteTileCoord:Set<Node>]()
    }
    
    func registerObserver(observer:MentalModelObserver)
    {
        self.observer = observer
    }
    
    func changeTile(coord:DiscreteTileCoord, tileValue:Int)
    {
        if (tileValue >= 0)
        {
            if (atomicMap.isWithinBounds(coord.x, y:coord.y))
            {
                let oldValue = atomicMap[coord]
                if (oldValue != tileValue)
                {
                    atomicMap[coord] = tileValue
                    updateShapeMapForChangeAt(coord, oldValue:oldValue)
                }
            }
        }
    }
    
    func updateShapeMapForChangeAt(coord:DiscreteTileCoord, oldValue:Int)
    {
        if let previousInfluences = shapeInfluenceMap[coord]
        {
            let previousInfluencesOfOldType = previousInfluences.filter({$0.value == oldValue})
            
            var oldCoordsToMerge = Set<DiscreteTileCoord>()
            // Wipe all previous influences of the old type
            for previousInfluence in previousInfluencesOfOldType
            {
                removeNodeFromShapeSkeleton(previousInfluence)
                
                for coord in previousInfluence.area().allCoords()
                {
                    oldCoordsToMerge.insert(coord)
                }
            }
            
            for oldCoord in oldCoordsToMerge
            {
                merge(oldCoord)
            }
        }
        
        merge(coord)
    }
    
    func merge(coord:DiscreteTileCoord)
    {
        let value = atomicMap[coord]
        
        if (value > 0)
        {
            updateShapeMap(coord, strength:1)
            addNodeToShapeSkeleton(Node(center:coord, value:atomicMap[coord], strength:1))
            
            var aggregationLimitReached = false
            var aggregations = aggregate(coord, aggregateImmediately:true)
            var aggregateStrength = 3
            
            while (!aggregationLimitReached)
            {
                if (aggregations.count == 0)
                {
                    aggregationLimitReached = true
                    break
                }
                else
                {
                    var nextAggregations = Set<DiscreteTileCoord>()
                    for aggregationPoint in aggregations
                    {
                        let aggregationsForPoint = aggregate(aggregationPoint, aggregateImmediately:false)
                        for nextAggregationPoint in aggregationsForPoint
                        {
                            nextAggregations.insert(nextAggregationPoint)
                        }
                    }
                    
                    aggregations.removeAll()
                    for nextAggregationPoint in nextAggregations
                    {
                        updateShapeMap(nextAggregationPoint, strength:aggregateStrength)
                        aggregations.insert(nextAggregationPoint)
                    }
                    
                    aggregateStrength += 2
                }
            }
        }
        else
        {
            updateShapeMap(coord, strength:0)
            
            if let node = shapeSkeleton[coord]
            {
                removeNodeFromShapeSkeleton(node)
            }
        }
    }
    
    func updateShapeMap(coord:DiscreteTileCoord, strength:Int)
    {
        let oldStrength = shapeMap[coord]

        shapeMap[coord] = strength
        
        if let observer = observer
        {
            observer.shapeStrengthChangedAt(coord, strength:strength, oldStrength:oldStrength)
        }
        
        // Aggregation has occurred
        if (strength > oldStrength)
        {
            let value = atomicMap[coord]
            let node = Node(center:coord, value:value, strength:strength)
            addNodeToShapeSkeleton(node)
        }
    }
    
    func addNodeToShapeSkeleton(node:Node)
    {
        
        let shouldAddSkeletonNode = true
        
        // Only add a key skeleton node if the CENTER is not being influenced by a larger node
        // (This is actually not quite as 'human-like' as I had hoped. Disabling for now)
//        if let influences = shapeInfluenceMap[node.center]
//        {
//            let largerInfluences = influences.filter({$0.strength > node.strength})
//            if (largerInfluences.count > 0)
//            {
//                shouldAddSkeletonNode = false
//            }
//        }
        
        if (shouldAddSkeletonNode)
        {
            // Remove smaller skeleton nodes
            if (node.strength > 1)
            {
                for enclosedNode in nodesCompletelyEnclosedByNode(node)
                {
                    removeNodeFromShapeSkeleton(enclosedNode)
                }
            }
            
            shapeSkeleton[node.center] = node
            addNodeToInfluenceMap(node)
            
            if let observer = observer
            {
                observer.shapeNodeAddedAt(node.center, node:node)
            }
        }
    }
    
    func removeNodeFromShapeSkeleton(node:Node)
    {
        if let _ = shapeSkeleton[node.center]
        {
            shapeSkeleton.removeValueForKey(node.center)
            removeNodeFromInfluenceMap(node)
            
            if let observer = observer
            {
                observer.shapeNodeRemovedAt(node.center)
            }
        }
    }
    
    func nodesCompletelyEnclosedByNode(node:Node) -> Set<Node>
    {
        var enclosedNodes = Set<Node>()
        
        for coord in node.area().allCoords()
        {
            if let existingNode = shapeSkeleton[coord]
            {
                if (node.area().completelyContains(existingNode.area()))
                {
                    enclosedNodes.insert(existingNode)
                }
            }
        }
        
        return enclosedNodes
    }
    
    func addNodeToInfluenceMap(node:Node)
    {
        for coord in node.area().allCoords()
        {
            addInfluenceAt(coord, influence:node)
        }
    }
    
    func removeNodeFromInfluenceMap(node:Node)
    {
        for coord in node.area().allCoords()
        {
            removeInfluenceAt(coord, influence:node)
        }
    }
    
    func addInfluenceAt(coord:DiscreteTileCoord, influence:Node)
    {
        if let influencingNodes = shapeInfluenceMap[coord]
        {
            if !influencingNodes.contains(influence)
            {
                shapeInfluenceMap[coord]!.insert(influence)
            }
        }
        else
        {
            var influences = Set<Node>()
            influences.insert(influence)
            shapeInfluenceMap[coord] = influences
        }
    }
    
    func removeInfluenceAt(coord:DiscreteTileCoord, influence:Node)
    {
        if let _ = shapeInfluenceMap[coord]
        {
            shapeInfluenceMap[coord]!.remove(influence)
            
            if (shapeInfluenceMap[coord]!.count == 0)
            {
                shapeInfluenceMap.removeValueForKey(coord)
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Aggregation Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    
    // Finds any positions needing aggregation within a 5x5 radius of the origin
    //  A position needs aggregating if it forms a 3x3 square of matching tile values and strengths
    // Returns any positions that were aggregated, or an empty set if none were necessary
    func aggregate(origin:DiscreteTileCoord, aggregateImmediately:Bool) -> Set<DiscreteTileCoord>
    {
        let left = origin.left()
        let right = origin.right()
        let up = origin.up()
        let down = origin.down()
        let upperLeft = up.left()
        let upperRight = up.right()
        let lowerLeft = down.left()
        let lowerRight = down.right()
        
        var checkLeft = true
        var checkRight = true
        var checkUp = true
        var checkDown = true
        
        var checkUpperLeft = true
        var checkUpperRight = true
        var checkLowerLeft = true
        var checkLowerRight = true
        
        var checkCenter = true
        
        let matchingValue = atomicMap[origin]
        let strength = shapeMap[origin]
        let aggregateStrength = strength + 2
        
        if !isValidMatch(up, atomicValue:matchingValue, strength:strength)
        {
            checkCenter = false
            checkUp = false
            checkRight = false
            checkLeft = false
            checkUpperLeft = false
            checkUpperRight = false
        }
        
        if !isValidMatch(down, atomicValue:matchingValue, strength:strength)
        {
            checkCenter = false
            checkDown = false
            checkLeft = false
            checkRight = false
            checkLowerLeft = false
            checkLowerRight = false
        }
        
        if !isValidMatch(left, atomicValue:matchingValue, strength:strength)
        {
            checkCenter = false
            checkLeft = false
            checkUp = false
            checkDown = false
            checkUpperLeft = false
            checkLowerLeft = false
        }
        
        if !isValidMatch(right, atomicValue:matchingValue, strength:strength)
        {
            checkCenter = false
            checkRight = false
            checkUp = false
            checkDown = false
            checkUpperRight = false
            checkLowerRight = false
        }
        
        if !isValidMatch(upperLeft, atomicValue:matchingValue, strength:strength)
        {
            checkCenter = false
            checkUp = false
            checkLeft = false
            checkUpperLeft = false
        }
        
        if !isValidMatch(upperRight, atomicValue:matchingValue, strength:strength)
        {
            checkCenter = false
            checkUp = false
            checkRight = false
            checkUpperRight = false
        }
        
        if !isValidMatch(lowerLeft, atomicValue:matchingValue, strength:strength)
        {
            checkCenter = false
            checkDown = false
            checkLeft = false
            checkLowerLeft = false
        }
        
        if !isValidMatch(lowerRight, atomicValue:matchingValue, strength:strength)
        {
            checkCenter = false
            checkDown = false
            checkRight = false
            checkLowerRight = false
        }
        
        var aggregatedCoordinates = Set<DiscreteTileCoord>()
        
        if (checkCenter)
        {
            aggregatedCoordinates.insert(origin)
        }
        
        if (checkLeft && shouldAggregateLeft(origin, value:matchingValue, strength:strength))
        {
            aggregatedCoordinates.insert(left)
        }
        
        if (checkRight && shouldAggregateRight(origin, value:matchingValue, strength:strength))
        {
            aggregatedCoordinates.insert(right)
        }
        
        if (checkUp && shouldAggregateUp(origin, value:matchingValue, strength:strength))
        {
            aggregatedCoordinates.insert(up)
        }
        
        if (checkDown && shouldAggregateDown(origin, value:matchingValue, strength:strength))
        {
            aggregatedCoordinates.insert(down)
        }
        
        if (checkUpperLeft && shouldAggregateUpperLeft(origin, value:matchingValue, strength:strength))
        {
            aggregatedCoordinates.insert(upperLeft)
        }
        
        if (checkUpperRight && shouldAggregateUpperRight(origin, value:matchingValue, strength:strength))
        {
            aggregatedCoordinates.insert(upperRight)
        }
        
        if (checkLowerLeft && shouldAggregateLowerLeft(origin, value:matchingValue, strength:strength))
        {
            aggregatedCoordinates.insert(lowerLeft)
        }
        
        if (checkLowerRight && shouldAggregateLowerRight(origin, value:matchingValue, strength:strength))
        {
            aggregatedCoordinates.insert(lowerRight)
        }
        
        if (aggregateImmediately)
        {
            for aggregatedCoordinate in aggregatedCoordinates
            {
                updateShapeMap(aggregatedCoordinate, strength:aggregateStrength)
            }
        }
        
        return aggregatedCoordinates
    }
    
    func shouldAggregateLeft(origin:DiscreteTileCoord, value:Int, strength:Int) -> Bool
    {
        let relativeCoords = [
            DiscreteTileCoord(x:-2, y:-1),
            DiscreteTileCoord(x:-2, y:0),
            DiscreteTileCoord(x:-2, y:1)]
        
        return relativeCoordsAreValid(relativeCoords, offset:origin, value:value, strength:strength)
    }
    
    func shouldAggregateRight(origin:DiscreteTileCoord, value:Int, strength:Int) -> Bool
    {
        let relativeCoords = [
            DiscreteTileCoord(x:2, y:-1),
            DiscreteTileCoord(x:2, y:0),
            DiscreteTileCoord(x:2, y:1)]
        
        return relativeCoordsAreValid(relativeCoords, offset:origin, value:value, strength:strength)
    }
    
    func shouldAggregateUp(origin:DiscreteTileCoord, value:Int, strength:Int) -> Bool
    {
        let relativeCoords = [
            DiscreteTileCoord(x:-1, y:2),
            DiscreteTileCoord(x:0, y:2),
            DiscreteTileCoord(x:1, y:2)]
        
        return relativeCoordsAreValid(relativeCoords, offset:origin, value:value, strength:strength)
    }
    
    func shouldAggregateDown(origin:DiscreteTileCoord, value:Int, strength:Int) -> Bool
    {
        let relativeCoords = [
            DiscreteTileCoord(x:-1, y:-2),
            DiscreteTileCoord(x:0, y:-2),
            DiscreteTileCoord(x:1, y:-2)]
        
        return relativeCoordsAreValid(relativeCoords, offset:origin, value:value, strength:strength)
    }
    
    func shouldAggregateUpperLeft(origin:DiscreteTileCoord, value:Int, strength:Int) -> Bool
    {
        let relativeCoords = [
            DiscreteTileCoord(x:-2, y:0),
            DiscreteTileCoord(x:-2, y:1),
            DiscreteTileCoord(x:-2, y:2),
            DiscreteTileCoord(x:-1, y:2),
            DiscreteTileCoord(x:0, y:2)]
        
        return relativeCoordsAreValid(relativeCoords, offset:origin, value:value, strength:strength)
    }
    
    func shouldAggregateUpperRight(origin:DiscreteTileCoord, value:Int, strength:Int) -> Bool
    {
        let relativeCoords = [
            DiscreteTileCoord(x:0, y:2),
            DiscreteTileCoord(x:1, y:2),
            DiscreteTileCoord(x:2, y:2),
            DiscreteTileCoord(x:2, y:1),
            DiscreteTileCoord(x:2, y:0)]
        
        return relativeCoordsAreValid(relativeCoords, offset:origin, value:value, strength:strength)
    }
    
    func shouldAggregateLowerLeft(origin:DiscreteTileCoord, value:Int, strength:Int) -> Bool
    {
        let relativeCoords = [
            DiscreteTileCoord(x:-2, y:0),
            DiscreteTileCoord(x:-2, y:-1),
            DiscreteTileCoord(x:-2, y:-2),
            DiscreteTileCoord(x:-1, y:-2),
            DiscreteTileCoord(x:0, y:-2)]
        
        return relativeCoordsAreValid(relativeCoords, offset:origin, value:value, strength:strength)
    }
    
    func shouldAggregateLowerRight(origin:DiscreteTileCoord, value:Int, strength:Int) -> Bool
    {
        let relativeCoords = [
            DiscreteTileCoord(x:0, y:-2),
            DiscreteTileCoord(x:1, y:-2),
            DiscreteTileCoord(x:2, y:-2),
            DiscreteTileCoord(x:2, y:-1),
            DiscreteTileCoord(x:2, y:0)]
        
        return relativeCoordsAreValid(relativeCoords, offset:origin, value:value, strength:strength)
    }
    
    func relativeCoordsAreValid(relativeCoords:[DiscreteTileCoord], offset:DiscreteTileCoord, value:Int, strength:Int) -> Bool
    {
        var valid = true
        
        for relativeCoord in relativeCoords
        {
            let absoluteCoord = relativeCoord + offset
            if !isValidMatch(absoluteCoord, atomicValue:value, strength:strength)
            {
                valid = false
                break
            }
        }
        
        return valid
    }
    
    func isValidMatch(coord:DiscreteTileCoord, atomicValue:Int, strength:Int) -> Bool
    {
        return atomicMap.isWithinBounds(coord.x, y:coord.y) && atomicMap[coord] == atomicValue && shapeMap[coord] >= strength
    }
    
    // A radius of zero will return only the center itself
    func neighborhood(center:DiscreteTileCoord, radius:Int) -> Set<DiscreteTileCoord>
    {
        var neighbors = Set<DiscreteTileCoord>()
        
        for tempRadius in 0...radius
        {
            let neighborRing = ring(center, radius:tempRadius)
            
            for coord in neighborRing
            {
                neighbors.insert(coord)
            }
        }
        
        return neighbors
    }
    
    // A radius of zero will return only the center itself
    func ring(center:DiscreteTileCoord, radius:Int) -> Set<DiscreteTileCoord>
    {
        var coordinateRing = Set<DiscreteTileCoord>()
        
        if (radius == 0)
        {
            coordinateRing.insert(DiscreteTileCoord(x:0, y:0) + center)
        }
        else
        {
            let left = -1*radius
            let right = radius
            let up = radius
            let down = -1*radius
            
            for y in down...up-1
            {
                let relativeCoord = DiscreteTileCoord(x:left, y:y)
                coordinateRing.insert(relativeCoord + center)
            }
            
            for x in left...right-1
            {
                let relativeCoord = DiscreteTileCoord(x:x, y:up)
                coordinateRing.insert(relativeCoord + center)
            }
            
            for y in (down+1...up).reverse()
            {
                let relativeCoord = DiscreteTileCoord(x:right, y:y)
                coordinateRing.insert(relativeCoord + center)
            }
            
            for x in (left+1...right).reverse()
            {
                let relativeCoord = DiscreteTileCoord(x:x, y:down)
                coordinateRing.insert(relativeCoord + center)
            }
        }
        
        return coordinateRing
    }
}