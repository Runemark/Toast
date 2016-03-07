//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ZZVisualizeDensity : QQTask
{
    override init()
    {
        super.init()
        
        ////////////////////////////////////////////////////////////
        // Input ()
        ////////////////////////////////////////////////////////////
        context.defineInput("density", type:QQVariableType.DENSITYMAP)
        
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
                let densityId = context.idForVariableNamed("density")!
                let density = QQWorkingMemory.sharedInstance.densityMapValue(densityId)!
                
                for coord in density.bounds.allCoords()
                {
                    let value = density.density(coord)
                    if (value > 0)
                    {
                        canvas.updateDensityNodeAt(coord, density:value)
                    }
                }
                
                let _ = NSTimer.scheduledTimerWithTimeInterval(0.4, target:self, selector:"visualUpdateComplete", userInfo:nil, repeats:false)
            }
        }
    }
    
    @objc func visualUpdateComplete()
    {
        success = true
        complete()
    }
}