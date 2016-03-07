//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

enum QQBuildFromGuidePhase
{
    case INITIALIZATION, WAIT
}

class QQBuildFromGuideTask : QQTask
{
    var phase:QQBuildFromGuidePhase = QQBuildFromGuidePhase.INITIALIZATION
    
    override init()
    {
        super.init()
        
        ////////////////////////////////////////////////////////////
        // Input (component:Component)
        ////////////////////////////////////////////////////////////
        context.defineInput("component", type:QQVariableType.COMPONENT)
        
        ////////////////////////////////////////////////////////////
        // Output ()
        ////////////////////////////////////////////////////////////
    }
    
    ////////////////////////////////////////////////////////////
    // Task
    override func apply()
    {
        // Cannot proceed unless all inputs are initialized
        if (context.allInputsInitialized())
        {
            if (phase == .INITIALIZATION)
            {
//                let buildComponentTask = QQBuildComponentTask()
//                if let componentId = context.idForVariableNamed("component")
//                {
//                    buildComponentTask.initializeInput("component", id:componentId)
//                }
//                
//                insertSubaskLast(outlineTask)
//                
//                let fillTask = QQFillOutlineTask()
//                outlineTask.entangle("outline", task:fillTask, inputName:"outline")
//                
//                insertSubaskLast(fillTask)
                
                phase = .WAIT
            }
            else if (phase == .WAIT)
            {
                print("COMPLETE BUILD TASK")
                complete()
            }
        }
    }
}