//
//  FriendsViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-13.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import FirebaseAuth

class FriendsViewController: UIViewController {

    @IBAction func logOut(_ sender: Any) {
        do{
        try Auth.auth().signOut()
            
            
        } catch let logoutError{
            print (logoutError)
        }
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.synchronize()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
