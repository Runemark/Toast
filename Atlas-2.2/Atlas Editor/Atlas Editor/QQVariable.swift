//
//  QQVariable.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 3/2/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

enum QQVariableType
{
    case COMPONENT, RECT, ATOMICMAP, DENSITYMAP, COORDSET
}

class QQVariable
{
    var type:QQVariableType
    var initialized:Bool
    var optional:Bool
    var id:String?
    
    // Other variables which should be cross-initialized as soon as this one is
    var observers:[QQVariable]
    
    // This constitutes "defining" the variable
    init(type:QQVariableType, optional:Bool = false)
    {
        self.type = type
        self.optional = optional
        // Optional variables are automatically considered initialized
        self.initialized = (optional) ? true : false
        
        self.observers = [QQVariable]()
    }
    
    // This constitutes "initializing" the variable
    func initialize(id:String)
    {
        self.id = id
        self.initialized = true
        
        for observer in observers
        {
            observer.initialize(id)
        }
    }
    
    func registerObserver(observer:QQVariable)
    {
        observers.append(observer)
    }
}