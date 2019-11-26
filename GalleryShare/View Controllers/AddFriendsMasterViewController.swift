//
//  AddFriendsMasterViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-11-21.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit

class AddFriendsMasterViewController: UIViewController {

    @IBOutlet weak var addFriends: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        addFriends.translatesAutoresizingMaskIntoConstraints = false
        addFriends.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        addFriends.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        addFriends.topAnchor.constraint(equalTo: view.topAnchor, constant: 125).isActive = true
        
      
    }
    
    @IBAction func requests(_ sender: Any) {
        let nav = self.storyboard!.instantiateViewController(withIdentifier: "forSegue")
        self.present(nav, animated: true, completion: nil)
    }
    
   
}
