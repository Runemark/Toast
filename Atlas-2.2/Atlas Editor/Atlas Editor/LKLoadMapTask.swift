//
//  LKLoadMapTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/24/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class LKLoadMapTask : LKTask
{
    override init(subtaskId:Int)
    {
        super.init(subtaskId:subtaskId)
        
        registerInput("mapTitle", variable:LKVariable(type:LKVariableType.STRING))
        registerOutput("map", variable:LKVariable(type:LKVariableType.ATOMICMAP))
    }
    
    override func apply()
    {
        if let canvas = canvas
        {
            print("MAP LOAD INITIALIZE")
            // We proceed to load an atomic mac from memory
            let mapTitleVariable = getInput("mapTitle")!
            let mapTitle = canvas.getString(mapTitleVariable.id!)!
            
            if let map = TileMapIO().importAtomicMap(mapTitle)
            {
                let mapId = canvas.registerAtomicMap(map)
                defineOutput("map", id:mapId)
            }
            else
            {
                // WARXING: Complete with PROBLEM
            }
            
            print("MAP LOAD COMPLETE")
            complete()
        }
    }
}