//
//  Odin.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/19/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

protocol ACCanvasDelegate
{
    // Canvas Actions
    func initializeMap()
    func setDensityAt(coord:DiscreteTileCoord, density:Int)
    func dimMapLayer()
    func hideMapLayer()
    func brightenMapLayer()
    
    func clearDenisty()
    func clearSkeleton()
    func addSkeletonNode(node:SkeletonNode)
    
    // Canvas Observations
    func modelMapLayerStatus() -> Bool
    func modelMapLayerBounds() -> TileRect
    func terrainValueAt(coord:DiscreteTileCoord) -> Int
}

class Odin : IntelligentAgentDelegate, ACCanvasDelegate
{
    var model:AnalysisModel
    
    var operatingState:OperatingState = OperatingState.HALTED
    
    var tasks:ACTaskList
    var hackCount:Int = 0
    
    var cognitionRegulator:NSTimer = NSTimer()
    
    init(model:AnalysisModel)
    {
        tasks = ACTaskList()
        
        self.model = model
        self.cognitionRegulator = NSTimer()
        self.initializeRegulators()
        
        tasks.registerCanvasDelegate(self)
        
        let initializeTask = ACInitializeMapLayerTask()
        tasks.insertSubtaskLast(initializeTask)
        
        let analysisTask = ACShapeDensityTask(importantTiles:Set([1,2,3,4]))
        tasks.insertSubtaskLast(analysisTask)
    }
    
    func initializeRegulators()
    {
        let cognitiveSpeed = 1.0/Double(30)
        cognitionRegulator = NSTimer.scheduledTimerWithTimeInterval(cognitiveSpeed, target:self, selector:#selector(Odin.cognitiveCore(_:)), userInfo:nil, repeats:true)
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
        // WARXING: HACKERY
        if (hackCount == 0)
        {
            operatingState = OperatingState.RUNNING
        }
        else if (hackCount == 1)
        {
            clearDenisty()
            clearSkeleton()
        }
        else if (hackCount == 2)
        {
            brightenMapLayer()
        }
        else if (hackCount == 3)
        {
            let analysisTask = ACShapeDensityTask(importantTiles:Set([3,4]))
            tasks.insertSubtaskLast(analysisTask)
        }
        else if (hackCount == 4)
        {
            clearDenisty()
            clearSkeleton()
        }
        else if (hackCount == 5)
        {
            brightenMapLayer()
        }
        else if (hackCount == 6)
        {
            let analysisTask = ACShapeDensityTask(importantTiles:Set([1,2]))
            tasks.insertSubtaskLast(analysisTask)
        }
        
        hackCount += 1
        
    }
    
    // Performs exactly one action and halts
    func nextAction()
    {
        operatingState = OperatingState.STEPPING
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Action Core
    //////////////////////////////////////////////////////////////////////////////////////////
    @objc func cognitiveCore(timer:NSTimer)
    {
        if (operatingState != .HALTED)
        {
            if (tasks.subtasksRemaining())
            {
                tasks.applyNextSubtask()
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Canvas Delegate
    //////////////////////////////////////////////////////////////////////////////////////////
    func initializeMap()
    {
        model.initializeMapLayer()
    }
    
    func setDensityAt(coord:DiscreteTileCoord, density:Int)
    {
        model.updateDensityAt(coord, density:density)
    }
    
    func dimMapLayer()
    {
        model.dimMapLayer()
    }
    
    func hideMapLayer()
    {
        model.hideMapLayer()
    }
    
    func brightenMapLayer()
    {
        model.brightenMapLayer()
    }
    
    func addSkeletonNode(node:SkeletonNode)
    {
        model.addSkeletonNode(node)
    }
    
    func clearDenisty()
    {
        model.clearDensity()
    }
    
    func clearSkeleton()
    {
        model.clearSkeleton()
    }
    
    
    
    func modelMapLayerStatus() -> Bool
    {
        return model.mapLayerStatus == .FREE
    }
    
    func modelMapLayerBounds() -> TileRect
    {
        return model.baseMap.mapBounds()
    }
    
    func terrainValueAt(coord:DiscreteTileCoord) -> Int
    {
        return model.baseMap.terrainTileUIDAt(coord)
    }
}