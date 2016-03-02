//
//  GameScene.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/4/16.
//  Copyright (c) 2016 Dusty Artifact. All rights reserved.
//

import SpriteKit

class IntroScene : SKScene, ButtonResponder
{
    //////////////////////////////////////////////////////////////////////////////////////////
    // View
    //////////////////////////////////////////////////////////////////////////////////////////
    var window:CGSize
    var center:CGPoint
    
    var collaborateButton:SimpleButton
    var generateButton:SimpleButton
    var analyzeButton:SimpleButton
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Controller
    //////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////////////////////////////////////////////////////////////////////
    // Model
    //////////////////////////////////////////////////////////////////////////////////////////
    
    override init(size:CGSize)
    {
        //////////////////////////////////////////////////////////////////////////////////////////
        // Model Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // View Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        window = size
        center = CGPoint(x:window.width/2.0, y:window.height/2.0)
        
        let iconSize = CGSizeMake(64, 64)
        collaborateButton = SimpleButton(iconSize:iconSize, touchable:iconSize*1.5, iconName:"collaborate", identifier:"collaborate", active:false, shouldColor: false, baseColor:nil)
        collaborateButton.position = center
        
        generateButton = SimpleButton(iconSize:iconSize, touchable:iconSize*1.5, iconName:"generate", identifier:"generate", active:false, shouldColor:false, baseColor:nil)
        generateButton.position = center
        
        analyzeButton = SimpleButton(iconSize:iconSize, touchable:iconSize*1.5, iconName:"analyze", identifier:"analyze", active:false, shouldColor:false, baseColor:nil)
        analyzeButton.position = center
        
        //////////////////////////////////////////////////////////////////////////////////////////
        // Controller Declaration
        //////////////////////////////////////////////////////////////////////////////////////////
        super.init(size:size)
        
        self.backgroundColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0)
        
        self.addChild(collaborateButton)
        self.addChild(generateButton)
        self.addChild(analyzeButton)
        
        collaborateButton.registerResponder(self)
        generateButton.registerResponder(self)
        analyzeButton.registerResponder(self)
        
        activate()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // UI Updates
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func activate()
    {
        let iconRadius = 128.0
        
        // Collaborate
        collaborateButton.removeAllActions()
        
        let collaborateDestination = radialDelta(degToRad(Double(90)), radius:iconRadius) + center
        let collaborateMoveAction = moveTo(collaborateButton, destination:collaborateDestination, duration:0.4, type:CurveType.QUADRATIC_INOUT)
        
        collaborateButton.runAction(collaborateMoveAction)
        collaborateButton.activate()
        
        // Analyze
        analyzeButton.removeAllActions()
        
        let analyzeDestination = radialDelta(degToRad(Double(210)), radius:iconRadius) + center
        let analyzeMoveAction = moveTo(analyzeButton, destination:analyzeDestination, duration:0.4, type:CurveType.QUADRATIC_INOUT)
        
        analyzeButton.runAction(analyzeMoveAction)
        analyzeButton.activate()
        
        // Generate
        generateButton.removeAllActions()
        
        let generateDestination = radialDelta(degToRad(Double(330)), radius:iconRadius) + center
        let generateMoveAction = moveTo(generateButton, destination:generateDestination, duration:0.4, type:CurveType.QUADRATIC_INOUT)
        
        generateButton.runAction(generateMoveAction)
        generateButton.activate()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Button Responder
    //////////////////////////////////////////////////////////////////////////////////////////
    func buttonPressed(id:String)
    {
        if (id == "collaborate")
        {
            print("collaborate")
            
            let transition = SKTransition.fadeWithDuration(0.4)
//            let scene = CollaborateScene(size:window)
            let scene = EditorScene(size:window)
            self.view?.presentScene(scene, transition:transition)
        }
        else if (id == "generate")
        {
            print("generate")
            
            let transition = SKTransition.fadeWithDuration(0.4)
            let scene = GenerateScene(size:window)
            self.view?.presentScene(scene, transition:transition)
            
        }
        else if (id == "analyze")
        {
            print("analyze")
            
            let transition = SKTransition.fadeWithDuration(0.4)
//            let scene = AnalysisScene(size:window)
            let scene = OneshotAnalysisScene(size:window)
            self.view?.presentScene(scene, transition:transition)
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Scene Overrides
    //////////////////////////////////////////////////////////////////////////////////////////
    override func didMoveToView(view:SKView)
    {
        
    }
    
    override func touchesBegan(touches:Set<UITouch>, withEvent event: UIEvent?)
    {
        if let touch = touches.first
        {
            generateButton.buttonMayTrigger(touch)
            collaborateButton.buttonMayTrigger(touch)
            analyzeButton.buttonMayTrigger(touch)
        }
    }
    
    override func update(currentTime: CFTimeInterval)
    {
        
    }
}