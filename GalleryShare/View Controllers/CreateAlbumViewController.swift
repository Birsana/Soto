//
//  CreateAlbumViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-18.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

class CreateAlbumViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var coverPhoto: UIImageView!
    
    @IBOutlet weak var create: UIButton!
    
    @IBOutlet weak var share: UIButton!
    
    @IBOutlet weak var albumName: UITextField!
    
    var isSharedAlbum = false
    var authUsername: String?
    
    var friendsToShareWith = [String]()
    
    
    var selectedImage: UIImage?
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func addCover(_ sender: Any) {
        
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
            self.coverPhoto.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
            self.coverPhoto.image = selectedImage!
            picker.dismiss(animated: true, completion: nil)
            
        }
    }
    
    func validateName() -> String?{
        if albumName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please give the album a name"
        }
        return nil
    }
    
    @IBAction func createTapped(_ sender: Any) {
        //IF SHARE WITH SOMEONE WHO ALREADY HAS ALBUM NAMED THIS, NAME BECOMES NAME 2 FOR THAT PERSON
        let error = validateName()
        
        //DO ERROR STUFF HERE
        var picURL: String?
        let albumNameClean = albumName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let imageName = NSUUID().uuidString
        let imageData = self.coverPhoto.image!.jpegData(compressionQuality: 1.0)
        let currentUser = Auth.auth().currentUser
        let uid = currentUser?.uid
        let DatabaseRef = Database.database().reference()
        let StorageRef = Storage.storage().reference()
        let picToSendStorageRef = StorageRef.child("albumCovers").child("\(imageName).jpg")
        DatabaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            let myData = snapshot.value as! NSDictionary
            self.authUsername = myData["username"] as? String
            self.friendsToShareWith.append(self.authUsername!)
            let uploadTask = picToSendStorageRef.putData(imageData!, metadata: nil)
            {metadata, error in
                
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                let size = metadata.size
                
                picToSendStorageRef.downloadURL { (url, error) in
                    guard let downloadURL = url
                        
                        else {
                            // Uh-oh, an error occurred!
                            return
                    }
                    picURL = downloadURL.absoluteString
                    var dict: [String: String] = [:]
                    dict["name"] = albumNameClean
                    dict["coverPhoto"] = picURL
                    
                    var dict2: [String: String] = [:]
                    var counter = 1
                    for friend in self.friendsToShareWith{
                        dict2["person\(counter)"] = friend
                        counter += 1
                    }
                    
                    let uuid = NSUUID().uuidString
                    DatabaseRef.child("AlbumsRef").child(uuid).updateChildValues(dict2)
                    
                    for friend in self.friendsToShareWith{ DatabaseRef.child("Albums").child(friend).child(uuid).updateChildValues(dict)
                    }
                }
            }
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newController = storyboard.instantiateViewController(withIdentifier: "AddPpl") as! AlbumFriendsTableViewController
        self.present(newController, animated: true, completion: nil)
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
}
