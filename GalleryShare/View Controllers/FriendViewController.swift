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
    
    public var screenHeightHalf: CGFloat {
          return UIScreen.main.bounds.height/4
      }
    
    @IBOutlet weak var sentPhotos: UICollectionView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    
    var labelText: String?
    
    var picURL = [String]()
    var picArray = [NSDictionary?]()
    var friend: String!
    var fromID: String?
    var imageArray=[UIImage]()
    
    var profilePicImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        
        profilePic.asCircle()
        username.text = labelText
        profilePic.image = profilePicImage
        
        var databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("usernames").observeSingleEvent(of: .value) { (snapshot) in
            
            let myData = snapshot.value as! NSDictionary
            self.fromID = myData[self.username.text!] as! String
            
            databaseRef.child("sentPics").child(self.fromID!).queryOrdered(byChild: "toID").queryEqual(toValue: uid).observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children{
                    let snap = child as! DataSnapshot
                    let dict = snap.value as! [String: Any]
                    let imageURL = dict["imageURL"] as! String
                    self.picURL.append(imageURL)
                    DispatchQueue.main.async {
                        self.sentPhotos.reloadData()
                    }
                    
                }
            }
            
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        
        sentPhotos.delegate=self
        sentPhotos.dataSource=self
        sentPhotos.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        sentPhotos.collectionViewLayout = layout
        
        sentPhotos.translatesAutoresizingMaskIntoConstraints = false
        sentPhotos.heightAnchor.constraint(equalToConstant: screenHeightHalf).isActive = true
        sentPhotos.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        sentPhotos.topAnchor.constraint(equalTo: view.topAnchor, constant: 250).isActive = true
        sentPhotos.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    
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
    
    
    
    @IBAction func dismiss(_ sender: Any) {
        
        //self.dismiss(animated: true, completion: nil)
        if let vc = (storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? MainTabViewController) {
            //self.definesPresentationContext = true
            // vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}
