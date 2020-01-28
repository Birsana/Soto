//
//  GalleryViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-04.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Photos
import Firebase
import FirebaseDatabase
import FirebaseFirestore


class GalleryViewController: UIViewController{
    
    
    public var screenHeightHalf: CGFloat {
        return UIScreen.main.bounds.height/3
    }
    
    @IBOutlet weak var galleries: UIView!
    
    
    @IBOutlet weak var noFriends: UILabel!
    @IBOutlet weak var addFriends: UIButton!
    
    
    @IBOutlet weak var friendView: UIView!
    
    
    var friendArray = [NSDictionary?]()
    var username = ""
    
   
    var imageArray=[UIImage]()

    
    var profilePicURL = [String]()
    var usernameArray = [String]()
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!

    
   
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let databaseRef = Database.database().reference()
        
        databaseRef.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.username = (dictionary["username"] as? String)!
                print("heeee")
                databaseRef.child("Friends").child(self.username).observeSingleEvent(of: .value, with: { (snapshot) in
                    print("slatt")
                    print(snapshot)
                    if snapshot.value is NSNull{
                        self.friendView.isHidden = true
                    }
                })
            }
        }
        
        

        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        friendView.translatesAutoresizingMaskIntoConstraints = false
        friendView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        friendView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        friendView.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        friendView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        self.title = "Photos"
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
    
        
        galleries.translatesAutoresizingMaskIntoConstraints = false
        galleries.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        galleries.heightAnchor.constraint(equalToConstant: screenHeightHalf).isActive = true
        galleries.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        galleries.topAnchor.constraint(equalTo: view.topAnchor, constant: 250).isActive = true
        galleries.backgroundColor = .red
        
        //50
      
    }
    
    
    
}

