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
            print("~~ Outline: Apply")
            
            let outline = TileRect(left:0, right:2, up:2, down:0)
//            let outline = TileRect(left:0, right:randIntBetween(0, stop:4), up:randIntBetween(0, stop:4), down:0)
//            let outline = coinFlip() ? TileRect(left:0, right:0, up:2, down:0) : TileRect(left:0, right:2, up:0, down:0)
            let outlineId = context.setGlobalRect(outline)
            context.initializeVariable("outline", id:outlineId)
            
            success = true
            complete()
            
            print("~~ Outline: <Complete>")
        }
    }
}