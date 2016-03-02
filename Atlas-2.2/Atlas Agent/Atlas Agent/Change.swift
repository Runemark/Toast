//
//  Change.swift
//  Atlas Agent
//
//  Created by Dusty Artifact on 1/26/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

struct Change
{
    var coord:DiscreteTileCoord
    var layer:TileLayer
    var value:Int
}

enum TileLayer
{
    case TERRAIN, DOODAD
}