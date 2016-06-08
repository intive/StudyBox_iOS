//
//  CircularLoaderView.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 01.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class CircularLoaderView: UIView {
    
    let foregroundCircleLayer = CAShapeLayer()
    let backgroundCircleLayer = CAShapeLayer()
    var circleRadius: CGFloat = 0
    let lineWidth: CGFloat = 20
    
    var progress: CGFloat {
        get {
            return foregroundCircleLayer.strokeEnd
        } set {
            foregroundCircleLayer.strokeEnd = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    ///Redraws circles when `layoutSubviews` is called
    override func layoutSubviews() {
        super.layoutSubviews()
        foregroundCircleLayer.frame = bounds
        foregroundCircleLayer.path = drawPath().CGPath
        
        backgroundCircleLayer.frame = bounds
        backgroundCircleLayer.path = drawPath().CGPath
    }
    
    ///Sets colors, end caps and width; adds circles to the view's `layer`
    func setupLayer() {
        foregroundCircleLayer.lineCap = kCALineCapRound
        foregroundCircleLayer.lineWidth = lineWidth
        foregroundCircleLayer.fillColor = UIColor.clearColor().CGColor
        foregroundCircleLayer.strokeColor = UIColor.sb_DarkBlue().CGColor
        
        backgroundCircleLayer.lineCap = kCALineCapRound
        backgroundCircleLayer.lineWidth = lineWidth
        backgroundCircleLayer.fillColor = UIColor.clearColor().CGColor
        backgroundCircleLayer.strokeColor = UIColor.sb_DarkBlue().colorWithAlphaComponent(0.3).CGColor
        
        layer.addSublayer(backgroundCircleLayer)
        layer.addSublayer(foregroundCircleLayer)
        backgroundColor = UIColor.clearColor()
    }
    
    //Draws the circle
    func drawPath() -> UIBezierPath {
        
        //Draw circle in its frame
        let layer = foregroundCircleLayer.bounds
        let centerPoint = CGPoint(x: layer.midX, y: layer.midY)
        let radius = (foregroundCircleLayer.bounds.width / 2) - lineWidth
        
        return UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI*3/2), clockwise: true)
    }
    
    //Animates the `foregroundCircleLayer` to `toValue`
    func animateProgress(toValue: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = toValue
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fillMode = kCAFillModeBoth // keep to value after finishing
        animation.removedOnCompletion = false
        foregroundCircleLayer.addAnimation(animation, forKey: animation.keyPath)
    }
}
