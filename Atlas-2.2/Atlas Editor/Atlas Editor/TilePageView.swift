//
//  TilePageView.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/16/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

protocol TileSelectionResponder
{
    func selectionChange(tileUUID:Int)
}

class TilePageView : SKNode, ButtonResponder
{
    var size:CGSize
    var tileSize:CGSize
    var tileset:Tileset
    var uids:[Int]
    
    var buttons:[Int:SimpleButton]
    
    var selectionIndicator:SKSpriteNode
    var selectionResponder:TileSelectionResponder?
    
    var buttonNode:SKNode
    
    init(size:CGSize, tileSize:CGSize, tileset:Tileset, tileUIDs:[Int])
    {
        self.size = size
        self.tileSize = tileSize
        self.tileset = tileset
        self.uids = tileUIDs
        
        buttonNode = SKNode()
        buttonNode.position = CGPointZero
        
        self.selectionIndicator = SKSpriteNode(imageNamed:"square.png")
        selectionIndicator.resizeNode(tileSize.width*CGFloat(1.25), y:tileSize.height*CGFloat(1.25))
        selectionIndicator.position = CGPointZero
        selectionIndicator.alpha = 0.0
        
        self.buttons = [Int:SimpleButton]()
        
        super.init()
        
        self.addChild(selectionIndicator)
        self.addChild(buttonNode)
    }
    
    func registerSelectionResponder(selectionResponder:TileSelectionResponder)
    {
        self.selectionResponder = selectionResponder
    }
    
    func selectIndex(index:Int)
    {
        if let button = buttons[index]
        {
            selectionIndicator.alpha = 1.0
            selectionIndicator.position = button.position
        }
    }
    
    func activate()
    {
        // How many can fit horizontally?
        let outerHorizontalPadding = 128.0
        let horizontalCount = Int(floor((((Double(size.width) - 2*outerHorizontalPadding) / Double(tileSize.width)) + 1.0) / 1.5))
        
        var currentTileIndex = 0
        for _ in 0..<horizontalCount
        {
            if (currentTileIndex < uids.count)
            {
                let position = positionForTileButtonAtIndex(currentTileIndex)
                createTileButtonAt(position, tileIndex:uids[currentTileIndex])
            }
            else
            {
                break
            }
        
            currentTileIndex += 1
        }
    }
    
    func deactivate()
    {
        for node in buttonNode.children
        {
            let button = node as! SimpleButton
            button.removeFromParent()
        }
        
        selectionIndicator.alpha = 0.0
        
        for (_, button) in buttons
        {
            button.removeFromParent()
        }
    }
    
    func positionForTileButtonAtIndex(index:Int) -> CGPoint
    {
        let outerHorizontalPadding = 64.0
        
        let xPos = 1.5*Double(tileSize.width)*Double(index) + 0.5*Double(tileSize.width)
        let paddedXPos = outerHorizontalPadding + xPos
        let adjustedXPos = paddedXPos - (Double(size.width)/2.0)
        let yPos = 0.0
        
        return CGPointMake(CGFloat(adjustedXPos), CGFloat(yPos))
    }
    
    func createTileButtonAt(position:CGPoint, tileIndex:Int)
    {
        var textureName:String?
        
        textureName = tileset.baseTextureNameForUID(tileIndex)
        
        if (tileIndex == 0)
        {
            textureName = "square"
        }
        
        if let textureName = textureName
        {
            let tileButton = SimpleButton(iconSize:tileSize, touchable:tileSize*1.25, iconName:textureName, identifier:"\(tileIndex)", active:true, shouldColor: false, baseColor:nil)
            tileButton.position = position
            tileButton.registerResponder(self)
            buttonNode.addChild(tileButton)
            
            if let _ = buttons[tileIndex]
            {
                buttons.removeValueForKey(tileIndex)
            }
            
            buttons[tileIndex] = tileButton
        }
    }
    
    func buttonPressed(id:String)
    {
        if let tileIndex = Int(id)
        {
            selectIndex(tileIndex)
            
            if let selectionResponder = selectionResponder
            {
                // Make the change
                selectionResponder.selectionChange(tileIndex)
            }
        }
    }
    
    func input(touch:UITouch)
    {
        for node in buttonNode.children
        {
            let button = node as! SimpleButton
            button.buttonMayTrigger(touch)
        }
    }
    
    func willUseInput(touch:UITouch) -> Bool
    {
        var willUse = false
        
        for node in buttonNode.children
        {
            let button = node as! SimpleButton
            if button.buttonShouldTrigger(touch)
            {
                willUse = true
                break
            }
        }
        
        return willUse
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Required methods
    //////////////////////////////////////////////////////////////////////////////////////////
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
