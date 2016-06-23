//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ZZBestOutlinePlacement : QQTask
{
    override init()
    {
        super.init()
        
        ////////////////////////////////////////////////////////////
        // Input ()
        ////////////////////////////////////////////////////////////
        context.defineInput("outline", type:QQVariableType.RECT)
        context.defineInput("density", type:QQVariableType.DENSITYMAP)
        context.defineInput("distance", type:QQVariableType.DENSITYMAP)
        
        ////////////////////////////////////////////////////////////
        // Output ()
        ////////////////////////////////////////////////////////////
        context.defineInput("offset", type:QQVariableType.DISCRETECOORD)
    }
    
    ////////////////////////////////////////////////////////////
    // Task
    override func apply()
    {
        // Cannot proceed unless all inputs are initialized
        if (context.allInputsInitialized())
        {
            if let canvas = canvas
            {
                _ = context.getLocalRect("outline")!
                _ = context.getLocalDensityMap("density")!
                _ = context.getLocalDensityMap("distance")!
                _ = canvas.canvasBounds().outerRect()
                
                let outlineId = context.variableNamed("outline")!.id!
                let rectDensityTask = ZZRectDensityMap()
                rectDensityTask.initializeInput("rect", id:outlineId)
                insertSubaskLast(rectDensityTask)
                
                // Roughly:
                // (1) Find the "ANCHOR" of the outline (expand the outline with a border of 1)
                
                // (2) Get all the negative density nodes of that (or higher) density.
                
                // (3) Filter nodes by the CLOSEST one to content
                
                // (4) If none exist, return error. If many exist, pick one at random.
                
                success = true
                complete()
            }
        }
    }
}