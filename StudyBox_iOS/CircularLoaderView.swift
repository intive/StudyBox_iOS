//
//  CircularLoaderView.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 01.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class CircularLoaderView: UIView {

    let circlePathLayer = CAShapeLayer()
    let backgroundCircleLayer = CAShapeLayer()
    var circleRadius: CGFloat = 0
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        } set {
            circlePathLayer.strokeEnd = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //self.progress = CGFloat(progress)
        setupLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews")
        backgroundCircleLayer.frame = bounds
        backgroundCircleLayer.path = drawPath().CGPath
        
        circlePathLayer.frame = bounds
        circlePathLayer.path = drawPath().CGPath
    }
    
    func setupLayer() {
        circlePathLayer.lineCap = kCALineCapRound
        circlePathLayer.lineWidth = 20
        circlePathLayer.fillColor = UIColor.clearColor().CGColor
        circlePathLayer.strokeColor = UIColor.sb_DarkBlue().CGColor
        
        backgroundCircleLayer.lineCap = kCALineCapRound
        backgroundCircleLayer.lineWidth = 20
        backgroundCircleLayer.fillColor = UIColor.clearColor().CGColor
        backgroundCircleLayer.strokeColor = UIColor.sb_DarkBlue().colorWithAlphaComponent(0.3).CGColor

        layer.addSublayer(backgroundCircleLayer)
        layer.addSublayer(circlePathLayer)
        backgroundColor = UIColor.clearColor()
    }
    
    ///Draws the curve inside `circleFrame`
    func drawPath() -> UIBezierPath {
        
        //Draw circle in its frame
        let path = UIBezierPath(ovalInRect: circleFrame())
        
        //Apply transforms to rotate shape around its center
        let bounds = CGPathGetBoundingBox(path.CGPath)
        let center = CGPoint(x:CGRectGetMidX(bounds), y:CGRectGetMidY(bounds))
        
        let toOrigin = CGAffineTransformMakeTranslation(-center.x, -center.y)
        path.applyTransform(toOrigin)
        
        let rotate: CGAffineTransform = CGAffineTransformMakeRotation(degreesToRadians(-90))
        path.applyTransform(rotate)
        
        let fromOrigin = CGAffineTransformMakeTranslation(center.x, center.y)
        path.applyTransform(fromOrigin)
        
        return path
    }
    
    ///Returns a frame in which the circle will be drawn
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: circleRadius, height: circleRadius)
        circleFrame.origin.x = CGRectGetMidX(circlePathLayer.bounds) - CGRectGetMidX(circleFrame)
        circleFrame.origin.y = CGRectGetMidY(circlePathLayer.bounds) - CGRectGetMidY(circleFrame)
        return circleFrame
    }
    
    func animateProgress(toValue: CGFloat) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = toValue
        animation.duration = 1.5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fillMode = kCAFillModeBoth // keep to value after finishing
        animation.removedOnCompletion = false
        circlePathLayer.addAnimation(animation, forKey: animation.keyPath)
    }
    
    func degreesToRadians(degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180)
    }
}
