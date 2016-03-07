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
    var atomicMaps:[String:AtomicMap<Int>]
    var densityMaps:[String:DensityMap]
    var coordSets:[String:Set<DiscreteTileCoord>]
    
    private init()
    {
        self.variables = [String:QQVariableType]()
        
        self.components = [String:FRStyleComponent]()
        self.rects = [String:TileRect]()
        self.atomicMaps = [String:AtomicMap<Int>]()
        self.densityMaps = [String:DensityMap]()
        self.coordSets = [String:Set<DiscreteTileCoord>]()
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
    
    func registerAtomicMap(value:AtomicMap<Int>) -> String
    {
        let id = NSUUID().UUIDString
        registerAtomicMap(id, value:value)
        
        return id
    }
    
    func registerDensityMap(value:DensityMap) -> String
    {
        let id = NSUUID().UUIDString
        registerDensityMap(id, value:value)
        
        return id
    }
    
    func registerCoordSet(value:Set<DiscreteTileCoord>) -> String
    {
        let id = NSUUID().UUIDString
        registerCoordSet(id, value:value)
        
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
    
    func registerAtomicMap(id:String, value:AtomicMap<Int>)
    {
        variables[id] = QQVariableType.ATOMICMAP
        atomicMaps[id] = value
    }
    
    func registerDensityMap(id:String, value:DensityMap)
    {
        variables[id] = QQVariableType.DENSITYMAP
        densityMaps[id] = value
    }
    
    func registerCoordSet(id:String, value:Set<DiscreteTileCoord>)
    {
        variables[id] = QQVariableType.COORDSET
        coordSets[id] = value
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
    
    func atomicMapValue(id:String) -> AtomicMap<Int>?
    {
        var value:AtomicMap<Int>?
        
        if idMatchesType(id, type:QQVariableType.ATOMICMAP)
        {
            value = atomicMaps[id]
        }
        
        return value
    }
    
    func densityMapValue(id:String) -> DensityMap?
    {
        var value:DensityMap?
        
        if idMatchesType(id, type:QQVariableType.DENSITYMAP)
        {
            value = densityMaps[id]
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