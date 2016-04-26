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
        foregroundCircleLayer.lineWidth = 20
        foregroundCircleLayer.fillColor = UIColor.clearColor().CGColor
        foregroundCircleLayer.strokeColor = UIColor.sb_DarkBlue().CGColor
        
        backgroundCircleLayer.lineCap = kCALineCapRound
        backgroundCircleLayer.lineWidth = 20
        backgroundCircleLayer.fillColor = UIColor.clearColor().CGColor
        backgroundCircleLayer.strokeColor = UIColor.sb_DarkBlue().colorWithAlphaComponent(0.3).CGColor
        
        layer.addSublayer(backgroundCircleLayer)
        layer.addSublayer(foregroundCircleLayer)
        backgroundColor = UIColor.clearColor()
    }
    
    //Draws the circle inside `circleFrame`
    func drawPath() -> UIBezierPath {
        
        //Draw circle in its frame
        let path = UIBezierPath(ovalInRect: circleFrame())
        
        //Apply transforms to rotate shape around its center
        let bounds = CGPathGetBoundingBox(path.CGPath)
        let center = CGPoint(x:CGRectGetMidX(bounds), y:CGRectGetMidY(bounds))
        
        let toOrigin = CGAffineTransformMakeTranslation(-center.x, -center.y)
        path.applyTransform(toOrigin)
        
        //Rotate by -90 degrees
        let rotate: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(-M_PI / 2))
        path.applyTransform(rotate)
        
        let fromOrigin = CGAffineTransformMakeTranslation(center.x, center.y)
        path.applyTransform(fromOrigin)
        
        return path
    }
    
    //Returns a frame in which the circle will be drawn
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: circleRadius, height: circleRadius)
        circleFrame.origin.x = CGRectGetMidX(foregroundCircleLayer.bounds) - CGRectGetMidX(circleFrame)
        circleFrame.origin.y = CGRectGetMidY(foregroundCircleLayer.bounds) - CGRectGetMidY(circleFrame)
        return circleFrame
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
