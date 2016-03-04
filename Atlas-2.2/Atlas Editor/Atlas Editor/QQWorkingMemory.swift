//
//  QQWorkingMemory.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/3/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class QQWorkingMemory
{
    // Singleton - lifetime is the duration of the program
    static let sharedInstance = QQWorkingMemory()
    
    var variables:[String:QQVariableType]
    
    var components:[String:FRStyleComponent]
    var rects:[String:TileRect]
    
    private init()
    {
        self.variables = [String:QQVariableType]()
        
        self.components = [String:FRStyleComponent]()
        self.rects = [String:TileRect]()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Registration
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func registerComponent(value:FRStyleComponent) -> String
    {
        let id = NSUUID().UUIDString
        registerComponent(id, value:value)
        
        return id
    }
    
    func registerRect(value:TileRect) -> String
    {
        let id = NSUUID().UUIDString
        registerRect(id, value:value)
        
        return id
    }
    
    func registerComponent(id:String, value:FRStyleComponent)
    {
        variables[id] = QQVariableType.COMPONENT
        components[id] = value
    }
    
    func registerRect(id:String, value:TileRect)
    {
        variables[id] = QQVariableType.RECT
        rects[id] = value
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Values
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func componentValue(id:String) -> FRStyleComponent?
    {
        var value:FRStyleComponent?
        
        if idMatchesType(id, type:QQVariableType.COMPONENT)
        {
            value = components[id]
        }
        
        return value
    }
    
    func rectValue(id:String) -> TileRect?
    {
        var value:TileRect?
        
        if idMatchesType(id, type:QQVariableType.RECT)
        {
            value = rects[id]
        }
        
        return value
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Convenience
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func idMatchesType(id:String, type:QQVariableType) -> Bool
    {
        var match = false
        
        if let variableType = variables[id]
        {
            if variableType == type
            {
                match = true
            }
        }
        
        return match
    }
}