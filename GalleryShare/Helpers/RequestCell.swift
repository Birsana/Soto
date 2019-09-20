//
//  RequestCell.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-15.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore

protocol RequestCellDelegate: class{
    func acceptFriend(requester: String, dbRef: DatabaseReference)
    func declineFriend(requester: String, dbRef: DatabaseReference)
}

class RequestCell: UITableViewCell {
    
    var myTableViewController: FriendRequestsTableViewController?
    
    
    @IBOutlet weak var Person: UILabel!
    
    @IBOutlet weak var Accept: UIButton!
    
    
    @IBOutlet weak var Decline: UIButton!
    
    @IBAction func acceptTapped(_ sender: Any) {
        myTableViewController?.deleteCell(cell: self)
        delegate?.acceptFriend(requester: (Person.text)!, dbRef: Database.database().reference())
    }
    
    
    @IBAction func declineTapped(_ sender: Any) {
        myTableViewController?.deleteCell(cell: self)
      delegate?.declineFriend(requester: (Person.text)!, dbRef: Database.database().reference())
        

    }
  
    
    weak var delegate: RequestCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
