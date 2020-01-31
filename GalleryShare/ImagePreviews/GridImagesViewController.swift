//
//  GridImagesViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-27.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase
import Photos
import PhotosUI

class GridImagesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate{
    
    var options = PHImageRequestOptions()
    var optionsToSend = PHImageRequestOptions()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        
        
        cell.selectLabel = UILabel(frame: CGRect(x:50, y: 0, width: 30, height: 30))
        
        //selectLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.selectLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        cell.selectLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cell.selectLabel.layer.cornerRadius = cell.selectLabel.frame.width/2
        cell.selectLabel.layer.masksToBounds = true
        cell.selectLabel.layer.borderWidth = 1
        cell.selectLabel.layer.borderColor = UIColor.white.cgColor
        cell.selectLabel.frame.origin.y = 0
        cell.selectLabel.frame.origin.x = cell.frame.width - cell.selectLabel.frame.width
        
        cell.addSubview(cell.selectLabel)
        
        let thumbnailSize = CGSize(width: cell.frame.width, height: cell.frame.height)
        options.deliveryMode = .highQualityFormat
        let asset = fetchResult.object(at: indexPath.item)
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: options, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        optionsToSend.deliveryMode = .highQualityFormat
        var currentPic: UIImage!
        let currentCell = myCollectionView.cellForItem(at: indexPath) as! PhotoItemCell
        let asset = fetchResult.object(at: indexPath.item)
        imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: optionsToSend) { image, _ in
            currentPic = image
            if self.picsToSend.contains(currentPic!){
                let itemToRemove = currentPic
                while self.picsToSend.contains(itemToRemove!) {
                    if let itemToRemoveIndex = self.picsToSend.firstIndex(of: itemToRemove!) {
                        self.picsToSend.remove(at: itemToRemoveIndex)
                        let cell = self.myCollectionView.cellForItem(at: indexPath) as! PhotoItemCell
                        cell.selectLabel.backgroundColor = UIColor.clear
                    }
                }
            }
            else{
                self.picsToSend.append(currentPic!)
                let cell = self.myCollectionView.cellForItem(at: indexPath) as! PhotoItemCell
                cell.selectLabel.backgroundColor = UIColor.blue
                
                
            }
        }
        
        
    }
    
    public var screenFourFifths: CGFloat {
        return UIScreen.main.bounds.height/8
    }
    
    var myCollectionView: UICollectionView!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var picsToSend = [UIImage]()
    
    
    fileprivate let imageManager = PHCachingImageManager()
    var fetchResult: PHFetchResult<PHAsset>!
    
    
    
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
