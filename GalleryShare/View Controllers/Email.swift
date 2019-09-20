//
//  Email.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-08.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class Email: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var passwordConfirm: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
     
    @IBOutlet weak var error: UILabel!
    
    let characterset = CharacterSet(charactersIn:
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    /*
    // MARK: - Navigation

     @IBAction func createTapped(_ sender: Any) {
     }
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    func isPasswordValid(_ password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    func validateUser() -> String?{
        var validUsername = true
        if usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordConfirm.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill in all fields"
        }
        if (usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count)! < 5{
            validUsername = false
        }
        if usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).rangeOfCharacter(from: characterset.inverted) == nil{
                validUsername = false
            }
        if validUsername == false{
                return "Usernames should only contain letters and numbers, and be at least 5 characters long"
            }
        let cleanedPassword = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false{
            return "Please make sure your password is at least 8 characters, and contains a special character and number"
        }
        return nil
    }
    
    
    @IBOutlet weak var createButton: UIButton!
    @IBAction func createTapped(_ sender: Any) {
        let error = validateUser()
        if error != nil {
            showError(error!)
        }
        else{
            let username = self.usernameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = self.emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = self.passwordConfirm.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                if err != nil{
                    self.showError("Error creating user")
                }
                else{
                   
                    //Success!
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["username": username, "uid": result!.user.uid], completion: { (error) in
                        
                        if error != nil {
                            // Show error message
                            self.showError("Error saving user data")
                        }
                        
                    })
                   self.goToHome()
                }
            }
        }
    }
    func showError(_ message:String){
        error.text = message
        error.alpha = 1
    }
   func goToHome(){
       self.performSegue(withIdentifier: "firebaseMade", sender: self)
        
    }
}
