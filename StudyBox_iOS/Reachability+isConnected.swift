//
//  Reachability+isConnected.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 04.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import Reachability

extension Reachability {
    class func isConnected() -> Bool {
        //returns true if connected, false if disconnected
        let reachability = Reachability.reachabilityForInternetConnection()
        
        if reachability.currentReachabilityStatus() == .NotReachable {
            return false
        } else {
            return true
        }
    }
}
