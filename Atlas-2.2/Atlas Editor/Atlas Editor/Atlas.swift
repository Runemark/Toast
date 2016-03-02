//
//  Atlas.swift
//  Atlas
//
//  Created by Dusty Artifact on 11/16/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

enum OperatingState
{
    case RUNNING, HALTED, STEPPING
}

protocol IntelligentAgentDelegate
{
    func proceed()
    func nextAction()
    func halt()
}

class Atlas
{
    var model:TileMap
    var bounds:TileRect
    var guide:FRStyleGuide
    
    var operatingState:OperatingState = OperatingState.HALTED
    
    var cognitionRegulator:NSTimer = NSTimer()
    var actionRegulator:NSTimer = NSTimer()
    
    var actions:Queue<Change>
    
    var oneTimeFlag = false
    
    init(model:TileMap, bounds:TileRect, guide:FRStyleGuide)
    {
        self.model = model
        self.bounds = bounds
        self.guide = guide
        
        self.actions = Queue<Change>()
        
        self.cognitionRegulator = NSTimer()
        self.actionRegulator = NSTimer()
        
        self.initializeRegulators()
    }
    
    func initializeRegulators()
    {
        let cognitiveSpeed = 1.0/Double(10)
        let actionSpeed = 1.0/Double(30)
        
        cognitionRegulator = NSTimer.scheduledTimerWithTimeInterval(cognitiveSpeed, target:self, selector:"cognitiveCore:", userInfo:nil, repeats:true)
        actionRegulator = NSTimer.scheduledTimerWithTimeInterval(actionSpeed, target:self, selector:"actionCore:", userInfo:nil, repeats:true)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Core Operators
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func halt()
    {
        operatingState = OperatingState.HALTED
    }
    
    func proceed()
    {
        operatingState = OperatingState.RUNNING
    }
    
    // Performs exactly one action and halts
    func nextAction()
    {
        operatingState = OperatingState.STEPPING
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Cognitive Core
    //////////////////////////////////////////////////////////////////////////////////////////
    @objc func cognitiveCore(timer:NSTimer)
    {
        if (operatingState != .HALTED)
        {
            
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Action Core
    //////////////////////////////////////////////////////////////////////////////////////////
    @objc func actionCore(timer:NSTimer)
    {
        if (operatingState != .HALTED)
        {
            // WARXING: Perform the next action on the queue
            if (!actions.isEmpty())
            {
                if let nextAction = actions.dequeue()
                {
                    if (nextAction.layer == .TERRAIN)
                    {
                        model.setTerrainTileAt(nextAction.coord, uid:nextAction.value, collaboratorID:nextAction.collaboratorUUID)
                    }
                    else if (nextAction.layer == .DOODAD)
                    {
                        model.setDoodadTileAt(nextAction.coord, uid:nextAction.value, collaboratorID:nextAction.collaboratorUUID)
                    }
                }
            }
            
            if (operatingState == .STEPPING)
            {
                operatingState = .HALTED
            }
        }
    }
}