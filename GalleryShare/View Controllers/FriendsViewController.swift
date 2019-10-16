//
//  FriendsViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-13.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import FirebaseAuth

//THIS IS A TEMP VIEW CONTROLLER THATS GONNA BE REMOVED

class FriendsViewController: UIViewController {

    @IBAction func logOut(_ sender: Any) {
        do{
        try Auth.auth().signOut()
            
            
        } catch let logoutError{
            print (logoutError)
        }
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.synchronize()
        let firstViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.firstViewController) as? ViewController
              firstViewController?.modalPresentationStyle = .fullScreen
              view.window?.rootViewController = firstViewController
              view.window?.makeKeyAndVisible()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("YAYAYAYAYAYAYAYAYAYA")
        // Do any additional setup after loading the view.
    }
    


}
