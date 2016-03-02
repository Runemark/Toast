//
//  TilesetIO.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/5/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class TilesetIO
{
    let fileIO:FileIO
    
    init()
    {
        fileIO = FileIO()
    }
    
    // All tilesets are stored in the BUNDLE itself
    func importTileset(name:String) -> Tileset
    {
        var tileset = Tileset()
        
        if let stringContents = fileIO.importStringFromFileInBundle(name, fileExtension:"tileset")
        {
            importTilesetFromStringContents(&tileset, contents:stringContents)
        }
        
        return tileset
    }
    
    private func importTilesetFromStringContents(inout tileset:Tileset, contents:String)
    {
        let tileEntryStrings = contents.componentsSeparatedByString("\n")
        
        for tileEntryString in tileEntryStrings
        {
            let tileEntryDataStrings = tileEntryString.componentsSeparatedByString("-")
            if (tileEntryDataStrings.count == 2)
            {
                if let uid = Int(tileEntryDataStrings[0])
                {
                    var size:TileViewSize?
                    var layer:TileLayer?
                    var alignment:TileViewAlignment?
                    var obstacle:Bool?
                    var baseTextureName:String?
                    var sideTextureName:String?
                    var extendedSideTextureName:String?
                    var topTextureName:String?
                    var microTextureName:String?
                    
                    let metaDataStrings = tileEntryDataStrings[1].componentsSeparatedByString(",")
                    
                    for metaDataString in metaDataStrings
                    {
                        let metaDataComponents = metaDataString.componentsSeparatedByString(":")
                        if (metaDataComponents.count == 2)
                        {
                            let componentName = metaDataComponents[0]
                            let componentValue = metaDataComponents[1]
                            
                            if (componentName == "size")
                            {
                                size = stringToTileViewSize(componentValue)
                            }
                            else if (componentName == "layer")
                            {
                                layer = stringToTileLayerType(componentValue)
                            }
                            else if (componentName == "alignment")
                            {
                                alignment = stringToTileAlignment(componentValue)
                            }
                            else if (componentName == "obstacle")
                            {
                                obstacle = stringToObstacle(componentValue)
                            }
                            else if (componentName == "texture")
                            {
                                baseTextureName = componentValue
                            }
                            else if (componentName == "sideTexture")
                            {
                                sideTextureName = componentValue
                            }
                            else if (componentName == "extendedSideTexture")
                            {
                                extendedSideTextureName = componentValue
                            }
                            else if (componentName == "topTexture")
                            {
                                topTextureName = componentValue
                            }
                            else if (componentName == "micro")
                            {
                                microTextureName = componentValue
                            }
                        }
                    }
                    
                    if (size != nil && layer != nil && obstacle != nil && baseTextureName != nil && microTextureName != nil)
                    {
                        tileset.registerUID(uid, viewSize:size!, alignment:alignment, layerType:layer!, obstacle:obstacle!, baseTextureName:baseTextureName!, sideTextureName:sideTextureName, extendedSideTextureName:extendedSideTextureName, topTextureName:topTextureName, microTextureName:microTextureName!)
                    }
                }
            }
        }
    }
    
    private func stringToTileViewSize(string:String) -> TileViewSize?
    {
        if (string == "short")
        {
            return TileViewSize.SHORT
        }
        else if (string == "tall")
        {
            return TileViewSize.TALL
        }
        else
        {
            return nil
        }
    }
    
    private func stringToTileLayerType(string:String) -> TileLayer?
    {
        if (string == "terrain")
        {
            return TileLayer.TERRAIN
        }
        else if (string == "doodad")
        {
            return TileLayer.DOODAD
        }
        else
        {
            return nil
        }
    }
    
    private func stringToObstacle(string:String) -> Bool?
    {
        if (string == "true")
        {
            return true
        }
        else if (string == "false")
        {
            return false
        }
        else
        {
            return nil
        }
    }
    
    private func stringToTileAlignment(string:String) -> TileViewAlignment?
    {
        if (string == "vertical")
        {
            return TileViewAlignment.VERTICAL
        }
        else if (string == "none")
        {
            return TileViewAlignment.NONE
        }
        else
        {
            return nil
        }
    }
        
    func importTilesetData(name:String) -> TilesetData
    {
        var tilesetData = TilesetData()
        
        if let stringContents = fileIO.importStringFromFileInBundle(name, fileExtension:"tileset")
        {
            importTilesetDataFromStringContents(&tilesetData, contents:stringContents)
        }
        
        return tilesetData
    }
    
    func importTilesetDataFromStringContents(inout tilesetData:TilesetData, contents:String)
    {
        let tileEntryStrings = contents.componentsSeparatedByString("\n")
        
        for tileEntryString in tileEntryStrings
        {
            let tileEntryDataStrings = tileEntryString.componentsSeparatedByString("-")
            if (tileEntryDataStrings.count == 2)
            {
                if let uid = Int(tileEntryDataStrings[0])
                {
                    var layer:TileLayer?
                    var obstacle:Bool?
                    
                    let metaDataStrings = tileEntryDataStrings[1].componentsSeparatedByString(",")
                    
                    for metaDataString in metaDataStrings
                    {
                        let metaDataComponents = metaDataString.componentsSeparatedByString(":")
                        if (metaDataComponents.count == 2)
                        {
                            let componentName = metaDataComponents[0]
                            let componentValue = metaDataComponents[1]
                    
                            if (componentName == "layer")
                            {
                                layer = stringToTileLayerType(componentValue)
                            }
                            else if (componentName == "obstacle")
                            {
                                obstacle = stringToObstacle(componentValue)
                            }
                        }
                    }
                    
                    if (layer != nil && obstacle != nil)
                    {
                        tilesetData.registerUID(uid, layerType:layer!, obstacle:obstacle!)
                    }
                }
            }
        }
    }
}

