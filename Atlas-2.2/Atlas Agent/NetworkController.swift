//
//  NetworkHandler.swift
//  Atlas Editor
//
//  Created by Dusty Artifact on 1/19/16.
//  Copyright © 2016 Dusty Artifact. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum MessageType
{
    case EDIT_REQUEST, EDIT_RESPONSE, BOUNDS_REQUEST, BOUNDS_RESPONSE, VIEW_REQUEST, VIEW_RESPONSE
}

class NetworkController:NetKitDelegate
{
    // Singleton
    static let sharedInstance = NetworkController()
    
    var transmitter:NetKitTransmitter?
    var networkDataIO:NetworkDataIO
    
    var connectedToServer:Bool
    
    private init()
    {
        connectedToServer = false
        networkDataIO = NetworkDataIO()
    }
    
    func registerTransmitter(transmitter:NetKitTransmitter)
    {
        self.transmitter = transmitter
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Network Controller Utility
    //////////////////////////////////////////////////////////////////////////////////////////
    func serverConnectionChanged(connected:Bool)
    {
        connectedToServer = connected
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Raw NetKit Input
    //////////////////////////////////////////////////////////////////////////////////////////
    func didReceiveData(data:NSData, fromPeer peer:MCPeerID)
    {
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        let dataComponents = str.componentsSeparatedByString("\n")
        
        var messageType:MessageType?
        
        if (dataComponents.count > 0)
        {
            let component = dataComponents[0]
            let elementComponents = component.componentsSeparatedByString(":")
            if (elementComponents.count == 2)
            {
                let name = elementComponents[0]
                let value = elementComponents[1]
                
                if (name == "messagetype")
                {
                    if let type = networkDataIO.messageTypeForString(value)
                    {
                        messageType = type
                    }
                }
            }
        }
        
        if let messageType = messageType
        {
            if (messageType == MessageType.BOUNDS_RESPONSE)
            {
                processBoundsResponseFromData(dataComponents)
            }
        }
    }
    
    func processBoundsResponseFromData(dataComponents:[String])
    {
        
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Raw NetKit Output
    //////////////////////////////////////////////////////////////////////////////////////////
    func sendData(data:NSData)
    {
        if (connectedToServer)
        {
            transmitter?.sendData(data)
        }
        else
        {
            print("ERROR; Tried to send to non-connected server")
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Message Handling (Output)
    //////////////////////////////////////////////////////////////////////////////////////////
    func sendChangeRequest(change:Change)
    {
        let requestString = networkDataIO.stringForEditRequest(change)
        let data = requestString.dataUsingEncoding(NSUTF8StringEncoding)!
        sendData(data)
    }
    
    func sendBoundsRequest()
    {
        let requestString = networkDataIO.stringForBoundsRequest()
        let data = requestString.dataUsingEncoding(NSUTF8StringEncoding)!
        sendData(data)
    }
    
    func sendViewRequest(view:TileRect)
    {
//        let requestString = networkDataIO.stringForViewRequest()
//        let data = requestString.dataUsingEncoding(NSUTF8StringEncoding)!
//        sendData(data)
    }
}