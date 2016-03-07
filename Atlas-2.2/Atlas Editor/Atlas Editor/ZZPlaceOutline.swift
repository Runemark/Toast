//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ZZPlaceOutline : QQTask
{
    override init()
    {
        super.init()
        
        ////////////////////////////////////////////////////////////
        // Input ()
        ////////////////////////////////////////////////////////////
        context.defineInput("outline", type:QQVariableType.RECT)
        
        ////////////////////////////////////////////////////////////
        // Output ()
        ////////////////////////////////////////////////////////////
        context.defineOutput("offset", type:QQVariableType.DISCRETECOORD)
    }
    
    ////////////////////////////////////////////////////////////
    // Task: Decide where to place the outline on the map
    // Returns an offset from the outline's
    override func apply()
    {
        if (context.allInputsInitialized())
        {
            if let canvas = canvas
            {
                print("~~ PlaceComponent: Apply")
                
                let outlineId = context.idForVariableNamed("outline")!
                let outline = QQWorkingMemory.sharedInstance.rectValue(outlineId)!
                
                if (canvas.componentRectCount() == 0)
                {
                    // Place at CENTER
                    let mapCenter = canvas.canvasBounds().center()
                    let outlineCenter = outline.center()
                    
                    let offset = mapCenter - outlineCenter
                    let offsetId = context.setGlobalDiscreteCoord(offset)
                    context.initializeVariable("offset", id:offsetId)
                    
                    
                    // Register the component rect with HQ
                    canvas.registerComponentRect(<#T##rect: TileRect##TileRect#>)
                }
                else
                {
//                    let densityTask = ZZDensityMap()
//                    let distanceTask = ZZContentDistanceMap()
//                    
//                    insertSubaskLast(densityTask)
//                    insertSubaskLast(distanceTask)
                }
            }
        }
    }
    
    override func subtaskCompleted(child:QQTask)
    {
        super.subtaskCompleted(child)
        
        if (subtasks.count == 0)
        {
            print("~~ PlaceComponent: Apply")
        }
    }
}