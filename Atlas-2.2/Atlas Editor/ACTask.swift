//
//  Task.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/6/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

protocol ACTaskDelegate
{
    func subtaskCompleted(child:ACTask)
}

class ACTask : ACTaskDelegate
{
    var id:String
    var canvas:ACCanvasDelegate?
    var completion:Double
    
    // Tasks which need to be notified of this task's result
    var parent:ACTaskDelegate?
    // Tasks which this task needs a result on in order to continue
    var subtasks:[ACTask]
    
    init()
    {
        self.id = NSUUID().UUIDString
        self.completion = 0.0
        
        self.subtasks = [ACTask]()
    }
    
    func registerCanvas(delegate:ACCanvasDelegate)
    {
        self.canvas = delegate
    }
    
    func registerParent(parent:ACTaskDelegate)
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
        
        completion = 1.0
    }
    
    func subtaskCompleted(subtask:ACTask)
    {
        // Superclass implementation (simply remove the subtask from list of children)
        // Each subclass of Task will have customized methods of dealing with completed children,
        // And will end with a call to this superclass implementation.
        removeSubtask(subtask)
    }
    
    func nextSubtask() -> ACTask?
    {
        var next:ACTask?
        
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
                    next = subtask
                    break
                }
            }
        }
        
        return next
    }
    
    func insertSubtaskFirst(task:ACTask)
    {
        if let canvas = canvas
        {
            task.registerCanvas(canvas)
        }
        subtasks.insert(task, atIndex:0)
    }
    
    func insertSubaskLast(task:ACTask)
    {
        if let canvas = canvas
        {
            task.registerCanvas(canvas)
        }
        subtasks.append(task)
    }
    
    func removeSubtask(subtask:ACTask)
    {
        var rootIndex = -1
        
        var tempIndex = 0
        for task in subtasks
        {
            if (task.id == subtask.id)
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