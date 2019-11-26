//
//  SettingsViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-11-20.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOut(_ sender: Any) {
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
