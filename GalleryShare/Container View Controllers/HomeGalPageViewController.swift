//
//  HomeGalPageViewController.swift
//  
//
//  Created by Andre Birsan on 2019-11-14.
//

import UIKit

class HomeGalPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageControl = UIPageControl()
    
    lazy var viewControllerList:[UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = sb.instantiateViewController(withIdentifier: "hgal1")
        
        let vc2 = sb.instantiateViewController(withIdentifier: "hgal2")
        
        let vc3 = sb.instantiateViewController(withIdentifier: "hgal3")
        
        return [vc1, vc2, vc3]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        configurePageControl()
        if let firstViewController = viewControllerList.first{
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
    }
    
    func configurePageControl(){
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY-50, width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = viewControllerList.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.currentPageIndicatorTintColor = UIColor.blue
        self.view.addSubview(pageControl)
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
    
}
