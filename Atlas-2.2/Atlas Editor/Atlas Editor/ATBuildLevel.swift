//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation


class ATBuildLevel : QQTask
{
    var recentNodes:Queue<DiscreteTileCoord>
    var flowMap:Set<DiscreteTileCoord>
    
    override init()
    {
        recentNodes = Queue<DiscreteTileCoord>()
        flowMap = Set<DiscreteTileCoord>()
        
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
        if let _ = canvas
        {
            selectNextNode()
        }
    }
    
    func selectNextNode()
    {
        let bounds = canvas!.canvasBounds()
        
        if let currentNode = recentNodes.peek()
        {
            let up = currentNode + DiscreteTileCoord(x:0, y:3)
            let down = currentNode + DiscreteTileCoord(x:0, y:-3)
            let left = currentNode + DiscreteTileCoord(x:3, y:0)
            let right = currentNode + DiscreteTileCoord(x:-3, y:0)
            
            var candidates = [up, down, left, right]
            var points = [DiscreteTileCoord]()
            
            for _ in 0...3
            {
                let randomIndex = randIntBetween(0, stop:candidates.count-1)
                let randomNode = candidates[randomIndex]
                points.append(randomNode)
            }
            
            checkPoints(points)
        }
        else
        {
            addNodeToFlowMap(bounds.center())
        }
    }
    
    func checkPoints(points:[DiscreteTileCoord])
    {
        var pointFound = false
        for point in points
        {
            if (nodeSpaceAvailable(point))
            {
                addNodeToFlowMap(point)
                pointFound = true
                break
            }
        }
        
        if (!pointFound)
        {
            if (recentNodes.count > 0)
            {
                recentNodes.dequeue()
            }
            else
            {
                complete()
            }
        }
    }

    func nodeSpaceAvailable(node:DiscreteTileCoord) -> Bool
    {
        var spaceAvailable = true
        for x in node.x-2...node.x+2
        {
            for y in node.y-2...node.y+2
            {
                let position = DiscreteTileCoord(x:x, y:y)
                if (flowMap.contains(position))
                {
                    spaceAvailable = false
                    break
                }
                
                if (!canvas!.canvasBounds().contains(position))
                {
                    spaceAvailable = false
                    break
                }
            }
        }
        
        return spaceAvailable
    }
    
    func addNodeToFlowMap(coord:DiscreteTileCoord)
    {
        if let mostRecent = recentNodes.peek()
        {
            canvas!.addFlowLineAt(LineSegment(a:mostRecent, b:coord))
        }
        recentNodes.enqueue(coord)
        flowMap.insert(coord)
//        canvas?.addFlowNodeAt(coord)
    }
}