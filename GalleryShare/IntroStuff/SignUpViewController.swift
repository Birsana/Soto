//
//  SignUpViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-09.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase



class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == email{
            if emailFirstTime{
                emailFirstTime = false
                textField.text = ""
            }
        }
        else if textField == password{
            if passwordFirstTime{
                passwordFirstTime = false
                textField.text = ""
                textField.isSecureTextEntry = true
            }
        }
        if textField == username{
            if usernameFirstTime{
                usernameFirstTime = false
                textField.text = ""
            }
        }
    }
    
    let characterset = CharacterSet(charactersIn:
        "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    
    var emailFirstTime = true
    var usernameFirstTime = true
    var passwordFirstTime = true
    
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {

        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        setUpElements()
        email.delegate = self
        password.delegate = self
        username.delegate = self
    }
    func setUpElements(){
        errorLabel.alpha = 0
    }
    func validateFields() -> String? {
        
        //MAKE USERNAME LOWERCASE
        
        var emailTaken = false
        let usernameTrim = username.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let emailTrim = email.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPassword = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        
        
        
        if username.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields"
        }
        
        if (usernameTrim?.count)! < 5 || username.text?.trimmingCharacters(in: .whitespacesAndNewlines).rangeOfCharacter(from: characterset.inverted) != nil {
            return "Usernames should be at least 5 characters, and only contain letters and numbers"
        }
        
        
        if Utilities.isPasswordValid(cleanedPassword) == false{
            return "Please make sure your password has at least 8 characters and a number"
        }
        
        return nil
    }
    
    @IBAction func createTapped(_ sender: Any) {
        let databaseRef = Database.database().reference()
        let usernameTrim = username.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        
        let error = validateFields()
        
        if error != nil{
            //uh oh!
            showError(error!)
            
        }
        else{
            //all good!
            let usernameClean = username.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let passwordClean = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let emailClean = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            databaseRef.child("usernames").child(usernameTrim!).observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.exists(){
                    self.showError("Sorry, this username is taken")
                }
                else
                {
                    Auth.auth().createUser(withEmail: emailClean, password: passwordClean, completion: { (user, error) in
                        
                        if(error != nil)
                        {
                            self.showError("Sorry, this email is already in use") //EMAIL TAKEN??
                            
                        }
                        else
                        {
                            Auth.auth().signIn(withEmail: emailClean, password: passwordClean, completion: { (user, error) in
                                
                                if(error == nil)
                                {
                                    databaseRef.child("users").child(user!.user.uid).child("email").setValue(emailClean)
                                    databaseRef.child("users").child(user!.user.uid).child("username").setValue(usernameClean)
                                    databaseRef.child("usernames").child(usernameClean).setValue(user!.user.uid)
            
                                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                    UserDefaults.standard.synchronize()
                                    UserDefaults.standard.set(true, forKey: "firstTime")
                                    UserDefaults.standard.synchronize()
                                    self.transitiontoHome()
                                }
                            })
                        }
                    })
                }
            }
        }
    }
    
    
    func showError(_ message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    func transitiontoHome(){
        if UserDefaults.standard.bool(forKey: "firstTime"){
            
            /**  let tempViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.temphomeViewController) as? FaceSubmitPageViewController
             
             self.present(tempViewController!, animated: true, completion: nil) **/
            
            let tempViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.firstLogIn) as? ProfilePicViewController
            tempViewController?.modalPresentationStyle = .fullScreen
            view.window?.rootViewController = tempViewController
            view.window?.makeKeyAndVisible()
            
            
        }
            
        else{
            let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? MainPage
            homeViewController?.modalPresentationStyle = .fullScreen
            view.window?.rootViewController = homeViewController
            view.window?.makeKeyAndVisible()
        }
    }
    
    
}
