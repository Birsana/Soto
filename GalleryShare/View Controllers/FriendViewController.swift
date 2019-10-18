//
//  FriendViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-15.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

class FriendViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate{
    
    @IBOutlet weak var sentPhotos: UICollectionView!
    @IBOutlet weak var username: UILabel!
    
    var labelText: String?
    
    var picURL = [String]()
    var picArray = [NSDictionary?]()
    var friend: String!
    var fromID: String?
    var imageArray=[UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        username.text = labelText
        
        var databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("usernames").observeSingleEvent(of: .value) { (snapshot) in
            
            let myData = snapshot.value as! NSDictionary
            //self.fromID = myData[self.username.text!] as! String
            self.fromID = myData[self.labelText] as! String
            databaseRef.child("sentPics").child(self.fromID!).queryOrdered(byChild: "toID").queryEqual(toValue: uid).observeSingleEvent(of: .value) { (snapshot) in
                
                for child in snapshot.children{
                    let snap = child as! DataSnapshot
                    let dict = snap.value as! [String: Any]
                    let imageURL = dict["imageURL"] as! String
                    self.picURL.append(imageURL)
                    
                }
                for imageURL in self.picURL {
                               var imageRef = Storage.storage().reference(forURL: imageURL as! String)
                               imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                                   if error != nil {
                                       // uh oh
                                       print("Error loading image")
                                   } else{
                                       print("Loaded image")
                                       let image = UIImage(data: data!)
                                       self.imageArray.append(image!)
                                       DispatchQueue.main.async {
                                           self.sentPhotos.reloadData()
                                       }
                                   }
                               }
                           }
                
            }
            
        }
        sentPhotos.delegate=self
        sentPhotos.dataSource=self
        sentPhotos.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        sentPhotos.backgroundColor=UIColor.red
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        //if image is nil, placeholder, otherwise load image
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        
        let cellImage = imageArray[indexPath.row]
        cell.img.image = cellImage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = FriendImagePreviewVC()
        vc.imgArray = self.imageArray
        
        vc.passedContentOffset = indexPath
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        
        if DeviceInfo.Orientation.isPortrait {
            return CGSize(width: width/4 - 1, height: width/4 - 1)
        } else {
            return CGSize(width: width/6 - 1, height: width/6 - 1)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
    
    @IBAction func dismiss(_ sender: Any) {
        
        //self.dismiss(animated: true, completion: nil)
        if let vc = (storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? MainTabViewController) {
            //self.definesPresentationContext = true
            // vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}
