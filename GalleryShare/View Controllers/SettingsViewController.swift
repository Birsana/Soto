//
//  SettingsViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-11-20.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseMessaging

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    func unsubscribeAll(){
        let databaseRef = Database.database().reference()
        let uid = Auth.auth().currentUser!.uid
        databaseRef.child("notifications").child(uid).observe(.value) { (snapshot) in
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                let dict = snap.value as! [String: Any]
                let topic = dict["topics"] as! String
                Messaging.messaging().unsubscribe(fromTopic: topic)
            }
        }
    }
    
    
    @IBAction func signOut(_ sender: Any) {
        unsubscribeAll()
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
    
    
}
