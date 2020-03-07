//
//  LogInViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-09.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailLog{
            if emailFirstTime{
                emailFirstTime = false
                textField.text = ""
            }
        }
        else if textField == passwordLog{
            if passwordFirstTime{
                passwordFirstTime = false
                textField.text = ""
                textField.isSecureTextEntry = true
            }
        }
    }
    
    var emailFirstTime = true
    var passwordFirstTime = true
    
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet weak var
    emailLog: UITextField!
    
    @IBOutlet weak var passwordLog: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        emailLog.delegate = self
        passwordLog.delegate = self
        // Do any additional setup after loading the view.
        setUpElements()
        
    }
    func setUpElements(){
        errorLabel.alpha = 0
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func subscribeAll(){
        let databaseRef = Database.database().reference()
        let uid = Auth.auth().currentUser!.uid
        databaseRef.child("notifications").child(uid).observe(.value) { (snapshot) in
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                let dict = snap.value as! [String: Any]
                let topic = dict["topics"] as! String
                print(topic)
                Messaging.messaging().subscribe(toTopic: topic){ error in
                  print("Subscribed to \(topic)")
                }

            }
        }
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        let email = emailLog.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordLog.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                // Couldn't sign in
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
            else {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.synchronize()
                let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? MainPage
                
                homeViewController?.modalPresentationStyle = .fullScreen
                
                self.view.window?.rootViewController = homeViewController
                self.view.window?.makeKeyAndVisible()
                self.subscribeAll()
            }
        }
    }
    
}
