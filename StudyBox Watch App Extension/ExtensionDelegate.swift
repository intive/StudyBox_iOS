//
//  ExtensionDelegate.swift
//  StudyBox Watch App Extension
//
//  Created by Kacper Cz on 11.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        WatchManager.sharedManager.startSession()
    }

}
