//
//  AnalysisScene.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/16/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import SpriteKit

class OneshotAnalysisScene : SKScene, ButtonResponder
{
    //////////////////////////////////////////////////////////////////////////////////////////
    // View
    //////////////////////////////////////////////////////////////////////////////////////////
    var window:CGSize
    var center:CGPoint
    
    var analysisView:LKAnalysisView
    var tileset:Tileset
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Intelligent Agent
    //////////////////////////////////////////////////////////////////////////////////////////
//    var loki:Loki
    
    override init(size:CGSize)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // Model Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        tileset = TilesetIO().importTileset("Rust")
        tileset.importAtlas("Rust")
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // View Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        let viewSize = CGSizeMake(window.width*0.75, window.height*0.5)
        let tileSize = CGSizeMake(16, 16)
        
        analysisView = LKAnalysisView(window:window, viewSize:viewSize, tileSize:tileSize)
        analysisView.position = center
        
        analysisView.swapTileset(tileset)
        
        // Loki's SOLE PURPOSE is to create a style guide based on the level provided
//        loki = Loki(analysisView:analysisView)
        
        super.init(size:size)
        
        self.backgroundColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        
        self.addChild(analysisView)
        
        let fenrir = Fenrir(title:"Scrap001", analysisView:analysisView)
        if let styleInfo = fenrir.createStyleGuide()
        {
            print(styleInfo)
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonPressed(id:String)
    {
        
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Scene Overrides
    //////////////////////////////////////////////////////////////////////////////////////////
    override func didMoveToView(view:SKView)
    {
        
    }
    
    override func touchesBegan(touches:Set<UITouch>, withEvent event:UIEvent?)
    {
//        loki.proceed()
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        
    }
}