//
//  PrivateViewController.swift
//  
//
//  Created by Andre Birsan on 2019-10-08.
//

import UIKit
import Firebase

class PrivateViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate{
    
    @IBOutlet weak var privatePhotos: UICollectionView!
    var privateArray = [NSDictionary?]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        let databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("privatePics").child(uid!).observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.privateArray.append(snapshot.value as? NSDictionary)
                let allURLs = Array(dictionary.values)
                
                for imageURL in allURLs {
                    let imageRef = Storage.storage().reference(forURL: imageURL as! String)
                    imageRef.getData(maxSize: 10 * 1024 * 1024) { (data, error) in
                        if error != nil {
                            print("Error loading image")
                        } else{
                            print("Loaded image")
                            let image = UIImage(data: data!)
                            self.imageArray.append(image!)
                            DispatchQueue.main.async {
                                self.privatePhotos.reloadData()
                            }
                        }
                    }
                }
                
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        privatePhotos.delegate=self
        privatePhotos.dataSource=self
        privatePhotos.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        privatePhotos.backgroundColor=UIColor.red
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = PrivImagePreviewVC()
        vc.imgArray = self.imageArray
        
        vc.passedContentOffset = indexPath
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        //if image is nil, placeholder, otherwise load image
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        
        let cellImage = imageArray[indexPath.row]
        cell.img.image = cellImage
        
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
    /** override func viewWillLayoutSubviews() {
     super.viewWillLayoutSubviews()
     privatePhotos.collectionViewLayout.invalidateLayout()
     }**/
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    
}
