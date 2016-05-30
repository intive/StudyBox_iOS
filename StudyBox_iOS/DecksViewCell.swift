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
    @IBOutlet weak var deckFlashcardsCountLabel: UILabel!
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
        reloadBorderLayer(forCellSize: bounds.size)
    }
    
    func reloadBorderLayer(forCellSize size: CGSize) {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        borderLayer?.path = UIBezierPath(rect: rect).CGPath
        borderLayer?.frame = rect
        borderLayer?.setNeedsDisplay()
        
    }
    
    func removeBorderLayer() {
        borderLayer?.removeFromSuperlayer()
        borderLayer = nil 
    }
    
}
