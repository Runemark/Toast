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
        context.defineInput("outline", type:QQVariableType.RECT)
        context.defineInput("offset", type:QQVariableType.DISCRETECOORD)
        
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
                let outline = context.getLocalRect("outline")!
                let offset = context.getLocalDiscreteCoord("offset")!
                
                print(outline)
                print(offset)
                
                let placedRect = outline.shift(offset)
                
                print(placedRect)
                
                for coord in placedRect.allCoords()
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