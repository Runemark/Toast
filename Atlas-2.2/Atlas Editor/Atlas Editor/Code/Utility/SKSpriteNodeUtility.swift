//
//  SKSpriteNodeUtility.swift
//  Atlas
//
//  Created by Martin Mumford on 10/2/15.
//  Copyright © 2015 Runemark Studios. All rights reserved.
//

import SpriteKit

public extension SKSpriteNode
{
    func resizeNode(x:CGFloat, y:CGFloat)
    {
        let original_x = self.size.width/self.xScale
        let original_y = self.size.height/self.yScale
        
        if (x != original_x)
        {
            self.xScale = x/original_x
        }
        
        if (y != original_y)
        {
            self.yScale = y/original_y
        }
    }
}