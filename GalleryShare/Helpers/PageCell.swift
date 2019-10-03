//
//  PageCell.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-26.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit

class PageCell: UICollectionViewCell, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
 //   let imageToSelect : UIImageView
  /**  let vc: UIViewController
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        
    //    imageView.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(handleSelectImage)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    
    var imagePicker = UIImagePickerController()
    
    private let pickImg: UIButton = {
        let button = UIButton(type: .system)
               button.setTitle("Select Image", for: .normal)
               button.translatesAutoresizingMaskIntoConstraints = false
               button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
               button.addTarget(self, action: #selector(pressChoose), for: .touchUpInside)
       return button
    }()
    
    @objc private func pressChoose(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                   
                    imagePicker.delegate = self
                   imagePicker.sourceType = .photoLibrary
                   imagePicker.allowsEditing = true
                   
                   
            vc.present(imagePicker, animated: true, completion: nil)
               }
            
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        vc.dismiss(animated: true, completion: { () -> Void in

              })

          //    imageToSelect.image = image
          }
    
    override init(frame: CGRect){
        
        super.init(frame: frame)
        backgroundColor = .purple
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    **/
}

