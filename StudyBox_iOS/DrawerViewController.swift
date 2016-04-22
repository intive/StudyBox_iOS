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
    let name: String
    let viewControllerBlock:(() -> Void)?
    let lazyLoadViewControllerBlock: (() -> UIViewController?)?
    var isActive = false
    
    private var _viewController: UIViewController? = nil
    var viewController: UIViewController? {
        mutating get {
            if _viewController == nil {
                _viewController = lazyLoadViewControllerBlock?()
            }
            return _viewController
        }
        set {
            _viewController = newValue
        }
    }
    
    init(name: String, viewController: UIViewController? = nil, lazyLoadViewControllerBlock: (() -> UIViewController?)? = nil,
         viewControllerBlock:( () -> Void)? = nil) {
        self.name = name
        self.lazyLoadViewControllerBlock = lazyLoadViewControllerBlock
        self.viewControllerBlock = viewControllerBlock
        self.viewController = viewController
    }
    
    init(name: String, viewControllerBlock: (() -> Void)?) {
        self.init(name: name, viewController: nil, lazyLoadViewControllerBlock: nil, viewControllerBlock: viewControllerBlock)
    }
}

class DrawerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    static let DrawerCellId = "DrawerCellId"
    
    private var drawerNavigationControllers = [DrawerNavigationChild]()
    private static var initialControllerIndex = 1
    private var currentControllerIndex = 1
    var barStyle = UIStatusBarStyle.Default
    private func lazyLoadViewControllerFromStoryboard(withStoryboardId idStoryboard: String) -> UIViewController? {
        if let board = self.storyboard {
            let controller = board.instantiateViewControllerWithIdentifier(idStoryboard)
            return controller
        }
        return nil
    }
    
    func setupDrawer() {
        if drawerNavigationControllers.isEmpty {
            drawerNavigationControllers.append(DrawerNavigationChild(name: "Moje konto"))
            drawerNavigationControllers.append(
                DrawerNavigationChild(name: "Moje talie", viewController: nil, lazyLoadViewControllerBlock: {[weak self] in
                    return self?.lazyLoadViewControllerFromStoryboard(withStoryboardId: Utils.UIIds.DecksViewControllerID)
                })
            )
            drawerNavigationControllers.append(DrawerNavigationChild(name: "Stwórz nową fiszkę"))
            drawerNavigationControllers.append(DrawerNavigationChild(name: "Odkryj nową fiszkę"))
            drawerNavigationControllers.append(DrawerNavigationChild(name: "Statystyki"))
            drawerNavigationControllers.append(
                DrawerNavigationChild(name: "Ustawienia", viewController: nil,
                    lazyLoadViewControllerBlock: {[weak self] in
                        return self?.lazyLoadViewControllerFromStoryboard(withStoryboardId: Utils.UIIds.SettingsViewControllerID)
                    })
            )
            drawerNavigationControllers.append(
                DrawerNavigationChild(name: "Wyloguj", viewController: nil) { [weak self] in
                    if let storyboard = self?.storyboard {
                        UIApplication.sharedRootViewController =  storyboard.instantiateViewControllerWithIdentifier(Utils.UIIds.LoginControllerId)
                    }
                })
        }
    }
    
    func initialCenterController() -> UIViewController? {
        setupDrawer()
        if !drawerNavigationControllers.isEmpty {
            var index = 0
            if DrawerViewController.initialControllerIndex < drawerNavigationControllers.count {
                index = DrawerViewController.initialControllerIndex
            }
            drawerNavigationControllers[index].isActive = true
            return drawerNavigationControllers[index].viewController
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDrawer()
        tableView.backgroundColor = UIColor.sb_Graphite()
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DrawerViewController.DrawerCellId, forIndexPath: indexPath)
        let drawerChild = drawerNavigationControllers[indexPath.row]
        cell.textLabel?.text = drawerChild.name
        
        if drawerChild.isActive {
            cell.backgroundColor = UIColor.sb_Raspberry()
        } else {
            cell.backgroundColor = UIColor.sb_Graphite()
        }
        
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drawerNavigationControllers.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        selectMenuOptionAtIndex(indexPath.row)
    }
    
    func selectMenuOptionAtIndex(index: Int) {
        var navigationChild = drawerNavigationControllers[index]
        navigationChild.isActive = true
        
        drawerNavigationControllers[currentControllerIndex].isActive = false
        if let controller = navigationChild.viewController {
            // viewController getter is mutating, it's possible that it was instantiated for the first time so the value was changed
            drawerNavigationControllers[index] = navigationChild
            
            if let mmDrawer = UIApplication.sharedRootViewController as? MMDrawerController {
                
                var sbController = controller as? StudyBoxViewController
                
                if sbController == nil {
                    if let navigationController = controller as? UINavigationController {
                        sbController = navigationController.childViewControllers[0] as? StudyBoxViewController
                    }
                }
                
                //necessary condition check, to handle programmaticall change of center view controller
                if mmDrawer.openSide != .None {
                    sbController?.isDrawerVisible = true
                    sbController?.setNeedsStatusBarAppearanceUpdate()
                }
                mmDrawer.setCenterViewController(controller, withCloseAnimation: true, completion: nil)
            }
            
        } else if let block = navigationChild.viewControllerBlock {
            block()
        } else {
            navigationChild.isActive = false
            drawerNavigationControllers[currentControllerIndex].isActive = true
            return
        }
        currentControllerIndex = index
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        barStyle = .Default
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return barStyle
    }
    
    func deactiveAllChildViewControllers() {
        for (index, _) in drawerNavigationControllers.enumerate() {
            drawerNavigationControllers[index].isActive = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        for (index, _) in drawerNavigationControllers.enumerate() {
            if !drawerNavigationControllers[index].isActive {
                drawerNavigationControllers[index].viewController = nil
            }
        }
    }
    
}

extension DrawerViewController {
    class func sharedSbDrawerViewControllerChooseMenuOption(atIndex index: Int) {
        if let sbDrawer = UIApplication.sharedRootViewController as? SBDrawerController,
            let drawer = sbDrawer.leftDrawerViewController as? DrawerViewController {
            drawer.selectMenuOptionAtIndex(index)
        }
    }
}
