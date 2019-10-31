//
//  AlbumsViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-08.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

//PUT CREATE IN CONTAINER VIEW, ALBUM COLLECTION VIEW COVERS REST OF PAGE, PULL TO REFRESH


class AlbumsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Alboom", for: indexPath) as! AlbumTabCell
        
        let cellImage = imageArray[indexPath.row]
        let cellName = nameArray[indexPath.row]
        cell.coverPhoto.image = cellImage
        cell.name.text = cellName
        
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
             if let vc = (storyboard?.instantiateViewController(withIdentifier: "display") as? DisplayAlbumViewController) {
                 self.definesPresentationContext = true
                 vc.modalPresentationStyle = .overCurrentContext
                vc.albumName = nameArray[indexPath.row]
                print(vc.albumName)
                 self.present(vc, animated: true, completion: nil)
                 
             }
         }
    
    @IBOutlet weak var createAlbum: UIButton!
    @IBOutlet weak var albums: UICollectionView!
    
    var imageArray = [UIImage]()
    var nameArray = [String]()
    var picURLs = [String]()
    
    var refreshControl = UIRefreshControl()
    
      @objc func refresh(sender:AnyObject) {
          self.albums.reloadData()
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        self.albums.addSubview(refreshControl) // not required when using UITabl
        
        let databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser
        let uid = user?.uid
        var authUsername: String?
        
        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            let myData = snapshot.value as! NSDictionary
            
            authUsername = myData["username"] as! String
            
            databaseRef.child("Albums").child(authUsername!).queryOrdered(byChild: "coverPhoto").observe(.childAdded) { (snapshot) in
               
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    if rest.key == "coverPhoto"{
                        
                        let imageURL = rest.value as! String
                        
                        let imageRef = Storage.storage().reference(forURL: imageURL as! String)
                        imageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
                            if error != nil {
                                print(imageURL)
                                print("Error loading image")
                            } else{
                                print("Loaded image")
                                let image = UIImage(data: data!)
                                self.imageArray.append(image!)
                                DispatchQueue.main.async {
                                    self.albums.reloadData()
                                }
                            }
                        }
                    }
                    else if rest.key == "name"{
                        self.nameArray.append(rest.value as! String)
                    }
                }
                
                
            }
            
        }
        albums.delegate = self
        albums.dataSource = self
        albums.backgroundColor = UIColor.red
    }
    
    
    
    @IBAction func createTapped(_ sender: Any) {
        
    }
    
}
