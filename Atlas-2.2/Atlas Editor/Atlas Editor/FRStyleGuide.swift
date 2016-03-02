//
//  FRStyleGuide.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/1/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

enum ShapeInfoPrecision
{
    case EXACT, RANGE
}

enum ShapeInfoGenerality
{
    case LOW, MEDIUM, HIGH
}

class FRStyleComponent
{
    // Region Shape Info
    let bestGeneralityTier:ShapeInfoGenerality
    let bestGeneralityPrecision:ShapeInfoPrecision
    
    let width:TileLengthRange
    let height:TileLengthRange
    let prop:ProportionRange?
    let normProp:ProportionRange?
    
    init(width:TileLengthRange, height:TileLengthRange, prop:ProportionRange?, normProp:ProportionRange?)
    {
        self.width = width
        self.height = height
        self.prop = prop
        self.normProp = normProp
        
        if let normProp = normProp
        {
            bestGeneralityTier = .HIGH
            if (normProp.min == normProp.max)
            {
                bestGeneralityPrecision = .EXACT
            }
            else
            {
                bestGeneralityPrecision = .RANGE
            }
        }
        else if let prop = prop
        {
            bestGeneralityTier = .MEDIUM
            if (prop.min == prop.max)
            {
                bestGeneralityPrecision = .EXACT
            }
            else
            {
                bestGeneralityPrecision = .RANGE
            }
        }
        else
        {
            bestGeneralityTier = .LOW
            if (width.min == width.max && height.min == height.max)
            {
                bestGeneralityPrecision = .EXACT
            }
            else
            {
                bestGeneralityPrecision = .RANGE
            }
        }
    }
}

class FRStyleGuide
{
    var components:[FRStyleComponent]
    var title:String
    
    init(title:String)
    {
        self.title = title
        components = [FRStyleComponent]()
    }
    
    func addComponent(width:TileLengthRange, height:TileLengthRange, prop:ProportionRange?, normProp:ProportionRange?)
    {
        let component = FRStyleComponent(width:width, height:height, prop:prop, normProp:normProp)
        components.append(component)
    }
}