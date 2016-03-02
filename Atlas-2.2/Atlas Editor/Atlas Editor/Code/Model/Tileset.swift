//
//  Tileset.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/4/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import SpriteKit

struct TileViewInfo
{
    var size:TileViewSize
    var layer:TileLayer
    var alignment:TileViewAlignment?
    var baseString:String
    var sideString:String?
    var extendedSideString:String?
    var topString:String?
    var microString:String
}

enum TileViewAlignment
{
    case VERTICAL, NONE
}

enum TileViewSize
{
    case SHORT, TALL
}

enum TileLayer
{
    case TERRAIN, DOODAD
}

class Tileset
{
    private var terrainUIDS:Set<Int>
    private var doodadUIDS:Set<Int>
    private var index:[Int:TileViewInfo]
    private var viewAtlas:SKTextureAtlas?
    
    init()
    {
        index = [Int:TileViewInfo]()
        terrainUIDS = Set<Int>()
        doodadUIDS = Set<Int>()
    }
    
    func importAtlas(name:String)
    {
        viewAtlas = SKTextureAtlas(named:name)
    }
    
    func registerUID(uid:Int, viewSize:TileViewSize, alignment:TileViewAlignment?, layerType:TileLayer, obstacle:Bool, baseTextureName:String, sideTextureName:String?, extendedSideTextureName:String?, topTextureName:String?, microTextureName:String)
    {
        let viewInfo = TileViewInfo(size:viewSize, layer:layerType, alignment:alignment, baseString:baseTextureName, sideString:sideTextureName, extendedSideString:extendedSideTextureName, topString:topTextureName, microString:microTextureName)
        index[uid] = viewInfo
        
        if (layerType == .TERRAIN)
        {
            terrainUIDS.insert(uid)
        }
        else if (layerType == .DOODAD)
        {
            doodadUIDS.insert(uid)
        }
    }
    
    func clearData()
    {
        index.removeAll()
        terrainUIDS.removeAll()
        doodadUIDS.removeAll()
    }
    
    func baseTextureNameForUID(uid:Int) -> String?
    {
        return index[uid]?.baseString
    }
    
    func sideTextureNameForUID(uid:Int) -> String?
    {
        return index[uid]?.sideString
    }
    
    func extendedSideTextureNameForUID(uid:Int) -> String?
    {
        return index[uid]?.extendedSideString
    }
    
    func topTextureNameForUID(uid:Int) -> String?
    {
        return index[uid]?.topString
    }
    
    func microTextureNameForUID(uid:Int) -> String?
    {
        return index[uid]?.microString
    }
    
    func sizeForUID(uid:Int) -> TileViewSize?
    {
        if (uid == 0)
        {
            return TileViewSize.SHORT
        }
        else
        {
            return index[uid]?.size
        }
    }
    
    func alignmentForUID(uid:Int) -> TileViewAlignment?
    {
        return index[uid]?.alignment
    }
    
    func baseTextureForUID(uid:Int) -> SKTexture?
    {
        if let baseTextureName = baseTextureNameForUID(uid)
        {
            if let texture = viewAtlas?.textureNamed(baseTextureName)
            {
                texture.filteringMode = .Nearest
                return texture
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    func sideTextureForUID(uid:Int) -> SKTexture?
    {
        if let sideTextureName = sideTextureNameForUID(uid)
        {
            if let texture = viewAtlas?.textureNamed(sideTextureName)
            {
                texture.filteringMode = .Nearest
                return texture
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    func extendedSideTextureForUID(uid:Int) -> SKTexture?
    {
        if let extendedSideTextureName = extendedSideTextureNameForUID(uid)
        {
            if let texture = viewAtlas?.textureNamed(extendedSideTextureName)
            {
                texture.filteringMode = .Nearest
                return texture
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    func topTextureForUID(uid:Int) -> SKTexture?
    {
        if let topTextureName = topTextureNameForUID(uid)
        {
            if let texture = viewAtlas?.textureNamed(topTextureName)
            {
                texture.filteringMode = .Nearest
                return texture
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    func microTextureForUID(uid:Int) -> SKTexture?
    {
        if let microTextureName = microTextureNameForUID(uid)
        {
            if let texture = viewAtlas?.textureNamed(microTextureName)
            {
                texture.filteringMode = .Nearest
                return texture
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    func allTerrainUIDS() -> Set<Int>
    {
        return terrainUIDS
    }
    
    func allDoodadUIDS() -> Set<Int>
    {
        return doodadUIDS
    }
    
    func allTerrainUIDSPlusEmpty() -> Set<Int>
    {
        var allUIDS = allTerrainUIDS()
        allUIDS.insert(0)
        return allUIDS
    }
    
    func allDoodadUIDSPlusEmpty() -> Set<Int>
    {
        var allUIDS = allDoodadUIDS()
        allUIDS.insert(0)
        return allUIDS
    }
}