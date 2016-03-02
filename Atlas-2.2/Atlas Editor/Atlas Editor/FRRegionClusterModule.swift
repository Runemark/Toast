//
//  FRRegionClusterModule.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 2/29/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class FRRegionClusterModule
{
    var rects:[TileRect]
    var clusters:[Int:Cluster]
    
    init(regions:[FRDynamicRegion])
    {
        rects = [TileRect]()
        clusters = [Int:Cluster]()
        
        for region in regions
        {
            if let rect = region.bounds
            {
                rects.append(rect)
            }
        }
    }
    
    func activate()
    {
        // Create the data points
        var data = [Vector]()
        
        for rect in rects
        {
            let datum = Vector(vars:[Double(rect.width()), Double(rect.height())])
            data.append(datum)
        }
        
        // Cluster them
        FRClusterModule().activate(data)
    }
}