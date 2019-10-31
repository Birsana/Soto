//
//  FR5ViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-29.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit

class FR5ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var selectedImage: UIImage?
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var check: Checkbox!
    
    @IBOutlet weak var imageSelect: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageSelect.asCircle()
               check.borderStyle = .square
               check.checkmarkStyle = .tick
               
               check.valueChanged = { (isChecked) in
                   check1Clicked = false
                   check2Clicked = false
                   check3Clicked = false
                   check4Clicked = false
                   check5Clicked = !check5Clicked
               }
       
    }
    override func viewWillAppear(_ animated: Bool) {
        if check1Clicked || check2Clicked || check3Clicked || check4Clicked{
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
        pic5Chose = true
        
        f5pic = selectedImage!
        
    }
}
