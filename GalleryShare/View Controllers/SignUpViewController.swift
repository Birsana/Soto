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


class SignUpViewController: UIViewController {
     var ref: DatabaseReference?
    
    let characterset = CharacterSet(charactersIn:
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    
    
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
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    func setUpElements(){
        errorLabel.alpha = 0
    }
    func validateFields() -> String? {
       
        
        if username.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields"
        }
        let usernameTrim = username.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailTrim = email.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if (usernameTrim?.count)! < 5 || username.text?.trimmingCharacters(in: .whitespacesAndNewlines).rangeOfCharacter(from: characterset.inverted) != nil {
            return "Usernames should be at least 5 characters, and only contain letters and numbers"
        }
        
        let cleanedPassword = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false{
            return "Please make sure your password has at least 8 characters and a number"
        }
     
 
        var usernameTaken = false
        var emailTaken = false
        ref!.child("users").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            if snapshot.hasChild(usernameTrim!){
                
                usernameTaken = true
                
            }else{
                
                usernameTaken = false
            }
        })
     /**  ref!.child("users").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            if snapshot.hasChild(emailTrim!){
                
                emailTaken = true
                
            }else{
                
                emailTaken = false
            }
        })
        if usernameTaken{
            return "Sorry, that username is taken"
        }
        if emailTaken{
            return "Sorry, that email is in use"
        } **/
        return nil
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func createTapped(_ sender: Any) {
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
            
            Auth.auth().createUser(withEmail: emailClean, password: passwordClean, completion: { (user, error) in
                
                if(error != nil)
                {
                            self.showError("Error creating user")                }
                else
                {
            
                    
                    Auth.auth().signIn(withEmail: emailClean, password: passwordClean, completion: { (user, error) in
                        
                        if(error == nil)
                        {
                            self.ref!.child("users").child(user!.user.uid).child("email").setValue(emailClean)
                            
                            self.ref!.child("users").child(user!.user.uid).child("username").setValue(usernameClean)
                            
                                self.ref!.child("usernames").child(usernameClean).setValue(user!.user.uid)
                            
                            
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
    

    func showError(_ message:String){
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    func transitiontoHome(){
       if UserDefaults.standard.bool(forKey: "firstTime"){
         
      /**  let tempViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.temphomeViewController) as? FaceSubmitPageViewController
        
        self.present(tempViewController!, animated: true, completion: nil) **/
        
                  let tempViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.firstLogIn) as? IntroPageViewController
                                      tempViewController?.modalPresentationStyle = .fullScreen
                                      view.window?.rootViewController = tempViewController
                                      view.window?.makeKeyAndVisible()
        
        
                    }
        
        else{
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? MainTabViewController
        homeViewController?.modalPresentationStyle = .fullScreen
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
        }
    }
  

}
