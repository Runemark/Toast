//
//  LKAnalysisTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/24/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

enum LKAnalysisPhase
{
    case INITIALIZE, DISPLAY, COMPLETE
}

class LKAnalysisTask : LKTask
{
    var analysisPhase:LKAnalysisPhase = LKAnalysisPhase.INITIALIZE
    
    override func apply()
    {
        if let canvas = canvas
        {
            if (analysisPhase == .INITIALIZE)
            {
                print("INITIALIZE ANALYSIS PHASE")
                // Register the map title
                let mapTitle = "Crypt001a"
                let mapTitleId = canvas.registerString(mapTitle)
                
                let loadMapTask = LKLoadMapTask(subtaskId:0)
                loadMapTask.defineInput("mapTitle", id:mapTitleId)
                insertSubaskLast(loadMapTask)
            }
        }
    }
    
    override func subtaskCompleted(child:LKTask)
    {
        // Get the output of the subtask?
        
        switch (child.subtaskId)
        {
            case 0:
                // Add a display task
                self.defineLocalVariable("BASE_MAP", variable:child.getOutput("map")!)
                let displayMapTask = LKDisplayMapTask(subtaskId:1)
                insertSubaskLast(displayMapTask)
            default:
                complete()
                break
        }
        
        
        // HERE'S THE PROBLEM: Subtasks are completed all the time, but we need to know where in the ORDER it happens. What's the context, anyways?
        // How do we tell that it's the LOAD MAP TASK that just completed, not the DISPLAY MAP TASK?
        
        
        // The LOAD MAP TASK needs to tell us about its OUTPUT so we can feed it into the INPUT fo the DISPLAY MAP TASK
        
        super.subtaskCompleted(child)
    }
}