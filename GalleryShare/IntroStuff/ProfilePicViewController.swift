//
//  ProfilePicViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-11-16.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase
import Vision 
import Alamofire

extension UIImageView{
    
    func asCircle() {
        
        self.layer.masksToBounds = true
        var radius = self.frame.size.width / 2
        if radius > 100 {
            radius = 35
        }
        self.layer.cornerRadius = radius
        
    }
}

class ProfilePicViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageSelect: UIImageView!
    
    @IBOutlet weak var goNext: UIButton!
    
    var selectedImage: UIImage?
    
    var imagePicker = UIImagePickerController()
    
    var noFace: Bool?
    var multipleFaces: Bool?
    
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goNext.isEnabled = false
        
        imageSelect.asCircle()
        imageSelect.isUserInteractionEnabled = true
        imageSelect.layer.borderWidth = 2
        imageSelect.layer.borderColor = UIColor.black.cgColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        imageSelect.addGestureRecognizer(tap)
        
    }
    
    func hasFaces(profilePic: UIImage){
        let request = VNDetectFaceRectanglesRequest { (req, error) in
            if let error = error{
                
                // print("no faces")
                self.noFace = true
                self.multipleFaces = false
                return
            }
            if req.results!.count == 0{
                print("no faces")
                self.noFace = true
                self.multipleFaces = false
            }
            else if req.results!.count > 1{
                print("multiple faces")
                self.noFace = false
                self.multipleFaces = true
            }
            else if req.results!.count == 1{
                print("one face")
                self.noFace = false
                self.multipleFaces = false
            }
        }
        let handler = VNImageRequestHandler(cgImage: profilePic.cgImage!, options: [:])
        
        do {
            try handler.perform([request])
        } catch let reqErr {
            print(reqErr)
        }
        
    }
    
    @IBAction func finishIntro(_ sender: Any) {
        hasFaces(profilePic: imageSelect.image!)
        
        if noFace!{
            let alert = UIAlertController(title: "Invalid Photo", message: "No faces were detected", preferredStyle: .alert)
            let okAction =  UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
        }
        else if multipleFaces!{
            let alert = UIAlertController(title: "Invalid Photo", message: "Multiple faces were detected", preferredStyle: .alert)
            let okAction =  UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            UserDefaults.standard.set(false, forKey: "firstTime")
            UserDefaults.standard.synchronize()
            
            let currentUser = Auth.auth().currentUser
            let imageData = imageSelect.image!.jpegData(compressionQuality: 0.9)
            let parameters = ["uid": currentUser!.uid]
            
            AF.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(imageData!, withName: "profilePics", fileName: "\(currentUser!.uid).jpg",
                mimeType: "image/jpg")
                for (key, value) in parameters{
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }    
            }, to: "http://soto.us-east-2.elasticbeanstalk.com/add").responseString { (response) in
                print(response)
            }
            
            
            let StorageRef = Storage.storage().reference()
            let DatabaseRef = Database.database().reference()
            
            
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
                    DatabaseRef.child("collectionPics").child(currentUser!.uid).child(Auth.auth().currentUser!.uid + "_1").setValue(downloadURL.absoluteString)
                }
            }
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? MainPage
            
            homeViewController?.modalPresentationStyle = .fullScreen
            
            self.view.window?.rootViewController = homeViewController
            self.view.window?.makeKeyAndVisible()
            
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
        
        goNext.isEnabled = true
    }
}
