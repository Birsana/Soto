//
//  MainPage.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2020-01-07.
//  Copyright © 2020 Andre Birsan. All rights reserved.
//

import UIKit

class MainPage: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageControl = UIPageControl()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait

        }
    }
    
    lazy var viewControllerList:[UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
       #if targetEnvironment(simulator)
            let vc = sb.instantiateViewController(withIdentifier: "Tabs")
            return [vc]
        #endif
        let vc1 = sb.instantiateViewController(withIdentifier: "camera")
        
        let vc2 = sb.instantiateViewController(withIdentifier: "Tabs")
        
        return [vc1, vc2]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        configurePageControl()
        if let firstViewController = viewControllerList.first{
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        goToNextPage()
        
    }
    func configurePageControl(){
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY-50, width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = viewControllerList.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.currentPageIndicatorTintColor = UIColor.blue
        //self.view.addSubview(pageControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = viewControllerList.firstIndex(of: pageContentViewController)!
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard viewControllerList.count > previousIndex else{
            return nil
        }
        
        return viewControllerList[previousIndex]
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.firstIndex(of: viewController) else{
            return nil
        }
        let nextIndex = vcIndex + 1
        
        guard viewControllerList.count != nextIndex else{
            return nil
        }
        
        guard viewControllerList.count > nextIndex else{
            return nil
        }
        return viewControllerList[nextIndex]
    }
    
    
    func goToNextPage(){

        guard let currentViewController = self.viewControllers?.first else { return }

        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }

        setViewControllers([nextViewController], direction: .forward, animated: false, completion: nil)

    }
}
