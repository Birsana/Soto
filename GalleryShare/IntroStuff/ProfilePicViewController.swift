//
//  ProfilePicViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-11-16.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

extension UIImageView{
    
    func asCircle(){
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.size.width / 2
        
    }
}

class ProfilePicViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imageSelect: UIImageView!
    
    @IBOutlet weak var goNext: UIButton!
    
    var selectedImage: UIImage?
    
    var imagePicker = UIImagePickerController()
    
    var noFace: Bool?
    var multipleFaces: Bool?
    lazy var vision = Vision.vision()
    
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
        imageSelect.layer.borderColor = UIColor.red.cgColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        imageSelect.addGestureRecognizer(tap)
        
    }
    
    func hasFaces(profilePic: UIImage){
        print("HIYA")
        let options = VisionFaceDetectorOptions()
        let visionImage = VisionImage(image: profilePic)
        //options.performanceMode = .accurate
        //options.landmarkMode = .all
        // options.classificationMode = .all
        let faceDetector = vision.faceDetector(options: options)
        faceDetector.process(visionImage) { faces, error in
            guard error == nil, let faces = faces, !faces.isEmpty else {
                print("how")
                return
            }
            print("hey")
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
        else{
            UserDefaults.standard.set(false, forKey: "firstTime")
            UserDefaults.standard.synchronize()
            
            let currentUser = Auth.auth().currentUser
            var StorageRef = Storage.storage().reference()
            var DatabaseRef = Database.database().reference()
            
            let imageData = imageSelect.image!.jpegData(compressionQuality: 0.9)
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
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? MainTabViewController
            
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
        let faceDetector = vision.faceDetector()
        let image = VisionImage(image: selectedImage!)
        
        faceDetector.process(image) { (faces, error) in
            print("Fucking work")
            print(faces)
        }
        goNext.isEnabled = true
    }
}
