//
//  ComponentLayoutPhenotype.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 5/21/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ComponentLayout
{
    private var componentCenters:Set<DiscreteTileCoord>
    
    init()
    {
        componentCenters = Set<DiscreteTileCoord>()
    }
    
    func allCenters() -> [DiscreteTileCoord]
    {
        return Array(componentCenters)
    }
    
    // Clears and generates a random component layout with <count> component centers
    func scramble(area:TileRect, count:Int)
    {
        componentCenters.removeAll()
        
        var adjustedCount = count
        if (count > area.volume())
        {
            adjustedCount = area.volume()
        }
        
        var availablePositions = area.allCoords()
        for _ in 0..<adjustedCount
        {
            if let componentCenter = availablePositions.randomElement()
            {
                availablePositions.remove(componentCenter)
                componentCenters.insert(componentCenter)
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // BASIC MANIPULATION
    //////////////////////////////////////////////////////////////////////////////////////////
    func addComponent(componentCenter:DiscreteTileCoord)
    {
        componentCenters.insert(componentCenter)
    }
    
    func moveComponentCenter(source:DiscreteTileCoord, destination:DiscreteTileCoord) -> Bool
    {
        var success = false
        
        if componentCenters.contains(source)
        {
            if !componentCenters.contains(destination)
            {
                componentCenters.remove(source)
                componentCenters.insert(destination)
                success = true
            }
        }
        
        return success
    }
    
    func randomComponent() -> DiscreteTileCoord?
    {
        return componentCenters.randomElement()
    }
    
    func randomComponents(subsetCount:Int) -> Set<DiscreteTileCoord>
    {
        return componentCenters.randomSubset(subsetCount)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // GENETIC MUTATION
    //////////////////////////////////////////////////////////////////////////////////////////
    func mutate(scope:Double, area:TileRect)
    {
        let maxComponentsToMutate = Int(floor(Double(componentCenters.count) * scope))
        
        for _ in 0..<maxComponentsToMutate
        {
            mutateRandomComponent(area)
        }
    }
    
    func mutateRandomComponent(area:TileRect)
    {
        let maximumAttempts = 10
        
        var attempt = 0
        var mutationSuccessful = false
        
        while (!mutationSuccessful && attempt < maximumAttempts)
        {
            if let source = randomComponent()
            {
                let destination = area.randomCoord()
                if moveComponentCenter(source, destination:destination)
                {
                    mutationSuccessful = true
                }
            }
            
            attempt += 1
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // EVALUATION CRITERIA
    //////////////////////////////////////////////////////////////////////////////////////////
    func evaluation_distanceFromAreaCenter(area:TileRect) -> Histogram
    {
        let distances = componentSquareDistancesFromPoint(area.center())
        let histogram = Histogram(values:distances)
        histogram.reBinValues(5, valueRange:nil)
        
        return histogram
    }
    
    func evaluation_distanceFromClusterCenter() -> Histogram
    {
        let center = componentClusterCenter()
        let distances = componentSquareDistancesFromPoint(center)
        let histogram = Histogram(values:distances)
        histogram.reBinValues(5, valueRange:nil)
        
        return histogram
    }
    
    func evaluation_localStats() -> (neighbors:Histogram, distances:Histogram, angles:Histogram)
    {
        let stats = localStats()
        
        let neighborCountHistogram = Histogram(values:stats.neighbors)
        let neighborDistanceHistogram = Histogram(values:stats.distances)
        let neighborAngleHistogram = Histogram(values:stats.angles)
        
        neighborCountHistogram.reBinValues(5, valueRange:nil)
        neighborDistanceHistogram.reBinValues(5, valueRange:nil)
        neighborAngleHistogram.reBinValues(5, valueRange:nil)
        
        return (neighbors:neighborCountHistogram, distances:neighborDistanceHistogram, angles:neighborAngleHistogram)
    }
    
    func localStats() -> (neighbors:[Double], distances:[Double], angles:[Double])
    {
        var neighborCounts = [Double]()
        var neighborDistances = [Double]()
        var angles = [Double]()
        
        for componentCenter in componentCenters
        {
            let cartesianNeighbors = nearestCartesianNeighbors(componentCenter)
            
            if (cartesianNeighbors.count > 0)
            {
                let neighborCount = Double(cartesianNeighbors.count)
                let distance = componentCenter.absDistance(cartesianNeighbors[0])
                
                neighborCounts.append(neighborCount)
                neighborDistances.append(distance)
                
                for neighbor in cartesianNeighbors
                {
                    let angle = angleBetweenCoords(componentCenter, p2:neighbor)
                    angles.append(angle)
                }
            }
        }
        
        return (neighbors:neighborCounts, distances:neighborDistances, angles:angles)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func nearestSquareNeighbors(center:DiscreteTileCoord) -> [DiscreteTileCoord]
    {
        var nearestNeighborDistance:Int?
        var neighbors = [(distance:Int, center:DiscreteTileCoord)]()
        for neighbor in componentCenters
        {
            if (center != neighbor)
            {
                let distance = center.squareDistance(neighbor)
                if let _ = nearestNeighborDistance
                {
                    if (distance < nearestNeighborDistance)
                    {
                        nearestNeighborDistance = distance
                    }
                }
                else
                {
                    nearestNeighborDistance = distance
                }
                
                neighbors.append(distance:distance, center:neighbor)
            }
        }
        
        var nearestNeighbors = [DiscreteTileCoord]()
        if let nearestNeighborDistance = nearestNeighborDistance
        {
            for neighbor in neighbors
            {
                if (neighbor.distance == nearestNeighborDistance)
                {
                    nearestNeighbors.append(neighbor.center)
                }
            }
        }
        
        return nearestNeighbors
    }
    
    func nearestCartesianNeighbors(center:DiscreteTileCoord) -> [DiscreteTileCoord]
    {
        var nearestNeighborDistance:Double?
        var neighbors = [(distance:Double, center:DiscreteTileCoord)]()
        for neighbor in componentCenters
        {
            if (center != neighbor)
            {
                let distance = center.absDistance(neighbor)
                if let _ = nearestNeighborDistance
                {
                    if (distance < nearestNeighborDistance)
                    {
                        nearestNeighborDistance = distance
                    }
                }
                else
                {
                    nearestNeighborDistance = distance
                }
                
                neighbors.append(distance:distance, center:neighbor)
            }
        }
        
        var nearestNeighbors = [DiscreteTileCoord]()
        if let nearestNeighborDistance = nearestNeighborDistance
        {
            for neighbor in neighbors
            {
                if (neighbor.distance == nearestNeighborDistance)
                {
                    nearestNeighbors.append(neighbor.center)
                }
            }
        }
        
        return nearestNeighbors
    }
    
    func componentClusterCenter() -> DiscreteTileCoord
    {
        var clusterCenter_x = 0.0
        var clusterCenter_y = 0.0
        
        for componentCenter in componentCenters
        {
            clusterCenter_x = clusterCenter_x + Double(componentCenter.x)
            clusterCenter_y = clusterCenter_y + Double(componentCenter.y)
        }
        
        let x = Int(floor(clusterCenter_x / Double(componentCenters.count)))
        let y = Int(floor(clusterCenter_y / Double(componentCenters.count)))
        
        return DiscreteTileCoord(x:x, y:y)
    }
    
    func componentAbsDistancesFromPoint(point:DiscreteTileCoord) -> [Double]
    {
        var distances = [Double]()
        for componentCenter in componentCenters
        {
            let dist = point.absDistance(componentCenter)
            distances.append(dist)
        }
        
        return distances
    }
    
    func componentSquareDistancesFromPoint(point:DiscreteTileCoord) -> [Double]
    {
        var distances = [Double]()
        
        for componentCenter in componentCenters
        {
            let dist = point.squareDistance(componentCenter)
            distances.append(Double(dist))
        }
        
        return distances
    }
}
