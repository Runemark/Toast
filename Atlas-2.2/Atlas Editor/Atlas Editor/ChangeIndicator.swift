//
//  ChangeIndicator.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/25/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

class ChangeIndicator:SKNode
{
//    let attributionBackground:SKSpriteNode
    let selectionIndicator:SKSpriteNode
    
    init(tileSize:CGSize, color:UIColor)
    {
//        attributionBackground = SKSpriteNode(imageNamed:"indicator.png")
//        attributionBackground.resizeNode(tileSize.width*1.5, y:tileSize.height*1.5)
//        attributionBackground.position = CGPointZero
//        attributionBackground.color = color
//        attributionBackground.colorBlendFactor = 1.0
        
//        attributionBackground = SKSpriteNode(imageNamed:"square.png")
//        attributionBackground.resizeNode(tileSize.width*1.25, y:tileSize.height*1.5)
//        attributionBackground.position = CGPointMake(0, tileSize.height*0.125)
//        attributionBackground.color = color
//        attributionBackground.colorBlendFactor = 1.0
        
//        let attributionHeight = tileSize.height*0.125
////        let attributionHeight = tileSize.height*0.0625
//        
//        attributionBackground = SKSpriteNode(imageNamed:"square.png")
//        attributionBackground.resizeNode(tileSize.width, y:attributionHeight)
//        attributionBackground.position = CGPointMake(0, tileSize.height*0.5 + attributionHeight*0.5)
//        attributionBackground.color = color
//        attributionBackground.colorBlendFactor = 1.0
        
        selectionIndicator = SKSpriteNode(imageNamed:"square.png")
        selectionIndicator.resizeNode(tileSize.width, y:tileSize.height)
        selectionIndicator.position = CGPointZero
//        selectionIndicator.color = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        selectionIndicator.color = color
        selectionIndicator.colorBlendFactor = 1.0
        
        super.init()
        
//        self.addChild(attributionBackground)
        self.addChild(selectionIndicator)
        
//        let glow = SKSpriteNode(imageNamed:"dull_glow.png")
//        glow.resizeNode(tileSize.width*3.0, y:tileSize.height*3.0)
//        glow.position = CGPointZero
//        self.addChild(glow)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Required Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}