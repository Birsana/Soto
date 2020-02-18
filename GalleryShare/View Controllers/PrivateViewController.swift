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
    var allURLs = [AnyObject]()
    var passURLs = [AnyObject]()
    
    public var screenHeightHalf: CGFloat {
        return UIScreen.main.bounds.height/8
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        let databaseRef = Database.database().reference()
 //       let user = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef.child("privatePics").child(uid!).observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.privateArray.append(snapshot.value as? NSDictionary)
                self.allURLs = Array(dictionary.values)
                self.passURLs += Array(dictionary.values)
              
                
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        privatePhotos.delegate=self
        privatePhotos.dataSource=self
        privatePhotos.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")

        
        
        privatePhotos.translatesAutoresizingMaskIntoConstraints = false
        privatePhotos.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        privatePhotos.heightAnchor.constraint(equalToConstant: screenHeightHalf).isActive = true
        privatePhotos.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        privatePhotos.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 120).isActive = true
        //FINISH THIS
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Count is", passURLs.count)
        return passURLs.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = PrivImagePreviewVC()
        
        vc.allURLs = self.passURLs
        
        vc.passedContentOffset = indexPath
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        //if image is nil, placeholder, otherwise load image
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
      
        let url = URL(string: (self.passURLs[indexPath.row] as! String))
       
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
    
    
}
