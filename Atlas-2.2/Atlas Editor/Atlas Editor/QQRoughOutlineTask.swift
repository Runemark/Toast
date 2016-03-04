//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class QQRoughOutlineTask : QQTask
{
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
        context.defineOutput("outline", type:QQVariableType.RECT)
    }
    
    ////////////////////////////////////////////////////////////
    // Task
    override func apply()
    {
        // Cannot proceed unless all inputs are initialized
        if (context.allInputsInitialized())
        {
//            let componentId = context.idForVariableNamed("component")!
//            let component = QQWorkingMemory.sharedInstance.componentValue(componentId)!
            
            let fancyRect = TileRect(left:1, right:3, up:3, down:1)
            let rectId = QQWorkingMemory.sharedInstance.registerRect(fancyRect)
            
            context.initializeVariable("outline", id:rectId)
            
            complete()
        }
    }
}