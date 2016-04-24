//
//  WatchManager.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 22.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//
import WatchKit
import Foundation
import WatchConnectivity

class WatchManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchManager()
    
    private override init() {
        super.init()
    }
    
    private let session: WCSession = WCSession.defaultSession()
    
    func startSession() {
        session.delegate = self
        session.activateSession()
    }
}

extension WatchManager {
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        
    }
}