//
//  AlbumsViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-08.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase


class AlbumsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Alboom", for: indexPath) as! AlbumTabCell
        
        let cellImageURL = self.picURLs[indexPath.row]
        let url = URL(string: cellImageURL)
        let cellName = nameArray[indexPath.row]
        //cell.coverPhoto.image = cellImage
        cell.coverPhoto.kf.setImage(with: url)
        cell.name.text = cellName
        
        cell.coverPhoto.translatesAutoresizingMaskIntoConstraints = false
        cell.coverPhoto?.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10).isActive = true
        cell.coverPhoto?.widthAnchor.constraint(equalToConstant: 80).isActive = true
        cell.coverPhoto?.heightAnchor.constraint(equalToConstant: 80).isActive = true
        cell.coverPhoto?.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        cell.coverPhoto?.layer.cornerRadius = 6
        cell.coverPhoto?.clipsToBounds = true
        
        cell.name.translatesAutoresizingMaskIntoConstraints = false
        cell.name.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        cell.name.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = (storyboard?.instantiateViewController(withIdentifier: "display") as? DisplayAlbumViewController) {
            vc.albumName = nameArray[indexPath.row]
            vc.albumID = idsToUse[indexPath.row]
            self.present(vc, animated: true, completion: nil)
            
        }
    }
    
   
    @IBOutlet weak var albums: UICollectionView!
    @IBOutlet weak var albumsTitle: UILabel!
    
    var imageArray = [UIImage]()
    var nameArray = [String]()
    var picURLs = [String]()
    
    var idArray = [String]()
    var idsToUse = [String]()
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    public var screenFourFifths: CGFloat {
        return UIScreen.main.bounds.height/7
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        albumsTitle.center.x = self.view.center.x
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
       
        
        self.albums.frame = CGRect(x:0, y: screenFourFifths, width: self.view.frame.width, height: self.view.frame.height - 120)
        self.albums.collectionViewLayout = layout
        
        grabAlbums()
        
        albums.delegate = self
        albums.dataSource = self
        
    }
    
    func grabAlbums(){
        let databaseRef = Database.database().reference()
               let user = Auth.auth().currentUser
               let uid = user?.uid
               var authUsername: String?
               
               databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
                   let myData = snapshot.value as! NSDictionary
                   
                   authUsername = (myData["username"] as! String)
                   databaseRef.child("Albums").child(authUsername!).queryOrdered(byChild: "timestamp").observe(.childAdded) { (snapshot) in
                       self.idArray.append(snapshot.key)
                       for rest in snapshot.children.allObjects as! [DataSnapshot] {
                           
                           if rest.key == "coverPhoto"{
                               let imageURL = rest.value as! String
                               self.picURLs.insert(imageURL, at: 0)
                           }
                           else if rest.key == "name"{
                               self.nameArray.insert(rest.value as! String, at: 0)
                           }
                           DispatchQueue.main.async {
                               self.albums.reloadData()
                               self.idsToUse = self.idArray.reversed()
                           }
                       }
                   }
                   
               }
    }
    
    @IBAction func createTapped(_ sender: Any) {
        
    }
    
}
