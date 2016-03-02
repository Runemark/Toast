//
//  FRRectSimilarityModule.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/29/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

struct TileLengthRange
{
    var min:Int
    var max:Int
    
    var variance:Int
    {
        get
        {
            return abs(min - max)
        }
    }
}

struct ProportionRange
{
    var min:Double
    var max:Double
    
    var variance:Double
    {
        get
        {
            return fabs(min - max)
        }
    }
}

class FRRectSimilarityModule
{
    var rects:[TileRect]
    
    var widthRange:TileLengthRange
    var heightRange:TileLengthRange
    var proportionRange:ProportionRange?
    var normalizedProportionRange:ProportionRange?
    
    init(regions:[FRDynamicRegion])
    {
        rects = [TileRect]()
        
        widthRange = TileLengthRange(min:0, max:0)
        heightRange = TileLengthRange(min:0, max:0)
        
        for region in regions
        {
            if let rect = region.bounds
            {
                rects.append(rect)
            }
        }
    }
    
    func activate() -> (width:TileLengthRange, height:TileLengthRange, prop:ProportionRange?, normProp:ProportionRange?)
    {
        if (rects.count > 0)
        {
            calculateDimensionRanges()
            
            if (widthRange.variance > 0 || heightRange.variance > 0)
            {
                calculateProportionRange()
                
                if (proportionRange!.variance > 0)
                {
                    calculateNormalizedProportionRange()
                }
            }
        }
        else
        {
        // No rects to compare!
        }
        
        return (width:widthRange, height:heightRange, prop:proportionRange, normProp:normalizedProportionRange)
    }

    func calculateDimensionRanges()
    {
        var rangesInitialized = false
        
        for rect in rects
        {
            if (rangesInitialized)
            {
                if (rect.width() < widthRange.min)
                {
                    widthRange.min = rect.width()
                }
                
                if (rect.width() > widthRange.max)
                {
                    widthRange.max = rect.width()
                }
                
                if (rect.height() < heightRange.min)
                {
                    heightRange.min = rect.height()
                }
                
                if (rect.height() > heightRange.max)
                {
                    heightRange.max = rect.height()
                }
            }
            else
            {
                widthRange.min = rect.width()
                widthRange.max = rect.width()
                heightRange.min = rect.height()
                heightRange.max = rect.height()
                
                rangesInitialized = true
            }
        }
    }
    
    func calculateProportionRange()
    {
        var rangeInitialized = false
        
        for rect in rects
        {
            let proportionality = proportion(rect)
            
            if (rangeInitialized)
            {
                if (proportionality < proportionRange!.min)
                {
                    proportionRange!.min = proportionality
                }
                
                if (proportionality > proportionRange!.max)
                {
                    proportionRange!.max = proportionality
                }
            }
            else
            {
                proportionRange = ProportionRange(min:proportionality, max:proportionality)
                
                rangeInitialized = true
            }
        }
    }
    
    func calculateNormalizedProportionRange()
    {
        var rangeInitialized = false
        
        for rect in rects
        {
            let proportionality = normalizedProportion(rect)
            
            if (rangeInitialized)
            {
                if (proportionality < normalizedProportionRange!.min)
                {
                    normalizedProportionRange!.min = proportionality
                }
                
                if (proportionality > normalizedProportionRange!.max)
                {
                    normalizedProportionRange!.max = proportionality
                }
            }
            else
            {
                normalizedProportionRange = ProportionRange(min:proportionality, max:proportionality)
                
                rangeInitialized = true
            }
        }
    }
    
    func proportion(rect:TileRect) -> Double
    {
        let width = Double(rect.width())
        let height = Double(rect.height())
        
        return (height > width) ? -1.0*(1.0 - (width / height)) : (1.0 - (height / width))
    }
    
    func normalizedProportion(rect:TileRect) -> Double
    {
        return fabs(proportion(rect))
    }
}