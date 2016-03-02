//
//  SynchronizedArray.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/27/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

public class SynchronizedArray<T>
{
    private var array: [T] = []
    private let accessQueue = dispatch_queue_create("SynchronizedArrayAccess", DISPATCH_QUEUE_SERIAL)
    
    public func append(newElement: T)
    {
        dispatch_sync(self.accessQueue)
        {
            self.array.append(newElement)
        }
    }
    
    public func removeFirst() -> T
    {
        var firstElement:T!
        
        dispatch_sync(self.accessQueue)
        {
            firstElement = self.array.removeFirst()
        }
        
        return firstElement
    }
    
    public func arrayCount() -> Int
    {
        var arrayCount:Int = 0
        
        dispatch_sync(self.accessQueue)
        {
            arrayCount = self.array.count
        }
        
        return arrayCount
    }
}