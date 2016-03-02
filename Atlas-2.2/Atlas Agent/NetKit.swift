//
//  NetKit.swift
//
//  Created by Martin Mumford on 3/4/15.
//  Copyright (c) 2015 Runemark Studios. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// Minimum Possible Networking to start networking

enum BrowsingStatus
{
    case browser_browsing, browser_stopped
}

enum AdvertisingStatus
{
    case advertiser_advertising, advertiser_stopped
}

public protocol NetKitDelegate
{
    func serverConnectionChanged(connected:Bool)
    func didReceiveData(data:NSData, fromPeer device:MCPeerID)
}

public protocol NetKitTransmitter
{
    func sendData(data:NSData)
}

class NetKit: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate, NetKitTransmitter
{
    private var serviceAdvertiser:MCNearbyServiceAdvertiser?
    private var serviceBrowser:MCNearbyServiceBrowser?
    private var session:MCSession
    private var myPeerID:MCPeerID
    private var browsingStatus:BrowsingStatus
    private var advertisingStatus:AdvertisingStatus
    
    private var delegate:NetKitDelegate?
    
    init(displayName:String)
    {
        self.myPeerID = MCPeerID(displayName:displayName)
        self.session = MCSession(peer:myPeerID)
        
        self.browsingStatus = .browser_stopped
        self.advertisingStatus = .advertiser_stopped
        
        super.init()
        
        self.session.delegate = self
    }
    
