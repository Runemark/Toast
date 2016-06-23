//
//  TileView.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/6/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

class ComponentNodeView : SKNode
{
    let center:SKSpriteNode
    let volume:SKSpriteNode
    
    init(tileSize:CGSize)
    {
        center = SKSpriteNode(imageNamed:"square.png")
        center.resizeNode(tileSize.width*CGFloat(0.5), y:tileSize.height*CGFloat(0.5))
        center.position = CGPointZero
        
        volume = SKSpriteNode(imageNamed:"square.png")
        let diameter_x = tileSize.width
        let diameter_y = tileSize.height
        volume.resizeNode(diameter_x, y:diameter_y)
        volume.alpha = 0.25
        
        super.init()
        
        self.addChild(volume)
        self.addChild(center)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Required Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}