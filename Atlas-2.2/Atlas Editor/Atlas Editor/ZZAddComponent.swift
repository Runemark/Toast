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
            print("~~ AddComponent: Apply")
            
            let outlineTask = ZZOutlineComponent()
            let placementTask = ZZPlaceOutline()
            
            outlineTask.prepareToSend("outline", receivingTask:placementTask, receivingVariable:"outline")
            
            insertSubaskLast(outlineTask)
            insertSubaskLast(placementTask)
        }
    }
}