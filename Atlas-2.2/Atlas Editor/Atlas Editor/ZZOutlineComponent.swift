//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ZZOutlineComponent : QQTask
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
        context.defineOutput("outline", type:QQVariableType.RECT)
    }
    
    ////////////////////////////////////////////////////////////
    // Task
    override func apply()
    {
        if (context.allInputsInitialized())
        {
            let outline = TileRect(left:0, right:0, up:3, down:3)
            let outlineId = context.setGlobalRect(outline)
            context.initializeVariable("outline", id:outlineId)
            
            success = true
            complete()
            
            print("~~~ Outline: <Complete>")
        }
    }
}