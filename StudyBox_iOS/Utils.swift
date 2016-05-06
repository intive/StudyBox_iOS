//
//  Utils.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 27.02.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class Utils {

    struct UIIds {
        static let LoginControllerId = "LoginViewControllerId"
        static let DrawerViewControllerId = "DrawerViewControllerId"
        static let DecksViewControllerID = "DecksViewControllerID"
        static let TestViewControllerID = "TestViewControllerID"
        static let DecksViewCellID = "DecksViewCellID"
        static let EditFlashcardViewControllerId = "EditFlashcardViewControllerId"
        static let SettingsViewControllerID = "SettingsViewControllerID"

    }
    struct DeckViewLayout{
        static let DecksSpacing: CGFloat = 20
        static let CellSquareSize: CGFloat = 150
        static let DeckWithoutTitle = "Bez tytułu"
    }
    
    struct UserAccount {
        static let MinimumPasswordLength = 8
    }
    
    struct NSUserDefaultsKeys {
        static let NotificationsEnabledKey = "notificationsEnabledKey"
        static let PickerFrequencyNumberKey = "pickerFrequencyNumber"
        static let PickerFrequencyTypeKey = "pickerFrequencyType"
        static let DecksToSynchronizeKey = "decksToSynchronize"
        static let LoggedUserEmail = "email"
        static let LoggedUserPassword = "password"
    }
}
