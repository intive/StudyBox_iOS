//
//  KDCircularProgress+init.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 23.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension KDCircularProgress {
    convenience init(frame:CGRect, color:UIColor) {
        self.init(frame: frame)
        
        self.angle = 0
        self.clockwise = true
        self.frame = frame
        self.glowMode = KDCircularProgressGlowMode.NoGlow
        self.progressThickness = 0.4
        self.roundedCorners = true
        self.startAngle = -90
        self.trackColor = color.colorWithAlphaComponent(0.3)
        self.trackThickness = 0.4
        
        self.setColors(color)
        self.refreshValues()
    }
}