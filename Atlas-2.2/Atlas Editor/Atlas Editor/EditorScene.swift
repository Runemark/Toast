//
//  GameScene.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/4/16.
//  Copyright (c) 2016 Dusty Artifact. All rights reserved.
//

import SpriteKit

class EditorScene : SKScene, EditorSceneInteractionControllerDelegate, TileSelectionResponder, ButtonResponder
{
    //////////////////////////////////////////////////////////////////////////////////////////
    // View
    //////////////////////////////////////////////////////////////////////////////////////////
    var window:CGSize
    var center:CGPoint
    
    var mapView:TileMapView
    var tileSelectionPanel:TileSelectionPanel
    var tileset:Tileset
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Controller
    //////////////////////////////////////////////////////////////////////////////////////////
    var interactionController:EditorSceneInteractionController
    var tileSelection:Int
    var editingEnabled:Bool
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Model
    //////////////////////////////////////////////////////////////////////////////////////////
    var map:TileMap
    
    override init(size:CGSize)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // Model Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        tileset = TilesetIO().importTileset("Rust")
        tileset.importAtlas("Rust")
        
        let rustTilesetData = TilesetIO().importTilesetData("Rust")
        
//        TileMapIO().removeModel("Scrap001")
        
        if let importedMap = TileMapIO().importModel("Scrap004")
        {
            map = importedMap
        }
        else
        {
            map = TileMap(bounds:TileRect(left:0, right:3, up:6, down:0), title:"Scrap004")
            map.swapTilesetData(rustTilesetData)
            map.setAllTerrainTiles(1, directly:true)
            TileMapIO().exportModel(map)
        }
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // View Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        let viewSize = CGSizeMake(window.width*0.75, window.height*0.5)
        let tileSize = CGSizeMake(32, 32)
        mapView = TileMapView(window:window, viewSize:viewSize, tileSize:tileSize)
        mapView.position = center
        
        mapView.swapTileset(tileset)
        map.registerDirectObserver(mapView)
        
        mapView.reloadMap()
        
        tileSelectionPanel = TileSelectionPanel(size:CGSizeMake(window.width, window.height*0.25), tileSize:tileSize, tileset:tileset)
        tileSelectionPanel.position = CGPointMake(center.x, window.height*0.15)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Controller Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        interactionController = EditorSceneInteractionController()
        tileSelection = 0
        editingEnabled = true
        
        super.init(size:size)
        
        tileSelectionPanel.registerSelectionResponder(self)
        tileSelectionPanel.showPage()
        
        self.backgroundColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        
        self.addChild(mapView)
        self.addChild(tileSelectionPanel)
        
        interactionController.registerDelegate(self)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonPressed(id:String)
    {
        if (id == "load")
        {
            print("popup load dialogue")
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Scene Overrides
    //////////////////////////////////////////////////////////////////////////////////////////
    override func didMoveToView(view:SKView)
    {
        
    }
    
    override func touchesBegan(touches:Set<UITouch>, withEvent event:UIEvent?)
    {
        if let touch = touches.first
        {
            if (tileSelectionPanel.willUseInput(touch))
            {
                tileSelectionPanel.input(touch)
            }
            else
            {
                let touchLocation = touch.locationInNode(mapView)
                let wrappedLocation = NSValue(CGPoint:touchLocation)
                // Give it a small delay, then activate if no gesture has been activated in the meantime
                _ = NSTimer.scheduledTimerWithTimeInterval(0.075, target:self, selector:Selector("delayedTouch:"), userInfo:["touchLocation":wrappedLocation], repeats:false)
            }
        }
    }
    
    func delayedTouch(timer:NSTimer)
    {
        let userInfo = timer.userInfo as! Dictionary<String,AnyObject>
        let location:CGPoint = (userInfo["touchLocation"] as! NSValue).CGPointValue()
        
        if (editingEnabled)
        {
            // Get the coordinate
            if let selectedCoord = mapView.tileAtLocation(location)
            {
                map.setTerrainTileAt(selectedCoord, uid:tileSelection, collaboratorID:"Internal")
                TileMapIO().exportModel(map)
            }
        }
        else
        {
            // Re-enable editing
            editingEnabled = true
        }
    }
    
    func delayedEditingEnabled()
    {
        // Re-enable editing
        editingEnabled = true
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        map.applyNextChange()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Tile Selection Responder Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    func selectionChange(tileUUID:Int)
    {
        tileSelection = tileUUID
        print("selectionChange:\(tileUUID)")
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Interaction Controller Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    func pan(delta:CGPoint)
    {
        // Disable editing during the pan operation
        editingEnabled = false
        
        
        
        // Execute pan action on map view
        mapView.translateView(delta)
    }
}