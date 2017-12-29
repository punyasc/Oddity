//
//  PagesViewController.swift
//  Oddity
//
//  Created by Punya Chatterjee on 12/23/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import UIKit

class PagesViewController: UIPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PAGES DID LOAD")
        dataSource = self
        delegate = self
        
        if let myView = view?.subviews.first as? UIScrollView {
            myView.canCancelContentTouches = false
        }
        /*
        navigationItem.title = ""
        let tiv = TintedImageView(image:#imageLiteral(resourceName: "icons8-dog-house-filled-72"))
        tiv.alpha = 0.2
        tiv.tintColor = view.window?.tintColor
        navigationItem.titleView = tiv
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-customer-72"), style: .plain, target: self, action: #selector(PagesViewController.jumpToProfile))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-time-machine-72-2"), style: .plain, target: self, action: #selector(PagesViewController.jumpToHistory))*/
        
        
        var butt = UIButton()
        butt.setImage(#imageLiteral(resourceName: "icons8-dog-house-filled-72"), for: .normal)
        butt.addTarget(self, action: #selector(PagesViewController.jumpToHome), for: .touchUpInside)
        var vu = UIView()
        vu.addSubview(UIButton())
        navigationItem.titleView = butt
        navigationItem.titleView?.alpha = 0.3
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-customer-72"), style: .plain, target: self, action: #selector(PagesViewController.jumpToProfile))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-time-machine-72-2"), style: .plain, target: self, action: #selector(PagesViewController.jumpToHistory))
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        setViewControllers([orderedViewControllers[1]],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DISAPPEAR")
        //orderedViewControllers = []
        dataSource = nil
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVC("Profile"),
                self.newVC("Home"),
                self.newVC("History")]
    }()
    
    private func newVC(_ name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(name)VC")
    }

}

extension PagesViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func updateNavItem() {
        if let vc = self.viewControllers?[0] {
            print("hur")
            switch vc {
            case orderedViewControllers[0]:
                /*
                let tiv = TintedImageView(image:#imageLiteral(resourceName: "icons8-customer-72"))
                tiv.alpha = 0.2
                tiv.tintColor = view.window?.tintColor
                navigationItem.titleView = tiv
                //navigationItem.title = "Profile"
                //navigationItem.titleView = nil
                navigationItem.leftBarButtonItem = nil
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-dog-house-filled-72"), style: .plain, target: self, action: #selector(PagesViewController.jumpToHome))*/
                navigationItem.leftBarButtonItem?.tintColor = .lightGray
                navigationItem.titleView?.alpha = 1.0
                navigationItem.rightBarButtonItem?.tintColor = .black
            case orderedViewControllers[1]:
                //navigationItem.title = ""
                //let tiv = TintedImageView(image:#imageLiteral(resourceName: "icons8-dog-house-filled-72"))
                //tiv.alpha = 0.2
                //tiv.tintColor = view.window?.tintColor
                navigationItem.leftBarButtonItem?.tintColor = .black
                navigationItem.titleView?.alpha = 0.3
                navigationItem.rightBarButtonItem?.tintColor = .black
            case orderedViewControllers[2]:
                /*
                let tiv = TintedImageView(image: #imageLiteral(resourceName: "icons8-time-machine-72-2"))
                tiv.alpha = 0.2
                tiv.tintColor = view.window?.tintColor
                navigationItem.titleView = tiv
                //navigationItem.title = "My Odds"
                //navigationItem.titleView = nil
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-dog-house-filled-72"), style: .plain, target: self, action: #selector(PagesViewController.jumpToHome))
                navigationItem.rightBarButtonItem = nil */
                navigationItem.leftBarButtonItem?.tintColor = .black
                navigationItem.titleView?.alpha = 1.0
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-time-machine-72-2"), style: .plain, target: self, action: #selector(PagesViewController.jumpToHistory))
                navigationItem.rightBarButtonItem?.tintColor = .lightGray
            default:
                navigationItem.title = "Oddity"
            }
        }
    }
    
    @objc func jumpToProfile() {
        setViewControllers([orderedViewControllers[0]],
                           direction: .reverse,
                           animated: true,
                           completion: nil)
        updateNavItem()
    }
    
    @objc func jumpToHome() {
        
        guard let vc = self.viewControllers?.first else { return }
        let isOnFirst:Bool = vc == orderedViewControllers.first
        let direction:UIPageViewControllerNavigationDirection = isOnFirst ? .forward : .reverse
        setViewControllers([orderedViewControllers[1]],
                           direction: direction,
                           animated: true,
                           completion: nil)
        updateNavItem()
    }
    
    @objc func jumpToHistory() {
        setViewControllers([orderedViewControllers[2]],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        updateNavItem()
    }
    
    @objc func notifyHistory() {
        if let vc = self.viewControllers?[0] {
            if vc != orderedViewControllers[2] {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icons8-time-notif"), style: .plain, target: self, action: #selector(PagesViewController.jumpToHistory))
            }
        }
        
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        updateNavItem()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
    
}

@IBDesignable class TintedImageView: UIImageView {
    override func prepareForInterfaceBuilder() {
        self.configure()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.configure()
    }
    
    @IBInspectable override var tintColor: UIColor! {
        didSet {
            self.configure()
        }
    }
    
    private func configure() {
        self.image = self.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    }
}
