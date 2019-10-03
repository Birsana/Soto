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


class FR3ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    let currentUserID = Auth.auth().currentUser?.uid
    
   
    
    
    @IBOutlet weak var check: Checkbox!
    
    
    
    @IBOutlet weak var goNext: UIButton!
    
    @IBOutlet weak var imageSelect: UIImageView!
    
     var imagePicker = UIImagePickerController()
       
       
       override func viewDidLoad() {
           super.viewDidLoad()
        
        if !pic1Chose || !pic2Chose || !pic3Chose{
            goNext.isEnabled = false
            print("p")
        }
        else{
            print("please")
            goNext.isEnabled = true
        }
    
        
        check.borderStyle = .square
        check.checkmarkStyle = .tick
        
           check.valueChanged = { (isChecked) in
               check3Clicked = true
               check1Clicked = false
               check2Clicked = false
           }

           // Do any additional setup after loading the view.
       }

    override func viewWillAppear(_ animated: Bool) {
         if check1Clicked || check2Clicked{
                    
                    check.isChecked = false
                }
     }
    
    override func viewDidAppear(_ animated: Bool) {
        if !pic1Chose || !pic2Chose || !pic3Chose{
                goNext.isEnabled = false
                print("p")
            }
          else{
                print("please")
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
    
    
    @IBAction func doneIntro(_ sender: Any) {
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         var selectedImage: UIImage?
           if let editedImage = info[.editedImage] as? UIImage {
               selectedImage = editedImage
               self.imageSelect.image = selectedImage!
               picker.dismiss(animated: true, completion: nil)
           } else if let originalImage = info[.originalImage] as? UIImage {
               selectedImage = originalImage
               self.imageSelect.image = selectedImage!
               picker.dismiss(animated: true, completion: nil)
           
           }
         pic3Chose = true
        if pic1Chose && pic2Chose && pic3Chose{
                goNext.isEnabled = true
                print("p")
            }

        
    }
    
    @IBAction func finishIntro(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "firstTime")
        UserDefaults.standard.synchronize()
        
    }
    
    
}
