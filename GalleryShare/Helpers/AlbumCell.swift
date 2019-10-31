//
//  AlbumCell.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-18.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

protocol AlbumCellDelegate: class{
    func appendFriend(friendToAdd: String, add: Bool)
}

class AlbumCell: UITableViewCell {

    @IBOutlet weak var checkbox: Checkbox!
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var profilePic: UIImageView!
    
    weak var delegate: AlbumCellDelegate?
    
    
    @objc func checkboxValueChanged(sender: Checkbox) {
           print("checkbox value change: \(sender.isChecked)")
       }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func addTarget(_ sender: Any) {
        delegate?.appendFriend(friendToAdd: username.text! , add: checkbox.isChecked)
        
    }
    
}
