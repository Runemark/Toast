//
//  TileMapView.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/6/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

class TileMapView : SKNode, DirectMapObserver
{
    //////////////////////////////////////////////////////////////////////////////////////////
    // View
    var baseTileLayer:SKNode
    var stackedTileLayer:SKNode
    var heightTileLayer:SKNode
    var changeIndicatorLayer:SKNode
    
    var tileSize:CGSize
    var viewBoundSize:CGSize
    
    var cameraOnScreen:CGPoint
    var tileViewRect:TileRect?
    //////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Model
    var tileset:Tileset?
    var modelDelegate:DirectModelDelegate?
    var mapBounds:TileRect
    var cameraInWorld:TileCoord
    //////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // View Model
    var registeredBaseTiles:[DiscreteTileCoord:TileView]
    var registeredStackedTiles:[DiscreteTileCoord:TileView]
    var registeredHeightTiles:[DiscreteTileCoord:TileView]
    var registeredChangeIndicators:[DiscreteTileCoord:ChangeIndicator]
    //////////////////////////////////////////////////////////////////////////////////////////
    
    init(window:CGSize, viewSize:CGSize, tileSize:CGSize)
    {
        self.tileSize = tileSize
        self.viewBoundSize = viewSize
        
        cameraInWorld = TileCoord(x:0.0, y:0.0)
        cameraOnScreen = CGPointZero
        
        baseTileLayer = SKNode()
        baseTileLayer.position = CGPointZero
        
        stackedTileLayer = SKNode()
        stackedTileLayer.position = CGPointZero
        
        heightTileLayer = SKNode()
        heightTileLayer.position = CGPointZero
        
        changeIndicatorLayer = SKNode()
        changeIndicatorLayer.position = CGPointZero
        
        registeredBaseTiles = [DiscreteTileCoord:TileView]()
        registeredStackedTiles = [DiscreteTileCoord:TileView]()
        registeredHeightTiles = [DiscreteTileCoord:TileView]()
        registeredChangeIndicators = [DiscreteTileCoord:ChangeIndicator]()
        
        mapBounds = TileRect(left:0, right:0, up:0, down:0)
        
        super.init()
        
        self.addChild(baseTileLayer)
        self.addChild(stackedTileLayer)
        self.addChild(heightTileLayer)
        self.addChild(changeIndicatorLayer)
        
        // Equivalent of a 4x view (where a 3x is the maximum zoom)
        let boundWidth = (window.width - viewBoundSize.width)/2.0
        let boundHeight = (window.height - viewBoundSize.height)/2.0
        let boundColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        
        let leftBound = SKSpriteNode(imageNamed:"square")
        leftBound.resizeNode(boundWidth, y:window.height)
        leftBound.position = CGPointMake(-1.0*(viewBoundSize.width*0.5) - (boundWidth*0.5), 0)
        leftBound.color = boundColor
        leftBound.colorBlendFactor = 1.0
        self.addChild(leftBound)
        
        let rightBound = SKSpriteNode(imageNamed:"square")
        rightBound.resizeNode(boundWidth, y:window.height)
        rightBound.position = CGPointMake(viewBoundSize.width*0.5 + (boundWidth*0.5), 0)
        rightBound.color = boundColor
        rightBound.colorBlendFactor = 1.0
        self.addChild(rightBound)

        let upperBound = SKSpriteNode(imageNamed:"square")
        upperBound.resizeNode(window.width, y:boundHeight)
        upperBound.position = CGPointMake(0, viewBoundSize.height*0.5 + (boundHeight*0.5))
        upperBound.color = boundColor
        upperBound.colorBlendFactor = 1.0
        self.addChild(upperBound)

        let lowerBound = SKSpriteNode(imageNamed:"square")
        lowerBound.resizeNode(window.width, y:boundHeight)
        lowerBound.position = CGPointMake(0, -1.0*(viewBoundSize.height*0.5) - (boundHeight*0.5))
        lowerBound.color = boundColor
        lowerBound.colorBlendFactor = 1.0
        self.addChild(lowerBound)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Tile Translation
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func translateView(screenDelta:CGPoint)
    {
        let screenCameraDelta = CGPointMake(-1*screenDelta.x, -1*screenDelta.y)
        let tileCameraDelta = tileDeltaForScreenDelta(screenCameraDelta, tileSize:tileSize)
        cameraInWorld += tileCameraDelta
        
        repositionTilesInView(screenDelta)
        let rectInfo = recalculateTileRect()
        if (rectInfo.updateNeeded)
        {
            updateTilesInView(rectInfo.oldRect)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Change Indicators
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func addChangeIndicatorAt(coord:DiscreteTileCoord, color:UIColor)
    {
        if let oldIndicator = registeredChangeIndicators[coord]
        {
            removeChangeIndicator(oldIndicator, coord:coord)
        }
        
//        let attributionColor = UIColor(red:1.0, green:0.0, blue:0.0, alpha:1.0)
        let changeIndicator = ChangeIndicator(tileSize:tileSize, color:color)
        changeIndicator.position = screenPosForTileViewAtCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
        
        let fadeAction = fadeTo(changeIndicator, alpha:0.0, duration:0.32, type:CurveType.QUADRATIC_IN)
        changeIndicator.runAction(fadeAction) { () -> Void in
            self.removeChangeIndicator(changeIndicator, coord:coord)
        }
        
        changeIndicatorLayer.addChild(changeIndicator)
        registeredChangeIndicators[coord] = changeIndicator
    }
    
    func removeChangeIndicator(indicator:ChangeIndicator, coord:DiscreteTileCoord)
    {
        indicator.removeFromParent()
        registeredChangeIndicators.removeValueForKey(coord)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Tile Drawing/Updating
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func addBaseTileViewAt(coord:DiscreteTileCoord, uid:Int)
    {
        if (uid > 0)
        {
            if let texture = tileset?.baseTextureForUID(uid)
            {
                let tileView = createTileViewWithTexture(texture, coord:coord)
                baseTileLayer.addChild(tileView)
                
                registeredBaseTiles[coord] = tileView
            }
        }
    }
    
    func addBaseTileViewFromSideAt(coord:DiscreteTileCoord, aboveUID:Int)
    {
        if (aboveUID > 0)
        {
            if let texture = tileset?.sideTextureForUID(aboveUID)
            {
                let tileView = createTileViewWithTexture(texture, coord:coord)
                baseTileLayer.addChild(tileView)
                
                registeredBaseTiles[coord] = tileView
            }
        }
    }
    
    func addBaseTileViewFromExtendedSideAt(coord:DiscreteTileCoord, aboveUID:Int)
    {
        if (aboveUID > 0)
        {
            if let texture = tileset?.extendedSideTextureForUID(aboveUID)
            {
                let tileView = createTileViewWithTexture(texture, coord:coord)
                baseTileLayer.addChild(tileView)
                
                registeredBaseTiles[coord] = tileView
            }
        }
    }
    
    func addStackedTileViewAt(coord:DiscreteTileCoord, uid:Int)
    {
        if (uid > 0)
        {
            if let texture = tileset?.baseTextureForUID(uid)
            {
                let tileView = createTileViewWithTexture(texture, coord:coord)
                stackedTileLayer.addChild(tileView)
                
                registeredStackedTiles[coord] = tileView
            }
        }
    }
    
    // The coord is where the height tile should be PLACED visually
    // The UID is for the coord BELOW (the height tile's "base")
    func addHeightTileViewAt(coord:DiscreteTileCoord, uid:Int)
    {
        if (uid > 0)
        {
            if let texture = tileset?.topTextureForUID(uid)
            {
                let tileView = createTileViewWithTexture(texture, coord:coord)
                heightTileLayer.addChild(tileView)
                
                registeredHeightTiles[coord] = tileView
            }
        }
    }
    
    func createTileViewWithTexture(texture:SKTexture, coord:DiscreteTileCoord) -> TileView
    {
        let tileView = TileView(texture:texture, size:tileSize)
        tileView.position = screenPosForTileViewAtCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
        
        return tileView
    }
    
    func removeTileViewsAt(coord:DiscreteTileCoord)
    {
        removeBaseTileViewAt(coord)
        removeStackedTileViewAt(coord)
        removeHeightTileViewAt(coord)
    }
    
    func removeBaseTileViewAt(coord:DiscreteTileCoord)
    {
        if let tileView = registeredBaseTiles[coord]
        {
            tileView.removeFromParent()
            registeredBaseTiles.removeValueForKey(coord)
        }
    }
    
    func removeStackedTileViewAt(coord:DiscreteTileCoord)
    {
        if let tileView = registeredStackedTiles[coord]
        {
            tileView.removeFromParent()
            registeredStackedTiles.removeValueForKey(coord)
        }
    }
    
    func removeHeightTileViewAt(coord:DiscreteTileCoord)
    {
        if let tileView = registeredHeightTiles[coord]
        {
            tileView.removeFromParent()
            registeredHeightTiles.removeValueForKey(coord)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // View Drawing/Updating
    //////////////////////////////////////////////////////////////////////////////////////////

    func reloadMap()
    {
        if let _ = modelDelegate
        {
            mapBounds = modelDelegate!.getBounds()
            cameraInWorld = TileCoord(x:Double(mapBounds.left + mapBounds.right + 1)/2.0, y:Double(mapBounds.down + mapBounds.up + 1)/2.0)
            
            recalculateTileRect()
            completelyRedrawView()
        }
    }
    
    func recalculateTileRect() -> (updateNeeded:Bool, oldRect:TileRect?)
    {
        let rightScreenBound = CGFloat(viewBoundSize.width / 2.0)
        let leftScreenBound = -1.0 * rightScreenBound
        let upScreenBound = CGFloat(viewBoundSize.height / 2.0)
        let downScreenBound = -1.0 * upScreenBound
        
        let rightTileBound = tileCoordForScreenPos(CGPointMake(rightScreenBound, 0), cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize).roundDown().x
        let leftTileBound = tileCoordForScreenPos(CGPointMake(leftScreenBound, 0), cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize).roundDown().x
        let upTileBound = tileCoordForScreenPos(CGPointMake(0, upScreenBound), cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize).roundDown().y
        let downTileBound = tileCoordForScreenPos(CGPointMake(0, downScreenBound), cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize).roundDown().y
        
        let newTileViewRect = TileRect(left:leftTileBound, right:rightTileBound, up:upTileBound, down:downTileBound)
        
        var updateNeeded = true
        let oldTileViewRect = tileViewRect
        
        if let _ = oldTileViewRect
        {
            // Compare the old and new view rectangles
            if (oldTileViewRect!.compare(newTileViewRect))
            {
                updateNeeded = false
            }
        }
        
        tileViewRect = newTileViewRect
        
        return (updateNeeded:updateNeeded, oldRect:oldTileViewRect)
    }
    
    func clearView()
    {
        for (coord, tileSprite) in registeredBaseTiles
        {
            tileSprite.removeFromParent()
            registeredBaseTiles.removeValueForKey(coord)
        }
        
        for (coord, tileSprite) in registeredStackedTiles
        {
            tileSprite.removeFromParent()
            registeredStackedTiles.removeValueForKey(coord)
        }
        
        for (coord, tileSprite) in registeredHeightTiles
        {
            tileSprite.removeFromParent()
            registeredHeightTiles.removeValueForKey(coord)
        }
    }
    
    func repositionTilesInView(screenDelta:CGPoint)
    {
        for (_, tileSprite) in registeredBaseTiles
        {
            tileSprite.position += screenDelta
        }
        
        for (_, tileSprite) in registeredStackedTiles
        {
            tileSprite.position += screenDelta
        }
        
        for (_, tileSprite) in registeredHeightTiles
        {
            tileSprite.position += screenDelta
        }
        
        for (_, indicatorSprite) in registeredChangeIndicators
        {
            indicatorSprite.position += screenDelta
        }
    }
    
    // Redraws the entire view from scratch
    func updateTilesInView(oldRect:TileRect?)
    {
        if let _ = modelDelegate
        {
            if let oldRect = oldRect
            {
                if let newRect = tileViewRect
                {
                    let oldLeft = oldRect.left
                    let oldRight = oldRect.right
                    let oldUp = oldRect.up
                    let oldDown = oldRect.down
                    
                    let newLeft = newRect.left
                    let newRight = newRect.right
                    let newUp = newRect.up
                    let newDown = newRect.down
                    
                    let leftDelta = newLeft - oldLeft
                    let rightDelta = newRight - oldRight
                    let upDelta = newUp - oldUp
                    let downDelta = newDown - oldDown
                    
                    if (leftDelta > 0)
                    {
                        removeTilesInRect(oldLeft, right:newLeft-1, down:oldDown, up:oldUp)
                    }
                    else if (leftDelta < 0)
                    {
                        addMissingTilesInRect(newLeft, right:oldLeft-1, down:newDown, up:newUp)
                    }
                    
                    if (rightDelta > 0)
                    {
                        addMissingTilesInRect(oldRight+1, right:newRight, down:newDown, up:newUp)
                    }
                    else if (rightDelta < 0)
                    {
                        removeTilesInRect(newRight+1, right:oldRight, down:oldDown, up:oldUp)
                    }
                    
                    if (upDelta > 0)
                    {
                        addMissingTilesInRect(newLeft, right:newRight, down:oldUp+1, up:newUp)
                    }
                    else if (upDelta < 0)
                    {
                        removeTilesInRect(oldLeft, right:oldRight, down:newUp+1, up:oldUp)
                    }
                    
                    if (downDelta > 0)
                    {
                        removeTilesInRect(oldLeft, right:oldRight, down:oldDown, up:newDown-1)
                    }
                    else if (downDelta < 0)
                    {
                        addMissingTilesInRect(newLeft, right:newRight, down:newDown, up:oldDown-1)
                    }
                }
            }
            else
            {
                // Add any new coords not already on the board
                for x in tileViewRect!.left...tileViewRect!.right
                {
                    for y in tileViewRect!.down...tileViewRect!.up
                    {
                        let coord = DiscreteTileCoord(x:x, y:y)
                        var needsRedraw = true
                        if let _ = registeredBaseTiles[coord]
                        {
                            needsRedraw = false
                        }
                        if let _ = registeredStackedTiles[coord]
                        {
                            needsRedraw = false
                        }
                        if let _ = registeredHeightTiles[coord]
                        {
                            needsRedraw = false
                        }
                        
                        if (needsRedraw)
                        {
                            redrawTileViewsAt(x, y:y)
                        }
                    }
                }
            }
        }
    }
    
    func removeTilesInRect(left:Int, right:Int, down:Int, up:Int)
    {
        for x in left...right
        {
            for y in down...up
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                removeTileViewsAt(coord)
            }
        }
    }
    
    func addMissingTilesInRect(left:Int, right:Int, down:Int, up:Int)
    {
        for x in left...right
        {
            for y in down...up
            {
                redrawTileViewsAt(x, y:y)
            }
        }
    }
    
    func createTerrainBaseAt(coord:DiscreteTileCoord, uid:Int)
    {
        let coordBelow = coord.down()
        
        if let modelDelegate = modelDelegate
        {
            if let tileset = tileset
            {
                var alignmentCaseHandled = false
                if let alignment = tileset.alignmentForUID(uid)
                {
                    let belowUID = modelDelegate.terrainTileUIDAt(coordBelow)
                    if let belowHeight = tileset.sizeForUID(belowUID)
                    {
                        if (alignment == .VERTICAL && belowHeight == .SHORT)
                        {
                            addBaseTileViewFromSideAt(coord, aboveUID:uid)
                            alignmentCaseHandled = true
                        }
                    }
                }
                
                if (!alignmentCaseHandled)
                {
                    addBaseTileViewAt(coord, uid:uid)
                }
            }
        }
    }
    
    func createDoodadBaseAt(coord:DiscreteTileCoord, uid:Int)
    {
        addStackedTileViewAt(coord, uid:uid)
    }
    
    func redrawTileViewsAt(x:Int, y:Int)
    {
        let coord = DiscreteTileCoord(x:x, y:y)
        let coordBelow = coord.down()
        let coordAbove = coord.up()
        
        if let modelDelegate = modelDelegate
        {
            if let tileset = tileset
            {
                let terrainUID = modelDelegate.terrainTileUIDAt(coord)
                let belowTerrainUID = modelDelegate.terrainTileUIDAt(coordBelow)
                let doodadUID = modelDelegate.doodadTileUIDAt(coord)
                let belowDoodadUID = modelDelegate.doodadTileUIDAt(coordBelow)
                
                if let _ = registeredBaseTiles[coord]
                {
                    // If tile already exists here, do nothing
                }
                else
                {
                    if (terrainUID > 0)
                    {
                        createTerrainBaseAt(coord, uid:terrainUID)
                    }
                    else
                    {
                        let aboveUID = modelDelegate.terrainTileUIDAt(coordAbove)
                        if (aboveUID > 0)
                        {
                            let size = tileset.sizeForUID(aboveUID)
                            if (size == .SHORT)
                            {
                                addBaseTileViewFromSideAt(coord, aboveUID:aboveUID)
                            }
                            else if (size == .TALL)
                            {
                                addBaseTileViewFromExtendedSideAt(coord, aboveUID:aboveUID)
                            }
                        }
                    }
                }
                
                if let _ = registeredHeightTiles[coord]
                {
                    // If tile already exists here, do nothing
                }
                else
                {
                    if (belowTerrainUID > 0)
                    {
                        let terrainSize = tileset.sizeForUID(belowTerrainUID)
                        if (terrainSize == .TALL)
                        {
                            addHeightTileViewAt(coord, uid:belowTerrainUID)
                        }
                    }
                    
                    if (belowDoodadUID > 0)
                    {
                        let doodadSize = tileset.sizeForUID(belowDoodadUID)
                        if (doodadSize == .TALL)
                        {
                            addHeightTileViewAt(coord, uid:belowDoodadUID)
                        }
                    }
                }
                
                if let _ = registeredStackedTiles[coord]
                {
                    // If tile already exists here, do nothing
                }
                else
                {
                    if (doodadUID > 0)
                    {
                        createDoodadBaseAt(coord, uid:doodadUID)
                    }
                }
            }
        }
    }
    
    func completelyRedrawView()
    {
        clearView()
        
        for x in tileViewRect!.left...tileViewRect!.right
        {
            for y in tileViewRect!.down...tileViewRect!.up
            {
                let coord = DiscreteTileCoord(x:x, y:y)
                if (mapBounds.expandBelow().contains(coord))
                {
                    redrawTileViewsAt(x, y:y)
                }
            }
        }
    }
    
    // Position relative to the MapView
    func tileAtLocation(location:CGPoint) -> DiscreteTileCoord?
    {
        let tileLocation = tileCoordForScreenPos(location, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
        let discreteTileLocation = tileLocation.roundDown()
        
        if (tileViewRect!.contains(discreteTileLocation))
        {
            return discreteTileLocation
        }
        else
        {
            return nil
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Tileset Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func swapTileset(newTileset:Tileset)
    {
        self.tileset = newTileset
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    // Map Observer Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func terrainChangedAt(coord:DiscreteTileCoord, old:Int, new:Int, collaboratorID:String?)
    {
        if let tileViewRect = tileViewRect
        {
            // We only care if something actually changed
            if (old != new)
            {
                // We only care about the change if we can see it
                if tileViewRect.contains(coord)
                {
                    // SOMETHING to SOMETHING ELSE | SOMETHING to EMPTY
                    if (old > 0)
                    {
                        refreshTerrainFromPositiveSource(coord, new:new)
                    }
                    // EMPTY to SOMETHING
                    else
                    {
                        refreshTerrainFromNegativeSource(coord, new:new)
                    }
                    
                    if let collaboratorID = collaboratorID
                    {
                        if (collaboratorID == "Internal")
                        {
                            addChangeIndicatorAt(coord, color:UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0))
                        }
                        else if let color = NetworkController.sharedInstance.colorForCollaboratorID(collaboratorID)
                        {
                            addChangeIndicatorAt(coord, color:color)
                        }
                    }
                }
                else if tileViewRect.lineAboveRect().contains(coord)
                {
                    // SOMETHING to SOMETHING ELSE | SOMETHING to EMPTY
                    if (old > 0)
                    {
                        refreshTerrainBelowFromPositiveSource(coord, new:new)
                    }
                    // EMPTY to SOMETHING
                    else
                    {
                        refreshTerrainBelowFromNegativeSource(coord, new:new)
                    }
                }
                else if tileViewRect.lineBelowRect().contains(coord)
                {
                    // SOMETHING to SOMETHING ELSE | SOMETHING to EMPTY
                    if (old > 0)
                    {
                        refreshTerrainAboveFromPositiveSource(coord, new:new)
                    }
                    // EMPTY to SOMETHING
                    else
                    {
                        refreshTerrainAboveFromNegativeSource(coord, new:new)
                    }
                }
            }
        }
    }
    
    // Tile changed from SOMETHING to SOMETHING ELSE, or SOMETHING to EMPTY
    func refreshTerrainBelowFromPositiveSource(coord:DiscreteTileCoord, new:Int)
    {
        let coordBelow = coord.down()
        
        if tileViewRect!.contains(coordBelow)
        {
            if let uidBelow = modelDelegate?.terrainTileUIDAt(coordBelow)
            {
                if (uidBelow == 0)
                {
                    if let _ = registeredBaseTiles[coordBelow]
                    {
                        // This could happen if the tile above switched to a new tile, thus requiring the removing/replacing of the side texture
                        // If there used to be a tile here in the view, remove it
                        removeBaseTileViewAt(coordBelow)
                    }
                    
                    if (new > 0)
                    {
                        if let size = tileset?.sizeForUID(new)
                        {
                            // Add the side view below
                            if (size == .SHORT)
                            {
                                addBaseTileViewFromSideAt(coordBelow, aboveUID:new)
                            }
                            else if (size == .TALL)
                            {
                                addBaseTileViewFromExtendedSideAt(coordBelow, aboveUID:new)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Tile changed from EMPTY to SOMETHING
    func refreshTerrainBelowFromNegativeSource(coord:DiscreteTileCoord, new:Int)
    {
        let coordBelow = coord.down()
        
        // Update the side view below this coord (if needed)
        if tileViewRect!.contains(coordBelow)
        {
            if let uidBelow = modelDelegate?.terrainTileUIDAt(coordBelow)
            {
                if (uidBelow == 0)
                {
                    if let _ = registeredBaseTiles[coordBelow]
                    {
                        // If there used to be a tile here in the view, remove it
                        removeBaseTileViewAt(coordBelow)
                    }
                    
                    if (new > 0)
                    {
                        if let size = tileset?.sizeForUID(new)
                        {
                            // Add the side view below
                            if (size == .SHORT)
                            {
                                addBaseTileViewFromSideAt(coordBelow, aboveUID:new)
                            }
                            else if (size == .TALL)
                            {
                                addBaseTileViewFromExtendedSideAt(coordBelow, aboveUID:new)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func refreshTerrainAboveFromPositiveSource(coord:DiscreteTileCoord, new:Int)
    {
        let coordAbove = coord.up()
        
        if tileViewRect!.contains(coordAbove)
        {
            // Remove any height tile above
            removeHeightTileViewAt(coordAbove)
            
            if (new > 0)
            {
                // Add a new height tile above if needed
                addHeightTileViewAt(coordAbove, uid:new)
            }
            
            if let aboveUID = modelDelegate?.terrainTileUIDAt(coordAbove)
            {
                if let aboveAlignment = tileset?.alignmentForUID(aboveUID)
                {
                    if (aboveAlignment == .VERTICAL)
                    {
                        removeBaseTileViewAt(coordAbove)
                        createTerrainBaseAt(coordAbove, uid:aboveUID)
                    }
                }
            }
        }
    }
    
    func refreshTerrainAboveFromNegativeSource(coord:DiscreteTileCoord, new:Int)
    {
        let coordAbove = coord.up()
        
        if tileViewRect!.contains(coordAbove)
        {
            if let _ = registeredHeightTiles[coordAbove]
            {
                // If there used to be a tile here in the view, remove it
                removeHeightTileViewAt(coordAbove)
            }
            
            if let size = tileset?.sizeForUID(new)
            {
                if (size == .TALL)
                {
                    // Add the height view above
                    addHeightTileViewAt(coordAbove, uid:new)
                    
                    if let aboveUID = modelDelegate?.terrainTileUIDAt(coordAbove)
                    {
                        if let aboveAlignment = tileset?.alignmentForUID(aboveUID)
                        {
                            if (aboveAlignment == .VERTICAL)
                            {
                                removeBaseTileViewAt(coordAbove)
                                createTerrainBaseAt(coordAbove, uid:aboveUID)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Assumes that the tile has changed from SOMETHING to SOMETHING ELSE, or SOMETHING to EMPTY
    func refreshTerrainFromPositiveSource(coord:DiscreteTileCoord, new:Int)
    {
        let coordAbove = coord.up()
        let coordBelow = coord.down()

        // If there used to be tile here in the view, remove it
        removeBaseTileViewAt(coord)
        
        // Tile has changed from SOMETHING to SOMETHING ELSE
        if (new > 0)
        {
            // If the new terrain is not blank, add a base tile for it
            createTerrainBaseAt(coord, uid:new)
        }
        // Tile has changed from SOMETHING to NOTHING
        else
        {
            if let aboveUID = modelDelegate?.terrainTileUIDAt(coordAbove)
            {
                if (aboveUID > 0)
                {
                    if let aboveSize = tileset?.sizeForUID(aboveUID)
                    {
                        if (aboveSize == .SHORT)
                        {
                            // If the tile above is not blank, add a side texture here
                            addBaseTileViewFromSideAt(coord, aboveUID:aboveUID)
                        }
                        else if (aboveSize == .TALL)
                        {
                            addBaseTileViewFromExtendedSideAt(coord, aboveUID:aboveUID)
                        }
                    }
                    
                    if (tileViewRect!.contains(coordAbove))
                    {
                        if let aboveAlignment = tileset?.alignmentForUID(aboveUID)
                        {
                            if (aboveAlignment == .VERTICAL)
                            {
                                if let size = tileset?.sizeForUID(new)
                                {
                                    if (size == .SHORT)
                                    {
                                        // Tile just changed to something short
                                        removeBaseTileViewAt(coordAbove)
                                        addBaseTileViewFromSideAt(coordAbove, aboveUID:aboveUID)
                                    }
                                    else if (size == .TALL)
                                    {
                                        // Tile just changed to something tall
                                        removeBaseTileViewAt(coordAbove)
                                        addBaseTileViewAt(coordAbove, uid:aboveUID)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if let belowUID = modelDelegate?.terrainTileUIDAt(coordBelow)
            {
                if (belowUID == 0)
                {
                    // If the tile below is blank, remove its side texture
                    removeBaseTileViewAt(coordBelow)
                }
            }
        }
        
        // Refresh the terrain above
        refreshTerrainAboveFromPositiveSource(coord, new:new)
        
        // Refresh the terrain below
        refreshTerrainBelowFromPositiveSource(coord, new:new)
    }
    
    // Assumes that the tile has changed from EMPTY to SOMETHING
    func refreshTerrainFromNegativeSource(coord:DiscreteTileCoord, new:Int)
    {
        // If there used to be tile here in the view (there shouldn't have), remove it
        removeBaseTileViewAt(coord)
        
        // Add the new base view
        createTerrainBaseAt(coord, uid:new)
        
        // Refresh the terrain below (if needed)
        refreshTerrainBelowFromNegativeSource(coord, new:new)
        
        // Refresh the terrain above (if needed)
        refreshTerrainAboveFromNegativeSource(coord, new:new)
    }
    
    func refreshDoodadAt(coord:DiscreteTileCoord, old:Int, new:Int, collaboratorID:String?)
    {
        if (old > 0)
        {
            // Remove the old doodad
            removeDoodadAt(coord, old:old)
            
            // Doodad changed from SOMETHING to SOMETHING ELSE
            if (new > 0)
            {
                regenerateDoodadAt(coord, new:new)
            }
        }
        // Doodad changed from EMPTY to SOMETHING
        else
        {
            // Regenerate the new doodad
            regenerateDoodadAt(coord, new:new)
        }
        
        if let collaboratorID = collaboratorID
        {
            if (collaboratorID == "Internal")
            {
                addChangeIndicatorAt(coord, color:UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0))
            }
            else if let color = NetworkController.sharedInstance.colorForCollaboratorID(collaboratorID)
            {
                addChangeIndicatorAt(coord, color:color)
            }
        }
    }
    
    func removeDoodadAt(coord:DiscreteTileCoord, old:Int)
    {
        let coordAbove = coord.up()
        
        if let tileset = tileset
        {
            if (tileViewRect!.contains(coord))
            {
                if let _ = registeredStackedTiles[coord]
                {
                    // Remove the stacked base
                    removeStackedTileViewAt(coord)
                }
            }
            
            if (tileViewRect!.contains(coordAbove))
            {
                if (old > 0)
                {
                    if let doodadSize = tileset.sizeForUID(old)
                    {
                        if (doodadSize == .TALL)
                        {
                            // If the doodad was tall, also remove the height
                            if let _ = registeredHeightTiles[coordAbove]
                            {
                                removeHeightTileViewAt(coordAbove)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func regenerateDoodadAt(coord:DiscreteTileCoord, new:Int)
    {
        let coordAbove = coord.up()
        
        if let tileset = tileset
        {
            if (tileViewRect!.contains(coord))
            {
                if let _ = registeredStackedTiles[coord]
                {
                    // If there is already a base view here, remove it
                    removeStackedTileViewAt(coord)
                }
                
                // Add the stacked base
                addStackedTileViewAt(coord, uid:new)
            }
            
            if (tileViewRect!.contains(coordAbove))
            {
                if let doodadSize = tileset.sizeForUID(new)
                {
                    if (doodadSize == .TALL)
                    {
                        // If there is already a height view above, remove it
                        if let _ = registeredHeightTiles[coordAbove]
                        {
                            removeHeightTileViewAt(coordAbove)
                        }
                        
                        // If the doodad was tall, also create a height view above
                        addHeightTileViewAt(coordAbove, uid:new)
                    }
                }
            }
        }
    }
    
    func doodadChangedAt(coord:DiscreteTileCoord, old:Int, new:Int, collaboratorID:String?)
    {
        if let tileViewRect = tileViewRect
        {
            // We only care if something actually changed
            if (old != new)
            {
                // We only care about the change if we can see it
                if tileViewRect.expandVertically().contains(coord)
                {
                    // SOMETHING to SOMETHING ELSE | SOMETHING to EMPTY
                    refreshDoodadAt(coord, old:old, new:new, collaboratorID:collaboratorID)
                }
            }
        }
    }
    
    func registerModelDelegate(delegate:DirectModelDelegate)
    {
        self.modelDelegate = delegate
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Required Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}