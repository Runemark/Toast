//
//  TileMapView.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/6/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

class AnalysisView : SKNode
{
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //      View
    //
    
    ////////////////////////////////////////////////////////////
    // MAP LAYER
    var microTileLayer:SKNode
    ////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////
    // SHAPE DENSITY LAYER
    var shapeDensityNodeLayer:SKNode
    ////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////
    // SHAPE SKELETON LAYER
    var shapeSkeletonLayer:SKNode
    ////////////////////////////////////////////////////////////
    
    var changeIndicatorLayer:SKNode
    
    var tileSize:CGSize
    var viewBoundSize:CGSize
    
    var cameraOnScreen:CGPoint
    //////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //       Model
    //
    
    var tileset:Tileset?
    var mapBounds:TileRect
    var cameraInWorld:TileCoord
    
    var model:AnalysisModelResponder?
    //////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // View Model
    var registeredMicroTiles:[DiscreteTileCoord:TileView]
    var registeredChangeIndicators:[DiscreteTileCoord:ChangeIndicator]
    var registeredShapeDensityNodes:[DiscreteTileCoord:SKSpriteNode]
    //////////////////////////////////////////////////////////////////////////////////////////
    
    init(window:CGSize, viewSize:CGSize, tileSize:CGSize)
    {
        self.tileSize = tileSize
        self.viewBoundSize = viewSize
        
        cameraInWorld = TileCoord(x:0.0, y:0.0)
        cameraOnScreen = CGPointZero
        
        microTileLayer = SKNode()
        microTileLayer.position = CGPointZero
        
        shapeDensityNodeLayer = SKNode()
        shapeDensityNodeLayer.position = CGPointZero
        
        shapeSkeletonLayer = SKNode()
        shapeSkeletonLayer.position = CGPointZero
        
        changeIndicatorLayer = SKNode()
        changeIndicatorLayer.position = CGPointZero
        
        registeredMicroTiles = [DiscreteTileCoord:TileView]()
        registeredChangeIndicators = [DiscreteTileCoord:ChangeIndicator]()
        registeredShapeDensityNodes = [DiscreteTileCoord:SKSpriteNode]()
        
        mapBounds = TileRect(left:0, right:0, up:0, down:0)
        
        super.init()
        
        self.addChild(microTileLayer)
        self.addChild(shapeDensityNodeLayer)
        self.addChild(shapeSkeletonLayer)
        self.addChild(changeIndicatorLayer)
    }
    
