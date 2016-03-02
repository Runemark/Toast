//
//  CollaboratorStatusPanel.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/28/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

class CollaboratorStatusPanel:SKNode
{
    var statusViewSlots:[CollaboratorStatusView]
    var statusViews:[String:CollaboratorStatusView]
    let statusPanelWidth:CGFloat
    let statusViewSize:CGSize
    
    var backgroundNode:SKNode
    var background:SKSpriteNode?
    var line:SKSpriteNode?
    
    init(width:CGFloat, statusViewSize:CGSize)
    {
        self.statusPanelWidth = width
        self.statusViewSize = statusViewSize
        
        statusViews = [String:CollaboratorStatusView]()
        statusViewSlots = [CollaboratorStatusView]()
        
        backgroundNode = SKNode()
        backgroundNode.position = CGPointZero
        
        super.init()
        
        self.addChild(backgroundNode)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Collaborator Display
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func addCollaborator(id:String, color:UIColor, status:ConnectionStatus)
    {
        // Update the view
        let newStatusView = CollaboratorStatusView(size:statusViewSize, color:color, status:status)
        
        let slotCount = statusViewSlots.count
        
        if (slotCount == 0)
        {
            showBackground()
        }
        
        self.addChild(newStatusView)
        statusViews[id] = newStatusView
        statusViewSlots.append(newStatusView)
        
        newStatusView.position = positionForStatusViewAtIndex(slotCount)
        
        repositionStatusViews()
    }
    
    func changeCollaboratorStatus(id:String, status:ConnectionStatus)
    {
        if let statusView = statusViews[id]
        {
            if (status == ConnectionStatus.CONNECTED)
            {
                statusView.showConnected()
                addSelfContainedExplosionAtPoint(statusView.position)
            }
            else if (status == ConnectionStatus.CONNECTING)
            {
                statusView.showConnecting()
            }
        }
    }
    
    func addSelfContainedExplosionAtPoint(point:CGPoint)
    {
        let explosionSprite = SKSpriteNode(imageNamed:"square.png")
        explosionSprite.resizeNode(statusViewSize.width, y:statusViewSize.height)
        explosionSprite.position = point
        
        self.addChild(explosionSprite)
        
        let fadeAction = fadeTo(explosionSprite, alpha:0.0, duration:0.3, type:CurveType.QUADRATIC_OUT)
        explosionSprite.runAction(fadeAction)
        
        let expandAction = scaleToSize(explosionSprite, size:statusViewSize*2.0, duration:0.3, type:CurveType.QUADRATIC_OUT)
        explosionSprite.runAction(expandAction) { () -> Void in
            explosionSprite.removeFromParent()
        }
    }
    
    func removeCollaborator(id:String)
    {
        if let statusView = statusViews[id]
        {
            if let index = indexForCollaborator(id)
            {
                statusViewSlots.removeAtIndex(index)
                statusViews.removeValueForKey(id)
                statusView.removeFromParent()
            }
            
            // No more status views, hide the background
            if (statusViewSlots.count == 0)
            {
                hideBackground()
            }
            
            repositionStatusViews()
        }
    }
    
    func pingCollaborator(id:String)
    {
        if let statusView = statusViews[id]
        {
            statusView.ping()
        }
    }
    
    func indexForCollaborator(id:String) -> Int?
    {
        var index:Int?
        
        if let statusView = statusViews[id]
        {
            var tempIndex = 0
            for statusViewInSlot in statusViewSlots
            {
                if (statusView === statusViewInSlot)
                {
                    index = tempIndex
                    break
                }
                
                tempIndex++
            }
        }
        
        return index
    }
    
    func repositionStatusViews()
    {
        for (index, statusView) in statusViewSlots.enumerate()
        {
            let newPosition = positionForStatusViewAtIndex(index)
            let moveAction = moveTo(statusView, destination:newPosition, duration:0.4, type:CurveType.QUADRATIC_INOUT)
            statusView.removeAllActions()
            statusView.runAction(moveAction)
        }
    }
    
    func positionForStatusViewAtIndex(index:Int) -> CGPoint
    {
        let statusViewCount = statusViews.count
        let widthIncrement = statusPanelWidth / CGFloat(statusViewCount + 1)
        let newXPosition = (-0.5 * statusPanelWidth) + (widthIncrement * CGFloat(index + 1))
        return CGPointMake(newXPosition, 0)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Background Display
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func showBackground()
    {
        background = SKSpriteNode(imageNamed:"square.png")
    
        background!.resizeNode(1, y:statusViewSize.height*1.75)
        background!.alpha = 0.0
        background!.position = CGPointZero
        backgroundNode.addChild(background!)
        
        let backgroundFadeAction = fadeTo(background!, alpha:0.15, duration:0.4, type:CurveType.QUADRATIC_INOUT)
        let backgroundResizeAction = scaleToSize(background!, size:CGSizeMake(statusPanelWidth, statusViewSize.height*1.75), duration:0.4, type:CurveType.QUADRATIC_INOUT)
        background!.removeAllActions()
        background!.runAction(backgroundResizeAction)
        background!.runAction(backgroundFadeAction)
        
        line = SKSpriteNode(imageNamed:"square.png")

        line!.alpha = 0.0
        line!.resizeNode(1, y:1)
        line!.position = CGPointZero
        backgroundNode.addChild(line!)
        
        let lineDelayAction = idle(CGFloat(0.1))
        let lineFadeAction = fadeTo(line!, alpha:1.0, duration:0.4, type:CurveType.QUADRATIC_INOUT)
        let lineResizeAction = scaleToSize(line!, size:CGSizeMake(statusPanelWidth, 1), duration:0.4, type:CurveType.QUADRATIC_INOUT)
        line!.removeAllActions()
        line!.runAction(SKAction.sequence([lineDelayAction, lineResizeAction]))
        line!.runAction(SKAction.sequence([lineDelayAction, lineFadeAction]))
    }
    
    func hideBackground()
    {
        if let _ = background
        {
            let backgroundDelayAction = idle(CGFloat(0.1))
            let backgroundFadeAction = fadeTo(background!, alpha:0.0, duration:0.4, type:CurveType.QUADRATIC_INOUT)
            let backgroundResizeAction = scaleToSize(background!, size:CGSizeMake(1, statusViewSize.height*1.75), duration:0.4, type:CurveType.QUADRATIC_INOUT)
            background!.removeAllActions()
            background!.runAction(SKAction.sequence([backgroundDelayAction, backgroundResizeAction]))
            background!.runAction(SKAction.sequence([backgroundDelayAction, backgroundFadeAction]), completion: { () -> Void in
                self.background!.removeFromParent()
                self.background = nil
            })
        }
        
        if let _ = line
        {
            let lineFadeAction = fadeTo(line!, alpha:0.0, duration:0.4, type:CurveType.QUADRATIC_INOUT)
            let lineResizeAction = scaleToSize(line!, size:CGSizeMake(1, 1), duration:0.4, type:CurveType.QUADRATIC_INOUT)
            line!.removeAllActions()
            line!.runAction(lineResizeAction)
            line!.runAction(lineFadeAction, completion: { () -> Void in
                self.line!.removeFromParent()
                self.line = nil
            })
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Required Methods
    //////////////////////////////////////////////////////////////////////////////////////////
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}