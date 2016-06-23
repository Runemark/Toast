//
//  FRSkeletonModule.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/26/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class FRSimpleSkeletonModule
{
    var skeleton:SkeletonMap
    var bounds:TileRect
    
    init(skeleton:SkeletonMap, bounds:TileRect)
    {
        self.skeleton = skeleton
        self.bounds = bounds
    }
    
    func activate() -> SkeletonMap
    {
//        let regions = FRDensitySubdivisionModule(skeleton:skeleton, bounds:bounds).activate()
//        for region in regions
//        {
//            // Simplify the region into its rect
//            if let regionBounds = region.bounds
//            {
//                localSkeletonForRect(regionBounds)
//            }
//        }
        return skeleton
    }
    
    func localSkeletonForRect(rect:TileRect) -> SkeletonMap
    {
        let width = rect.width()
        let height = rect.height()
        let bounds = TileRect(left:0, right:width-1, up:height-1, down:0)
        
        let density = densityForRect(rect)
        return FRSkeletonModule(density:density, bounds:bounds).activate()
    }
    
    func densityForRect(rect:TileRect) -> DensityMap
    {
        let width = rect.width()
        let height = rect.height()
        
        let base = AtomicMap<Int>(xMax:width, yMax:height, filler:1, offset:DiscreteTileCoord(x:0, y:0))
        let densityBounds = TileRect(left:0, right:width-1, up:height-1, down:0)
        let validSet = Set<Int>([1])
        
        return FRDensityModule(base:base, densityBounds:densityBounds, validSet:validSet).activate()
    }
}