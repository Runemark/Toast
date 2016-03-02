//
//  TileMapIO.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/17/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class StyleGuideIO
{
    let fileIO:FileIO
    
    init()
    {
        fileIO = FileIO()
    }
    
    func importGuide(modelName:String) -> FRStyleGuide?
    {
        var guide:FRStyleGuide?
        
        if let stringContents = fileIO.importStringFromFileInDocs(modelName, fileExtension:"map", pathFromDocs:"Guides")
        {
            guide = importGuideFromFileContents(stringContents)
        }
        
        return guide
    }
    
    func removeGuide(modelName:String)
    {
        fileIO.removeFileInDocs(modelName, fileExtension:"map", pathFromDocs:"Guides")
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Model Import
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func importGuideFromFileContents(fileContents:String) -> FRStyleGuide?
    {
        var guide:FRStyleGuide?
        
        let rows = fileContents.componentsSeparatedByString("\n")
        
        var title:String?
        var width:TileLengthRange?
        var height:TileLengthRange?
        var prop:ProportionRange?
        var normProp:ProportionRange?
        
        for row in rows
        {
            let rowData = row.componentsSeparatedByString(":")
            if (rowData.count == 2)
            {
                let name = rowData[0]
                let value = rowData[1]
                
                if (name == "title")
                {
                    title = value
                }
                else if (name == "width")
                {
                    width = tileRangeFromString(value)
                }
                else if (name == "height")
                {
                    height = tileRangeFromString(value)
                }
                else if (name == "prop")
                {
                    prop = proportionRangeFromString(value)
                }
                else if (name == "normProp")
                {
                    normProp = proportionRangeFromString(value)
                }
            }
        }
        
        if (title != nil && width != nil && height != nil)
        {
            guide = FRStyleGuide(title:title!)
            // WARXING: INCOMPLETE: WE ONLY IMPORT THE FIRST COMPONENT FOR NOW
            guide!.addComponent(width!, height:height!, prop:prop, normProp:normProp)
        }
        
        return guide
    }
    
    func exportGuide(guide:FRStyleGuide)
    {
        let modelString = guideToString(guide)
        fileIO.exportToFileInDocs(guide.title, fileExtension:"map", pathFromDocs:"Guides", contents:modelString)
    }
    
    func guideToString(guide:FRStyleGuide) -> String
    {
        var guideString = "title:\(guide.title)\n"
        
        let component = guide.components.first!
        
        guideString += "width:\(stringForTileRange(component.width))\n"
        guideString += "height:\(stringForTileRange(component.height))"
        
        if let prop = component.prop
        {
            guideString += "\nprop:\(stringForProportionRange(prop))"
        }
        
        if let normProp = component.normProp
        {
            guideString += "\nnormProp:\(stringForProportionRange(normProp))"
        }
        
        return guideString
    }

    func tileRangeFromString(rangeString:String) -> TileLengthRange?
    {
        var range:TileLengthRange?
        
        let rangeComponents = rangeString.componentsSeparatedByString(",")
        if (rangeComponents.count == 2)
        {
            if let min = Int(rangeComponents[0])
            {
                if let max = Int(rangeComponents[1])
                {
                    range = TileLengthRange(min:min, max:max)
                }
            }
        }
        
        return range
    }
    
    func proportionRangeFromString(rangeString:String) -> ProportionRange?
    {
        var range:ProportionRange?
        
        let rangeComponents = rangeString.componentsSeparatedByString(",")
        if (rangeComponents.count == 2)
        {
            if let min = Double(rangeComponents[0])
            {
                if let max = Double(rangeComponents[1])
                {
                    range = ProportionRange(min:min, max:max)
                }
            }
        }
        
        return range
    }
    
    func stringForTileRange(range:TileLengthRange) -> String
    {
        return "\(range.min),\(range.max)"
    }
    
    func stringForProportionRange(range:ProportionRange) -> String
    {
        return "\(range.min),\(range.max)"
    }
}