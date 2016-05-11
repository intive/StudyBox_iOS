//
//  String+base64Encoded.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 05.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension String {
    func base64Encoded() -> String? {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data?.base64EncodedStringWithOptions(.Encoding76CharacterLineLength)
    }
}
