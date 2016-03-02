//
//  LKLoadMapTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/24/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class LKDisplayMapTask : LKTask
{
    var coordsToDisplay:Queue<DiscreteTileCoord>
    var initialized = false
    
    override init(subtaskId:Int)
    {
        coordsToDisplay = Queue<DiscreteTileCoord>()
        
        super.init(subtaskId:subtaskId)
        
        registerInput("map", variable:LKVariable(type:LKVariableType.ATOMICMAP))
    }
    
    override func apply()
    {
        if let canvas = canvas
        {
            if (!initialized)
            {
                print("MAP DISPLAY INITIALIZE")
                // We proceed to load an atomic mac from memory
                let mapVariable = getInput("map")!
                let map = canvas.getAtomicMap(mapVariable.id!)!
                
                let mapBounds = TileRect(left:0, right:map.xMax-1, up:map.yMax-1, down:0)
                for coord in mapBounds.allCoords()
                {
                    coordsToDisplay.enqueue(coord)
                }

                initialized = true
            }
            else
            {
                let mapVariable = getInput("map")!
                let map = canvas.getAtomicMap(mapVariable.id!)!
                
                for _ in 1...10
                {
                    if let nextCoord = coordsToDisplay.dequeue()
                    {
                        let value = map[nextCoord]
                        if (value > 0)
                        {
                            canvas.setMapTile(nextCoord, value:value)
                        }
                    }
                }
                
                if (coordsToDisplay.count == 0)
                {
                    print("MAP LOAD COMPLETE")
                    complete()
                }
            }
        }
    }
}