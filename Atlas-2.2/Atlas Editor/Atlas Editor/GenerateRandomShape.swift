//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class GenerateRandomShape : QQTask
{
    var stage:Int = 0
    var shape:ShapeComponent
    
    override init()
    {
        self.shape = ShapeComponent()
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
            let bounds = canvas.canvasBounds()
            
            if (stage == 0)
            {
                shape.addNode(shape.createNode(bounds.center(), radius:2))
                stage = 1
            }
            else if (stage == 1)
            {
                shape.augmentWithRandomNodesOfRadius(2, nodeCount:1)
                stage = 2
            }
            else if (stage == 2)
            {
                shape.augmentWithRandomNodesOfRadius(1, nodeCount:3)
                stage = 3
            }
            else if (stage == 3)
            {
                canvas.clearDensity()
                for coord in shape.shapeMass()
                {
                    canvas.updateDensityNodeAt(coord, density:1)
                }
                
                shape = ShapeComponent()
                stage = 0
            }
        }
    }
}