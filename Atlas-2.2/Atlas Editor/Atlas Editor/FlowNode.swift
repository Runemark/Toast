//
//  FlowNode.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 5/14/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class FlowNode
{
    var center:DiscreteTileCoord
    var connections:[FlowNode]
    var strength:Int
    var radius:Int
    {
        return 1 + 2*strength
    }
    
    init(center:DiscreteTileCoord, strength:Int)
    {
        self.center = center
        self.strength = strength
        self.connections = [FlowNode]()
    }
    
    func dist(other:FlowNode) -> Double
    {
        return sqrt( pow(Double(center.x - other.center.x), 2.0) + pow(Double(center.y - other.center.y), 2.0) )
    }
    
    func squareDist(other:FlowNode) -> Int
    {
        let delta_x = abs(other.center.x - self.center.x)
        let delta_y = abs(other.center.y - self.center.y)
        return max(delta_x, delta_y)
    }
    
    func edgeSquareDist(other:FlowNode) -> Int
    {
        let sd = squareDist(other)
        return sd - (strength + other.strength) - 1
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Evaluation
    func internalCohesionMismatches(cohesion:(min:Int, max:Int)) -> [(connection:FlowNode, direction:RangeMatch, delta:Int, angle:Int)]
    {
        var matchValues = [(connection:FlowNode, direction:RangeMatch, delta:Int, angle:Int)]()
        for connection in connections
        {
            let distance = squareDist(connection)
            let angle = Int(floor(angleBetweenPoints(center, p2:connection.center)))
            if (!distance.inRange(cohesion))
            {
                let direction = (distance > cohesion.max) ? RangeMatch.OVER : RangeMatch.UNDER
                let delta = (direction == RangeMatch.OVER) ? distance - cohesion.max : cohesion.min - distance
                let matchValue = (connection, direction:direction, delta:delta, angle:angle)
                matchValues.append(matchValue)
            }
        }
        
        return matchValues
    }
    
    func propertyValue(nodeProperties:[FlowMapProperty]) -> Double
    {
        let propertyCount = nodeProperties.count
        var validPropertyCount = 0
        for property in nodeProperties
        {
            switch(property.propertyType)
            {
            case .INTERNAL_COHESION:
                validPropertyCount += (validateInternalCohesion(property.range)) ? 1 : 0
                break
            case .ANGLE:
                validPropertyCount += (validateAngle(property.range)) ? 1 : 0
                break
            default:
                break
            }
        }
        
        return Double(validPropertyCount)/Double(propertyCount)
    }
    
    func validateInternalCohesion(cohesion:(min:Int, max:Int)) -> Bool
    {
        for connection in connections
        {
            let squareDist = self.squareDist(connection)
            if (!squareDist.inRange(cohesion))
            {
                return false
            }
        }
        
        return true
    }
    
    func validateAngle(range:(min:Int, max:Int)) -> Bool
    {
        return true
    }
}