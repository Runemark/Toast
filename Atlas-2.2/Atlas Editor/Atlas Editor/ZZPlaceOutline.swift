//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ZZPlaceComponent : QQTask
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
    }
    
    ////////////////////////////////////////////////////////////
    // Task
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
                    let center = canvas.canvasBounds().center()
                    
                    
                }
                else
                {
                    let densityTask = ZZDensityMap()
                    let distanceTask = ZZContentDistanceMap()
                    
                    insertSubaskLast(densityTask)
                    insertSubaskLast(distanceTask)
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