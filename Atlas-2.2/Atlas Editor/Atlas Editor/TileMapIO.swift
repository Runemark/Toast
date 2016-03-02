//
//  TileMapIO.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/17/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class TileMapIO
{
    let fileIO:FileIO
    
    init()
    {
        fileIO = FileIO()
    }
    
    func importModel(modelName:String) -> TileMap?
    {
        var model:TileMap?
        
        if let stringContents = fileIO.importStringFromFileInDocs(modelName, fileExtension:"map", pathFromDocs:"Sources")
        {
            model = importModelFromFileContents(stringContents)
        }
        
        return model
    }
    
    func importAtomicMap(modelName:String) -> AtomicMap<Int>?
    {
        var map:AtomicMap<Int>?
        
        if let stringContents = fileIO.importStringFromFileInDocs(modelName, fileExtension:"map", pathFromDocs:"Sources")
        {
            map = importMapFromFileContents(stringContents)
        }
        
        return map
    }
    
    func removeModel(modelName:String)
    {
        fileIO.removeFileInDocs(modelName, fileExtension:"map", pathFromDocs:"Sources")
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Model Import
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func importModelFromFileContents(fileContents:String) -> TileMap?
    {
        var map:TileMap?
        
        let rows = fileContents.componentsSeparatedByString("\n")

        var title:String?
        var bounds:TileRect?
        var mapData = [DiscreteTileCoord:Int]()

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
                else if (name == "size")
                {
                    let sizeData = value.componentsSeparatedByString("x")
                    if (sizeData.count == 4)
                    {
                        let left = Int(sizeData[0])
                        let right = Int(sizeData[1])
                        let up = Int(sizeData[2])
                        let down = Int(sizeData[3])
                        
                        if (left != nil && right != nil && up != nil && down != nil)
                        {
                            bounds = TileRect(left:left!, right:right!, up:up!, down:down!)
                        }
                    }
                }
                else
                {
                    let coordinateData = name.componentsSeparatedByString(",")
                    if (coordinateData.count == 2)
                    {
                        let x = Int(coordinateData[0])
                        let y = Int(coordinateData[1])

                        if let x = x
                        {
                            if let y = y
                            {
                                let coordinate = DiscreteTileCoord(x:x, y:y)

                                if let tileValue = Int(value)
                                {
                                    mapData[coordinate] = tileValue
                                }
                            }
                        }
                    }
                }
            }
        }

        if let title = title
        {
            if let bounds = bounds
            {
                map = TileMap(bounds:bounds, title:title)
                
                for (coord, value) in mapData
                {
                    map!.directlySetTerrainTileAt(coord, uid:value)
                }
            }
        }
        
        return map
    }
    
    func importMapFromFileContents(fileContents:String) -> AtomicMap<Int>?
    {
        var map:AtomicMap<Int>?
        
        let rows = fileContents.componentsSeparatedByString("\n")
        
        var bounds:TileRect?
        var mapData = [DiscreteTileCoord:Int]()
        
        for row in rows
        {
            let rowData = row.componentsSeparatedByString(":")
            if (rowData.count == 2)
            {
                let name = rowData[0]
                let value = rowData[1]
                
                if (name == "title")
                {
                    // Do nothing
                }
                if (name == "size")
                {
                    let sizeData = value.componentsSeparatedByString("x")
                    if (sizeData.count == 4)
                    {
                        let left = Int(sizeData[0])
                        let right = Int(sizeData[1])
                        let up = Int(sizeData[2])
                        let down = Int(sizeData[3])
                        
                        if (left != nil && right != nil && up != nil && down != nil)
                        {
                            bounds = TileRect(left:left!, right:right!, up:up!, down:down!)
                        }
                    }
                }
                else
                {
                    let coordinateData = name.componentsSeparatedByString(",")
                    if (coordinateData.count == 2)
                    {
                        let x = Int(coordinateData[0])
                        let y = Int(coordinateData[1])
                        
                        if let x = x
                        {
                            if let y = y
                            {
                                let coordinate = DiscreteTileCoord(x:x, y:y)
                                
                                if let tileValue = Int(value)
                                {
                                    mapData[coordinate] = tileValue
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if let bounds = bounds
        {
            map = AtomicMap<Int>(xMax:bounds.width(), yMax:bounds.height(), filler:0, offset:DiscreteTileCoord(x:0, y:0))
            
            for (coord, value) in mapData
            {
                map![coord] = value
            }
        }
        
        return map
    }
    
    func exportModel(model:TileMap)
    {
        let modelString = modelToString(model)
        fileIO.exportToFileInDocs(model.mapTitle(), fileExtension:"map", pathFromDocs:"Sources", contents:modelString)
    }
    
    func modelToString(model:TileMap) -> String
    {
        var modelString = "title:\(model.mapTitle())\n"
        let bounds = model.mapBounds()
        modelString += "size:\(bounds.left)x\(bounds.right)x\(bounds.up)x\(bounds.down)"
        
        for (coord, value) in model.allTerrainData()
        {
            modelString += "\n\(coord.x),\(coord.y):\(value)"
        }
        
        return modelString
    }
}