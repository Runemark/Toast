//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ZZFillRect : QQTask
{
    override init()
    {
        super.init()
        
        ////////////////////////////////////////////////////////////
        // Input ()
        ////////////////////////////////////////////////////////////
        context.defineInput("rect", type:QQVariableType.RECT)
        
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
            // Cannot proceed unless all inputs are initialized
            if (context.allInputsInitialized())
            {
                let rectId = context.idForVariableNamed("rect")!
                let outline = QQWorkingMemory.sharedInstance.rectValue(rectId)!
                
                for coord in outline.allCoords()
                {
                    canvas.setTerrainTileAt(coord, value:1)
                }
                
                success = true
                
                print("~~ ~~ Fill Rect: [Complete]")
                
                complete()
            }
        }
    }
}