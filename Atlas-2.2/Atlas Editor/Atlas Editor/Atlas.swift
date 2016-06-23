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

protocol QQCanvasDelegate
{
    func canvasBounds() -> TileRect
    func atomicValueAt(coord:DiscreteTileCoord) -> Int
    func setTerrainTileAt(coord:DiscreteTileCoord, value:Int)
    func updateDensityNodeAt(coord:DiscreteTileCoord, density:Int)
    func clearDensity()
    func registerComponentRect(rect:TileRect)
    func componentRectCount() -> Int
    func addFlowNodeAt(coord:DiscreteTileCoord, diameter:Int)
    func redrawFlowMap(flowMap:FlowMap)
    func addFlowLineAt(line:LineSegment)
    func redrawComponentLayout(layout:ComponentLayout)
}

class Atlas : QQCanvasDelegate
{
    var model:TileMap
    var mapView:TileMapView?
    var bounds:TileRect
    var guide:FRStyleGuide
    var task:QQTask
    
    var operatingState:OperatingState = OperatingState.HALTED
    
    var cognitionRegulator:NSTimer = NSTimer()
    var actionRegulator:NSTimer = NSTimer()
    
    var actions:Queue<Change>
    
    var components:[TileRect]
    
    init(model:TileMap, bounds:TileRect, guide:FRStyleGuide)
    {
        self.model = model
        self.bounds = bounds
        self.guide = guide
        
        self.actions = Queue<Change>()
        
        self.cognitionRegulator = NSTimer()
        self.actionRegulator = NSTimer()
        
//        self.task = ZZBuildLevel()
        self.task = GenerateRandomShape()
        
        self.components = [TileRect]()
        
        task.registerCanvas(self)
        
        self.initializeRegulators()
    }
    
    func registerMapView(mapView:TileMapView)
    {
        self.mapView = mapView
    }
    
    func initializeRegulators()
    {
        let cognitiveSpeed = 1.0/Double(8)
        let actionSpeed = 1.0/Double(60)
        
        cognitionRegulator = NSTimer.scheduledTimerWithTimeInterval(cognitiveSpeed, target:self, selector:#selector(Atlas.cognitiveCore(_:)), userInfo:nil, repeats:true)
        actionRegulator = NSTimer.scheduledTimerWithTimeInterval(actionSpeed, target:self, selector:#selector(Atlas.actionCore(_:)), userInfo:nil, repeats:true)
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
//            let randomCoord = bounds.randomCoord()
//            let randomUID = randIntBetween(0, stop:2)
//            let change = Change(coord:randomCoord, layer:TileLayer.TERRAIN, value:randomUID, collaboratorUUID:"Internal")
//            actions.enqueue(change)
            
            if let nextTask = task.nextSubtask()
            {
                nextTask.apply()
            }
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
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // CANVAS METHODS
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func canvasBounds() -> TileRect
    {
        return bounds
    }
    
    func atomicValueAt(coord:DiscreteTileCoord) -> Int
    {
        return model.terrainTileUIDAt(coord)
    }
    
    func setTerrainTileAt(coord:DiscreteTileCoord, value:Int)
    {
        let change = Change(coord:coord, layer:TileLayer.TERRAIN, value:value, collaboratorUUID:"Internal")
        actions.enqueue(change)
    }
    
    func updateDensityNodeAt(coord:DiscreteTileCoord, density:Int)
    {
        if let mapView = mapView
        {
            mapView.updateDensityNodeAt(coord, density:density)
        }
    }
    
    func clearDensity()
    {
        if let mapView = mapView
        {
            mapView.clearDensity()
        }
    }
    
    func registerComponentRect(rect:TileRect)
    {
        components.append(rect)
    }
    
    func componentRectCount() -> Int
    {
        return components.count
    }
    
    func addFlowNodeAt(coord:DiscreteTileCoord, diameter:Int)
    {
//        if let mapView = mapView
//        {
//            mapView.addFlowNodeAt(coord, diameter:diameter)
//        }
    }
    
    func redrawFlowMap(flowMap:FlowMap)
    {
        if let mapView = mapView
        {
            mapView.clearFlow()
            mapView.drawFlow(flowMap)
        }
    }
    
    func addFlowLineAt(line:LineSegment)
    {
        if let mapView = mapView
        {
            mapView.addConnection(line)
        }
    }
    
    func redrawComponentLayout(layout:ComponentLayout)
    {
        if let mapView = mapView
        {
            mapView.drawLayout(layout)
        }
    }
}