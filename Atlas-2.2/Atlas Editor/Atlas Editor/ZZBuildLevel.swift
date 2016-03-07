//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

enum ZZBuildLevelStage
{
    case BUILD, EVALUATE
}

class ZZBuildLevel : QQTask
{
    var stage:ZZBuildLevelStage = ZZBuildLevelStage.BUILD
    var componentCount = 0
    
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
        if let _ = canvas
        {
            if (context.allInputsInitialized())
            {
                if (stage == .BUILD || stage == .EVALUATE)
                {
                    if (stage == .BUILD)
                    {
                        buildStage()
                    }
                    else if (stage == .EVALUATE)
                    {
                        evaluateStage()
                    }
                    
                    toggleStage()
                }
            }
        }
    }
    
    func buildStage()
    {
        print("BuildLevel: Build Stage")
        
        let addComponentTask = ZZAddComponent()
        insertSubaskLast(addComponentTask)
    }
    
    func evaluateStage()
    {
        print("BuildLevel: Evaluate stage")
        
        if (componentCount == 3)
        {
            complete()
        }
    }
    
    func toggleStage()
    {
        if (stage == .BUILD)
        {
            stage = .EVALUATE
        }
        else if (stage == .EVALUATE)
        {
            stage = .BUILD
        }
    }
    
    override func subtaskCompleted(child:QQTask)
    {
        if (child.success)
        {
            componentCount++
        }
        
        super.subtaskCompleted(child)
    }
}