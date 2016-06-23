//
//  IntExtensions.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 5/14/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

extension Int
{
    func inRange(range:(min:Int, max:Int)) -> Bool
    {
        return (self >= range.min && self <= range.max)
    }
}