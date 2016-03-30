//
//  KDCircularProgress+init.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 23.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension KDCircularProgress {
    convenience init(frame:CGRect, startAngle: Int, angle: Int, thickness: Float, clockwise:Bool, glowMode: KDCircularProgressGlowMode, color:UIColor, roundedCorners: Bool ){
        self.init(frame: frame)
        
        self.angle = angle
        self.clockwise = clockwise
        self.frame = frame
        self.glowMode = glowMode
        self.progressThickness = CGFloat(thickness)
        self.roundedCorners = true
        self.startAngle = startAngle
        self.trackColor = color.colorWithAlphaComponent(0.3)
        self.trackThickness = CGFloat(thickness)

        self.setColors(color)
        self.refreshValues()
        }
}