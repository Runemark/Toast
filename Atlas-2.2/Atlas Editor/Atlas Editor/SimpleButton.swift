//
//  SimpleButton.swift
//  Hexbreaker
//
//  Created by Dusty Artifact on 12/18/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

protocol ButtonResponder
{
    func buttonPressed(id:String)
}

class SimpleButton : SKNode
{
    var iconSize:CGSize
    var touchable:CGRect
    var icon:SKSpriteNode
    
    var identifier:String
    var active:Bool
    
    var baseColor:UIColor?
    
    var responder:ButtonResponder?
    
    init(iconSize:CGSize, touchable:CGSize, iconName:String, identifier:String, active:Bool, shouldColor:Bool, baseColor:UIColor?)
    {
        self.iconSize = iconSize
        //        self.touchable = CGRectMake(-1*iconSize.width/2, -1*iconSize.height/2, iconSize.width, iconSize.height)
        self.touchable = CGRectMake(CGFloat(-1.0)*touchable.width/CGFloat(2.0), CGFloat(-1.0)*touchable.height/CGFloat(2.0), touchable.width, touchable.height)
        
        self.identifier = identifier
        
        self.icon = SKSpriteNode(imageNamed:"\(iconName).png")
        icon.resizeNode(iconSize.width, y:iconSize.height)
        icon.position = CGPointZero
        
        if (shouldColor)
        {
            if let baseColor = baseColor
            {
                icon.color = baseColor
            }
            else
            {
                icon.color = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1.0)
            }
            
            icon.colorBlendFactor = 1.0
        }
        
        self.active = active
        
        if (!active)
        {
            icon.alpha = 0.0
        }
        
        super.init()
        
        self.addChild(icon)
    }
    
    func registerResponder(responder:ButtonResponder)
    {
        self.responder = responder
    }
    
    func buttonMayTrigger(touch:UITouch)
    {
        if (active)
        {
            let location = touch.locationInNode(self)
            
            if (touchable.contains(location))
            {
                responder?.buttonPressed(identifier)
            }
        }
    }
    
    func buttonShouldTrigger(touch:UITouch) -> Bool
    {
        if (active)
        {
            let location = touch.locationInNode(self)
            
            return touchable.contains(location)
        }
        else
        {
            return false
        }
    }
    
    func deactivate()
    {
        if (active)
        {
            icon.removeAllActions()
            
            let fadeAction = fadeTo(icon, alpha:0.0, duration:0.25, type:CurveType.QUADRATIC_INOUT)
            icon.runAction(fadeAction)
            
            active = false
        }
    }
    
    func activate()
    {
        if (!active)
        {
            icon.removeAllActions()
            
            let fadeAction = fadeTo(icon, alpha:1.0, duration:0.4, type:CurveType.QUADRATIC_INOUT)
            icon.runAction(fadeAction)
            
            active = true
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}