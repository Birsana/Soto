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
        return UIScreen.main.bounds.height/3
    }
    
    
    @IBOutlet weak var noFriends: UILabel!
    @IBOutlet weak var addFriends: UIButton!
    
    
    @IBOutlet weak var friendView: UIView!
    
    var personsFriends = [] as Any
    var personsPics = [] as Any
    
    var friendArray = [NSDictionary?]()
    var username = ""
    
    var myCollectionView: UICollectionView!
    var imageArray=[UIImage]()

    
    var profilePicURL = [String]()
    var usernameArray = [String]()
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
            let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
            cell.img.image=imageArray[indexPath.item]
            return cell
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let vc = ImagePreviewVC()
            vc.imgArray = self.imageArray
            
            vc.passedContentOffset = indexPath
            self.present(vc, animated: true, completion: nil)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "hasFriends"){
            noFriends.isHidden = true
            addFriends.isHidden = true
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //CREATE SPECIAL CASE FOR WHEN ACCEPT FRIEND REQUEST
        
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        friendView.translatesAutoresizingMaskIntoConstraints = false
        friendView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        friendView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        friendView.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
        friendView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        self.title = "Photos"
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        //self.view.frame = CGRect(x: 0, y: screenHeightHalf, width: 320, height: 480);
        var thisFrame = CGRect(x: 0, y: screenHeightHalf,  width: self.view.frame.width, height: self.view.frame.height)
        myCollectionView = UICollectionView(frame: thisFrame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor=UIColor.white
        myCollectionView.alwaysBounceVertical = true
        self.view.addSubview(myCollectionView)
        
        
        
        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        
        grabPhotos()
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
            
            DispatchQueue.main.async {
                
                self.myCollectionView.reloadData()
            }
        }
    }
    
    
}

