//
//  ButtonsGridViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-27.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit

class ButtonsGridViewController: UIViewController {
    
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    
    var sendPics = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor=UIColor.black

    }
    
    @IBAction func privateTapped(_ sender: Any) {
        
    }
    
    @IBAction func galleryTapped(_ sender: Any) {
        
    }
    
     @IBAction func friendTapped(_ sender: Any) {
        
        print(sendPics.count)
        
     }
    
    

}
