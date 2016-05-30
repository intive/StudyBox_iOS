//
//  DataManager+utils.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 30.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

enum DataManagerResponse<T> {
    case Success(obj: T)
    case Error(obj: ErrorType)
}

enum DataManagerError: ErrorType {
    case JSONParseError, NoLocalData, ErrorSavingData, ErrorWith(message: String), UserNotLoggedIn
}

extension DataManager {
    func logout() {
        remoteDataManager.logout()
        clearUserDefaults()
        clearLocalDataManager()
        let fm = NSFileManager()
        do {
            try fm.removeItemAtURL(localDataManager.gravatarDestinationURL)
        } catch {}
    }
    
    func clearUserDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(Utils.NSUserDefaultsKeys.DecksToSynchronizeKey)
        defaults.removeObjectForKey(Utils.NSUserDefaultsKeys.NotificationsEnabledKey)
        defaults.removeObjectForKey(Utils.NSUserDefaultsKeys.PickerFrequencyNumberKey)
        defaults.removeObjectForKey(Utils.NSUserDefaultsKeys.PickerFrequencyTypeKey)
    }
    
    func clearLocalDataManager() {
        localDataManager.deleteAll(Deck)
        localDataManager.deleteAll(Flashcard)
        localDataManager.deleteAll(Tip)
        localDataManager.deleteAll(TestInfo)
    }
}
