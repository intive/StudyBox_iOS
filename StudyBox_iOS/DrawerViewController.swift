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
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var gravatarImageView: UIImageView!
    static let DrawerCellId = "DrawerCellId"
    var dataManager: DataManager = UIApplication.appDelegate().dataManager
    
    
    private var drawerNavigationControllers = [DrawerNavigationChild]()
    private static var initialControllerIndex = 0
    private var currentControllerIndex = 0
    var barStyle = UIStatusBarStyle.Default
    private func lazyLoadViewController(withStoryboardId idStoryboard: String) -> UIViewController? {
        if let board = self.storyboard {
            let controller = board.instantiateViewControllerWithIdentifier(idStoryboard)
            return controller
        }
        return nil
    }
    
    func setupDrawer() {
        if drawerNavigationControllers.isEmpty {
            
            drawerNavigationControllers.append(
                DrawerNavigationChild(name: UIApplication.isUserLoggedIn ? "Moje talie" : "Wyszukaj talie", viewController: nil,
                    lazyLoadViewControllerBlock: {[weak self] in
                        return self?.lazyLoadViewController(withStoryboardId: Utils.UIIds.DecksViewControllerID)
                })
            )
            
            drawerNavigationControllers.append(
                DrawerNavigationChild(name: "Stwórz nową fiszkę", viewController: nil,
                    lazyLoadViewControllerBlock: {[weak self] in
                        guard UIApplication.isUserLoggedIn else {
                            return nil
                        }
                        let vc = self?.lazyLoadViewController(withStoryboardId: Utils.UIIds.EditFlashcardViewControllerID) as? UINavigationController
                        
                        if let editVC = vc?.childViewControllers[0] as? EditFlashcardViewController {
                            editVC.mode = .Add
                            return vc
                        }
                        return nil 
                }) { [weak self] in
                    let alert = UIAlertController(title: "Uwaga", message: "Musisz być zalogowany", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Przejdź do logowania", style: .Default) { _ in
                            self?.selectMenuOptionAtIndex(4)
                        }
                    )
                    self?.presentViewController(alert, animated: true, completion: nil)
                }
            )
            
            
            drawerNavigationControllers.append(
                DrawerNavigationChild(name: "Odkryj losową talię", viewController: nil,
                lazyLoadViewControllerBlock: {[weak self] in
                   return self?.lazyLoadViewController(withStoryboardId: Utils.UIIds.RandomDeckViewControllerID)
                })
            )
            
            drawerNavigationControllers.append(
                DrawerNavigationChild(name: "Statystyki", viewController: nil,
                lazyLoadViewControllerBlock: { [weak self] in
                    return self?.lazyLoadViewController(withStoryboardId: Utils.UIIds.StatisticsViewControllerID)
                })
            )
            
            if UIApplication.isUserLoggedIn {
                drawerNavigationControllers.append(
                    DrawerNavigationChild(name: "Ustawienia", viewController: nil,
                        lazyLoadViewControllerBlock: {[weak self] in
                            return self?.lazyLoadViewController(withStoryboardId: Utils.UIIds.SettingsViewControllerID)
                        })
                )
            }
            
            
            drawerNavigationControllers.append(
                DrawerNavigationChild(name: UIApplication.isUserLoggedIn ? "Wyloguj" : "Zaloguj", viewController: nil) { [weak self] in
                    UIApplication.appDelegate().dataManager.logout()
                    
                    if let storyboard = self?.storyboard {
                        UIApplication.sharedRootViewController =  storyboard.instantiateViewControllerWithIdentifier(Utils.UIIds.LoginControllerID)
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
        gravatarImageView.layer.cornerRadius = gravatarImageView.bounds.width / 2
        gravatarImageView.clipsToBounds = true
        gravatarImageView.layer.borderColor = UIColor.sb_White().CGColor
        gravatarImageView.layer.borderWidth = 3
        tableView.backgroundColor = UIColor.sb_Graphite()
        view.backgroundColor = UIColor.sb_Graphite()
        if let email = self.dataManager.remoteDataManager.user?.email {
            self.emailLabel.text = email
        }
        
        dataManager.gravatar {
            
            if case .Success(let obj) = $0, let image = UIImage(data: obj) { //swiftlint:disable:this conditional_binding_cascade
                self.gravatarImageView.image = image
            } else {
                self.gravatarImageView.hidden = true
                self.emailLabel.hidden = true
            }
        }
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
            let isActive = drawerNavigationControllers[index].isActive
            var mainViewController: UIViewController?
            
            if let navigationController = drawerNavigationControllers[index].viewController as? UINavigationController
                where !navigationController.childViewControllers.isEmpty {
                mainViewController = navigationController.childViewControllers[0]
            } else {
                mainViewController = drawerNavigationControllers[index].viewController
            }
            if let resourceDisposableVC = mainViewController as? DrawerResourceDisposable {
                resourceDisposableVC.disposeResources(isActive)
            }
            
            if !isActive {
                drawerNavigationControllers[index].viewController = nil
            }
        }
    }
    
}

extension DrawerViewController {
    class func sharedSbDrawerViewControllerChooseMenuOption(atIndex index: Int) {
        if let sbDrawer = UIApplication.sharedRootViewController as? SBDrawerController,
             drawer = sbDrawer.leftDrawerViewController as? DrawerViewController {
            drawer.selectMenuOptionAtIndex(index)
        }
    }
}
