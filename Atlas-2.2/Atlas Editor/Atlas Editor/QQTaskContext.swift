//
//  QQTaskContext.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

// The context stores and indexes the actual VALUES of QQVariables.
// QQVariables only point to the id

class QQTaskContext
{
    // name : variable
    private var variables:[String:QQVariable]
    private var inputNames:Set<String>
    private var outputNames:Set<String>
    
    init()
    {
        self.variables = [String:QQVariable]()
        self.inputNames = Set<String>()
        self.outputNames = Set<String>()
    }
    
    func defineInput(name:String, type:QQVariableType, optional:Bool = false)
    {
        defineVariable(name, type:type, optional:optional, input:true)
    }
    
    func defineOutput(name:String, type:QQVariableType, optional:Bool = false)
    {
        defineVariable(name, type:type, optional:optional, output:true)
    }
    
    func initializeVariable(name:String, id:String)
    {
        if let variable = variableNamed(name)
        {
            variable.initialize(id)
        }
    }
    
    func defineVariable(name:String, type:QQVariableType, optional:Bool = false, input:Bool = false, output:Bool = false)
    {
        variables[name] = QQVariable(type:type, optional:optional)
        // The variable is now DEFINED, but UNINITIALIZED (no id associated)
        
        if (input)
        {
            inputNames.insert(name)
        }
        
        if (output)
        {
            outputNames.insert(name)
        }
    }
    
    func variableNamed(name:String) -> QQVariable?
    {
        return variables[name]
    }
    
    func idForVariableNamed(name:String) -> String?
    {
        var id:String?
        
        if let variable = variableNamed(name)
        {
            if (variable.initialized)
            {
                id = variable.id!
            }
        }
        
        return id
    }
    
    func allInputsInitialized() -> Bool
    {
        var allInitialized = true
        
        for inputName in inputNames
        {
            if let input = variableNamed(inputName)
            {
                if !input.initialized
                {
                    allInitialized = false
                    break
                }
            }
            else
            {
                allInitialized = false
                break
            }
        }
        
        return allInitialized
    }
    
    func inputDefined(name:String) -> Bool
    {
        return inputNames.contains(name)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Global Variables
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func setGlobalRect(value:TileRect) -> String
    {
        return QQWorkingMemory.sharedInstance.registerRect(value)
    }
    
    func setGlobalAtomicMap(value:AtomicMap<Int>) -> String
    {
        return QQWorkingMemory.sharedInstance.registerAtomicMap(value)
    }
    
    func setGlobalDensityMap(value:DensityMap) -> String
    {
        return QQWorkingMemory.sharedInstance.registerDensityMap(value)
    }
    
    func setGlobalDiscreteCoord(value:DiscreteTileCoord) -> String
    {
        return QQWorkingMemory.sharedInstance.registerDiscreteCoord(value)
    }
    
    
    
    func getGlobalRect(id:String) -> TileRect?
    {
        return QQWorkingMemory.sharedInstance.rectValue(id)
    }
    
    func getGlobalDensityMap(id:String) -> DensityMap?
    {
        return QQWorkingMemory.sharedInstance.densityMapValue(id)
    }
    
    func getGlobalDiscreteCoord(id:String) -> DiscreteTileCoord?
    {
        return QQWorkingMemory.sharedInstance.discreteCoordValue(id)
    }
    
    func getLocalRect(name:String) -> TileRect?
    {
        var value:TileRect?
        
        if let id = idForVariableNamed(name)
        {
            value = getGlobalRect(id)
        }
        
        return value
    }
    
    func getLocalDensityMap(name:String) -> DensityMap?
    {
        var value:DensityMap?
        
        if let id = idForVariableNamed(name)
        {
            value = getGlobalDensityMap(id)
        }
        
        return value
    }
    
    func getLocalDiscreteCoord(name:String) -> DiscreteTileCoord?
    {
        var value:DiscreteTileCoord?
        
        if let id = idForVariableNamed(name)
        {
            value = getGlobalDiscreteCoord(id)
        }
        
        return value
    }
}