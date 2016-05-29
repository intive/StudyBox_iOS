//
//  AppInfoScreen.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 28.05.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class AppInfoScreen: StudyBoxViewController, UITextViewDelegate {
    
    @IBOutlet weak var infoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoTextView.contentOffset = CGPoint(x: infoTextView.contentInset.left, y: infoTextView.contentInset.top)
    }
}
