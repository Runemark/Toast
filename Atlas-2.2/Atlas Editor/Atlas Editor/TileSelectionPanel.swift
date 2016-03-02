//
//  TileSelectionPanel.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/16/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

class TileSelectionPanel : SKNode
{
    var size:CGSize
    var tileSize:CGSize
    var tileset:Tileset
    var terrainUIDs:[Int]
    
    var selectionResponder:TileSelectionResponder?
    
    var pageNode:SKNode
    
    init(size:CGSize, tileSize:CGSize, tileset:Tileset)
    {
        self.size = size
        self.tileSize = tileSize
        self.tileset = tileset
        
        pageNode = SKNode()
        pageNode.position = CGPointZero
        
        var allTerrain = tileset.allTerrainUIDS()
        allTerrain.insert(0)
        terrainUIDs = Array(allTerrain).sort()
        
        // Determine how many pages are required (default to 1)
        
        super.init()
        
        self.addChild(pageNode)
        
    }
    
    func registerSelectionResponder(responder:TileSelectionResponder)
    {
        self.selectionResponder = responder
    }
    
    func showPage()
    {
        let pageView = TilePageView(size:size, tileSize:tileSize, tileset:tileset, tileUIDs:terrainUIDs)
        
        if let selectionResponder = selectionResponder
        {
            pageView.registerSelectionResponder(selectionResponder)
        }
        
        pageView.position = CGPointZero
        pageView.activate()
        
        pageNode.addChild(pageView)
    }
    
    func input(touch:UITouch)
    {
        for node in pageNode.children
        {
            let pageView = node as! TilePageView
            pageView.input(touch)
        }
    }
    
    func willUseInput(touch:UITouch) -> Bool
    {
        var willUse = false
        
        for node in pageNode.children
        {
            let pageView = node as! TilePageView
            if pageView.willUseInput(touch)
            {
                willUse = true
                break
            }
        }
        
        return willUse
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}