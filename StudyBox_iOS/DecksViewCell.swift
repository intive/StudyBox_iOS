//
//  DecksViewCell.swift
//  StudyBox_iOS
//
//  Created by Piotr Zielinski on 07.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class DecksViewCell: UICollectionViewCell {
    
    @IBOutlet weak var deckNameLabel: UILabel!
    private(set) var borderLayer: CAShapeLayer? = nil
    
    func setupBorderLayer() {
        if borderLayer == nil {
            borderLayer = CAShapeLayer()
            if let borderLayer = borderLayer {
                contentView.layer.insertSublayer(borderLayer, below: deckNameLabel.layer)
            }
            borderLayer?.strokeColor = UIColor.sb_Graphite().CGColor
            borderLayer?.fillColor = nil
            borderLayer?.lineDashPattern = [10, 5]
            borderLayer?.masksToBounds = true

        }
        reloadBorderLayer()
    }
    
    func reloadBorderLayer() {
        
        borderLayer?.path = UIBezierPath(rect: contentView.bounds).CGPath
        borderLayer?.frame = bounds
        borderLayer?.setNeedsDisplay()
        
    }
    
    func removeBorderLayer() {
        borderLayer?.removeFromSuperlayer()
        borderLayer = nil 
    }
    
}
