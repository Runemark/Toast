//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation


class GABuildLevel3 : QQTask
{
    var genePool:GeneticComponentLayout?
    
    override init()
    {
        super.init()
        
        ////////////////////////////////////////////////////////////
        // Input ()
        ////////////////////////////////////////////////////////////
        
        ////////////////////////////////////////////////////////////
        // Output ()
        ////////////////////////////////////////////////////////////
    }
    
    ////////////////////////////////////////////////////////////
    // Task
    override func apply()
    {
        if let canvas = canvas
        {
            if let genePool = genePool
            {
                let best = genePool.nextGeneration()
                print(best.score)
                
                canvas.redrawComponentLayout(best.layout)
            }
            else
            {
                let sourceLevel = ComponentLayout()
                sourceLevel.addComponent(DiscreteTileCoord(x:1, y:1))
                sourceLevel.addComponent(DiscreteTileCoord(x:3, y:1))
                sourceLevel.addComponent(DiscreteTileCoord(x:1, y:3))
                sourceLevel.addComponent(DiscreteTileCoord(x:3, y:3))
                
                let areaTemplate = sourceLevel.evaluation_distanceFromAreaCenter(canvas.canvasBounds())
                let clusterTemplate = sourceLevel.evaluation_distanceFromClusterCenter()
                let localTemplateGroup = sourceLevel.evaluation_localStats()
                let localNeighborTemplate = localTemplateGroup.neighbors
                let localDistanceTemplate = localTemplateGroup.distances
                let localAngleTemplate = localTemplateGroup.angles
                
                let sourceTemplate = ComponentLayoutTemplate(desiredAreaHist:areaTemplate, desiredClusterHist:clusterTemplate, desiredLocalDistHist:localDistanceTemplate, desiredLocalNeighborHist:localNeighborTemplate, desiredLocalAngleHist:localAngleTemplate)
                
                genePool = GeneticComponentLayout(popCount:25, componentCount:4, area:canvas.canvasBounds(), template:sourceTemplate)
            }
        }
    }
}