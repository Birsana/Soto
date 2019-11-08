//
//  PrivImagePreviewVC.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-09.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//


import UIKit
import Firebase
import Kingfisher

class PrivImagePreviewVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    var myCollectionView: UICollectionView!
    var imgArray = [UIImage]()
    var passedContentOffset = IndexPath()
    var allURLs = [AnyObject]()
    
    var stringURLs = [String]()
    
    
    private let addButton: UIButton = {
                let button = UIButton(type: .system)
                button.setTitle("Save", for: .normal)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                button.setTitleColor(.systemPink, for: .normal)
                button.addTarget(self, action: #selector(savePic), for: .touchUpInside)
                return button
            }()
    
    private let deleteButton: UIButton = {
                   let button = UIButton(type: .system)
                   button.setTitle("Delete", for: .normal)
                   button.translatesAutoresizingMaskIntoConstraints = false
                   button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                   button.setTitleColor(.systemPink, for: .normal)
                   button.addTarget(self, action: #selector(deletePic), for: .touchUpInside)
                   return button
               }()
   @objc private func savePic(){
          var pictoSave: UIImage!
          for cell in myCollectionView.visibleCells{
              let indexPriv = myCollectionView.indexPath(for: cell)
            let currentcell = myCollectionView.cellForItem(at: indexPriv!) as! PrivImagePreviewFullViewCell
            pictoSave = currentcell.imgView.image
           
          }
          let imageData = pictoSave.jpegData(compressionQuality: 1)
          let imgToSave = UIImage(data: imageData!)
          UIImageWriteToSavedPhotosAlbum(imgToSave!, nil, nil, nil)
          
          let alert = UIAlertController(title: "Saved", message: "Your image has been saved", preferredStyle: .alert)
          let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
          alert.addAction(okAction)
          self.present(alert, animated: true, completion: nil)
      }
    @objc private func deletePic(){
        let storage = Storage.storage()
        let databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        
        for cell in myCollectionView.visibleCells{
            let urlIndex = myCollectionView.indexPath(for: cell)
            let urlDelete = self.allURLs[urlIndex!.item] as! String
            databaseRef.child("privatePics").child(uid!).queryOrdered(byChild: "url").queryEqual(toValue: urlDelete).observeSingleEvent(of: .value) { (snapshot) in
                let myData = snapshot.value as! NSDictionary
                let componentArray = myData.allKeys
                let toDelete = componentArray.first as? String
                databaseRef.child("privatePics").child(uid!).child(toDelete!).removeValue()
                
              
                self.stringURLs = self.allURLs as! [String]
                if let index = self.stringURLs.index(of: urlDelete){
                    self.stringURLs.remove(at: index)
                }
                
                self.allURLs = self.stringURLs as [AnyObject]
                self.myCollectionView.reloadData()
               
            }
            
        }
        
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
        myCollectionView.register(PrivImagePreviewFullViewCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.isPagingEnabled = true
        
              //  myCollectionView.scrollToItem(at: x, at: .left, animated: true)
        
        self.view.addSubview(myCollectionView)
        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
        self.view.addSubview(addButton)
        addButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        addButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        self.view.addSubview(deleteButton)
        addButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        addButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 20).isActive = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let x = passedContentOffset
        
        DispatchQueue.main.async {
        self.myCollectionView.scrollToItem(at: x, at: .left, animated: false)
                       }
       
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PrivImagePreviewFullViewCell
        let url = URL(string: allURLs[indexPath.item] as! String)
        cell.imgView.kf.setImage(with: url)
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


class PrivImagePreviewFullViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
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

