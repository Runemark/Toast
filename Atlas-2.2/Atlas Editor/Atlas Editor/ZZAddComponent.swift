//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ZZAddComponent : QQTask
{
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
        if (context.allInputsInitialized())
        {
            let outlineTask = ZZOutlineComponent()
            let placementTask = ZZPlaceOutline()
            let fillTask = ZZFillRect()
            
            outlineTask.prepareToSend("outline", receivingTask:placementTask, receivingVariable:"outline")
            outlineTask.prepareToSend("outline", receivingTask:fillTask, receivingVariable:"outline")
            placementTask.prepareToSend("offset", receivingTask:fillTask, receivingVariable:"offset")
            
            insertSubaskLast(outlineTask)
            insertSubaskLast(placementTask)
            insertSubaskLast(fillTask)
        }
    }
    
    override func subtaskCompleted(child:QQTask)
    {
        if child is ZZPlaceOutline
        {
            success = child.success
            
            if (!success)
            {
                complete()
            }
        }
        else if child is ZZFillRect
        {
            success = true
            complete()
        }
    }
}