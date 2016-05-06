//
//  NSURL+URLByAppendingElements.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension NSURL {
    func URLByAppendingPathComponents(elements: String...) -> NSURL {
        var url = self
        for element in elements {
            url = url.URLByAppendingPathComponent(element)
        }
        return url
    }
}
