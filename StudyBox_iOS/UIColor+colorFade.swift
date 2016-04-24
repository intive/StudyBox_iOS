//
//  UIColor+colorFade.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 09.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

extension UIColor {
    class func fade(fromColor color: UIColor, toColor: UIColor, currentStep: CGFloat, steps: CGFloat, alpha: CGFloat = 1)
        ->  UIColor {
        let cgColor = color.CGColor
        let toCgColor = toColor.CGColor
        let cgColorComponents = CGColorGetComponents(cgColor)
        let toCgColorComponents = CGColorGetComponents(toCgColor)
        var resultColorValues = [CGFloat]()
        for i in 0...2 {
            resultColorValues.append(UIColor.componentFade(cgColorComponents[i], toComponent: toCgColorComponents[i], currentStep: currentStep, steps: steps))
        }
        return UIColor(red: resultColorValues[0], green: resultColorValues[1], blue: resultColorValues[2], alpha: alpha)
    }
    
    private class func componentFade(fromComponent: CGFloat, toComponent: CGFloat, currentStep: CGFloat, steps: CGFloat) -> CGFloat {
        let dif = (toComponent - fromComponent) / steps
        return (fromComponent + dif * currentStep)
    }
    
    
}
