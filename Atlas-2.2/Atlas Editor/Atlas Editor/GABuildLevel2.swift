//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation


class GABuildLevel2 : QQTask
{
    var flowMap:FlowMap?
    var alternator = true
    
    override init()
    {
        super.init()
        
        ////////////////////////////////////////////////////////////
        // Input ()
        ////////////////////////////////////////////////////////////
        
        ////////////////////////////////////////////////////////////
        // Output ()
        ////////////////////////////////////////////////////////////
    }
    
    ////////////////////////////////////////////////////////////
    // Task
    override func apply()
    {
        if let canvas = canvas
        {
            if let flowMap = flowMap
            {
                mutate(flowMap)
                canvas.redrawFlowMap(flowMap)
            }
            else
            {
                generate()
                canvas.redrawFlowMap(flowMap!)
            }
        }
    }
    
    func generate()
    {
        if let canvas = canvas
        {
            var nodeProperties = [FlowMapProperty]()
            var globalProperties = [FlowMapProperty]()
            nodeProperties.append(FlowMapProperty(propertyType:FlowMapPropertyType.INTERNAL_COHESION, range:(min:1, max:1)))
            globalProperties.append(FlowMapProperty(propertyType:FlowMapPropertyType.EXTERNAL_COHESION, range:(min:0, max:0)))
            flowMap = FlowMap(bounds:canvas.canvasBounds(), nodeProperties:nodeProperties, globalProperties:globalProperties)
            flowMap?.populateWithRandomThreaded(10)
        }
    }
    
    func mutate(map:FlowMap)
    {
        // Find an offending node
        if (alternator)
        {
            map.improveInternalCohesion((min:1, max:6))
        }
        else
        {
            map.improveExternalCohesion((min:1, max:1))
        }
        
        alternator = !alternator
    }
}