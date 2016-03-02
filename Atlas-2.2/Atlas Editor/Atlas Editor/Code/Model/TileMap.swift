//
//  Map.swift
//  Atlas 2.1
//
//  Created by Dusty Artifact on 12/12/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

protocol DirectMapObserver
{
    func terrainChangedAt(coord:DiscreteTileCoord, old:Int, new:Int, collaboratorID:String?)
    func doodadChangedAt(coord:DiscreteTileCoord, old:Int, new:Int, collaboratorID:String?)
    func registerModelDelegate(delegate:DirectModelDelegate)
}

protocol DirectModelDelegate
{
    func getBounds() -> TileRect
    func terrainTileUIDAt(coord:DiscreteTileCoord) -> Int
    func doodadTileUIDAt(coord:DiscreteTileCoord) -> Int
    func setTerrainTileAt(coord:DiscreteTileCoord, uid:Int, collaboratorID:String?)
    func setDoodadTileAt(coord:DiscreteTileCoord, uid:Int, collaboratorID:String?)
    func terrainTileExistsAt(coord:DiscreteTileCoord) -> Bool
    func doodadTileExistsAt(coord:DiscreteTileCoord) -> Bool
    
    func registerChange(change:Change)
    
    func allTerrainObstacles() -> Set<Int>
    func allTerrainPathables() -> Set<Int>
}

class TileMap : DirectModelDelegate
{
    private var terrainTiles:[DiscreteTileCoord:Int]
    private var doodadTiles:[DiscreteTileCoord:Int]
    private var bounds:TileRect
    private var tilesetData:TilesetData?
    
    private var directObservers:[DirectMapObserver]
    
    private var changes:ChangeQueue
    private var title:String
    
