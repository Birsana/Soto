//
//  PhotoItemCell.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-06.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
class PhotoItemCell: UICollectionViewCell {
    
    var img = UIImageView()
    var selectLabel = UILabel()
    var representedAssetIdentifier: String?

       var thumbnailImage: UIImage! {
           didSet {
               img.image = thumbnailImage
           }
       }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds=true
        self.addSubview(img)
    }
    
    override func prepareForReuse() {
           super.prepareForReuse()
           img.image = nil
       }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        img.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct DeviceInfo {
    struct Orientation {
        // indicate current device is in the LandScape orientation
        static var isLandscape: Bool {
            get {
                return UIDevice.current.orientation.isValidInterfaceOrientation
                    ? UIDevice.current.orientation.isLandscape
                    : UIApplication.shared.statusBarOrientation.isLandscape
            }
        }
        // indicate current device is in the Portrait orientation
        static var isPortrait: Bool {
            get {
                return UIDevice.current.orientation.isValidInterfaceOrientation
                    ? UIDevice.current.orientation.isPortrait
                    : UIApplication.shared.statusBarOrientation.isPortrait
            }
        }
    }
}
