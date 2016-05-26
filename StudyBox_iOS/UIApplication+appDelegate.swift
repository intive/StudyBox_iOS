//
//  UIApplication+appDelegate.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 22.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

protocol AppDelegateProtocol {
    var dataManager: DataManager {get}
    var newDataManager: NewDataManager {get}
    func scheduleNotification()
}


extension UIApplication {
    static func appDelegate() -> AppDelegateProtocol {
        return UIApplication.sharedApplication().delegate as! AppDelegateProtocol //swiftlint:disable:this force_cast
    }
}
