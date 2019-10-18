//
//  File.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-04.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

class ImagePreviewVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    var myCollectionView: UICollectionView!
    var imgArray = [UIImage]()
    var passedContentOffset = IndexPath()
    
   
       private let addButton: UIButton = {
             let button = UIButton(type: .system)
             button.setTitle("Add", for: .normal)
             button.translatesAutoresizingMaskIntoConstraints = false
             button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
             button.setTitleColor(.systemPink, for: .normal)
             button.addTarget(self, action: #selector(getPic), for: .touchUpInside)
             return button
         }()
    
    private let sendButton: UIButton = {
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 110, y: 0, width: 90, height: 30))
                button.setTitle("Send", for: .normal)
                button.translatesAutoresizingMaskIntoConstraints = true
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                button.setTitleColor(.systemPink, for: .normal)
                button.addTarget(self, action: #selector(sendPic), for: .touchUpInside)
                return button
            }()
    
    
    @objc private func getPic(){
        var pictoSend: UIImage!
        for cell in myCollectionView.visibleCells{
            let indexPriv = myCollectionView.indexPath(for: cell)
            let intPriv = indexPriv?.item
            pictoSend = imgArray[intPriv!]
            
        }
        let imageName = NSUUID().uuidString
        let currentUser = Auth.auth().currentUser
        var StorageRef = Storage.storage().reference()
        var DatabaseRef = Database.database().reference()
        let imageData = pictoSend.jpegData(compressionQuality: 0.9)
        let privatePicStorageRef = StorageRef.child("users/\(currentUser!.uid)/privatePics").child("\(imageName).jpg")
        
         let uploadTask = privatePicStorageRef.putData(imageData!, metadata: nil)
            {metadata, error in
                
                 guard let metadata = metadata else {
                   // Uh-oh, an error occurred!
                   return
                 }
                let size = metadata.size
                
                privatePicStorageRef.downloadURL { (url, error) in
                guard let downloadURL = url
                    
                    else {
                  // Uh-oh, an error occurred!
                  return
                }
                    DatabaseRef.child("privatePics").child(currentUser!.uid).childByAutoId().child("url").setValue(downloadURL.absoluteString)
                }
            }
    }
    
    @objc private func sendPic(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newController = storyboard.instantiateViewController(withIdentifier: "SendPic") as! SendTableViewController
        
        var transferPic: UIImage!
        for cell in myCollectionView.visibleCells{
            let indexPriv = myCollectionView.indexPath(for: cell)
            let intPriv = indexPriv?.item
            transferPic = imgArray[intPriv!]
        }
        newController.picToSend = transferPic
        newController.passedIndex = passedContentOffset
        newController.passedArray = imgArray
        
        self.present(newController, animated: true, completion: nil)
        

    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor=UIColor.black
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing=0
        layout.minimumLineSpacing=0
        layout.scrollDirection = .horizontal
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(ImagePreviewFullViewCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.isPagingEnabled = true
        
      //  myCollectionView.scrollToItem(at: x, at: .left, animated: true)
        
        self.view.addSubview(myCollectionView)
        self.view.addSubview(addButton)
        self.view.addSubview(sendButton)
        
        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let x = passedContentOffset
        DispatchQueue.main.async {
        self.myCollectionView.scrollToItem(at: x, at: .left, animated: false)
                       }
       
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImagePreviewFullViewCell
        cell.imgView.image=imgArray[indexPath.row]
        return cell
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = myCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.itemSize = myCollectionView.frame.size
        
        flowLayout.invalidateLayout()
        
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let offset = myCollectionView.contentOffset
        let width  = myCollectionView.bounds.size.width
        
        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        
        myCollectionView.setContentOffset(newOffset, animated: false)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.myCollectionView.reloadData()
            
            self.myCollectionView.setContentOffset(newOffset, animated: false)
        }, completion: nil)
    }

}


class ImagePreviewFullViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var scrollImg: UIScrollView!
    var imgView: UIImageView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollImg = UIScrollView()
        scrollImg.delegate = self
        scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = true
        scrollImg.flashScrollIndicators()
        
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 4.0
        
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        scrollImg.addGestureRecognizer(doubleTapGest)
        
        self.addSubview(scrollImg)
        
        imgView = UIImageView()
        imgView.image = UIImage(named: "user3")
        scrollImg.addSubview(imgView!)
        imgView.contentMode = .scaleAspectFit
    }
    
    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollImg.zoomScale == 1 {
            scrollImg.zoom(to: zoomRectForScale(scale: scrollImg.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollImg.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imgView.frame.size.height / scale
        zoomRect.size.width  = imgView.frame.size.width  / scale
        let newCenter = imgView.convert(center, from: scrollImg)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollImg.frame = self.bounds
        imgView.frame = self.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollImg.setZoomScale(1, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}