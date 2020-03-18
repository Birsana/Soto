//
//  SendCell.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-12.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase


protocol SendCellDelegate: class{
    func sendPic(sendTo: String)
}

class SendCell: UITableViewCell {
    
  
    var sendLabel = UILabel()
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var username: UILabel!
    
    weak var delegate: SendCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.width/2.0
        self.profilePicture.clipsToBounds = true
    }
}
