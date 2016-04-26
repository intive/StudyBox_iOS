//
//  DecksCollectionViewLayout.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 26.04.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class DecksCollectionViewLayout: UICollectionViewFlowLayout {

    override func collectionViewContentSize() -> CGSize {
        let expectedSize = super.collectionViewContentSize()
        if let collectionView = collectionView {
            
            var targetSize = collectionView.frame.size
            
            let height = expectedSize.height
            
            if height < targetSize.height {
                let sharedApp = UIApplication.sharedApplication()
                if !sharedApp.statusBarHidden {
                    targetSize.height -= UIApplication.sharedApplication().statusBarFrame.height
                }
                return targetSize
            }
        }
        return expectedSize
    }
}
