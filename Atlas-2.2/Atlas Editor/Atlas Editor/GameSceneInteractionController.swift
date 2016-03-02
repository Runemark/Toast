//
//  GameSceneInteractionController.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/19/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

protocol GameSceneInteractionControllerDelegate
{
    func pan(delta:CGPoint)
}

class GameSceneInteractionController:PanHandler
{
    let panController:PanController
    var delegate:GameSceneInteractionControllerDelegate?
    
    init()
    {
        panController = PanController.sharedInstance
        panController.registerHandler(self)
    }
    
    func registerDelegate(delegate:GameSceneInteractionControllerDelegate)
    {
        self.delegate = delegate
    }
    
    func pan(delta:CGPoint)
    {
        delegate?.pan(delta)
    }
}
