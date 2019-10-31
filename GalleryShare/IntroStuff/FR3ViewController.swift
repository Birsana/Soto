//
//  FR3ViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-29.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage


class FR3ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    
 var selectedImage: UIImage?
    
    @IBOutlet weak var check: Checkbox!
    @IBOutlet weak var goNext: UIButton!
    @IBOutlet weak var imageSelect: UIImageView!
    
    var imagePicker = UIImagePickerController()
    var anyCheck = false
       
       override func viewDidLoad() {
           super.viewDidLoad()
        
        imageSelect.asCircle()
        let currentUserID = Auth.auth().currentUser?.uid
        var DatabaseRef = Database.database().reference()
        var StorageRef = Storage.storage().reference()
        
    
        
        check.borderStyle = .square
        check.checkmarkStyle = .tick
        
           check.valueChanged = { (isChecked) in
               check1Clicked = false
               check2Clicked = false
               check3Clicked = !check3Clicked
               check4Clicked = false
               check5Clicked = false
            
            if check3Clicked{
                if !pic1Chose || !pic2Chose || !pic3Chose || !pic4Chose || !pic5Chose{
                    self.goNext.isEnabled = false
                    
                }
                else{
                    self.goNext.isEnabled = true
                }
            }
           
        }
           // Do any additional setup after loading the view.
       }

  override func viewWillAppear(_ animated: Bool) {
           if check1Clicked || check2Clicked || check3Clicked || check4Clicked || check5Clicked{
                        anyCheck = true
                    }
              
    if !pic1Chose || !pic2Chose || !pic3Chose || !pic4Chose || !pic5Chose{
                  goNext.isEnabled = false
                  
              }
              else if !anyCheck{
                  goNext.isEnabled = false
              }
              else{
                  
                  goNext.isEnabled = true
              }
     }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
          if check1Clicked || check2Clicked || check3Clicked{
                        anyCheck = true
                    }
              
          if !pic1Chose || !pic2Chose || !pic3Chose{
                  goNext.isEnabled = false
                  
              }
         else if !anyCheck{
                  goNext.isEnabled = false
              }
          else{
                  
                  goNext.isEnabled = true
              }
        
        }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func clickChoose(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                  
                    imagePicker.delegate = self
                   imagePicker.sourceType = .photoLibrary
                   imagePicker.allowsEditing = true
                   
                   
                   present(imagePicker, animated: true, completion: nil)
               }
        
    }
    
    
   
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let editedImage = info[.editedImage] as? UIImage {
               selectedImage = editedImage
            selectedImage = makeSquare(image: selectedImage!)
               self.imageSelect.image = selectedImage!
               picker.dismiss(animated: true, completion: nil)
           } else if let originalImage = info[.originalImage] as? UIImage {
               selectedImage = originalImage
            selectedImage = makeSquare(image: selectedImage!)
               self.imageSelect.image = selectedImage!
               picker.dismiss(animated: true, completion: nil)
           
           }
        pic3Chose = true
        if pic1Chose && pic2Chose && pic3Chose{
            if anyCheck{
                goNext.isEnabled = true
            }            
            }

        
    }
    
    @IBAction func finishIntro(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "firstTime")
        UserDefaults.standard.synchronize()
        
        if check1Clicked{
            pic1Selected()
        }
        if check2Clicked{
            pic2Selected()
        }
        if check3Clicked{
            pic3Selected()
        }
        
        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? MainTabViewController
                       
                       homeViewController?.modalPresentationStyle = .fullScreen
                       
                       self.view.window?.rootViewController = homeViewController
                       self.view.window?.makeKeyAndVisible()
        
    }
    
    func pic1Selected(){
        let currentUser = Auth.auth().currentUser
        var StorageRef = Storage.storage().reference()
        var DatabaseRef = Database.database().reference()
        
       let imageData = f1pic.jpegData(compressionQuality: 0.9)
      //  let imageData = picToUse.jpegData(compressionQuality: 0.9)
        let profilePicStorageRef = StorageRef.child("users/\(currentUser!.uid)/profilePics")
               
               let uploadTask = profilePicStorageRef.putData(imageData!, metadata: nil)
               {metadata, error in
                   
                    guard let metadata = metadata else {
                      // Uh-oh, an error occurred!
                      return
                    }
                   let size = metadata.size
                   
                   profilePicStorageRef.downloadURL { (url, error) in
                   guard let downloadURL = url
                       
                       else {
                     // Uh-oh, an error occurred!
                     return
                   }
                       DatabaseRef.child("users").child(currentUser!.uid).child("profilePic").setValue(downloadURL.absoluteString)
                       
                   }
               }
    }
    func pic2Selected(){
          let currentUser = Auth.auth().currentUser
          var StorageRef = Storage.storage().reference()
          var DatabaseRef = Database.database().reference()
        
        let imageData = f2pic.jpegData(compressionQuality: 0.9)
        let profilePicStorageRef = StorageRef.child("users/\(currentUser!.uid)/profilePics")
                      
                      let uploadTask = profilePicStorageRef.putData(imageData!, metadata: nil)
                      {metadata, error in
                          
                           guard let metadata = metadata else {
                             // Uh-oh, an error occurred!
                             return
                           }
                          let size = metadata.size
                          
                          profilePicStorageRef.downloadURL { (url, error) in
                          guard let downloadURL = url
                              
                              else {
                            // Uh-oh, an error occurred!
                            return
                          }
                              DatabaseRef.child("users").child(currentUser!.uid).child("profilePic").setValue(downloadURL.absoluteString)
                              
                          }
                      }
           
       }
    func pic3Selected(){
        let currentUser = Auth.auth().currentUser
        var StorageRef = Storage.storage().reference()
        var DatabaseRef = Database.database().reference()
        let imageData = selectedImage?.jpegData(compressionQuality: 0.9)
        let profilePicStorageRef = StorageRef.child("users/\(currentUser!.uid)/profilePics")
        
        let uploadTask = profilePicStorageRef.putData(imageData!, metadata: nil)
        {metadata, error in
            
             guard let metadata = metadata else {
               // Uh-oh, an error occurred!
               return
             }
            let size = metadata.size
            
            profilePicStorageRef.downloadURL { (url, error) in
            guard let downloadURL = url
                
                else {
              // Uh-oh, an error occurred!
              return
            }
                DatabaseRef.child("users").child(currentUser!.uid).child("profilePic").setValue(downloadURL.absoluteString)
                
            }
        }
           
       }
    
    
    
}
