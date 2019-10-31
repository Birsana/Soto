//
//  IntroPageViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-29.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit

//MAKE IT FIVE PICTURES, SAY ONLY NEED TO DO THIS ONCE, I THINK

// WILL PROBABLY CHANGE TO A COLLECTION VIEW I THINK


var check1Clicked = false
var check2Clicked = false
var check3Clicked = false
var check4Clicked = false
var check5Clicked = false


var pic1Chose = false
var pic2Chose = false
var pic3Chose = false
var pic4Chose = false
var pic5Chose = false




var f1pic = UIImage()
var f2pic = UIImage()
var f4pic = UIImage()
var f5pic = UIImage()

var appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])



class IntroPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    var pageControl = UIPageControl()

    lazy var viewControllerList:[UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = sb.instantiateViewController(withIdentifier: "first")
        let vc2 = sb.instantiateViewController(withIdentifier: "second")
        let vc3 = sb.instantiateViewController(withIdentifier: "third")
        let vc4 = sb.instantiateViewController(withIdentifier: "fourth")
        let vc5 = sb.instantiateViewController(withIdentifier: "fifth")
        let vc6 = sb.instantiateViewController(withIdentifier: "sixth")
        
    
        
        return [vc1,  vc2, vc3, vc5, vc6, vc4]
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     


        // Do any additional setup after loading the view.
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
        pageControl.tintColor = UIColor.red
        pageControl.pageIndicatorTintColor = UIColor.black
        pageControl.currentPageIndicatorTintColor = UIColor.blue
        self.view.addSubview(pageControl)
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = viewControllerList.index(of: pageContentViewController)!
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
