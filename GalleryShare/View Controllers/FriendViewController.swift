//
//  FriendViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-15.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

class FriendViewController: UIViewController, UINavigationControllerDelegate{
    
    public var screenHeightHalf: CGFloat {
          return UIScreen.main.bounds.height/4
      }
    
    @IBOutlet weak var galleries: UIView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
   var containverVC: FriendGalPageViewController?
    
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    
    var labelText: String?
    
    var picURL = [String]()
    var picArray = [NSDictionary?]()
    var friend: String!
    var fromID: String?
    var imageArray=[UIImage]()
    
    var profilePicImage: UIImage?
    
    var selfUsername: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("jungle")
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        
        profilePic.asCircle()
        username.text = labelText
        profilePic.image = profilePicImage
        
        galleries.translatesAutoresizingMaskIntoConstraints = false
        galleries.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        galleries.heightAnchor.constraint(equalToConstant: screenHeightHalf).isActive = true
        galleries.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        galleries.topAnchor.constraint(equalTo: view.topAnchor, constant: 250).isActive = true
        
       
        
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gallery"{
            containverVC = segue.destination as? FriendGalPageViewController
            containverVC?.username1 = self.labelText
            
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        
        //self.dismiss(animated: true, completion: nil)
        if let vc = (storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? MainTabViewController) {
            //self.definesPresentationContext = true
            // vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}
