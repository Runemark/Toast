//
//  LKAnalysisView.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/24/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

protocol VisualDelegate
{
    func updateDensityNodeAt(coord:DiscreteTileCoord, density:Int)
}

class LKAnalysisView : SKNode, VisualDelegate
{
    ////////////////////////////////////////////////////////////
    // MAP LAYER
    private var mapLayer:SKNode
    ////////////////////////////////////////////////////////////
    
    
    ////////////////////////////////////////////////////////////
    // SHAPE DENSITY LAYER
    private var shapeDensityLayer:SKNode
    ////////////////////////////////////////////////////////////
    
    
    ////////////////////////////////////////////////////////////
    // SHAPE SKELETON LAYER
    private var shapeSkeletonLayer:SKNode
    ////////////////////////////////////////////////////////////
    
    
    ////////////////////////////////////////////////////////////
    // SPECIAL REGION LAYER
    private var regionLayer:SKNode
    ////////////////////////////////////////////////////////////
    
    
    ////////////////////////////////////////////////////////////
    // EFFECTS LAYERS
    private var changeIndicatorLayer:SKNode
    ////////////////////////////////////////////////////////////
    
    
    ////////////////////////////////////////////////////////////
    // GENERAL VIEW DATA
    private var tileSize:CGSize
    private var viewBoundSize:CGSize
    private var cameraOnScreen:CGPoint
    private var tileset:Tileset?
    private var mapBounds:TileRect
    private var cameraInWorld:TileCoord
    ////////////////////////////////////////////////////////////
    
    
    ////////////////////////////////////////////////////////////
    // VIEWMODEL
    private var registeredMapTiles:[DiscreteTileCoord:TileView]
    private var registeredChangeIndicators:[DiscreteTileCoord:ChangeIndicator]
    private var registeredShapeDensityNodes:[DiscreteTileCoord:SKSpriteNode]
    ////////////////////////////////////////////////////////////
    
