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
        if let canvas = canvas
        {
            // Cannot proceed unless all inputs are initialized
            if (context.allInputsInitialized())
            {
                var randomRect:TileRect!
                
                // 
                
                if (canvas.componentRectCount() == 0)
                {
                    // Place in center
                    let center = canvas.canvasBounds().center()
                    let left = center.x - 1
                    let down = center.y - 1
                    randomRect = TileRect(left:left, right:left+2, up:down+2, down:down)
                }
                else
                {
                    // Pick a random 3x3 window
                    let bounds = canvas.canvasBounds()
                    let randomLeft = randIntBetween(bounds.left, stop:bounds.right-2)
                    let randomDown = randIntBetween(bounds.down, stop:bounds.up-2)
                    randomRect = TileRect(left:randomLeft, right:randomLeft+2, up:randomDown+2, down:randomDown)
                }
                
                
                // Vaildate -- can it be placed?
                var validRect = true
                for coord in randomRect.allCoords()
                {
                    if (canvas.atomicValueAt(coord) > 0)
                    {
                        validRect = false
                        break
                    }
                }
                
                if (validRect)
                {
                    let rectId = QQWorkingMemory.sharedInstance.registerRect(randomRect)
                    
                    print("~~ AddComponent: Valid Rect Generated \(randomRect)")
                    
                    let fillTask = ZZFillRect()
                    fillTask.context.initializeVariable("rect", id:rectId)
                    insertSubaskLast(fillTask)
                    
                    canvas.registerComponentRect(randomRect)
                    success = true
                }
                else
                {
                    print("~~ AddComponent Failed!")
                    success = false
                    complete()
                }
                
                print("~~ AddComponent: [Complete]")
            }
        }
    }
    
    override func subtaskCompleted(child:QQTask)
    {
        if (child.success)
        {
            super.subtaskCompleted(child)
            complete()
        }
        else
        {
            // FILL ERROR (not really possible though)
        }
    }
}