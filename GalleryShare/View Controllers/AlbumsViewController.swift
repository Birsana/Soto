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
        cell.coverPhoto?.layer.cornerRadius = 4
        cell.coverPhoto?.clipsToBounds = true
        
        cell.name.translatesAutoresizingMaskIntoConstraints = false
        cell.name.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        cell.name.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 2
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = (storyboard?.instantiateViewController(withIdentifier: "display") as? DisplayAlbumViewController) {
            self.definesPresentationContext = true
            vc.modalPresentationStyle = .overCurrentContext
            vc.albumName = nameArray[indexPath.row]
            vc.albumID = idArray[indexPath.row]
            self.present(vc, animated: true, completion: nil)
            
        }
    }
    
    @IBOutlet weak var createAlbum: UIButton!
    @IBOutlet weak var albums: UICollectionView!
    
    var imageArray = [UIImage]()
    var nameArray = [String]()
    var picURLs = [String]()
    
    var idArray = [String]()
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var refreshControl = UIRefreshControl()
    
    @objc func refresh(sender:AnyObject) {
        self.albums.reloadData()
    }
    
    public var screenFourFifths: CGFloat {
        return UIScreen.main.bounds.height/8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
       /** refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        self.albums.addSubview(refreshControl) // not required when using UITabl **/
        
        self.albums.frame = CGRect(x:0, y: screenFourFifths, width: self.view.frame.width, height: self.view.frame.height)
        self.albums.collectionViewLayout = layout
        
        let databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser
        let uid = user?.uid
        var authUsername: String?
        
        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            let myData = snapshot.value as! NSDictionary
            
            authUsername = myData["username"] as! String
            
            databaseRef.child("Albums").child(authUsername!).queryOrdered(byChild: "coverPhoto").observe(.childAdded) { (snapshot) in
                self.idArray.append(snapshot.key)
                for rest in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    if rest.key == "coverPhoto"{
                        
                        let imageURL = rest.value as! String
                        self.picURLs.append(imageURL)
                    }
                    else if rest.key == "name"{
                        self.nameArray.append(rest.value as! String)
                    }
                    DispatchQueue.main.async {
                        self.albums.reloadData()
                    }
                }
                
                
            }
            
        }
        albums.delegate = self
        albums.dataSource = self
        
    }
    
    
    
    @IBAction func createTapped(_ sender: Any) {
        
    }
    
}
