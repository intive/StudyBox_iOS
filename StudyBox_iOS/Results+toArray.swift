//
//  Results+toArray.swift
//  StudyBox_iOS
//
//  Created by Piotr Zielinski on 24.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import RealmSwift

extension Results {
    func toArray() -> [T] {
        return self.map{$0}
    }
}
