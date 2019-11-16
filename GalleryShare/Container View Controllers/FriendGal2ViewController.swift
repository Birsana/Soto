//
//  FriendGal2ViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-11-12.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

class FriendGal2ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate{
    
    @IBOutlet weak var sentPhotos: UICollectionView!
    
    var viewHeightHalf: CGFloat {
        return view.frame.height/4
    }
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var testString: String?
    
    var labelText: String?
    
    var picURL = [String]()
    var picArray = [NSDictionary?]()
    var friend: String!
    var toID: String?
    var imageArray=[UIImage]()
    
    var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("usernames").observeSingleEvent(of: .value) { (snapshot) in
            let myData = snapshot.value as! NSDictionary
            self.toID = myData[self.username] as! String
            databaseRef.child("sentPics").child(uid!).queryOrdered(byChild: "toID").queryEqual(toValue: self.toID!).observeSingleEvent(of: .value) { (snapshot) in
                print(snapshot)
                for child in snapshot.children{
                    let snap = child as! DataSnapshot
                    let dict = snap.value as! [String: Any]
                    let imageURL = dict["imageURL"] as! String
                    self.picURL.append(imageURL)
                    DispatchQueue.main.async {
                        self.sentPhotos?.reloadData()
                    }
                    
                }
            }
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: viewHeightHalf / 3, height: viewHeightHalf / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        
        sentPhotos?.delegate=self
        sentPhotos?.dataSource=self
        sentPhotos?.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        sentPhotos?.collectionViewLayout = layout
        
        sentPhotos?.translatesAutoresizingMaskIntoConstraints = false
        sentPhotos?.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        sentPhotos?.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        sentPhotos?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        sentPhotos?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Count is", picURL.count)
        return picURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        //if image is nil, placeholder, otherwise load image
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        
        let url = URL(string: picURL[indexPath.row])
        cell.img.kf.setImage(with: url)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = FriendImagePreviewVC()
        vc.imgArray = self.imageArray
        vc.urlArray = self.picURL
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
    
}
