//
//  FRRegionClusterModule.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/29/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

struct Vector
{
    var vars:[Double]
    
    var length:Int
        {
        get
        {
            return vars.count
        }
    }
    
    mutating func add(other:Vector)
    {
        if (length == other.length)
        {
            for varIndex in 0..<length
            {
                vars[varIndex] = vars[varIndex] + other.vars[varIndex]
            }
        }
    }
    
    mutating func mult(other:Vector)
    {
        if (length == other.length)
        {
            for varIndex in 0..<length
            {
                vars[varIndex] = vars[varIndex] * other.vars[varIndex]
            }
        }
    }
    
    func delta(other:Vector) -> Double
    {
        var sum = 0.0
        for varIndex in 0..<length
        {
            let variableDelta = vars[varIndex] - other.vars[varIndex]
            sum += pow(variableDelta, 2.0)
        }
        
        return sqrt(sum)
    }
}

struct Cluster
{
    var elements:[Vector]
    var centroid:Vector? = nil
    
    mutating func insertElement(element:Vector)
    {
        let oldCount = elements.count
        if (oldCount < 1)
        {
            centroid = element
        }
        else
        {
            let length = centroid!.length
            
            var oldCountArray = [Double]()
            var newTotalArray = [Double]()
            for _ in 0..<length
            {
                oldCountArray.append(Double(oldCount))
                newTotalArray.append(1.0/Double(oldCount+1))
            }
            
            let oldCountVector = Vector(vars:oldCountArray)
            let newTotalVector = Vector(vars:newTotalArray)
            
            centroid!.mult(oldCountVector)
            centroid!.add(element)
            centroid!.mult(newTotalVector)
        }
        
        elements.append(element)
    }
}

class FRClusterModule
{
    var clusters:[Int:Cluster]
    
    init()
    {
        clusters = [Int:Cluster]()
    }
    
    func activate(data:[Vector])
    {
        for (index, datum) in data.enumerate()
        {
            var cluster = Cluster(elements:[], centroid:nil)
            cluster.insertElement(datum)
            
            clusters[index] = cluster
        }
    }
    
    // Returns whether a merge was successful
    func mergeClusters() -> Bool
    {
        var leastDistanceSoFar = 0.0
        var leastDistanceInitialized = false
        var bestPairSoFar:(a:Int, b:Int) = (a:-1, b:-1)
        
        for (index_a, cluster_a) in clusters
        {
            for (index_b, cluster_b) in clusters
            {
                if let centroid_a = cluster_a.centroid
                {
                    if let centroid_b = cluster_b.centroid
                    {
                        let distance = centroid_a.delta(centroid_b)
                        if (leastDistanceInitialized)
                        {
                            if (distance < leastDistanceSoFar)
                            {
                                leastDistanceSoFar = distance
                                bestPairSoFar = (a:index_a, b:index_b)
                            }
                        }
                        else
                        {
                            leastDistanceSoFar = distance
                            bestPairSoFar = (a:index_a, b:index_b)
                            
                            leastDistanceInitialized = true
                        }
                    }
                }
            }
        }
        
        if (bestPairSoFar.a > 0 && bestPairSoFar.b > 0)
        {
            mergeClusters(bestPairSoFar.a, b:bestPairSoFar.b)
            return true
        }
        else
        {
            return false
        }
    }
    
    func mergeClusters(a:Int, b:Int)
    {
        if let _ = clusters[a]
        {
            if let cluster_b = clusters[b]
            {
                // Combine all of b's elements into a
                for element in cluster_b.elements
                {
                    clusters[a]!.insertElement(element)
                }
                
                // Delete b
                clusters.removeValueForKey(b)
            }
        }
    }
}