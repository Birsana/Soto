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
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var members: UIView!
    
    public var screenHeightHalf: CGFloat {
        return UIScreen.main.bounds.height/3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picURL.count
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        
        let cellImageURL = self.picURL[indexPath.row]
        let url = URL(string: cellImageURL)
        
        cell.img.kf.setImage(with: url)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = AlbumImagePreviewVC()
  
        
        vc.urlArr = self.picURL
        vc.sentArray = self.whoSent
        vc.passedContentOffset = indexPath
        
        
        let DatabaseRef = Database.database().reference()
        let tempPicSender = whoSent[indexPath.item]
        
        DatabaseRef.child("users").child(tempPicSender).observeSingleEvent(of: .value) { (snapshot) in
            print(tempPicSender)
            let dictionary = snapshot.value as? [String: AnyObject]
            let profilePicURL = (dictionary!["profilePic"] as? String)!
            let url = NSURL(string: profilePicURL)
            
            URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                if error != nil{
                    return
                }
                DispatchQueue.main.async {
                    
                    self.firstImage = UIImage(data: data!)!
                    vc.firstSender = self.firstImage
                    print(self.firstImage)
                    print("is nil?")
                    self.present(vc, animated: true, completion: nil)
                }
            }).resume()
        }
    }
    
    var albumName: String!
    var username = ""
    var albumID: String?
    var picURL = [String]()
    var whoSent = [String]()
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var firstImage: UIImage?
    
    
    var myCollectionView: UICollectionView!
    
    var containverVC: AlbumContainerViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerSegue"{
            containverVC = segue.destination as? AlbumContainerViewController
            containverVC?.albumID = self.albumID
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        members.translatesAutoresizingMaskIntoConstraints = false
        members.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        members.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        members.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        members.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        name.text = albumName
        
        let layout = UICollectionViewFlowLayout()
        
        var thisFrame = CGRect(x: 0, y: screenHeightHalf, width: view.frame.width, height: view.frame.height)
        myCollectionView = UICollectionView(frame: thisFrame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor=UIColor.white
        self.view.addSubview(myCollectionView)
        
        //SAME STLYE AS PRIVATE PHOTOS
        
        grabPhotos()
        
    }
    func grabPhotos(){
      
        let currentUser = Auth.auth().currentUser
        let StorageRef = Storage.storage().reference()
        let DatabaseRef = Database.database().reference()
        let uid = currentUser!.uid
        
        DatabaseRef.child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            let dict = snapshot.value as? [String: AnyObject]
            self.username = (dict!["username"] as? String)!
            
            
            DatabaseRef.child("sentAlbumPics").child(self.albumID!).observeSingleEvent(of: .value) { (snapshot) in
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
}
