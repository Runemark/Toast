//
//  Collaborator.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/28/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

class Collaborator
{
    var uuid:String
    var color:UIColor
    
    init()
    {
        self.uuid = NSUUID().UUIDString
        self.color = randomColor()
    }
}