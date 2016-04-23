//
//  Searchable.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 15.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation


protocol Searchable {
    func matches(expression: String?) -> Bool
}
