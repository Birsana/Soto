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
    
    @IBOutlet weak var sendPic: UIButton!
    
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

    
    @IBAction func sendPicTapped(_ sender: Any) {
        delegate?.sendPic(sendTo: username.text!)
    }
    
}
