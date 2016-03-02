//
//  ColorUtility.swift
//  Atlas
//
//  Created by Martin Mumford on 10/10/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation
import SpriteKit

extension UIColor
{
    func red() -> CGFloat
    {
        return CGColorGetComponents(self.CGColor)[0]
    }
    
    func green() -> CGFloat
    {
        return CGColorGetComponents(self.CGColor)[1]
    }
    
    func blue() -> CGFloat
    {
        return CGColorGetComponents(self.CGColor)[2]
    }
    
    func rgb() -> [CGFloat]
    {
        var components = [CGFloat]()
        
        components.append(red())
        components.append(green())
        components.append(blue())
        
        return components
    }
}

func colorForRGB(r:Int, g:Int, b:Int) -> UIColor
{
    let red = CGFloat(Double(r) / 255.0)
    let green = CGFloat(Double(g) / 255.0)
    let blue = CGFloat(Double(b) / 255.0)
    
    return UIColor(red:red, green:green, blue:blue, alpha:1.0)
}

//func colorForHSV(h:Int, s:Int, b:Int) -> UIColor
//{
//    
//}

func blendedLinearPalette(a:UIColor, b:UIColor, totalSteps:Int) -> [UIColor]
{
    var palette = [UIColor]()
    
    let blendStep = 1.0 / Double(totalSteps-1)
    var currentBlendFactor = 0.0
    
    for _ in 0..<totalSteps
    {
        palette.append(blendColors(a, b:b, blendFactor:currentBlendFactor))
        currentBlendFactor += blendStep
    }
    
    return palette
}

// Finds the color somewhere in-between to colors
//  Where a blendFactor of 0.0 is just the color A, and a blendFactor of 1.0 is just the color B
//  Ingores alpha (always returns a color with alpha of 1.0)
func blendColors(a:UIColor, b:UIColor, blendFactor:Double) -> UIColor
{
    let a_components = a.rgb()
    let b_components = b.rgb()
    
    var blend_r = CGFloat(0)
    var blend_g = CGFloat(0)
    var blend_b = CGFloat(0)
    
    let delta_r = (a_components[0] == b_components[0]) ? 0.0 : b_components[0] - a_components[0]
    blend_r = a_components[0] + CGFloat(blendFactor)*delta_r
    
    let delta_g = (a_components[1] == b_components[1]) ? 0.0 : b_components[1] - a_components[1]
    blend_g = a_components[1] + CGFloat(blendFactor)*delta_g
    
    let delta_b = (a_components[2] == b_components[2]) ? 0.0 : b_components[2] - a_components[2]
    blend_b = a_components[2] + CGFloat(blendFactor)*delta_b
    
    return UIColor(red:blend_r, green:blend_g, blue:blend_b, alpha:CGFloat(1.0))
}

func randomColor() -> UIColor
{
    let random_r = CGFloat(randNormalDouble())
    let random_g = CGFloat(randNormalDouble())
    let random_b = CGFloat(randNormalDouble())
    
    return UIColor(red:random_r, green:random_g, blue:random_b, alpha:CGFloat(1.0))
}