    init(window:CGSize, viewSize:CGSize, tileSize:CGSize)
    {
        self.tileSize = tileSize
        self.viewBoundSize = viewSize
        
        cameraInWorld = TileCoord(x:0.0, y:0.0)
        cameraOnScreen = CGPointZero
        
        mapLayer = SKNode()
        mapLayer.position = CGPointZero
        
        shapeDensityLayer = SKNode()
        shapeDensityLayer.position = CGPointZero
        
        shapeSkeletonLayer = SKNode()
        shapeSkeletonLayer.position = CGPointZero
        
        regionLayer = SKNode()
        regionLayer.position = CGPointZero
        
        changeIndicatorLayer = SKNode()
        changeIndicatorLayer.position = CGPointZero
        
        registeredMapTiles = [DiscreteTileCoord:TileView]()
        registeredChangeIndicators = [DiscreteTileCoord:ChangeIndicator]()
        registeredShapeDensityNodes = [DiscreteTileCoord:SKSpriteNode]()
        
        mapBounds = TileRect(left:0, right:0, up:0, down:0)
        
        super.init()
        
        self.addChild(mapLayer)
        self.addChild(shapeDensityLayer)
        self.addChild(shapeSkeletonLayer)
        self.addChild(regionLayer)
        self.addChild(changeIndicatorLayer)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // MAP DRAWING
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func loadMapMetaData(bounds:TileRect)
    {
        self.mapBounds = bounds
        self.cameraInWorld = TileCoord(x:(Double(bounds.width()) / 2.0) + Double(bounds.left), y:(Double(bounds.height()) / 2.0) + Double(bounds.down))
    }
    
    func setMapTileAt(coord:DiscreteTileCoord, uid:Int)
    {
        var shouldDisplayChangeIndicator = false
        
        if (removeMapTileAt(coord))
        {
            shouldDisplayChangeIndicator = true
        }
        
        if (uid > 0)
        {
            createMapTileAt(coord, uid:uid)
            shouldDisplayChangeIndicator = true
        }
        
        if (shouldDisplayChangeIndicator)
        {
            addChangeIndicatorAt(coord, color:UIColor.whiteColor())
        }
    }
    
    private func createMapTileAt(coord:DiscreteTileCoord, uid:Int)
    {
        if (uid > 0)
        {
            if let texture = tileset?.microTextureForUID(uid)
            {
                let tileView = createTileViewWithTexture(texture, coord:coord)
                mapLayer.addChild(tileView)
                
                registeredMapTiles[coord] = tileView
            }
        }
    }
    
    private func createTileViewWithTexture(texture:SKTexture, coord:DiscreteTileCoord) -> TileView
    {
        let tileView = TileView(texture:texture, size:tileSize)
        tileView.position = screenPosForTileViewAtCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
        
        return tileView
    }
    
    private func removeMapTileAt(coord:DiscreteTileCoord) -> Bool
    {
        if let tileView = registeredMapTiles[coord]
        {
            tileView.removeFromParent()
            registeredMapTiles.removeValueForKey(coord)
            
            return true
        }
        else
        {
            // Nothing to remove
            return false
        }
    }
    
    func clearMapLayer()
    {
        for (coord, _) in registeredMapTiles
        {
            removeMapTileAt(coord)
        }
    }
    
    func brightenMapLayer()
    {
        changeMapAlpha(1.00)
    }
    
    func dimMapLayer()
    {
        changeMapAlpha(0.25)
    }
    
    func hideMapLayer()
    {
        changeMapAlpha(0.00)
    }
    
    private func changeMapAlpha(alpha:Double)
    {
        for (_, view) in registeredMapTiles
        {
            view.removeAllActions()
            let hideAction = fadeTo(view, alpha:CGFloat(alpha), duration:0.4, type:CurveType.QUADRATIC_INOUT)
            view.runAction(hideAction)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Change Indicators
    //////////////////////////////////////////////////////////////////////////////////////////
    
    private func addChangeIndicatorAt(coord:DiscreteTileCoord, color:UIColor)
    {
        if let oldIndicator = registeredChangeIndicators[coord]
        {
            removeChangeIndicator(oldIndicator, coord:coord)
        }
        
        let changeIndicator = ChangeIndicator(tileSize:tileSize, color:color)
        changeIndicator.position = screenPosForTileViewAtCoord(coord, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
        
        let fadeAction = fadeTo(changeIndicator, alpha:0.0, duration:0.4, type:CurveType.QUADRATIC_IN)
        changeIndicator.runAction(fadeAction) { () -> Void in
            self.removeChangeIndicator(changeIndicator, coord:coord)
        }
        
        changeIndicatorLayer.addChild(changeIndicator)
        registeredChangeIndicators[coord] = changeIndicator
    }
    
    private func removeChangeIndicator(indicator:ChangeIndicator, coord:DiscreteTileCoord)
    {
        indicator.removeFromParent()
        registeredChangeIndicators.removeValueForKey(coord)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Regions
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func addRegion(region:TileRect)
    {
        if mapBounds.completelyContains(region)
        {
            let tileShift = CGPointMake(tileSize.width*0.5, tileSize.height*0.5)
            
            let leftTilePoint = TileCoord(x:Double(region.left), y:Double(region.down + region.up)/2.0)
            let leftScreenPos = screenPosForCoord(leftTilePoint, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
            
            let upperLeftPoint = TileCoord(x:Double(region.left), y:Double(region.up))
            let upperLeftScreenPos = screenPosForCoord(upperLeftPoint, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize: tileSize)
            
            let lowerLeftPoint = TileCoord(x:Double(region.left), y:Double(region.down))
            let lowerLeftScreenPos = screenPosForCoord(lowerLeftPoint, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
            
            let rightTilePoint = TileCoord(x:Double(region.right), y:Double(region.down + region.up)/2.0)
            let rightScreenPos = screenPosForCoord(rightTilePoint, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
            
            let upperRightPoint = TileCoord(x:Double(region.right), y:Double(region.up))
            let upperRightScreenPos = screenPosForCoord(upperRightPoint, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)
            
            let lowerRightPoint = TileCoord(x:Double(region.right), y:Double(region.down))
            let lowerRightScreenPos = screenPosForCoord(lowerRightPoint, cameraInWorld:cameraInWorld, cameraOnScreen:cameraOnScreen, tileSize:tileSize)

            let upperScreenPos = CGPointMake((upperRightScreenPos.x + upperLeftScreenPos.x) / 2.0, upperRightScreenPos.y)
            let lowerScreenPos = CGPointMake((lowerRightScreenPos.x + lowerLeftScreenPos.x) / 2.0, lowerRightScreenPos.y)
            
            let boundHeight = (upperLeftPoint.y == lowerLeftPoint.y) ? CGFloat(2.0) : CGFloat(upperLeftScreenPos.y - lowerLeftScreenPos.y)
            let boundWidth = (lowerLeftPoint.x == lowerRightPoint.x) ? CGFloat(2.0) : CGFloat(upperRightScreenPos.x - upperLeftScreenPos.x)
            
            let leftBound = SKSpriteNode(imageNamed:"square.png")
            leftBound.position = leftScreenPos + tileShift
            leftBound.resizeNode(CGFloat(2.0), y:boundHeight)
            
            let rightBound = SKSpriteNode(imageNamed:"square.png")
            rightBound.position = rightScreenPos + tileShift
            rightBound.resizeNode(CGFloat(2.0), y:boundHeight)
            
            let upperBound = SKSpriteNode(imageNamed:"square.png")
            upperBound.position = upperScreenPos + tileShift
            upperBound.resizeNode(boundWidth, y:CGFloat(2.0))
            
            let lowerBound = SKSpriteNode(imageNamed:"square.png")
            lowerBound.position = lowerScreenPos + tileShift
            lowerBound.resizeNode(boundWidth, y:CGFloat(2.0))
            
            regionLayer.addChild(leftBound)
            regionLayer.addChild(rightBound)
            regionLayer.addChild(upperBound)
            regionLayer.addChild(lowerBound)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Density Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    
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
            
            shapeDensityLayer.addChild(node)
            registeredShapeDensityNodes[coord] = node
        }
    }
    
    func updateDensityNodeAt(coord:DiscreteTileCoord, density:Int)
    {
        if (density > 0)
        {
            if let existingNode = registeredShapeDensityNodes[coord]
            {
//                let growAction = scaleToSize(existingNode, size:tileSize*Double(density), duration:0.4, type:CurveType.QUADRATIC_INOUT)
//                existingNode.runAction(growAction)
                let fadeAction = fadeTo(existingNode, alpha:CGFloat(density)*CGFloat(0.1), duration:0.4, type:CurveType.QUADRATIC_INOUT)
                existingNode.removeAllActions()
                existingNode.runAction(fadeAction)
            }
            else
            {
                addDensityNodeAt(coord, density:density)
            }
        }
        else
        {
            removeDensityNodeAt(coord)
        }
    }
    
    func removeDensityNodeAt(coord:DiscreteTileCoord)
    {
        if let shapeNode = registeredShapeDensityNodes[coord]
        {
            let fadeAction = fadeTo(shapeNode, alpha:0.0, duration:0.4, type:CurveType.QUADRATIC_OUT)
            shapeNode.runAction(fadeAction)
            
            let growAction = scaleToSize(shapeNode, size:CGSizeMake(1, 1), duration:0.4, type:CurveType.QUADRATIC_INOUT)
            shapeNode.runAction(growAction, completion: { () -> Void in
                shapeNode.removeFromParent()
                self.registeredShapeDensityNodes.removeValueForKey(coord)
            })
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
