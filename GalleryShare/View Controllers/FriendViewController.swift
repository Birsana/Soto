//
//  FriendViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-15.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

class FriendViewController: UIViewController {
    
    var friend: String!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }
    

    @IBAction func dismiss(_ sender: Any) {
        
        //self.dismiss(animated: true, completion: nil)
        if let vc = (storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? MainTabViewController) {
        //self.definesPresentationContext = true
       // vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
           }
    }
    
}
