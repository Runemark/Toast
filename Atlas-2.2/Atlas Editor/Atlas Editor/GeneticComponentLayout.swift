//
//  GeneticComponentLayout.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 5/28/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

struct ComponentLayoutTemplate
{
    var desiredAreaHist:Histogram
    var desiredClusterHist:Histogram
    var desiredLocalDistHist:Histogram
    var desiredLocalNeighborHist:Histogram
    var desiredLocalAngleHist:Histogram
}

class GeneticComponentLayout
{
    var population:[ComponentLayout]
    var populationCount:Int
    var componentCount:Int
    var selectionRate:Double
    var mutationRate:Double
    var workspace:TileRect
    var bestComponent:(score:Double, layout:ComponentLayout)?
    
    var template:ComponentLayoutTemplate
    
    init(popCount:Int, componentCount:Int, area:TileRect, template:ComponentLayoutTemplate)
    {
        self.population = [ComponentLayout]()
        self.populationCount = popCount
        self.componentCount = componentCount
        self.selectionRate = 0.5
        self.mutationRate = 0.95
        self.workspace = area
        self.template = template
    }
    
    func repopulateRandom()
    {
        while population.count < populationCount
        {
            let randomLayout = ComponentLayout()
            randomLayout.scramble(workspace, count:componentCount)
            
            population.append(randomLayout)
        }
    }
    
    func nextGeneration() -> (score:Double, layout:ComponentLayout)
    {
        repopulateRandom()
        mutate()
        naturalSelection()
        
        return bestComponent!
    }
    
    func naturalSelection()
    {
        let selectionLimit = Int(floor(Double(populationCount) * selectionRate))
        
        var rankedPopulation = [(score:Double, layout:ComponentLayout)]()
        for layout in population
        {
            let score = fitness(layout)
            rankedPopulation.append((score:score, layout:layout))
        }
        
        rankedPopulation.sortInPlace { (a, b) -> Bool in
            a.score > b.score
        }
        
        population.removeAll()
        for index in 0..<selectionLimit
        {
            population.append(rankedPopulation[index].layout)
        }
        
        if (rankedPopulation.count > 0)
        {
            bestComponent = rankedPopulation[0]
        }
    }
    
    func mutate()
    {
        let mutationLimit = Int(floor(Double(populationCount) * mutationRate))
        
        for layout in population.randomSubset(mutationLimit)
        {
            layout.mutate(0.25, area:workspace)
        }
    }
    
    // 0.0 <---worse---|---better---> 1.0
    func fitness(layout:ComponentLayout) -> Double
    {
        let areaHist = layout.evaluation_distanceFromAreaCenter(workspace)
        let clusterHist = layout.evaluation_distanceFromClusterCenter()
        let localHistGroup = layout.evaluation_localStats()
        let angleHist = localHistGroup.angles
        let distHist = localHistGroup.distances
        let neighborHist = localHistGroup.neighbors
        
        // histogram deltas range from exact match (0.0) <---> extremely different (infinity)
        let clusterDelta = template.desiredClusterHist.compare(clusterHist)
        let areaDelta = template.desiredAreaHist.compare(areaHist)
        let angleDelta = template.desiredLocalAngleHist.compare(angleHist)
        let distanceDelta = template.desiredLocalDistHist.compare(distHist)
        let neighborDelta = template.desiredLocalNeighborHist.compare(neighborHist)
        
        // TODO: Perhaps ONLY evaluate fitness on the one that is doing the WORST?
        // TODO: Specific Mutations for Specific Fitness Problems
        
        let score = 1.0 / ((distanceDelta + angleDelta + neighborDelta + clusterDelta + areaDelta) + 1.0)
        
        return score
    }
}