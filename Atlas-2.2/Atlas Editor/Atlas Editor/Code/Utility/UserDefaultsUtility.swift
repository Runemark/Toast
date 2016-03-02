//
//  UserDefaultsUtility.swift
//  Hexbreaker
//
//  Created by Dusty Artifact on 11/21/15.
//  Copyright © 2015 Runemark. All rights reserved.
//

import Foundation

enum DefaultsKey:String
{
    case firstTimeLaunched = "firstTime_launch",
            gameCounter = "game_count"
}

func keyExists(key:DefaultsKey) -> Bool
{
    return defaults().dictionaryRepresentation().keys.contains(key.rawValue)
}

func firstTimeLaunched() -> Bool
{
    let key = DefaultsKey.firstTimeLaunched
    
    if (!keyExists(key))
    {
        // Create one
        defaults().setBool(true, forKey:key.rawValue)
        return true
    }
    else
    {
        return defaults().boolForKey(key.rawValue)
    }
}

func disableFirstTimeLaunched()
{
    defaults().setBool(false, forKey:DefaultsKey.firstTimeLaunched.rawValue)
}

func enableFirstTimeLaunched()
{
    defaults().setBool(true, forKey:DefaultsKey.firstTimeLaunched.rawValue)
}

func currentGameCount() -> Int
{
    let key = DefaultsKey.gameCounter
    
    if (!keyExists(key))
    {
        defaults().setInteger(0, forKey:key.rawValue)
        return 0
    }
    else
    {
        let currentCount = defaults().integerForKey(key.rawValue)
        return currentCount
    }
}

func incrementGameCounter()
{
    let key = DefaultsKey.gameCounter
    
    if (!keyExists(key))
    {
        defaults().setInteger(1, forKey:key.rawValue)
    }
    else
    {
        let currentCount = defaults().integerForKey(key.rawValue)
        defaults().setInteger(currentCount+1, forKey:key.rawValue)
    }
}

func resetGameCounter()
{
    let key = DefaultsKey.gameCounter
    defaults().setInteger(0, forKey:key.rawValue)
}

func defaults() -> NSUserDefaults
{
    return NSUserDefaults.standardUserDefaults()
}