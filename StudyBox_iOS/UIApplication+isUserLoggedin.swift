//
//  UIApplication+isLoggedIn.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 26.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension UIApplication {
    static var isUserLoggedIn: Bool {
        get {
            return UIApplication.appDelegate().dataManager.remoteDataManager.user != nil
        }
    }
}