    func registerModelResponder(modelResponder:AnalysisModelResponder)
    {
        self.model = modelResponder
        
        let worldCenter = TileCoord(x:Double(model!.mapBounds().width()) / 2.0, y:Double(model!.mapBounds().height()) / 2.0)
        cameraInWorld = worldCenter
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
        
        let fadeAction = fadeTo(changeIndicator, alpha:0.0, duration:0.4, type:CurveType.QUADRATIC_IN)
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
    
    func createMicroTileViewAt(coord:DiscreteTileCoord, uid:Int)
    {
        if (uid > 0)
        {
            if let texture = tileset?.microTextureForUID(uid)
            {
                let tileView = createTileViewWithTexture(texture, coord:coord)
                microTileLayer.addChild(tileView)
                
                registeredMicroTiles[coord] = tileView
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
        removeMicroTileViewAt(coord)
    }
    
    func removeMicroTileViewAt(coord:DiscreteTileCoord)
    {
        if let tileView = registeredMicroTiles[coord]
        {
            tileView.removeFromParent()
            registeredMicroTiles.removeValueForKey(coord)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // View Drawing/Updating
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func clearMapLayer()
    {
        for (coord, _) in registeredMicroTiles
        {
            removeMicroTileViewAt(coord)
        }
    }
    
    func brightenMapLayer()
    {
        for (_, view) in registeredMicroTiles
        {
            if (view.alpha < 1.0)
            {
                view.removeAllActions()
                let brightenAction = fadeTo(view, alpha:1.0, duration:0.4, type:CurveType.QUADRATIC_INOUT)
                view.runAction(brightenAction)
            }
        }
    }
    
    func dimMapLayer()
    {
        for (_, view) in registeredMicroTiles
        {
            if (view.alpha != 0.25)
            {
                view.removeAllActions()
                let dimAction = fadeTo(view, alpha:0.25, duration:0.4, type:CurveType.QUADRATIC_INOUT)
                view.runAction(dimAction)
            }
        }
    }
    
    func hideMapLayer()
    {
        for (_, view) in registeredMicroTiles
        {
            if (view.alpha > 0.0)
            {
                view.removeAllActions()
                let hideAction = fadeTo(view, alpha:0.0, duration:0.4, type:CurveType.QUADRATIC_INOUT)
                view.runAction(hideAction)
            }
        }
    }
    
    func updateTileViewAt(coord:DiscreteTileCoord)
    {
        if let model = model
        {
            let newUID = model.terrainTileUIDAt(coord)
            
            if let _ = registeredMicroTiles[coord]
            {
                removeMicroTileViewAt(coord)
            }
            
            if newUID > 0
            {
                createMicroTileViewAt(coord, uid:newUID)
                addChangeIndicatorAt(coord, color:UIColor.whiteColor())
            }
        }
    }
    
    func addDensityNodeAt(coord:DiscreteTileCoord, density:Int)
    {
        if (density > 0)
        {
            let node = SKSpriteNode(imageNamed:"square.png")
            node.resizeNode(tileSize.width/CGFloat(5), y:tileSize.height/CGFloat(5))
            let alpha = CGFloat(Double(density) * 0.1)
            node.position = screenPosForTileViewAtCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
            
            let fadeAction = fadeTo(0.0, finish:alpha, duration:0.4, type:CurveType.QUADRATIC_OUT)
            node.runAction(fadeAction)
            
            let growAction = scaleToSize(node, size:tileSize, duration:0.4, type:CurveType.QUADRATIC_INOUT)
            node.runAction(growAction)
            
            shapeDensityNodeLayer.addChild(node)
            registeredShapeDensityNodes[coord] = node
        }
    }
    
    func changeDensityNodeAt(coord:DiscreteTileCoord, density:Int)
    {
        if let _ = registeredShapeDensityNodes[coord]
        {
//            shapeNode.removeAllActions()
//            let fadeAction = scaleToSize(shapeNode, size:CGSizeMake(CGFloat(density*2), CGFloat(density*2)), duration:0.2, type:CurveType.QUADRATIC_OUT)
//            shapeNode.runAction(resizeAction)
        }
    }
    
    func removeDensityNodeAt(coord:DiscreteTileCoord)
    {
        if let shapeNode = registeredShapeDensityNodes[coord]
        {
            shapeNode.removeFromParent()
            registeredShapeDensityNodes.removeValueForKey(coord)
        }
    }
    
    func clearDensity()
    {
        var delay = 0.000
        for densityNode in shapeDensityNodeLayer.children
        {
            let idleAction = idle(CGFloat(delay))
            let densitySprite = densityNode as! SKSpriteNode
            let fadeAction = fadeTo(densitySprite, alpha:0.0, duration:0.3, type:CurveType.QUADRATIC_OUT)
            let growAction = scaleToSize(densitySprite, size:CGSizeMake(1,1), duration:0.3, type:CurveType.QUADRATIC_OUT)
            densitySprite.removeAllActions()
            densitySprite.runAction(SKAction.sequence([idleAction, fadeAction]))
            densitySprite.runAction(SKAction.sequence([idleAction, growAction]))
            
            delay += 0.005
        }
    }
    
    func addSkeletonNode(node:SkeletonNode)
    {
        let nodeSprite = SKSpriteNode(imageNamed:"square.png")
        let strength = CGFloat(node.strength*2)
        nodeSprite.position = screenPosForTileViewAtCoord(node.center, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
        nodeSprite.resizeNode(48, y:48)
        nodeSprite.alpha = 0.0
        
        let resizeAction = scaleToSize(nodeSprite, size:CGSizeMake(strength,strength), duration:0.3, type:CurveType.QUADRATIC_INOUT)
        nodeSprite.runAction(resizeAction)
        
        let fadeAction = fadeTo(nodeSprite, alpha:1.0, duration:0.3, type:CurveType.QUADRATIC_OUT)
        nodeSprite.runAction(fadeAction)
        
        shapeSkeletonLayer.addChild(nodeSprite)
    }
    
    func clearSkeleton()
    {
        var delay = 0.000
        for skeletonNode in shapeSkeletonLayer.children
        {
            let idleAction = idle(CGFloat(delay))
            let skeletonSprite = skeletonNode as! SKSpriteNode
            let fadeAction = fadeTo(skeletonSprite, alpha:0.0, duration:0.3, type:CurveType.QUADRATIC_OUT)
            skeletonSprite.removeAllActions()
            skeletonSprite.runAction(SKAction.sequence([idleAction, fadeAction]))
            
            delay += 0.005
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
    // Required Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}