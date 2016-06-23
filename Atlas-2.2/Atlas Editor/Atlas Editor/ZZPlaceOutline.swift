//
//  QQBuildComponentTask.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

enum ZZPlaceOutlinePhase
{
    case PREPARATION, PLACEMENT, VALIDATION, WAIT
}

class ZZPlaceOutline : QQTask
{
    var phase:ZZPlaceOutlinePhase = ZZPlaceOutlinePhase.PREPARATION
    var offsetsToValidate:Queue<DiscreteTileCoord>
    
    override init()
    {
        offsetsToValidate = Queue<DiscreteTileCoord>()
        
        super.init()
        
        ////////////////////////////////////////////////////////////
        // Input ()
        ////////////////////////////////////////////////////////////
        context.defineInput("outline", type:QQVariableType.RECT)
        
        ////////////////////////////////////////////////////////////
        // Output ()
        ////////////////////////////////////////////////////////////
        context.defineOutput("offset", type:QQVariableType.DISCRETECOORD)
    }
    
    ////////////////////////////////////////////////////////////
    // Task: Decide where to place the outline on the map
    // Returns an offset from the outline's
    override func apply()
    {
        if (context.allInputsInitialized())
        {
            if let canvas = canvas
            {
                let outlineId = context.idForVariableNamed("outline")!
                let outline = QQWorkingMemory.sharedInstance.rectValue(outlineId)!
                
                if (phase == ZZPlaceOutlinePhase.PREPARATION)
                {
                    let densityTask = ZZDensityMap()
//                    let distanceTask = ZZContentDistanceMap()
                    
                    context.defineVariable("density", type:QQVariableType.DENSITYMAP)
//                    context.defineVariable("distance", type:QQVariableType.DENSITYMAP)
                    
                    prepareToReceive("density", sendingTask:densityTask, sendingVariable:"density")
//                    prepareToReceive("distance", sendingTask:distanceTask, sendingVariable:"distance")
                    
                    insertSubaskLast(densityTask)
//                    insertSubaskLast(distanceTask)
                    
                    phase = ZZPlaceOutlinePhase.WAIT
                }
                else if (phase == ZZPlaceOutlinePhase.PLACEMENT)
                {
                    if (canvas.componentRectCount() == 0)
                    {
                        // Place at CENTER
                        let mapCenter = canvas.canvasBounds().center()
                        let outlineCenter = outline.center()
                        
                        let offset = mapCenter - outlineCenter
                        offsetsToValidate.enqueue(offset)
                        
                        // Register the component rect with HQ
                        canvas.registerComponentRect(outline.shift(offset))
                        
                        phase = ZZPlaceOutlinePhase.VALIDATION
                    }
                    else
                    {
                        let density = context.getLocalDensityMap("density")!
//                        let distance = context.getLocalDensityMap("distance")!
                        
                        for strength in density.orderedStrengths()
                        {
                            if (strength > 1)
                            {
                                if let candidatesForStrength = density.registry[strength]
                                {
                                    for candidate in candidatesForStrength
                                    {
                                        offsetsToValidate.enqueue(candidate)
                                    }
                                }
                            }
                        }
                        
                        phase = ZZPlaceOutlinePhase.VALIDATION
                        
//                        // We've got an outline, we've got density, and we've got distance.
//                        // Can we place it anywhere?
//                        
//                        // HACK - FOR ANY RECTANGULAR OUTLINE
//                        // Check the outline -- pick the largest node
//                        let widthItr = Int(ceil(Double(outline.width())/2.0))
//                        let heightItr = Int(ceil(Double(outline.height())/2.0))
//                        let largestNodeWidth = 1 + (widthItr-1)*2
//                        let largestNodeHieght = 1 + (heightItr-1)*2
//                        let largestNodeSize = max(largestNodeWidth, largestNodeHieght)
//
//                        let anchorShift = Int(ceil(Double(largestNodeSize+1)/2.0))-1
//                        // We now have an anchorPoint relative to the outline
//                        let anchorPoint = DiscreteTileCoord(x:outline.left + anchorShift, y:outline.down + anchorShift)
//                        
//                        // First, does the densityMap contain any nodes greater than or equal to the outline's largest node size?
//                        var potentialStrengthMatch = -1
//                        for strength in density.orderedStrengths()
//                        {
//                            if (strength >= largestNodeSize)
//                            {
//                                potentialStrengthMatch = strength
//                                break
//                            }
//                        }
//                        
//                        if (potentialStrengthMatch > 0)
//                        {
//                            if let potentialAnchorMatches = density.registry[potentialStrengthMatch]
//                            {
//                                for potentialAnchorMatch in potentialAnchorMatches
//                                {
//                                    let offset = potentialAnchorMatch - DiscreteTileCoord(x:anchorShift, y:anchorShift)
//                                    offsetsToValidate.enqueue(offset)
//                                }
////                                var anchorMatchesByDistance = [(dist:Int, anchor:DiscreteTileCoord)]()
////                                
////                                var minimumDistanceSoFar = 10000
////                                for potentialAnchorMatch in potentialAnchorMatches
////                                {
////                                    let dist = distance.map[potentialAnchorMatch]
////                                    anchorMatchesByDistance.append(dist:dist, anchor:potentialAnchorMatch)
////                                    
////                                    if (dist < minimumDistanceSoFar && dist > 1)
////                                    {
////                                        minimumDistanceSoFar = dist
////                                    }
////                                }
////                                
////                                let anchorCandidates = anchorMatchesByDistance.filter({$0.dist == minimumDistanceSoFar})
////                                for anchorCandidate in potentialAnchor
////                                {
////                                    // THIS is the point where we'll ANCHOR our shape. Now subtract the anchorshift to get the rect origin
////                                    let offset = anchorCandidate.anchor - DiscreteTileCoord(x:anchorShift, y:anchorShift)
////                                    offsetsToValidate.enqueue(offset)
////                                }
//                            }
//                            else
//                            {
//                                print("OUTLINE FAILED")
//                                success = false
//                                complete()
//                            }
//                        }
//                        else
//                        {
//                            print("OUTLINE FAILED")
//                            // No potential map -- outline CANNOT fit on the board
//                            success = false
//                            complete()
//                        }
                    }
                    
                    phase = ZZPlaceOutlinePhase.VALIDATION
                }
                else if (phase == ZZPlaceOutlinePhase.VALIDATION)
                {
                    if let nextPotentialAnchor = offsetsToValidate.dequeue()
                    {
                        // TOTAL HACK: NOW CAN ONLY WORK WITH RECTANGLES WITH A MAX NODE STRENGTH OF (3)
                        let offset = nextPotentialAnchor
                        print(nextPotentialAnchor)
                        let offsetId = context.setGlobalDiscreteCoord(offset)
                        context.initializeVariable("offset", id:offsetId)
                        
                        let validateTask = ZZValidateOutlinePlacement()
                        validateTask.initializeInput("outline", id:outlineId)
                        validateTask.initializeInput("offset", id:offsetId)
                        insertSubaskLast(validateTask)
                    }
                    else
                    {
                        // None left
                        success = false
                        complete()
                    }
                }
            }
        }
    }
    
    override func subtaskCompleted(child:QQTask)
    {
        if child is ZZDensityMap
        {
            phase = ZZPlaceOutlinePhase.PLACEMENT
        }
        else if child is ZZValidateOutlinePlacement
        {
            if (child.success)
            {
                success = true
                complete()
            }
            else
            {
                // Continue validating
            }
        }
        
        super.subtaskCompleted(child)
    }
}