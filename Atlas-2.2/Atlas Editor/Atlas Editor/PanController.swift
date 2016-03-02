//
//  PanController.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/19/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

protocol PanHandler:class
{
    func pan(delta:CGPoint)
}

class PanController
{
    static let sharedInstance = PanController()
    
    var inProgress:Bool
    var panStart:CGPoint?
    var handlers:[PanHandler]
    
    private init()
    {
        inProgress = false
        handlers = [PanHandler]()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Handler Registration
    //////////////////////////////////////////////////////////////////////////////////////////
    func handlerIsRegistered(handler:PanHandler) -> Bool
    {
        var handlerIsAlreadyRegistered = false
        
        for registeredHandler in handlers
        {
            if handler === registeredHandler
            {
                handlerIsAlreadyRegistered = true
                break
            }
        }
        
        return handlerIsAlreadyRegistered
    }
    
    func indexOfHandler(handler:PanHandler) -> Int?
    {
        var index:Int?
        var tempIndex = 0
        for registeredHandler in handlers
        {
            if handler === registeredHandler
            {
                index = tempIndex
                break
            }
            tempIndex++
        }
        
        return index
    }
    
    func registerHandler(handler:PanHandler)
    {
        if (!handlerIsRegistered(handler))
        {
            handlers.append(handler)
        }
    }
    
    func unregisterHandler(handler:PanHandler)
    {
        if let handlerIndex = indexOfHandler(handler)
        {
            handlers.removeAtIndex(handlerIndex)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Recongizer
    //////////////////////////////////////////////////////////////////////////////////////////
    // Generates a UIPanGestureRecognizer object to be attached to the main view
    func generatePanRecognizer() -> UIPanGestureRecognizer
    {
        let panRecognizer = UIPanGestureRecognizer(target:self, action:"handlePan:")
        panRecognizer.minimumNumberOfTouches = 2
        panRecognizer.maximumNumberOfTouches = 2
        
        return panRecognizer
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Gesture State
    //////////////////////////////////////////////////////////////////////////////////////////
    @objc func handlePan(recognizer:UIPanGestureRecognizer)
    {
        let location = recognizer.locationInView(recognizer.view)
        // SpriteKit y-axis is reversed from UIKit
        let spriteKitLocation = CGPointMake(location.x, -1*location.y)
        let roundedFinalLocation = spriteKitLocation.roundDown()
        
        switch (recognizer.state)
        {
            case .Began:
                
                panStart = roundedFinalLocation
                inProgress = true
                break
            
            case .Changed:
                
                if (recognizer.numberOfTouches() == 2)
                {
                    let screenDelta = roundedFinalLocation - panStart!
                    panStart = roundedFinalLocation
                    
                    for handler in handlers
                    {
                        handler.pan(screenDelta)
                    }
                    
                }
                break
            
            case .Ended:
                
                panStart = nil
                inProgress = false
                break
            
            default:
                
                panStart = nil
                inProgress = false
                break
        }
    }
}