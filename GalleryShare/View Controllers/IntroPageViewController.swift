//
//  IntroPageViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-29.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit


var check1Clicked = false
var check2Clicked = false
var check3Clicked = false

var pic1Chose = false
var pic2Chose = false
var pic3Chose = false

class IntroPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    lazy var viewControllerList:[UIViewController] = {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = sb.instantiateViewController(withIdentifier: "first")
        let vc2 = sb.instantiateViewController(withIdentifier: "second")
        let vc3 = sb.instantiateViewController(withIdentifier: "third")
        let vc4 = sb.instantiateViewController(withIdentifier: "fourth")
        
      
        
        
        return [vc1,  vc2, vc3, vc4]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dataSource = self
        

        
        
        if let firstViewController = viewControllerList.first{
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
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
