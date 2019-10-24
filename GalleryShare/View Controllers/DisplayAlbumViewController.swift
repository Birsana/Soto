//
//  DisplayAlbumViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-23.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

class DisplayAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    public var screenHeightHalf: CGFloat {
           return UIScreen.main.bounds.height/2
       }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
               
               let cellImage = imageArray[indexPath.row]
               cell.img.image = cellImage
               
               return cell
    }
    
    
    
    var imageArray=[UIImage]()
    var albumName: String!
    var username = ""
    var albumID: String?
    var picURL = [String]()
    
    var myCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        
        let layout2 = UICollectionViewFlowLayout()
        layout2.scrollDirection = .horizontal
        
        //self.view.frame = CGRect(x: 0, y: screenHeightHalf, width: 320, height: 480);
        var thisFrame = CGRect(x: 0, y: screenHeightHalf, width: 320, height: 480);
        myCollectionView = UICollectionView(frame: thisFrame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor=UIColor.white
        self.view.addSubview(myCollectionView)
        
        grabPhotos()
        
    }
    func grabPhotos(){
        imageArray = []
        
        let currentUser = Auth.auth().currentUser
        let StorageRef = Storage.storage().reference()
        let DatabaseRef = Database.database().reference()
        let uid = currentUser!.uid
        
        DatabaseRef.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? [String: AnyObject]
            self.username = (dict!["username"] as? String)!
            
            DatabaseRef.child("Albums").child(self.username).queryOrdered(byChild: "name").queryEqual(toValue: self.albumName).observeSingleEvent(of: .value) { (snapshot) in
                let myData = snapshot.value as! NSDictionary
                let componentArray = myData.allKeys
                self.albumID = componentArray.first as? String
                
                DatabaseRef.child("sentAlbumPics").child(uid).queryOrdered(byChild: "toID").queryEqual(toValue: self.albumID).observeSingleEvent(of: .value) { (snapshot) in
                    print(snapshot)
                    for child in snapshot.children{
                        let snap = child as! DataSnapshot
                        let dict = snap.value as! [String: Any]
                        let imageURL = dict["imageURL"] as! String
                        self.picURL.append(imageURL)
                    }
                    for imageURL in self.picURL {
                        //print(self.picURL)
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
                                   self.myCollectionView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
}
