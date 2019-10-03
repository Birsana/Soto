//
//  FaceRecViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-25.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit




class FaceRecViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    

    @IBOutlet weak var imageToSelect: UIImageView!
    
    
    @IBOutlet weak var check: Checkbox!
    
    
    var imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        check.borderStyle = .square
        check.checkmarkStyle = .tick
        
        check.valueChanged = { (isChecked) in
               check1Clicked = true
               check2Clicked = false
               check3Clicked = false
           }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if check2Clicked || check3Clicked{
            
            check.isChecked = false
        }
    }
    
  
    @IBAction func clickChoose(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
             imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            
            
            present(imagePicker, animated: true, completion: nil)
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
    
   
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
               var selectedImage: UIImage?
                 if let editedImage = info[.editedImage] as? UIImage {
                     selectedImage = editedImage
                     self.imageToSelect.image = selectedImage!
                     picker.dismiss(animated: true, completion: nil)
                 } else if let originalImage = info[.originalImage] as? UIImage {
                     selectedImage = originalImage
                     self.imageToSelect.image = selectedImage!
                     picker.dismiss(animated: true, completion: nil)
                 }
        pic1Chose = true
        print("1")

          }
    }




