//
//  DrawerViewController.swift
//  StudyBox_iOS
//
//  Created by Damian Malarczyk on 06.03.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import MMDrawerController

struct DrawerNavigationChild {
    let name:String
    let viewController:UIViewController?
    let viewControllerBlock:(()->Void)?
}

class DrawerViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    static let DrawerCellId = "DrawerCellId"
    
    var drawerNavigationControllers = [DrawerNavigationChild]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawerNavigationControllers.append(DrawerNavigationChild(name: "Moje konto", viewController: nil,viewControllerBlock: nil))
        drawerNavigationControllers.append(DrawerNavigationChild(name: "Moje talie", viewController: nil,viewControllerBlock: nil))
        drawerNavigationControllers.append(DrawerNavigationChild(name: "Stwórz nową fiszkę", viewController: nil,viewControllerBlock: nil))
        drawerNavigationControllers.append(DrawerNavigationChild(name: "Odkryj nową fiszkę", viewController: nil,viewControllerBlock: nil))
        drawerNavigationControllers.append(DrawerNavigationChild(name: "Statystyki", viewController: nil,viewControllerBlock: nil))
        drawerNavigationControllers.append(DrawerNavigationChild(name: "Wyloguj", viewController: nil) { [weak self] in
            if let storyboard = self?.storyboard {
                UIApplication.sharedRootViewController =  storyboard.instantiateViewControllerWithIdentifier(Utils.UIIds.LoginControllerId)
            }
        })
        
        tableView.backgroundColor = UIColor.grayColor()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return drawerNavigationControllers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DrawerViewController.DrawerCellId, forIndexPath: indexPath)
        cell.textLabel?.text = drawerNavigationControllers[indexPath.section].name
        cell.backgroundColor = UIColor.grayColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        let navigationChild = drawerNavigationControllers[indexPath.section]
        
        if let controller = navigationChild.viewController {
            if let mmDrawer = UIApplication.sharedRootViewController as? MMDrawerController {
                mmDrawer.centerViewController = controller
            }
        }else if let block = navigationChild.viewControllerBlock {
            block()
        }else {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
}
