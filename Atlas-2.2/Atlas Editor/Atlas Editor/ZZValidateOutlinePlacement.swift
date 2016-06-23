//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ZZValidateOutlinePlacement : QQTask
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
        // Cannot proceed unless all inputs are initialized
        if (context.allInputsInitialized())
        {
            if let canvas = canvas
            {
                print("~~ ValidateChoice: Start")
                
                let outline = context.getLocalRect("outline")!
                let offset = context.getLocalDiscreteCoord("offset")!
                
                let placedRect = outline.shift(offset)
                
                let bounds = canvas.canvasBounds()
                let aesBuffer = 1
                
                var valid = true
                for x in placedRect.left-aesBuffer...placedRect.right+aesBuffer
                {
                    if (valid)
                    {
                        for y in placedRect.down-aesBuffer...placedRect.up+aesBuffer
                        {
                            let coord = DiscreteTileCoord(x:x, y:y)
                            if (bounds.contains(coord))
                            {
                                let value = canvas.atomicValueAt(coord)
                                
                                if (value > 0)
                                {
                                    valid = false
                                    break
                                }
                            }
                        }
                    }
                }
                
                print("~~ ValidateChoice: Complete (\(valid))")
                
                success = valid
                complete()
            }
        }
    }
}