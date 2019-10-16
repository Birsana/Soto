//
//  FR2ViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-29.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit

class FR2ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    

    
    var selectedImage: UIImage?
    
    @IBOutlet weak var imageSelect: UIImageView!
    
    
    @IBOutlet weak var check: Checkbox!
    
    var imagePicker = UIImagePickerController()
    
       override func viewDidLoad() {
           
           super.viewDidLoad()
           imageSelect.asCircle()
           check.borderStyle = .square
           check.checkmarkStyle = .tick
    
            check.valueChanged = { (isChecked) in
                check1Clicked = false
                check2Clicked = !check2Clicked
                check3Clicked = false
            }
           // Do any additional setup after loading the view.
       }
    
    
    override func viewWillAppear(_ animated: Bool) {
         if check1Clicked || check3Clicked{
             check.isChecked = false
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
           // var selectedImage: UIImage?
              if let editedImage = info[.editedImage] as? UIImage {
                  selectedImage = editedImage
                  self.imageSelect.image = selectedImage!
                  picker.dismiss(animated: true, completion: nil)
              } else if let originalImage = info[.originalImage] as? UIImage {
                  selectedImage = originalImage
                  self.imageSelect.image = selectedImage!
                  picker.dismiss(animated: true, completion: nil)
              }
    pic2Chose = true
    print("2")
    f2pic = selectedImage!

       }
    
}
