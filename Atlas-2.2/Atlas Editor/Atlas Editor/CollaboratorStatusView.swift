//
//  CollaboratorStatusView.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/28/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

enum ConnectionStatus
{
    case CONNECTING, CONNECTED, DISCONNECTED
}

class CollaboratorStatusView:SKNode
{
    let colorSprite:SKSpriteNode
    let statusSprite:SKSpriteNode
    let pingSprite:SKSpriteNode
    var status:ConnectionStatus = ConnectionStatus.CONNECTING
    
    init(size:CGSize, color:UIColor, status:ConnectionStatus)
    {
        colorSprite = SKSpriteNode(imageNamed:"square.png")
        colorSprite.resizeNode(size.width, y:size.height)
        colorSprite.position = CGPointZero
        colorSprite.color = color
        colorSprite.colorBlendFactor = 1.0
        
        statusSprite = SKSpriteNode(imageNamed:"square.png")
        statusSprite.resizeNode(size.width*1.2, y:size.height*1.2)
        statusSprite.position = CGPointZero
        
        pingSprite = SKSpriteNode(imageNamed:"square.png")
        pingSprite.resizeNode(size.width, y:2)
        pingSprite.position = CGPointMake(0, -1.25*size.height)
        pingSprite.alpha = 0.0
        
        self.status = status
        
        super.init()
        
        self.addChild(statusSprite)
        self.addChild(colorSprite)
        self.addChild(pingSprite)
        
        if (status == ConnectionStatus.CONNECTING)
        {
            showConnecting()
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Required Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showConnected()
    {
        statusSprite.removeAllActions()
        statusSprite.alpha = 1.0
        status = ConnectionStatus.CONNECTED
    }
    
    func showConnecting()
    {
        let fadeOutAction = fadeTo(1.0, finish:0.0, duration:0.5, type:CurveType.QUADRATIC_OUT)
        let fadeInAction = fadeTo(0.0, finish:1.0, duration:0.5, type:CurveType.QUADRATIC_IN)
        
        statusSprite.removeAllActions()
        statusSprite.runAction(SKAction.repeatActionForever(SKAction.sequence([fadeOutAction, fadeInAction])))
        
        status = ConnectionStatus.CONNECTING
    }
    
    func ping()
    {
        pingSprite.removeAllActions()
        pingSprite.alpha = 1.0
        
        let fadeAction = fadeTo(1.0, finish:0.0, duration:0.15, type:CurveType.QUADRATIC_OUT)
        pingSprite.runAction(fadeAction)
    }
}