//
//  TestingAppDelegate.swift
//  StudyBox_iOS
//
//  Created by Piotr Rudnicki on 26.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import UIKit

class TestingAppDelegate: UIResponder, UIApplicationDelegate, AppDelegateProtocol {
    var window: UIWindow?
    
    func scheduleNotification() {}
    private(set) var dataManager: DataManager = DataManager()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        self.window?.rootViewController = UIViewController()
        return true
    }
}
