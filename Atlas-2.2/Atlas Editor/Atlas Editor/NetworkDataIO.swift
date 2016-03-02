//
//  NetworkDataIO.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/27/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation

class NetworkDataIO
{
    //////////////////////////////////////////////////////////////////////////////////////////
    // Data Translation
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func stringForEditRequest(change:Change) -> String
    {
        var string = "messagetype:\(stringForMessageType(MessageType.EDIT_REQUEST))"
        
        string += "\n"
        string += "coord:\(stringForCoordinate(change.coord))"
        string += "\n"
        string += "layer:\(stringForLayer(change.layer))"
        string += "\n"
        string += "value:\(stringForValue(change.value))"
        
        return string
    }
    
    func stringForBoundsRequest() -> String
    {
        return "messagetype:\(stringForMessageType(MessageType.BOUNDS_REQUEST))"
    }
    
    func coordinateForString(string:String) -> DiscreteTileCoord?
    {
        var coordinate:DiscreteTileCoord?
        
        let coordinateComponents = string.componentsSeparatedByString(",")
        if (coordinateComponents.count == 2)
        {
            let xString = coordinateComponents[0]
            let yString = coordinateComponents[1]
            
            if let x = Int(xString)
            {
                if let y = Int(yString)
                {
                    coordinate = DiscreteTileCoord(x:x, y:y)
                }
            }
        }
        
        return coordinate
    }
    
    func stringForCoordinate(coord:DiscreteTileCoord) -> String
    {
        return "\(coord.x),\(coord.y)"
    }
    
    func layerForString(string:String) -> TileLayer?
    {
        var layer:TileLayer?
        
        if (string == "Terrain")
        {
            layer = TileLayer.TERRAIN
        }
        else if (string == "Doodad")
        {
            layer = TileLayer.DOODAD
        }
        
        return layer
    }
    
    func stringForLayer(layer:TileLayer) -> String
    {
        var string = ""
        
        switch (layer)
        {
        case TileLayer.TERRAIN:
            string = "Terrain"
            break
        case TileLayer.DOODAD:
            string = "Doodad"
            break
        }
        
        return string
    }
    
    func valueForString(string:String) -> Int?
    {
        var value:Int?
        
        if let intValue = Int(string)
        {
            value = intValue
        }
        
        return value
    }
    
    func stringForValue(value:Int) -> String
    {
        return "\(value)"
    }
    
    func messageTypeForString(string:String) -> MessageType?
    {
        var type:MessageType?
        
        if (string == "edit_request")
        {
            type = MessageType.EDIT_REQUEST
        }
        else if (string == "edit_response")
        {
            type = MessageType.EDIT_RESPONSE
        }
        else if (string == "bounds_request")
        {
            type = MessageType.BOUNDS_REQUEST
        }
        else if (string == "bounds_response")
        {
            type = MessageType.BOUNDS_RESPONSE
        }
        else if (string == "view_request")
        {
            type = MessageType.VIEW_REQUEST
        }
        else if (string == "view_response")
        {
            type = MessageType.VIEW_RESPONSE
        }
        
        return type
    }
    
    func stringForMessageType(type:MessageType) -> String
    {
        var string = ""
        
        switch (type)
        {
        case MessageType.EDIT_REQUEST:
            string = "edit_request"
            break
        case MessageType.EDIT_RESPONSE:
            string = "edit_response"
            break
        case MessageType.BOUNDS_REQUEST:
            string = "bounds_request"
            break
        case MessageType.BOUNDS_RESPONSE:
            string = "bounds_response"
            break
        case MessageType.VIEW_REQUEST:
            string = "view_request"
            break
        case MessageType.VIEW_RESPONSE:
            string = "view_response"
            break
        }
        
        return string
    }
}