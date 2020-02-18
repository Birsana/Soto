//
//  FriendGal1ViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-11-12.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

class FriendGal1ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
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
    var fromID: String?
    var imageArray=[UIImage]()
    
    
    
    @IBOutlet weak var sentPhotos: UICollectionView!
    
    var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser
        let uid = user!.uid
        
        databaseRef.child("usernames").observeSingleEvent(of: .value) { (snapshot) in
            let myData = snapshot.value as! NSDictionary
            self.fromID = (myData[self.username as Any] as! String)
            databaseRef.child("sentPics").child(self.fromID!).queryOrdered(byChild: "timestamp").observe(.childAdded) { (snapshot) in
                let dict = snapshot.value as! [String: Any]
                if dict["toID"] as? String == uid{
                    let imageURL = dict["imageURL"] as! String
                    self.picURL.insert(imageURL, at: 0)
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
