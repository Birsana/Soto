//
//  square.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-29.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit


func makeSquare(image: UIImage) -> UIImage{
       
       let originalWidth  = image.size.width
       let originalHeight = image.size.height
       var x: CGFloat = 0.0
       var y: CGFloat = 0.0
       var edge: CGFloat = 0.0
       
       if (originalWidth > originalHeight) {
           // landscape
           edge = originalHeight
           x = (originalWidth - edge) / 2.0
           y = 0.0
           
       } else if (originalHeight > originalWidth) {
           // portrait
           edge = originalWidth
           x = 0.0
           y = (originalHeight - originalWidth) / 2.0
       } else {
           // square
           edge = originalWidth
       }
       let cropSquare = CGRect(x: x, y: y, width: edge, height: edge)
       let imageRef = image.cgImage!.cropping(to: cropSquare);
       
       return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
   }
