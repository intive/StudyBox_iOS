//
//  JSONInstantiable.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 05.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol JSONInitializable {
    init?(withJSON json: JSON)
}
