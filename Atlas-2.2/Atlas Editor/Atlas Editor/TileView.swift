//
//  TileView.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/6/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

class TileView : SKNode
{
    let sprite:SKSpriteNode
    
    init(texture:SKTexture, size:CGSize)
    {
        sprite = SKSpriteNode(texture:texture)
        sprite.resizeNode(size.width, y:size.height)
        sprite.position = CGPointZero
        
        super.init()
        
        self.addChild(sprite)
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    // Required Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}