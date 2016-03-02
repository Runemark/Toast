//
//  GameScene.swift
//  Atlas Agent
//
//  Created by Dusty Artifact on 1/19/16.
//  Copyright (c) 2016 Dusty Artifact. All rights reserved.
//

import SpriteKit

class GameScene: SKScene
{
    var networkController:NetworkController?
    var ticker = 0
    var shouldProceed = false
    
    override func didMoveToView(view: SKView)
    {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 45
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        networkController = NetworkController.sharedInstance
        
        self.addChild(myLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        shouldProceed = !shouldProceed
//        networkController?.sendBoundsRequest()
    }
   
    override func update(currentTime: CFTimeInterval)
    {
        if (ticker % 5 == 0)
        {
            if let networkController = networkController
            {
                if networkController.connectedToServer
                {
                    if (shouldProceed)
                    {
                        let randomX = randIntBetween(0, stop:15)
                        let randomY = randIntBetween(0, stop:15)
                        let randomCoord = DiscreteTileCoord(x:randomX, y:randomY)
                        let randomLayer = TileLayer.TERRAIN
                        let randomValue = randIntBetween(0, stop:6)
                        let randomChange = Change(coord:randomCoord, layer:randomLayer, value:randomValue)
                        
                        networkController.sendChangeRequest(randomChange)
                    }
                }
            }
        }
        
        updateTicker()
    }
    
    func updateTicker()
    {
        ticker++
        if (ticker > 10000)
        {
            ticker = 0
        }
    }
}
