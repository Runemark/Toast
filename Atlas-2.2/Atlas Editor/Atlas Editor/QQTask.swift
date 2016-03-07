//
//  Task.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/6/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

protocol QQTaskDelegate
{
    func subtaskCompleted(child:QQTask)
}

class QQTask : QQTaskDelegate
{
    var taskID:String
    
    var inputs:[String:QQVariable]
    var outputs:[String:QQVariable]
    
    var context:QQTaskContext
    var canvas:QQCanvasDelegate?
    var completed:Bool
    var success:Bool = false
    
    // This task will have ACCESS to its parent's context as well
    var parent:QQTaskDelegate?
    var subtasks:[QQTask]
    
    init()
    {
        self.taskID = NSUUID().UUIDString
        
        self.context = QQTaskContext()
        self.completed = false
        
        self.inputs = [String:QQVariable]()
        self.outputs = [String:QQVariable]()
        
        self.subtasks = [QQTask]()
    }
    
    func registerCanvas(delegate:QQCanvasDelegate)
    {
        self.canvas = delegate
    }
    
    func registerParent(parent:QQTaskDelegate)
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
    // Context
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func prepareToReceive(receivingVariable:String, sendingTask:QQTask, sendingVariable:String)
    {
        if let sendingVar = sendingTask.context.variableNamed(sendingVariable)
        {
            if let receivingVar = context.variableNamed(receivingVariable)
            {
                sendingVar.registerObserver(receivingVar)
            }
        }
    }
    
    func prepareToSend(sendingVariable:String, receivingTask:QQTask, receivingVariable:String)
    {
        if let sendingVar = context.variableNamed(sendingVariable)
        {
            if let receivingVar = receivingTask.context.variableNamed(receivingVariable)
            {
                sendingVar.registerObserver(receivingVar)
            }
        }
    }
    
    func initializeInput(name:String, id:String)
    {
        // Checks to make sure this is an input variable, not a local one
        if (context.inputDefined(name))
        {
            context.initializeVariable(name, id:id)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Tasks
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func subtaskCompleted(subtask:QQTask)
    {
        // Superclass implementation (simply remove the subtask from list of children)
        // Each subclass of Task will have customized methods of dealing with completed children,
        // And will end with a call to this superclass implementation.
        removeSubtask(subtask)
    }
    
    func nextSubtask() -> QQTask?
    {
        var next:QQTask?
        
        if (subtasks.count == 0 && !self.completed)
        {
            next = self
        }
        else
        {
            for child in subtasks
            {
                if let subtask = child.nextSubtask()
                {
                    if (subtask.context.allInputsInitialized())
                    {
                        next = subtask
                        break
                    }
                }
            }
        }
        
        return next
    }
    
    func insertSubtaskFirst(task:QQTask)
    {
        if let canvas = canvas
        {
            task.registerCanvas(canvas)
            task.registerParent(self)
        }
        subtasks.insert(task, atIndex:0)
    }
    
    func insertSubaskLast(task:QQTask)
    {
        if let canvas = canvas
        {
            task.registerCanvas(canvas)
            task.registerParent(self)
        }
        subtasks.append(task)
    }
    
    func removeSubtask(subtask:QQTask)
    {
        var rootIndex = -1
        
        var tempIndex = 0
        for task in subtasks
        {
            if (task.taskID == subtask.taskID)
            {
                rootIndex = tempIndex
                break
            }
            
            tempIndex++
        }
        
        if (rootIndex > -1)
        {
            subtasks.removeAtIndex(rootIndex)
        }
    }
}