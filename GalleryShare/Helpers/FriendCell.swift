//
//  FriendCell.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-13.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore

protocol FriendCellDelegate: class {
    func addFriend(friend: String, dbRef: DatabaseReference)
}

class FriendCell: UITableViewCell {

    
    @IBAction func addFriendTapped(_ sender: Any) {
        delegate?.addFriend(friend: (Person.text)!, dbRef: Database.database().reference())
    }
    
    @IBOutlet weak var Person: UILabel!
    
    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var addFriend: UIButton!
    
    
    weak var delegate: FriendCellDelegate?
    
    func addFriend(friend: String, dbRef: DatabaseReference){
        if let currentUser = Auth.auth().currentUser?.uid{
            let myDataRef = dbRef.child("users").child(currentUser)
            
            myDataRef.observeSingleEvent(of: .value) { (snapshot) in
                let myData = snapshot.value as! Dictionary<String, String>
                let userFriendRequestRef = dbRef.child("FriendRequest").child(friend).child(currentUser)
                
                userFriendRequestRef.updateChildValues(myData)
                self.addFriend.isHidden = true
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        self.profilePic.layer.cornerRadius = self.profilePic.frame.width/2.0
        self.profilePic.clipsToBounds = true
    }

}
