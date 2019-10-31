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
            /** let profileImageUrl = self.picURL[indexPath.row]
                   
               let url = NSURL(string: profileImageUrl)
               URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                   
                   if error != nil{
                       return
                   }
                   DispatchQueue.main.async {
                    cell.img.image = UIImage(data: data!)
                    print("ay")
                   }
                   
               }).resume() **/
               
               return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           
           let vc = AlbumImagePreviewVC()
           vc.imgArray = self.imageArray
           vc.sentArray = self.whoSent
        
           
           vc.passedContentOffset = indexPath
           self.present(vc, animated: true, completion: nil)
           
       }
    
    
    
    var imageArray=[UIImage]()
    var albumName: String!
    var username = ""
    var albumID: String?
    var picURL = [String]()
    var whoSent = [String]()

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
                
                if snapshot.exists(){
                let myData = snapshot.value as! NSDictionary
                let componentArray = myData.allKeys
                self.albumID = componentArray.first as? String
                
                DatabaseRef.child("sentAlbumPics").child(self.albumID!).observeSingleEvent(of: .value) { (snapshot) in
                    print(snapshot)
                    for child in snapshot.children{
                        let snap = child as! DataSnapshot
                        let dict = snap.value as! [String: Any]
                        let imageURL = dict["imageURL"] as! String
                        let picSender = dict["fromID"] as! String
                        self.picURL.append(imageURL)
                        self.whoSent.append(picSender)
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
}
