//
//  Fenrir.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/26/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class Fenrir
{
    var analysisView:LKAnalysisView
    var bounds:TileRect
    var title:String
    
    init(title:String, analysisView:LKAnalysisView)
    {
        self.analysisView = analysisView
        self.bounds = TileRect(left:0, right:0, up:0, down:0)
        self.title = title
    }
    
    func createStyleGuide() -> FRStyleGuide?
    {
        if let map = TileMapIO().importAtomicMap(title)
        {
            bounds = TileRect(left:0, right:map.xMax-1, up:map.yMax-1, down:0)
            analysisView.loadMapMetaData(bounds)
            
            let densityMap = FRDensityModule(base:map, densityBounds:bounds, validSet:Set([1,2])).activate()
            let skeleton = FRSkeletonModule(density:densityMap, bounds:bounds).activate()

            // Visualize the plain density map
            for x in densityMap.bounds.left...densityMap.bounds.right
            {
                for y in densityMap.bounds.down...densityMap.bounds.up
                {
                    let coord = DiscreteTileCoord(x:x, y:y)
                    analysisView.updateDensityNodeAt(coord, density:densityMap.density(coord))
                }
            }
            
            let regions = FRDensitySubdivisionModule(skeleton:skeleton, bounds:bounds).activate()
            
            print(regions.count)
            
            if (regions.count > 0)
            {
                for region in regions
                {
                    if let bounds = region.bounds
                    {
                        analysisView.addRegion(bounds)
                    }
                }
            }
            
            let similarity = FRRectSimilarityModule(regions:regions)
            let styleInfo = similarity.activate()
            
            let guide = FRStyleGuide(title:title)
            guide.addComponent(styleInfo.width, height:styleInfo.height, prop:styleInfo.prop, normProp:styleInfo.normProp)
            
            StyleGuideIO().exportGuide(guide)
            return guide
        }
        else
        {
            print("ERROR: COULD NOT LOAD MAP")
            
            return nil
        }
    }
}