//
//  FRDensitySubdivisionModule.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/26/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class FRDensitySubdivisionModule
{
    var skeleton:SkeletonMap
    var densityBounds:TileRect
    var subRegions:[TileRect]
    
    init(skeleton:SkeletonMap, bounds:TileRect)
    {
        self.skeleton = skeleton
        self.densityBounds = bounds
        self.subRegions = [TileRect]()
    }
    
    // If the map already contains separate portions, it will return the regions for them
    // If the map is fully reachable, it will successively drop out larger and larger skeleton nodes until it causes the map to segment, 
    //   and will return those segmented regions.
    // If the map cannot segment at any level, the complete base region will be returned
    func activate() -> [FRDynamicRegion]
    {
        let baseContent = skeleton.dropoutMap(0)
        let baseRegions = FRContentTraversalModule(content:baseContent).activate()
        if (baseRegions.count > 1)
        {
            return baseRegions
        }
        else
        {
            for strength in skeleton.orderedStrengths()
            {
                let content = skeleton.dropoutMap(strength)
                let regions = FRContentTraversalModule(content:content).activate()
                
                if (regions.count > 1)
                {
                    // Early return --- will break loop
                    return regions
                }
            }
            
            return baseRegions
        }
    }
}