    init(bounds:TileRect, title:String)
    {
        self.bounds = bounds
        self.title = title
        terrainTiles = [DiscreteTileCoord:Int]()
        doodadTiles = [DiscreteTileCoord:Int]()
        
        directObservers = [DirectMapObserver]()
        
        changes = ChangeQueue(capacity:100)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Observers
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func registerDirectObserver(observer:DirectMapObserver)
    {
        observer.registerModelDelegate(self)
        directObservers.append(observer)
    }
    
    func notifyDirectObserversOfTerrainChange(coord:DiscreteTileCoord, old:Int, new:Int, collaboratorID:String?)
    {
        for observer in directObservers
        {
            observer.terrainChangedAt(coord, old:old, new:new, collaboratorID:collaboratorID)
        }
    }
    
    func notifyDirectObserversOfDoodadChange(coord:DiscreteTileCoord, old:Int, new:Int, collaboratorID:String?)
    {
        for observer in directObservers
        {
            observer.doodadChangedAt(coord, old:old, new:new, collaboratorID:collaboratorID)
        }
    }
    
    func notifyRemoteObserversOfTerrainChange(coord:DiscreteTileCoord, new:Int)
    {
        
    }
    
    func removeAllObservers()
    {
        directObservers.removeAll()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Model Access Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func mapTitle() -> String
    {
        return title
    }
    
    func mapBounds() -> TileRect
    {
        return bounds
    }
    
    func registerChange(change:Change)
    {
        changes.pushChange(change)
    }
    
    func applyNextChange()
    {
        if let nextChange = changes.popChange()
        {
            let coord = nextChange.coord
            let value = nextChange.value
            let collaboratorID = nextChange.collaboratorUUID
            
            if (nextChange.layer == TileLayer.TERRAIN)
            {
                setTerrainTileAt(coord, uid:value, collaboratorID:collaboratorID)
            }
            else if (nextChange.layer == TileLayer.DOODAD)
            {
                setDoodadTileAt(coord, uid:value, collaboratorID:collaboratorID)
            }
        }
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Model Access Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func withinBounds(coord:DiscreteTileCoord) -> Bool
    {
        return bounds.contains(coord)
    }
    
    func terrainTileExistsAt(coord:DiscreteTileCoord) -> Bool
    {
        if let _ = terrainTiles[coord]
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func doodadTileExistsAt(coord:DiscreteTileCoord) -> Bool
    {
        if let _ = doodadTiles[coord]
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func terrainTileUIDAt(coord:DiscreteTileCoord) -> Int
    {
        if let uid = terrainTiles[coord]
        {
            return uid
        }
        else
        {
            return 0
        }
    }
    
    func doodadTileUIDAt(coord:DiscreteTileCoord) -> Int
    {
        if let uid = doodadTiles[coord]
        {
            return uid
        }
        else
        {
            return 0
        }
    }
    
    func getBounds() -> TileRect
    {
        return bounds
    }
    
    func directlySetTerrainTileAt(coord:DiscreteTileCoord, uid:Int)
    {
        terrainTiles[coord] = uid
    }
    
    func directlySetDoodadTileAt(coord:DiscreteTileCoord, uid:Int)
    {
        doodadTiles[coord] = uid
    }
    
    func setTerrainTileAt(coord:DiscreteTileCoord, uid:Int, collaboratorID:String?)
    {
        if withinBounds(coord)
        {
            if let oldType = terrainTiles[coord]
            {
                if (oldType != uid)
                {
                    if (uid == 0)
                    {
                        terrainTiles.removeValueForKey(coord)
                    }
                    else if (oldType != uid)
                    {
                        terrainTiles[coord] = uid
                    }
                    
                    removeDoodadAt(coord, collaboratorID:collaboratorID)
                    notifyDirectObserversOfTerrainChange(coord, old:oldType, new:uid, collaboratorID:collaboratorID)
                }
            }
            else
            {
                if (uid > 0)
                {
                    terrainTiles[coord] = uid
                    removeDoodadAt(coord, collaboratorID:collaboratorID)
                    notifyDirectObserversOfTerrainChange(coord, old:0, new:uid, collaboratorID:collaboratorID)
                }
            }
        }
    }
    
    // Doodads can only be placed on non-void, non-obstacle terrain
    // If a doodad already exists at the coordinate, it will be replaced instantly
    func canPlaceDoodadAt(coord:DiscreteTileCoord) -> Bool
    {
        var canPlace = false
        
        let underlyingTerrainUID = terrainTileUIDAt(coord)
        if (underlyingTerrainUID > 0)
        {
            if let underlyingTerrainIsObstacle = tilesetData?.isObstacle(underlyingTerrainUID)
            {
                if (!underlyingTerrainIsObstacle)
                {
                    canPlace = true
                }
            }
        }
        
        return canPlace
    }
    
    func setDoodadTileAt(coord:DiscreteTileCoord, uid:Int, collaboratorID:String?)
    {
        if (withinBounds(coord))
        {
            if let oldType = doodadTiles[coord]
            {
                if (oldType != uid)
                {
                    if (uid == 0)
                    {
                        doodadTiles.removeValueForKey(coord)
                    }
                    else if (oldType != uid)
                    {
                        doodadTiles[coord] = uid
                    }
                    
                    notifyDirectObserversOfDoodadChange(coord, old:oldType, new:uid, collaboratorID:collaboratorID)
                }
            }
            else
            {
                // There did not used to be any tile here
                if (uid > 0)
                {
                    doodadTiles[coord] = uid
                    notifyDirectObserversOfDoodadChange(coord, old:0, new:uid, collaboratorID:collaboratorID)
                }
            }
        }
    }
    
    func removeDoodadAt(coord:DiscreteTileCoord, collaboratorID:String?)
    {
        if (doodadTileExistsAt(coord))
        {
            setDoodadTileAt(coord, uid:0, collaboratorID:collaboratorID)
        }
    }
    
    func randomCoord() -> DiscreteTileCoord
    {
        let random_x = randIntBetween(bounds.left, stop:bounds.right)
        let random_y = randIntBetween(bounds.down, stop:bounds.up)
        
        return DiscreteTileCoord(x:random_x, y:random_y)
    }
    
    func clearAllTerrainTiles()
    {
        terrainTiles.removeAll()
    }
    
    func clearAllDoodadTiles()
    {
        terrainTiles.removeAll()
    }
    
    func clearAllTiles()
    {
        clearAllTerrainTiles()
        clearAllDoodadTiles()
    }
    
    func setAllTerrainTiles(uid:Int, directly:Bool)
    {
        for x in bounds.left...bounds.right
        {
            for y in bounds.down...bounds.up
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                
                if (directly)
                {
                    directlySetTerrainTileAt(coord, uid:uid)
                }
                else
                {
                    // Enqueue change
                    let change = Change(coord:coord, layer:TileLayer.TERRAIN, value:uid, collaboratorUUID:nil)
                    registerChange(change)
                }
            }
        }
    }
    
    func allTerrainData() -> [DiscreteTileCoord:Int]
    {
        return terrainTiles
    }
    
    func randomizeAllTerrainTiles(uids:Set<Int>, directly:Bool)
    {
        for x in bounds.left...bounds.right
        {
            for y in bounds.down...bounds.up
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                if let randomUID = uids.randomElement()
                {
                    if (directly)
                    {
                        directlySetTerrainTileAt(coord, uid:randomUID)
                    }
                    else
                    {
                        // Enqueue change
                        let change = Change(coord:coord, layer:TileLayer.TERRAIN, value:randomUID, collaboratorUUID:nil)
                        registerChange(change)
                    }
                }
            }
        }
    }
    
    func randomizeAllDoodadTiles(uids:Set<Int>, directly:Bool)
    {
        for x in bounds.left...bounds.right
        {
            for y in bounds.down...bounds.up
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                
                if (canPlaceDoodadAt(coord))
                {
                    if let randomUID = uids.randomElement()
                    {
                        if (directly)
                        {
                            directlySetDoodadTileAt(coord, uid:randomUID)
                        }
                        else
                        {
                            // Enqueue change
                            let change = Change(coord:coord, layer:TileLayer.DOODAD, value:randomUID, collaboratorUUID:nil)
                            registerChange(change)
                        }
                    }
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Tileset Data
    //////////////////////////////////////////////////////////////////////////////////////////
    func swapTilesetData(newTilesetData:TilesetData)
    {
        self.tilesetData = newTilesetData
    }
    
    func allTerrainObstacles() -> Set<Int>
    {
        if let tilesetData = tilesetData
        {
            return tilesetData.allTerrainObstacles()
        }
        else
        {
            return Set<Int>()
        }
    }
    
    func allTerrainPathables() -> Set<Int>
    {
        if let tilesetData = tilesetData
        {
            return tilesetData.allTerrainPathables()
        }
        else
        {
            return Set<Int>()
        }
    }
}