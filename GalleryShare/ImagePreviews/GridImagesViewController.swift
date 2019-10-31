//
//  GridImagesViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-27.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

class GridImagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        cell.img.image=imgArray[indexPath.item]
        cell.layer.borderColor = UIColor.red.cgColor
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if picsToSend.contains(imgArray[indexPath.item]){
            let itemToRemove = imgArray[indexPath.item]
            while picsToSend.contains(itemToRemove) {
                if let itemToRemoveIndex = picsToSend.firstIndex(of: itemToRemove) {
                    picsToSend.remove(at: itemToRemoveIndex)
                    print("YAH")
                }
            }
        }
        else{
            picsToSend.append(imgArray[indexPath.item])
            print("YEET")
        }
    }
    
    public var screenFourFifths: CGFloat {
        return UIScreen.main.bounds.height/8
    }
    
    
    var imgArray = [UIImage]()
    var myCollectionView: UICollectionView!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var picsToSend = [UIImage]()
    
    
    @IBAction func privateButton(_ sender: Any) {
        for image in picsToSend{
            let imageName = NSUUID().uuidString
            let currentUser = Auth.auth().currentUser
            let StorageRef = Storage.storage().reference()
            let DatabaseRef = Database.database().reference()
            let imageData = image.jpegData(compressionQuality: 0.9)
            let privatePicStorageRef = StorageRef.child("users/\(currentUser!.uid)/privatePics").child("\(imageName).jpg")
            
            let uploadTask = privatePicStorageRef.putData(imageData!, metadata: nil)
            {metadata, error in
                
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                let size = metadata.size
                
                privatePicStorageRef.downloadURL { (url, error) in
                    guard let downloadURL = url
                        
                        else {
                            // Uh-oh, an error occurred!
                            return
                    }
                    DatabaseRef.child("privatePics").child(currentUser!.uid).childByAutoId().child("url").setValue(downloadURL.absoluteString)
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func galleryButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newController = storyboard.instantiateViewController(withIdentifier: "sendAlbum") as! SendAlbumTableViewController
        
        newController.picsToSend = picsToSend
        
        self.present(newController, animated: true, completion: nil)
    }
    @IBAction func friendButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newController = storyboard.instantiateViewController(withIdentifier: "SendPic") as! SendTableViewController
        newController.picsToSend = picsToSend
        self.present(newController, animated: true, completion: nil)
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor=UIColor.black
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        var frame = CGRect(x:0, y: screenFourFifths, width: self.view.frame.width, height: self.view.frame.height)
        
        myCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor=UIColor.black
        self.view.addSubview(myCollectionView)
    }
    
    
    
}
