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
    var modelDelegate:DirectModelDelegate?
    var viewDelegate:EditorViewDelegate?
    let networkDataIO:NetworkDataIO
    
    var collaborators:[MCPeerID:Collaborator]
    
    private init()
    {
        networkDataIO = NetworkDataIO()
        
        collaborators = [MCPeerID:Collaborator]()
    }
    
    func registerTransmitter(transmitter:NetKitTransmitter)
    {
        self.transmitter = transmitter
    }
    
    func registerModelDelegate(delegate:DirectModelDelegate)
    {
        self.modelDelegate = delegate
    }
    
    func registerViewDelegate(delegate:EditorViewDelegate)
    {
        self.viewDelegate = delegate
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Network Controller Utility
    //////////////////////////////////////////////////////////////////////////////////////////
    func peerConnecting(peerID:MCPeerID)
    {
        // Create a new collaborator
        let newCollaborator = Collaborator()
        collaborators[peerID] = newCollaborator
        viewDelegate?.collaboratorConnecting(newCollaborator)
    }
    
    func peerConnected(peerID:MCPeerID)
    {
        if let collaborator = collaborators[peerID]
        {
            viewDelegate?.collaboratorConnected(collaborator)
        }
    }
    
    func peerDisconnected(peerID:MCPeerID)
    {
        if let collaborator = collaborators[peerID]
        {
            viewDelegate?.collaboratorDisconnected(collaborator)
            collaborators.removeValueForKey(peerID)
        }
    }
    
    func receivedDataFromPeer(peerID:MCPeerID)
    {
        if let collaborator = collaborators[peerID]
        {
            viewDelegate?.receivedDataFromCollaborator(collaborator)
        }
    }
    
    func collaboratorForID(id:String) -> Collaborator?
    {
        var matchingCollaborator:Collaborator?
        
        for (_, collaborator) in collaborators
        {
            let collaboratorID = collaborator.uuid
            if (collaboratorID == id)
            {
                matchingCollaborator = collaborator
                break
            }
        }
        
        return matchingCollaborator
    }
    
    func colorForCollaboratorID(id:String) -> UIColor?
    {
        var matchingColor:UIColor?
        
        if let collaborator = collaboratorForID(id)
        {
            matchingColor = collaborator.color
        }
        
        return matchingColor
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Raw NetKit Input
    //////////////////////////////////////////////////////////////////////////////////////////
    func didReceiveData(data:NSData, fromPeer peer:MCPeerID)
    {
        receivedDataFromPeer(peer)
        
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
            if (messageType == MessageType.EDIT_REQUEST)
            {
                processEditRequestFromData(dataComponents, fromPeer:peer)
            }
        }
    }
    
    func processEditRequestFromData(components:[String], fromPeer peer:MCPeerID)
    {
        var coord:DiscreteTileCoord?
        var layer:TileLayer?
        var value:Int?
        
        for component in components
        {
            let elementComponents = component.componentsSeparatedByString(":")
            if (elementComponents.count == 2)
            {
                let elementName = elementComponents[0]
                let contents = elementComponents[1]
                
                if (elementName == "coord")
                {
                    coord = networkDataIO.coordinateForString(contents)
                }
                else if (elementName == "layer")
                {
                    layer = networkDataIO.layerForString(contents)
                }
                else if (elementName == "value")
                {
                    value = networkDataIO.valueForString(contents)
                }
            }
        }
        
        if let collaborator = collaborators[peer]
        {
            executeEditRequest(coord, layer:layer, value:value, collaboratorUUID:collaborator.uuid)
        }
    }
    
            

    //////////////////////////////////////////////////////////////////////////////////////////
    // Raw NetKit Output
    //////////////////////////////////////////////////////////////////////////////////////////
    func sendData(data:NSData)
    {
        transmitter?.sendData(data)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Message Handling (Input)
    //////////////////////////////////////////////////////////////////////////////////////////
    func executeEditRequest(coord:DiscreteTileCoord?, layer:TileLayer?, value:Int?, collaboratorUUID:String)
    {
        if let coord = coord
        {
            if let layer = layer
            {
                if let value = value
                {
                    let change = Change(coord:coord, layer:layer, value:value, collaboratorUUID:collaboratorUUID)
                    modelDelegate?.registerChange(change)
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Message Handling (Output)
    //////////////////////////////////////////////////////////////////////////////////////////
    func sendBoundsReply()
    {
        
    }
}