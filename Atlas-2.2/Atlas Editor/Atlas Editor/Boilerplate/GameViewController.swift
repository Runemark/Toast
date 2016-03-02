//
//  GameViewController.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/4/16.
//  Copyright (c) 2016 Dusty Artifact. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController
{
    var scene:SKScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        let recognizer = PanController.sharedInstance.generatePanRecognizer()
        self.view!.addGestureRecognizer(recognizer)
    
        scene = IntroScene(size:(skView.frame.size))
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        scene!.scaleMode = .AspectFill
        skView.presentScene(scene)
    }

    override func shouldAutorotate() -> Bool
    {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            return .AllButUpsideDown
        }
        else
        {
            return .All
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
}
