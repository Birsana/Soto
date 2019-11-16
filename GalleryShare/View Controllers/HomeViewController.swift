//
//  HomeViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-09.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        UserDefaults.standard.set(false, forKey: "firstTime")
                                   UserDefaults.standard.synchronize()
        // Do any additional setup after loading the view.
    
        
    }
}
