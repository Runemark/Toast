//
//  ACInitializeMapLayerTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/19/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ACInitializeMapLayerTask : ACTask
{
    var active:Bool = false
    
    override func apply()
    {
        if let canvas = canvas
        {
            if (!active)
            {
                canvas.initializeMap()
                active = true
            }
            else
            {
                // Check to see if map has been initialized
                if canvas.modelMapLayerStatus()
                {
                    complete()
                }
            }
        }
    }
}
