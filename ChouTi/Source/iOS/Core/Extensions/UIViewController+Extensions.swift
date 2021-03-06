//
//  UIViewController+Extensions.swift
//  Pods
//
//  Created by Honghao Zhang on 2015-10-28.
//
//

import UIKit

// MARK: - Storyboard
public extension UIViewController {
    
    /**
     Initialize a view controller in storyboard.
     
     :param: storyboardName     Storyboard name
     :param: viewControllerName Storyboard ID of the view controller
     
     :returns: An instance of view controller.
     */
    class public func viewControllerInStoryboard(_ storyboardName: String , viewControllerName: String) -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: storyboardName, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerName)
        return viewController
    }
}

// MARK: - Utility
public extension UIViewController {
    /// Retrieve the view controller currently on-screen
    ///
    /// Based off code here: http://stackoverflow.com/questions/24825123/get-the-current-view-controller-from-the-app-delegate
    public class var currentViewController: UIViewController? {
        if let controller = UIApplication.shared.keyWindow?.rootViewController {
            return findCurrentViewController(controller)
        }
        return nil
    }
    
    fileprivate class func findCurrentViewController(_ controller: UIViewController) -> UIViewController {
        if let controller = controller.presentedViewController {
            return findCurrentViewController(controller)
        }
        else if let controller = controller as? UISplitViewController, let lastViewController = controller.viewControllers.first, controller.viewControllers.count > 0 {
            return findCurrentViewController(lastViewController)
        }
        else if let controller = controller as? UINavigationController, let topViewController = controller.topViewController, controller.viewControllers.count > 0 {
            return findCurrentViewController(topViewController)
        }
        else if let controller = controller as? UITabBarController, let selectedViewController = controller.selectedViewController, controller.viewControllers?.isEmpty == false {
            return findCurrentViewController(selectedViewController)
        }
        else {
            return controller
        }
    }
}

// MARK: - UI
public extension UIViewController {
    
    /**
     Create a left navigation bar backrgound view, this view will spans between leading and title's leading
     
     - returns: a newly created background view
     */
    public func addLeftNavigationBarBackgroundView() -> UIView? {
        guard let navigationBar = navigationController?.navigationBar else {
            NSLog("navigationBar is nil")
            return nil
        }
        
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(backgroundView)
        
        backgroundView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor).isActive = true
        
        if let titleView = navigationItem.titleView {
            backgroundView.trailingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
        } else {
            backgroundView.trailingAnchor.constraint(equalTo: navigationBar.centerXAnchor).isActive = true
        }
        
        backgroundView.topAnchor.constraint(equalTo: navigationBar.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
        
        return backgroundView
    }
    
    /**
     Create a right navigation bar backrgound view, this view will spans between title's trailing and trailing
     
     - returns: a newly created background view
     */
    public func addRightNavigationBarBackgroundView() -> UIView? {
        guard let navigationBar = navigationController?.navigationBar else {
            NSLog("navigationBar is nil")
            return nil
        }
        
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.addSubview(backgroundView)
        
        backgroundView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor).isActive = true
        
        if let titleView = navigationItem.titleView {
            backgroundView.leadingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
        } else {
            backgroundView.leadingAnchor.constraint(equalTo: navigationBar.centerXAnchor).isActive = true
        }
        
        backgroundView.topAnchor.constraint(equalTo: navigationBar.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
        
        return backgroundView
    }
}
