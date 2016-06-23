//
//  Histogram.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 5/21/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class Histogram {
    
    private var rawValues:[Double]
    private var bins:[Int]
    private var binCount:Int = 0
    
    init(values:[Double])
    {
        self.rawValues = values
        self.bins = [Int]()
    }
    
    func raw() -> [Double]
    {
        return rawValues
    }
    
    func allBins() -> [Int]
    {
        return bins
    }
    
    private func reBinValues(count:Int, range:(min:Double, max:Double, delta:Double))
    {
        let binIncrement = range.delta / Double(binCount)
        var binStart = range.min
        var binEnd = binStart + binIncrement
        if (range.delta == 0.0)
        {
            for _ in 0..<binCount
            {
                bins.append(0)
            }
            
            bins[0] = rawValues.count
        }
        else
        {
            for bin in 0..<binCount
            {
                bins.append(0)
                for value in rawValues
                {
                    let minMatch = (value >= binStart || withinTolerance(value, expected:binStart))
                    let maxMatch = ((bin == binCount-1) ? (value <= binEnd) : (value < binEnd)) || withinTolerance(value, expected:binEnd)
                    if (minMatch && maxMatch)
                    {
                        bins[bin] = bins[bin] + 1
                    }
                }
                
                binStart = binEnd
                binEnd += binIncrement
            }
        }
    }
    
    func withinTolerance(given:Double, expected:Double) -> Bool
    {
        return fabs(given - expected) < 0.0000000001
    }
    
    func reBinValues(newBinCount:Int, valueRange:(min:Double, max:Double, delta:Double)?)
    {
        binCount = newBinCount
        
        bins.removeAll()
        if (binCount > 0)
        {
            if let valueRange = valueRange
            {
                reBinValues(binCount, range:valueRange)
            }
            else
            {
                if let calculatedValueRange = range(rawValues)
                {
                    reBinValues(binCount, range:calculatedValueRange)
                }
            }
        }
    }
    
    // 0.0 = identical, 1.0 = infinitely different
    func compare(other:Histogram) -> Double {
        
        // First find the combined ranges
        let allValues = rawValues + other.rawValues
        let fullRange = range(allValues)!
        
        let normalizedHistogram = Histogram(values:rawValues)
        let normalizedOtherHistogram = Histogram(values:other.rawValues)
        
        let compareBinCount = 5
        // Bin the histograms over the same range
        normalizedHistogram.reBinValues(compareBinCount, valueRange:fullRange)
        normalizedOtherHistogram.reBinValues(compareBinCount, valueRange:fullRange)
        
        var deltaError = 0
        for bin in 0..<compareBinCount
        {
            let count = normalizedHistogram.bins[bin]
            let otherCount = normalizedOtherHistogram.bins[bin]
            
            let countDelta = abs(count - otherCount)
            deltaError += countDelta
        }
        
        return 1.0 - (1.0 / (Double(deltaError) + 1.0))
    }
    
    // TODO: Turn this into a T<Comparable> method
    func range(values:[Double]) -> (min:Double, max:Double, delta:Double)?
    {
        var valueRange:(min:Double, max:Double, delta:Double)?
        
        if (values.count > 0)
        {
            var min:Double?
            var max:Double?
            
            for value in values
            {
                if let oldMin = min
                {
                    if (value < oldMin)
                    {
                        min = value
                    }
                }
                else
                {
                    min = value
                }
                
                if let oldMax = max
                {
                    if (value > oldMax)
                    {
                        max = value
                    }
                }
                else
                {
                    max = value
                }
            }
            
            if let min = min
            {
                if let max = max
                {
                    valueRange = (min:min, max:max, delta:max-min)
                }
            }
        }
        
        return valueRange
    }
}