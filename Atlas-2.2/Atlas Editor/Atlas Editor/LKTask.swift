//
//  Task.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/6/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

protocol LKTaskDelegate
{
    func subtaskCompleted(child:LKTask)
}

class LKVariable
{
    var type:LKVariableType
    var defined:Bool
    var id:String?
    
    init(type:LKVariableType)
    {
        self.type = type
        self.defined = false
    }
    
    func initialize(id:String)
    {
        self.id = id
        self.defined = true
    }
}

class LKTask : LKTaskDelegate
{
    var inputs:[String:LKVariable]
    var outputs:[String:LKVariable]
    
    var localVariables:[String:LKVariable]
    
    var subtaskId:Int
    var canvas:LKCanvasDelegate?
    var completed:Bool
    
    // Tasks which need to be notified of this task's result
    var parent:LKTaskDelegate?
    // Tasks which this task needs a result on in order to continue
    var subtasks:[LKTask]
    
    init(subtaskId:Int)
    {
        self.subtaskId = subtaskId
        self.completed = false
        
        inputs = [String:LKVariable]()
        outputs = [String:LKVariable]()
        
        localVariables = [String:LKVariable]()
        
        self.subtasks = [LKTask]()
    }
    
    func registerCanvas(delegate:LKCanvasDelegate)
    {
        self.canvas = delegate
    }
    
    func registerParent(parent:LKTaskDelegate)
    {
        self.parent = parent
    }
    
    func apply()
    {
        
    }
    
    func complete()
    {
        if let parent = parent
        {
            parent.subtaskCompleted(self)
        }
        
        completed = true
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // I/O
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func registerInput(name:String, variable:LKVariable)
    {
        inputs[name] = variable
    }
    
    func registerOutput(name:String, variable:LKVariable)
    {
        outputs[name] = variable
    }
    
    func defineInput(name:String, id:String)
    {
        if let variable = inputs[name]
        {
            variable.initialize(id)
        }
    }
    
    func defineOutput(name:String, id:String)
    {
        if let variable = outputs[name]
        {
            variable.initialize(id)
        }
    }
    
    func getInput(name:String) -> LKVariable?
    {
        return inputs[name]
    }
    
    func getOutput(name:String) -> LKVariable?
    {
        return outputs[name]
    }
    
    func allInputsDefined() -> Bool
    {
        var allDefined = true
        
        for (_, variable) in inputs
        {
            if !variable.defined
            {
                allDefined = false
                break
            }
        }
        
        return allDefined
    }
    
    func allOutputsDefined() -> Bool
    {
        var allDefined = true
        
        for (_, variable) in outputs
        {
            if !variable.defined
            {
                allDefined = false
                break
            }
        }
        
        return allDefined
    }
    
    func defineLocalVariable(name:String, variable:LKVariable)
    {
        localVariables[name] = variable
    }
    
    func getLocalVariable(name:String) -> LKVariable?
    {
        return localVariables[name]
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Tasks
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func subtaskCompleted(subtask:LKTask)
    {
        // Superclass implementation (simply remove the subtask from list of children)
        // Each subclass of Task will have customized methods of dealing with completed children,
        // And will end with a call to this superclass implementation.
        removeSubtask(subtask)
    }
    
    func nextSubtask() -> LKTask?
    {
        var next:LKTask?
        
        if (subtasks.count == 0)
        {
            next = self
        }
        else
        {
            for child in subtasks
            {
                if let subtask = child.nextSubtask()
                {
                    // Can only proceed if all inputs are defined
                    if (subtask.allInputsDefined())
                    {
                        next = subtask
                        break
                    }
                }
            }
        }
        
        return next
    }
    
    func insertSubtaskFirst(task:LKTask)
    {
        if let canvas = canvas
        {
            task.registerCanvas(canvas)
            task.registerParent(self)
        }
        subtasks.insert(task, atIndex:0)
    }
    
    func insertSubaskLast(task:LKTask)
    {
        if let canvas = canvas
        {
            task.registerCanvas(canvas)
            task.registerParent(self)
        }
        subtasks.append(task)
    }
    
    func removeSubtask(subtask:LKTask)
    {
        var rootIndex = -1
        
        var tempIndex = 0
        for task in subtasks
        {
            if (task.subtaskId == subtask.subtaskId)
            {
                rootIndex = tempIndex
                break
            }
            
            tempIndex += 1
        }
        
        if (rootIndex > -1)
        {
            subtasks.removeAtIndex(rootIndex)
        }
    }
}