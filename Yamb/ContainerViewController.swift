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
    
    fileprivate func displayContentController(_ contentVC: UIViewController, completion: (() -> Void)? = nil)
    {
        addChildViewController(contentVC)
        contentVC.view.frame = view.frame
        view.addSubview(contentVC.view)
        contentVC.didMove(toParentViewController: self)
        completion?()
        onTransitionFinished(nil, toVC: contentVC)
    }
    
    fileprivate func cycleFromVC(_ fromVC: UIViewController, toVC: UIViewController, completion: (() -> Void)? = nil)
    {
        fromVC.willMove(toParentViewController: toVC)
        addChildViewController(toVC)
        
        toVC.view.frame = view.frame
        
        transition(from: fromVC,
                                     to: toVC,
                                     duration: 0,
                                     options: UIViewAnimationOptions(),
                                     animations: nil,
                                     completion: {(finished) in
                                        fromVC.removeFromParentViewController()
                                        toVC.didMove(toParentViewController: self)
                                        completion?()
                                        self.onTransitionFinished(fromVC, toVC: toVC)
            }
        )
    }
    
    func selectByIndex(_ idx: Int, completion: (() -> Void)? = nil) -> UIViewController?
    {
        
        guard idx >= 0 && idx < items.count else {return nil}
        
        let item = items[idx]
        let newVC = item.vc
        if childViewControllers.count == 0
        {
            displayContentController(newVC, completion: completion)
        }
        else if let lastVC = childViewControllers.last, lastVC != newVC
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
    func selectByName(_ itemName: String, completion: (() -> Void)?) -> UIViewController?
    {
        for (index, item) in items.enumerated()
        {
            if item.name == itemName
            {
                selectByIndex(index, completion: completion)
                return item.vc
            }
        }
        return nil
    }
    
    fileprivate func onTransitionFinished(_ fromVC: UIViewController?, toVC: UIViewController)
    {
        NotificationCenter.default.post(name: NotificationName.containerItemSelected, object: self)
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
