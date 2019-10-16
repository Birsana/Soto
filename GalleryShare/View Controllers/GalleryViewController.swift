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


class GalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate{
    
    public var screenHeightHalf: CGFloat {
        return UIScreen.main.bounds.height/2
    }
    
    
    @IBOutlet weak var noFriends: UILabel!
    @IBOutlet weak var addFriends: UIButton!
    
    var personsFriends = [] as Any
    var personsPics = [] as Any
    
    var friendArray = [NSDictionary?]()
    var username = ""
    
    var myCollectionView: UICollectionView!
    var imageArray=[UIImage]()
    var myCollectionViewFriends: UICollectionView!
    
    //var profilePicArray = [UIImage]()
    var profilePicURL = [String]()
    var usernameArray = [String]()
    //in did load populate these arrays, then copy tutorial
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.myCollectionView{
            return imageArray.count
        }
        else{
            
            return self.friendArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.myCollectionView{
            let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
            cell.img.image=imageArray[indexPath.item]
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ACell", for: indexPath) as! PersonImageCell
            
            cell.friendName?.text = usernameArray[indexPath.row]
            cell.backgroundColor = indexPath.item % 2 == 0 ?.black : .green
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.myCollectionView{
        let vc = ImagePreviewVC()
        vc.imgArray = self.imageArray
        
        vc.passedContentOffset = indexPath
        self.present(vc, animated: true, completion: nil)
        }
        else{
             if let vc = (storyboard?.instantiateViewController(withIdentifier: "myFriend") as? FriendViewController) {
                self.definesPresentationContext = true
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)
                   }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        
        if DeviceInfo.Orientation.isPortrait {
            return CGSize(width: width/4 - 1, height: width/4 - 1)
        } else {
            return CGSize(width: width/6 - 1, height: width/6 - 1)
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
    func viewLoadSetUp(){
        
        var databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.username = (dictionary["username"] as? String)!
                
                databaseRef.child("Friends").child(self.username).queryOrdered(byChild: "username").observe(.childAdded, with: { (snapshot) in
                    //print (snapshot)
                    let myData = snapshot.value as! NSDictionary
                    self.friendArray.append(snapshot.value as? NSDictionary)
                    DispatchQueue.main.async {
                        for friend in self.friendArray{
                        if !self.usernameArray.contains(friend?["username"] as! String){
                           self.usernameArray.append(friend?["username"] as! String)
                        }
                        if !self.profilePicURL.contains(friend?["profilePic"] as! String){
                           self.profilePicURL.append(friend?["profilePic"] as! String)
                        }
                                     }
                        
                        self.myCollectionViewFriends.reloadData()
                        
                    }
                    
                    
                }) { (error) in
                    print(error.localizedDescription
                    )
                    
                }
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewLoadSetUp()
        //CREATE SPECIAL CASE FOR WHEN ACCEPT FRIEND REQUEST
        
        self.title = "Photos"
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
        
        var anothaFrame = CGRect(x: 0, y: 0, width: 320, height: 480)
        myCollectionViewFriends = UICollectionView(frame: anothaFrame, collectionViewLayout: layout2)
        myCollectionViewFriends.delegate = self
        myCollectionViewFriends.dataSource = self
        myCollectionViewFriends.register(PersonImageCell.self, forCellWithReuseIdentifier: "ACell")
        myCollectionViewFriends.backgroundColor=UIColor.red
        
        self.view.addSubview(myCollectionViewFriends)
        
        
        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        
        grabPhotos()
        
        // Do any additional setup after loading the view.
    }
    
    func grabPhotos(){
        imageArray = []
        
        DispatchQueue.global(qos: .background).async {
            let imgManager=PHImageManager.default()
            
            let requestOptions=PHImageRequestOptions()
            requestOptions.isSynchronous=true
            requestOptions.deliveryMode = .highQualityFormat
            
            let fetchOptions=PHFetchOptions()
            fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
            
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count{
                    imgManager.requestImage(for: fetchResult.object(at: i) as PHAsset, targetSize: CGSize(width:500, height: 500),contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
                        self.imageArray.append(image!)
                    })
                }
            } else {
                print("You have no photos.")
            }
            //    print("imageArray count: \(self.imageArray.count)")
            
            DispatchQueue.main.async {
                
                self.myCollectionView.reloadData()
            }
        }
    }
    
    
}

