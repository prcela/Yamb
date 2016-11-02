//
//  ContainerViewController.swift
//  Yamb
//
//  Created by Kresimir Prcela on 02/11/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import UIKit

struct ContainerItem {
    let vc: UIViewController
    let name: String
}

class ContainerViewController: UIViewController {
    
    var items: [ContainerItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    private func displayContentController(contentVC: UIViewController, completion: (() -> Void)? = nil)
    {
        addChildViewController(contentVC)
        contentVC.view.frame = view.frame
        view.addSubview(contentVC.view)
        contentVC.didMoveToParentViewController(self)
        completion?()
        onTransitionFinished(nil, toVC: contentVC)
    }
    
    private func cycleFromVC(fromVC: UIViewController, toVC: UIViewController, completion: (() -> Void)? = nil)
    {
        fromVC.willMoveToParentViewController(toVC)
        addChildViewController(toVC)
        
        toVC.view.frame = view.frame
        
        transitionFromViewController(fromVC,
                                     toViewController: toVC,
                                     duration: 0,
                                     options: .TransitionNone,
                                     animations: nil,
                                     completion: {(finished) in
                                        fromVC.removeFromParentViewController()
                                        toVC.didMoveToParentViewController(self)
                                        completion?()
                                        self.onTransitionFinished(fromVC, toVC: toVC)
            }
        )
    }
    
    func selectByIndex(idx: Int, completion: (() -> Void)? = nil) -> UIViewController?
    {
        
        guard idx >= 0 && idx < items.count else {return nil}
        
        let item = items[idx]
        let newVC = item.vc
        if childViewControllers.count == 0
        {
            displayContentController(newVC, completion: completion)
        }
        else if let lastVC = childViewControllers.last where lastVC != newVC
        {
            cycleFromVC(lastVC, toVC: newVC, completion: completion)
        }
        else
        {
            completion?()
        }
        
        return newVC
    }
    
    /// Selects the item and returns root view controller of item
    func selectByName(itemName: String, completion: (() -> Void)?) -> UIViewController?
    {
        for (index, item) in items.enumerate()
        {
            if item.name == itemName
            {
                selectByIndex(index, completion: completion)
                return item.vc
            }
        }
        return nil
    }
    
    private func onTransitionFinished(fromVC: UIViewController?, toVC: UIViewController)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationName.containerItemSelected, object: self)
    }
    
    func selectedViewController() -> UIViewController?
    {
        return childViewControllers.last
    }
    
    func selectedItem() -> ContainerItem?
    {
        if let selected = selectedViewController()
        {
            for item in items
            {
                if item.vc === selected
                {
                    return item
                }
            }
        }
        return nil
    }
}
