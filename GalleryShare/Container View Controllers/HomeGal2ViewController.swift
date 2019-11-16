//
//  HomeGal2ViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-11-14.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

class HomeGal2ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate  {
    
    var myCollectionView: UICollectionView!
    var firstImage: UIImage?
    
    var picURL = [String]()
    var whoSent = [String]()
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    public var screenHeightHalf: CGFloat {
        return UIScreen.main.bounds.height/2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        
        let cellImageURL = self.picURL[indexPath.row]
        let url = URL(string: cellImageURL)
        
        cell.img.kf.setImage(with: url)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        
        if DeviceInfo.Orientation.isPortrait {
            return CGSize(width: width/4 - 1, height: width/4 - 1)
        } else {
            return CGSize(width: width/6 - 1, height: width/6 - 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = AlbumImagePreviewVC()
        
        vc.urlArr = self.picURL
        vc.sentArray = self.whoSent
        vc.passedContentOffset = indexPath
        
        
        let DatabaseRef = Database.database().reference()
        let tempPicSender = whoSent[indexPath.item]
        
        DatabaseRef.child("users").child(tempPicSender).observeSingleEvent(of: .value) { (snapshot) in
            let dictionary = snapshot.value as? [String: AnyObject]
            let profilePicURL = (dictionary!["profilePic"] as? String)!
            print(profilePicURL)
        
            let url = NSURL(string: profilePicURL)
            
            URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                if error != nil{
                    return
                }
                DispatchQueue.main.async {
                    
                    self.firstImage = UIImage(data: data!)!
                    vc.firstSender = self.firstImage
                    print(self.whoSent)
                    self.present(vc, animated: true, completion: nil)
                }
            }).resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout = UICollectionViewFlowLayout()
        
        var thisFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        myCollectionView = UICollectionView(frame: thisFrame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor=UIColor.white
        self.view.addSubview(myCollectionView)
        
        grabPhotos()
        
        
    }
    
    func grabPhotos(){
        let databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("sentPicsRef").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                let dict = snap.value as! [String: Any]
                let imageURL = dict["imageURL"] as! String
                let picSender = dict["fromID"] as! String
                self.picURL.append(imageURL)
                self.whoSent.append(picSender)
                DispatchQueue.main.async {
                    self.myCollectionView.reloadData()
                }
            }
        }
        
    }
    
}