    func registerDelegate(delegate:NetKitDelegate)
    {
        self.delegate = delegate
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Inspection
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func peerAlreadyConnected(peerID:MCPeerID) -> Bool
    {
        var alreadyConnected = false
        
        for connectedPeer:MCPeerID in connectedPeerIDs()
        {
            if (connectedPeer == peerID)
            {
                alreadyConnected = true
                break
            }
        }
        
        return alreadyConnected
    }
    
    func connectedPeerIDs() -> [MCPeerID]
    {
        var peerIDs = [MCPeerID]()
        
        for peerID in session.connectedPeers
        {
            peerIDs.append(peerID as MCPeerID)
        }
        
        return peerIDs
    }
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Service Control
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func disconnect()
    {
        if advertisingStatus == .advertiser_advertising
        {
            stopAdvertising()
        }
        
        if browsingStatus == .browser_browsing
        {
            stopBrowsing()
        }
        
        session.disconnect()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Transceiving Control (Simulatneously Advertise and Browse)
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func startTransceiving(serviceType serviceType:String)
    {
        print("Start Transceiving")
        
        startAdvertising(serviceType:serviceType)
        startBrowsing(serviceType:serviceType)
    }
    
    func resumeTransceiving()
    {
        print("Resume Transceiving")
        
        resumeAdvertising()
        resumeBrowsing()
    }
    
    func pauseTransceiving()
    {
        print("Pause Transceiving")
        
        pauseAdvertising()
        pauseBrowsing()
    }
    
    func stopTransceiving()
    {
        print("Stop Transceiving")
        
        stopAdvertising()
        stopBrowsing()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Advertising Control
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func startAdvertising(serviceType serviceType:String)
    {
        // If we are advertising, it is because we do not have a connection with the server
        delegate?.serverConnectionChanged(false)
        
        print("Start Advertising")
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer:myPeerID, discoveryInfo:nil, serviceType:serviceType)
        serviceAdvertiser?.delegate = self;
        
        advertisingStatus = .advertiser_advertising
        serviceAdvertiser?.startAdvertisingPeer()
    }
    
    func resumeAdvertising()
    {
        print("Resume Advertising")
        
        advertisingStatus = .advertiser_advertising
        serviceAdvertiser?.startAdvertisingPeer()
    }
    
    func pauseAdvertising()
    {
        print("Pause Advertising")
        
        advertisingStatus = .advertiser_stopped
        serviceAdvertiser?.stopAdvertisingPeer()
    }
    
    func stopAdvertising()
    {
        print("Stop Advertising")
        
        serviceAdvertiser?.delegate = nil
        
        advertisingStatus = .advertiser_stopped
        serviceAdvertiser?.stopAdvertisingPeer()
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Browsing Control
    //////////////////////////////////////////////////////////////////////////////////////////
    
    func startBrowsing(serviceType serviceType:String)
    {
        print("Start Browsing")
        
        serviceBrowser = MCNearbyServiceBrowser(peer:myPeerID, serviceType:serviceType)
        serviceBrowser?.delegate = self;
        
        browsingStatus = .browser_browsing
        serviceBrowser?.startBrowsingForPeers()
    }
    
    func resumeBrowsing()
    {
        print("Resume Browsing")
        
        browsingStatus = .browser_browsing
        serviceBrowser?.startBrowsingForPeers()
    }
    
    func pauseBrowsing()
    {
        print("Pause Browsing")
        
        browsingStatus = .browser_stopped
        serviceBrowser?.stopBrowsingForPeers()
    }
    
    func stopBrowsing()
    {
        print("Stop Browsing")
        
        serviceBrowser?.delegate = nil
        
        browsingStatus = .browser_stopped
        serviceBrowser?.stopBrowsingForPeers()
    }
    
    
    
    
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Utility
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Events
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////
    // MCNearbyServiceAdvertiserDelegate
    ////////////////////////////////////////////////////////////
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void)
    {
        disconnect()
        
        print("AdvertiserDelegate:didReceiveInvitationFromPeer:\(peerID)")
        
        if (!peerAlreadyConnected(peerID))
        {
            // Makes the connection
            invitationHandler(true, session);
        }
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError)
    {
        print("AdvertiserDelegate:didNotStartAdvertisingPeer error:\(error)")
    }
    
    ////////////////////////////////////////////////////////////
    // MCNearbyServiceBrowserDelegate
    ////////////////////////////////////////////////////////////
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError)
    {
        print("BrowserDelegate:didNotStartBrowserPeer error:\(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?)
    {
        print("BrowserDelegate:foundPeer peerID:\(peerID)")
        
        // Automatically invite every peer you see
        serviceBrowser?.invitePeer(peerID, toSession:session, withContext:nil, timeout:30)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID)
    {
        print("BrowserDelegate:lostPeer peerID:\(peerID)")
    }
    
    ////////////////////////////////////////////////////////////
    // MCNearbyServiceBrowserDelegate
    ////////////////////////////////////////////////////////////
    
    // MCSessionState: {0:MCSessionStateNotConected, 1:MCSessionStateConnecting, 2:MCSessionStateConnected}
    // A (0) MCSessionStateNotConnected change occurs when a client disconnects, or when a browser's invitation times out
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void)
    {
        print("Session:didReceiveCertificate fromPeer: \(peerID)")
        // Even though this method is listed as optional in the docs, if you leave it blank your peers CANNOT CONNECT. Great work there, Apple.
        certificateHandler(true)
    }
    
    func session(session:MCSession, didReceiveData data:NSData, fromPeer peerID:MCPeerID)
    {
        print("Session:didReceiveData: \(data) fromPeer: \(peerID)")
        let str = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        print(str)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID)
    {
        print("Session:didReceiveStream withName: \(streamName) fromPeer: \(peerID)")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress)
    {
        print("Session:didStartReceivingResourceWithName: \(resourceName) fromPeer: \(peerID)")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?)
    {
        print("Session:didFinishReceivingResourceWithName: \(resourceName) fromPeer: \(peerID)")
    }
    
    func session(session:MCSession, peer peerID:MCPeerID, didChangeState state:MCSessionState)
    {
        // (0): Not Connected
        // (1): Connecting
        // (2): Connected
        print("Session:peer:\(peerID) didChangeState:\(state.rawValue)")
        
        switch state
        {
            case MCSessionState.Connected:
                // Now connected to server
                delegate?.serverConnectionChanged(true)
//                pauseAdvertising()
                break
            case MCSessionState.Connecting:
                // Connecting to server
                break
            case MCSessionState.NotConnected:
                // Lost connection to server
                delegate?.serverConnectionChanged(false)
                
                if (advertisingStatus == AdvertisingStatus.advertiser_stopped)
                {
                    resumeAdvertising()
                }
                
                break
        }
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Transmission
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func sendData(data:NSData)
    {
        do
        {
            try session.sendData(data, toPeers:session.connectedPeers, withMode:MCSessionSendDataMode.Unreliable)
        }
        catch
        {
            print("Mistakes were made!")
        }
    }
}