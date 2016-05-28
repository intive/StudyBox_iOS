//
//  String+md5.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 25.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation

extension String {
    
    /// source: http://stackoverflow.com/questions/32163848/how-to-convert-string-to-md5-hash-using-ios-swift
    var md5: String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
}
