//
//  GameScene.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/4/16.
//  Copyright (c) 2016 Dusty Artifact. All rights reserved.
//

import SpriteKit

class GenerateScene : SKScene,GameSceneInteractionControllerDelegate
{
    //////////////////////////////////////////////////////////////////////////////////////////
    // View
    //////////////////////////////////////////////////////////////////////////////////////////
    var window:CGSize
    var center:CGPoint
    
    var mapView:TileMapView
    var tileset:Tileset
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Controller
    //////////////////////////////////////////////////////////////////////////////////////////
    var interactionController:GameSceneInteractionController
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Model
    //////////////////////////////////////////////////////////////////////////////////////////
    var map:TileMap
    var atlas:Atlas?
    
    override init(size:CGSize)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // Model Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        tileset = TilesetIO().importTileset("Rust")
        tileset.importAtlas("Rust")
        
        let rustTilesetData = TilesetIO().importTilesetData("Rust")
        
        map = TileMap(bounds:TileRect(left:0, right:19, up:19, down:0), title:"GenTest")
        map.swapTilesetData(rustTilesetData)
        
//        map.randomizeAllTerrainTiles(Set([0,1,2,3,4]), directly:true)
        map.setAllTerrainTiles(0, directly:true)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // View Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        let viewSize = window
        let tileSize = CGSizeMake(16, 16)
        mapView = TileMapView(window:window, viewSize:viewSize, tileSize:tileSize)
        mapView.position = center
        
        mapView.swapTileset(tileset)
        map.registerDirectObserver(mapView)
        
        mapView.reloadMap()
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Controller Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        interactionController = GameSceneInteractionController()
        
        super.init(size:size)
        
        if let guide = StyleGuideIO().importGuide("Scrap001")
        {
            atlas = Atlas(model:map, bounds:map.mapBounds(), guide:guide)
        }
        
        self.backgroundColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        
        self.addChild(mapView)
        
        interactionController.registerDelegate(self)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Scene Overrides
    //////////////////////////////////////////////////////////////////////////////////////////
    override func didMoveToView(view:SKView)
    {
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if let atlas = atlas
        {
            if (atlas.operatingState == .HALTED)
            {
                atlas.proceed()
            }
            else
            {
                atlas.halt()
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        map.applyNextChange()
    }
    
    func pan(delta:CGPoint)
    {
        mapView.translateView(delta)
    }
}