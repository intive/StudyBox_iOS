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
    
    private var navbarHeight: CGFloat  {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "O programie"
        infoTextView.contentInset.top = -navbarHeight - UIApplication.sharedApplication().statusBarFrame.height
    }
}
