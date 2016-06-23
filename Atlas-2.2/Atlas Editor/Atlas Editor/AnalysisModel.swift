//
//  AnalysisModel.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/18/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

protocol AnalysisModelResponder
{
    func terrainTileUIDAt(coord:DiscreteTileCoord) -> Int
    func doodadTileUIDAt(coord:DiscreteTileCoord) -> Int
    func mapBounds() -> TileRect
}

enum LayerStatus
{
    case BUSY, FREE
}

enum LayerVisibility
{
    case BRIGHT, DIM, HIDDEN
}

class AnalysisModel : AnalysisModelResponder
{
    var analysisView:AnalysisView?
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // MAP LAYER
    var baseMap:TileMap
    var mapLayerStatus:LayerStatus = LayerStatus.FREE
    var mapLayerVisibility:LayerVisibility = LayerVisibility.HIDDEN
    var mapActions:Queue<DiscreteTileCoord>
    //////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // DENSITY LAYER
    var densityMap:AtomicMap<Int>
    //////////////////////////////////////////////////////////////////////////////////////////
    
    init(baseMap:TileMap)
    {
        self.baseMap = baseMap
        self.mapActions = Queue<DiscreteTileCoord>()
        
        self.densityMap = AtomicMap<Int>(xMax:baseMap.mapBounds().width(), yMax:baseMap.mapBounds().height(), filler:0, offset:DiscreteTileCoord(x:0, y:0))
    }
    
    func registerView(view:AnalysisView)
    {
        self.analysisView = view
    }
    
    func update()
    {
        if (mapActions.count > 0)
        {
            mapLayerStatus = .BUSY
            
            let coolFactor = (mapActions.count > 250) ? 25 : Int(ceil(Double(mapActions.count) / 10.0))
            for _ in 1...coolFactor
            {
                if let mapCoord = mapActions.dequeue()
                {
                    analysisView?.updateTileViewAt(mapCoord)
                }
            }
            
            if (mapActions.count == 0)
            {
                let _ = NSTimer.scheduledTimerWithTimeInterval(0.4, target:self, selector:#selector(AnalysisModel.freeVisualStatus), userInfo:nil, repeats:false)
            }
        }
    }
    
    @objc func freeVisualStatus()
    {
        mapLayerStatus = LayerStatus.FREE
        mapLayerVisibility = LayerVisibility.BRIGHT
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // MAP LAYER VIEW ACTIONS
    
    func hideMapLayer()
    {
        analysisView?.hideMapLayer()
        mapLayerVisibility = LayerVisibility.HIDDEN
    }
    
    func brightenMapLayer()
    {
        analysisView?.brightenMapLayer()
        mapLayerVisibility = LayerVisibility.BRIGHT
    }
    
    func dimMapLayer()
    {
        analysisView?.dimMapLayer()
        mapLayerVisibility = LayerVisibility.DIM
    }
    
    func clearDensity()
    {
        densityMap.reset()
        analysisView?.clearDensity()
    }
    
    func clearSkeleton()
    {
        analysisView?.clearSkeleton()
    }
    
    func initializeMapLayer()
    {
        let bounds = baseMap.mapBounds()
        
        for coord in bounds.allCoords()
        {
            mapActions.enqueue(coord)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // MAP LAYER METHODS
    
    func terrainTileUIDAt(coord:DiscreteTileCoord) -> Int
    {
        return baseMap.terrainTileUIDAt(coord)
    }
    
    func doodadTileUIDAt(coord:DiscreteTileCoord) -> Int
    {
        return baseMap.doodadTileUIDAt(coord)
    }
    
    func mapBounds() -> TileRect
    {
        return baseMap.mapBounds()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // DENSITY LAYER METHODS
    
    func updateDensityAt(coord:DiscreteTileCoord, density:Int)
    {
        let oldDensity = densityMap[coord]
        
        if (oldDensity != density)
        {
            densityMap[coord] = density
            
            if (oldDensity == 0)
            {
                analysisView?.addDensityNodeAt(coord, density:density)
            }
            else if (density == 0)
            {
                analysisView?.removeDensityNodeAt(coord)
            }
            else
            {
                analysisView?.changeDensityNodeAt(coord, density:density)
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // SKELETON NODE METHODS
    
    func addSkeletonNode(node:SkeletonNode)
    {
        analysisView?.addSkeletonNode(node)
    }
}