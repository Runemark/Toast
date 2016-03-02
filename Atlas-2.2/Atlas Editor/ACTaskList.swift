//
//  TaskList.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/9/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class ACTaskList : ACTaskDelegate
{
    private var subtasks:[ACTask]
    private var canvas:ACCanvasDelegate?
    
    init()
    {
        self.subtasks = [ACTask]()
    }
    
    func registerCanvasDelegate(delegate:ACCanvasDelegate)
    {
        self.canvas = delegate
    }
    
    func insertSubtaskFirst(subtask:ACTask)
    {
        subtask.registerParent(self)
        
        if let canvas = canvas
        {
            subtask.registerCanvas(canvas)
        }
       
        subtasks.insert(subtask, atIndex:0)
    }
    
    func insertSubtaskLast(subtask:ACTask)
    {
        subtask.registerParent(self)
        
        if let canvas = canvas
        {
            subtask.registerCanvas(canvas)
        }
        
        subtasks.append(subtask)
    }
    
    func removeSubtask(subtask:ACTask)
    {
        if let indexToRemove = indexForSubtask(subtask)
        {
            subtasks.removeAtIndex(indexToRemove)
        }
        
        subtask.parent = nil
    }
    
    func indexForSubtask(subtask:ACTask) -> Int?
    {
        var index:Int?
        
        var tempIndex = 0
        for task in subtasks
        {
            if (task.id == subtask.id)
            {
                index = tempIndex
                break
            }
            
            tempIndex++
        }
        
        return index
    }
    
    func subtasksRemaining() -> Bool
    {
        return subtasks.count > 0
    }
    
    func applyNextSubtask()
    {
        if let rootTask = subtasks.first
        {
            if let nextSubTask = rootTask.nextSubtask()
            {
                print(Mirror(reflecting:nextSubTask).subjectType)
                nextSubTask.apply()
            }
        }
    }
    
    func subtaskCompleted(subtask:ACTask)
    {
        removeSubtask(subtask)
    }
}