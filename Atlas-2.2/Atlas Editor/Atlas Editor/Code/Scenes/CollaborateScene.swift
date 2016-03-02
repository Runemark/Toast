//
//  GameScene.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/4/16.
//  Copyright (c) 2016 Dusty Artifact. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

protocol EditorViewDelegate
{
    func collaboratorConnecting(collaborator:Collaborator)
    func collaboratorConnected(collaborator:Collaborator)
    func collaboratorDisconnected(collaborator:Collaborator)
    func receivedDataFromCollaborator(collaborator:Collaborator)
}

class CollaborateScene : SKScene, GameSceneInteractionControllerDelegate, EditorViewDelegate
{
    //////////////////////////////////////////////////////////////////////////////////////////
    // View
    //////////////////////////////////////////////////////////////////////////////////////////
    var window:CGSize
    var center:CGPoint
    
    var mapView:TileMapView
    var tileset:Tileset
    
    var statusPanel:CollaboratorStatusPanel
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Controller
    //////////////////////////////////////////////////////////////////////////////////////////
    var interactionController:GameSceneInteractionController
    var networkController:NetworkController
    
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
        
        map = TileMap(bounds:TileRect(left:0, right:13, up:13, down:0), title:"Test")
        map.swapTilesetData(rustTilesetData)
        
        networkController = NetworkController.sharedInstance
        networkController.registerModelDelegate(map)
        
        var tiles = Set<Int>()
        tiles.insert(1)
        tiles.insert(2)
        map.randomizeAllTerrainTiles(tiles, directly:true)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // View Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        let viewSize = CGSizeMake(window.width*0.6, window.height*0.5)
        let tileSize = CGSizeMake(32, 32)
        mapView = TileMapView(window:window, viewSize:viewSize, tileSize:tileSize)
        mapView.position = center
        
        mapView.swapTileset(tileset)
        map.registerDirectObserver(mapView)
        mapView.reloadMap()
        
        statusPanel = CollaboratorStatusPanel(width:window.width, statusViewSize:tileSize)
        statusPanel.position = CGPointMake(center.x, window.height*0.1)
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Controller Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        interactionController = GameSceneInteractionController()
        
        super.init(size:size)
        
        self.backgroundColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        
        self.addChild(mapView)
        self.addChild(statusPanel)
        
        interactionController.registerDelegate(self)
        networkController.registerViewDelegate(self)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Editor View Delegate Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    func collaboratorConnecting(collaborator:Collaborator)
    {
        statusPanel.addCollaborator(collaborator.uuid, color:collaborator.color, status:ConnectionStatus.CONNECTING)
    }
    
    func collaboratorConnected(collaborator:Collaborator)
    {
        statusPanel.changeCollaboratorStatus(collaborator.uuid, status:ConnectionStatus.CONNECTED)
    }
    
    func collaboratorDisconnected(collaborator:Collaborator)
    {
        statusPanel.removeCollaborator(collaborator.uuid)
    }
    
    func receivedDataFromCollaborator(collaborator:Collaborator)
    {
        statusPanel.pingCollaborator(collaborator.uuid)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Scene Overrides
    //////////////////////////////////////////////////////////////////////////////////////////
    override func didMoveToView(view:SKView)
    {
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        
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
