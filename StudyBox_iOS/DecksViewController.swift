//
//  DecksViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 03.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit

class DecksViewController: StudyBoxViewController {

    @IBAction func manualTest(sender: AnyObject) {
        let test = storyboard?.instantiateViewControllerWithIdentifier(Utils.UIIds.TestViewControllerID)
        navigationController?.viewControllers = [ test!]
    }
}
