//
//  RandomExtensions.swift
//  DeepGeneration
//
//  Created by Martin Mumford on 3/28/15.
//  Copyright (c) 2015 Runemark Studios. All rights reserved.

import Foundation

// Returns a random bool with 50/50 chance of getting true/false
func coinFlip() -> Bool
{
    return weightedCoinFlip(0.5)
}

// Returns with a (trueProb) probability of returning true, and a (1-trueProb) probability of returning false
func weightedCoinFlip(trueProb:Double) -> Bool
{
    return (trueProb > randNormalDouble())
}

// Returns a random int between the specified ranges (inclusive)
func randIntBetween(start:Int, stop:Int) -> Int
{
    var offset = 0
    
    if start < 0
    {
        offset = abs(start)
    }
    
    let mini = UInt32(start + offset)
    let maxi = UInt32(stop + offset)
    
    return Int(mini + arc4random_uniform(maxi + 1 - mini)) - offset
}

func randIndexWithProbabilities(probabilities:[Double]) -> Int
{
    var probabilitySegments = [Double]()
    var runningProbability = 0.0
    for probability in probabilities
    {
        runningProbability += probability
        probabilitySegments.append(runningProbability)
    }
    
    let randomNumber = randDoubleBetween(0.0, stop:1.0)
    
    var randomIndex = 0
    
    for probabilitySegment in probabilitySegments
    {
        if randomNumber < probabilitySegment
        {
            break
        }
        
        randomIndex += 1
    }
    
    return randomIndex
}

// Returns a random float between 0 and 1
func randNormalFloat() -> Float
{
    return Float(arc4random()) / Float(UINT32_MAX)
}

// Returns a random double between 0 and 1
func randNormalDouble() -> Double
{
    return Double(arc4random()) / Double(UINT32_MAX)
}

func randDoubleBetween(start:Double, stop:Double) -> Double
{
    let difference = abs(start - stop)
    return start + randNormalDouble()*difference
}

public extension Array
{
    func randomElement() -> Element?
    {
        if (self.count > 0)
        {
            let randomIndex = randIntBetween(0, stop:self.count-1)
            return self[randomIndex]
        }
        else
        {
            return nil
        }
    }
    
    func randomSubset(subsetCount:Int) -> Array
    {
        var subset = Array<Element>()
        
        if (subsetCount >= self.count || subsetCount < 0)
        {
            subset = Array(self)
        }
        else
        {
            var indexes = [Int]()
            
            for index in 0..<self.count
            {
                indexes.append(index)
            }
            
            indexes.shuffle()
            
            var subset = Array<Element>()
            for i in 0..<subsetCount
            {
                let nextIndex = indexes[i]
                subset.append(self[nextIndex])
            }
        }
        
        return subset
    }
    
    // Fisher-Yates (fast and uniform) shuffle
    mutating func shuffle()
    {
        if count < 2 {
            return
        }
        for i in 0..<(count - 1)
        {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            
            let i_element = self[i]
            let j_element = self[j]
            
            self[i] = j_element
            self[j] = i_element
        }
    }
}

public extension Set
{
    func randomElement() -> Element?
    {
        let array = Array(self)
        return array.randomElement()
    }
    
    func randomSubset(subsetCount:Int) -> Set<Element>
    {
        var subset = Set<Element>()
        
        if (subsetCount >= self.count || subsetCount < 0)
        {
            subset = Set(self)
        }
        else
        {
            let array = Array(self)
            
            var indexes = [Int]()
            
            for index in 0..<self.count
            {
                indexes.append(index)
            }
            
            indexes.shuffle()
            
            subset = Set<Element>()
            for i in 0..<subsetCount
            {
                let nextIndex = indexes[i]
                subset.insert(array[nextIndex])
            }
        }
        
        return subset
    }
}