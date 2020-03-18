//
//  SendAlbumCell.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-22.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit

protocol SendAlbumCellDelegate{
    func sendPic(album: String)
}

class SendAlbumCell: UITableViewCell {
    
    
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var add: UIButton!
    
    var delegate: SendAlbumCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func addTapped(_ sender: Any) {
        delegate?.sendPic(album: albumName.text!)
        print("tapped")
    }
    
}
