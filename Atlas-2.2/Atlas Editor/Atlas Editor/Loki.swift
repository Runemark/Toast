//
//  Loki.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/24/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

protocol LKCanvasDelegate
{
    func typeForVariableId(id:String) -> LKVariableType?
    
    func registerString(string:String) -> String
    func registerAtomicMap(map:AtomicMap<Int>) -> String
    
    func getString(id:String) -> String?
    func getAtomicMap(id:String) -> AtomicMap<Int>?
    
    func loadMapMetaData(bounds:TileRect)
    func setMapTile(coord:DiscreteTileCoord, value:Int)
}

enum LKVariableType
{
    case STRING, ATOMICMAP
}

class Loki : LKCanvasDelegate
{
    var analysisView:LKAnalysisView
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Computational Canvas
    //////////////////////////////////////////////////////////////////////////////////////////
    var styleGuide:Bool = false
    
    var variables:[String:LKVariableType]
    
    var strings:[String:String]
    
    var atomicMaps:[String:AtomicMap<Int>]
    var densityMaps:[String:DensityMap]
    var skeletons:[String:SkeletonMap]
    var regions:[String:TileRect]
    
    var root:LKTask
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Cognition
    //////////////////////////////////////////////////////////////////////////////////////////
    var operatingState:OperatingState = OperatingState.HALTED
    var regulator:NSTimer = NSTimer()
    
    init(analysisView:LKAnalysisView)
    {
        self.analysisView = analysisView
        
        self.variables = [String:LKVariableType]()
        
        self.strings = [String:String]()
        
        self.atomicMaps = [String:AtomicMap<Int>]()
        self.densityMaps = [String:DensityMap]()
        self.skeletons = [String:SkeletonMap]()
        self.regions = [String:TileRect]()
        
        self.root = LKAnalysisTask(subtaskId:0)
        self.root.registerCanvas(self)
        
        initializeRegulator()
    }
    
    func initializeRegulator()
    {
        let cognitiveSpeed = 1.0/Double(30)
        regulator = NSTimer.scheduledTimerWithTimeInterval(cognitiveSpeed, target:self, selector:#selector(Loki.cognitiveCore(_:)), userInfo:nil, repeats:true)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Cognitive Core
    //////////////////////////////////////////////////////////////////////////////////////////
    @objc func cognitiveCore(timer:NSTimer)
    {
        if (operatingState != .HALTED)
        {
            if let nextSubtask = root.nextSubtask()
            {
                nextSubtask.apply()
            }
        }
    }
    
    func proceed()
    {
        operatingState = .RUNNING
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //   Computational Canvas
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////
    // Variables
    ////////////////////////////////////////////////////////////
    func typeForVariableId(id:String) -> LKVariableType?
    {
        return variables[id]
    }
    
    func registerString(string:String) -> String
    {
        let id = generateVariableId()
        
        strings[id] = string
        variables[id] = LKVariableType.STRING
        
        return id
    }
    
    func registerAtomicMap(map:AtomicMap<Int>) -> String
    {
        let id = generateVariableId()
        
        atomicMaps[id] = map
        variables[id] = LKVariableType.ATOMICMAP
        
        return id
    }
    
    func getString(id:String) -> String?
    {
        return strings[id]
    }
    
    func getAtomicMap(id:String) -> AtomicMap<Int>?
    {
        return atomicMaps[id]
    }
    
    func generateVariableId() -> String
    {
        return NSUUID().UUIDString
    }
    
    ////////////////////////////////////////////////////////////
    // Visual
    ////////////////////////////////////////////////////////////
    
    func loadMapMetaData(bounds:TileRect)
    {
        analysisView.loadMapMetaData(bounds)
    }
    
    func setMapTile(coord:DiscreteTileCoord, value:Int)
    {
        analysisView.setMapTileAt(coord, uid:value)
    }
}