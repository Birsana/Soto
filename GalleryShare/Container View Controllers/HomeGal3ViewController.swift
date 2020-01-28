//
//  HomeGal3ViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2020-01-07.
//  Copyright © 2020 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

class HomeGal3ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    var myCollectionView: UICollectionView!
    var firstImage: UIImage?
    
    var picURL = [String]()
    var whoRecieves = [String]()
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    @IBOutlet weak var titleLabel: UILabel!
    
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
        print(self.whoRecieves)
        vc.urlArr = self.picURL
        vc.sentArray = self.whoRecieves
        vc.passedContentOffset = indexPath
       
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.textAlignment = .center
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 5)
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout = UICollectionViewFlowLayout()
        
       var thisFrame = CGRect(x: 0, y: 55,  width: self.view.frame.width, height: self.view.frame.height-55)
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
        
        databaseRef.child("sentPics").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
            for child in snapshot.children{
                let snap = child as! DataSnapshot
                let dict = snap.value as! [String: Any]
                let imageURL = dict["imageURL"] as! String
                let picReciever = dict["toID"] as! String
                self.picURL.append(imageURL)
                self.whoRecieves.append(picReciever)
                DispatchQueue.main.async {
                    self.myCollectionView.reloadData()
                }
            }
        }
        
    }

}