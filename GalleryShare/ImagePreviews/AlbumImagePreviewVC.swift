//
//  AlbumImagePreviewVC.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-25.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class AlbumImagePreviewVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    var myCollectionView: UICollectionView!
    var passedContentOffset = IndexPath()
    var sentArray = [String]()
    
    var urlArr = [String]()
    
    //  var firstSender: UIImage?
    var firstPic = true
    
    
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.systemPink, for: .normal)
        button.addTarget(self, action: #selector(getPic), for: .touchUpInside)
        return button
    }()
    
    private let sendFriendButton: UIButton = {
        //ADD SEARCH FUNCTIONALITY FOR ALBUM AND FRIENDS
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 110, y: 0, width: 90, height: 30))
        button.setTitle("Send to Friend", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.systemPink, for: .normal)
        button.addTarget(self, action: #selector(sendPic), for: .touchUpInside)
        return button
        
    }()
    
    private let addAlbumButton: UIButton = {
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 110, y: 300, width: 90, height: 30))
        button.setTitle("Add to Album", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.systemPink, for: .normal)
        button.addTarget(self, action: #selector(sendPic2), for: .touchUpInside)
        return button
    }()
    
    
    @objc private func getPic(){
        var pictoSend: UIImage!
        for cell in myCollectionView.visibleCells{
            let indexPriv = myCollectionView.indexPath(for: cell)
            let currentcell = myCollectionView.cellForItem(at: indexPriv!) as! AlbumImagePreviewFullViewCell
            pictoSend = currentcell.imgView.image
            
        }
        let imageName = NSUUID().uuidString
        let currentUser = Auth.auth().currentUser
        let StorageRef = Storage.storage().reference()
        let DatabaseRef = Database.database().reference()
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
            let currentcell = myCollectionView.cellForItem(at: indexPriv!) as! AlbumImagePreviewFullViewCell
            transferPic = currentcell.imgView.image
        }
        newController.picToSend = transferPic
        
        self.present(newController, animated: true, completion: nil)
        
        
    }
    @objc private func sendPic2(){
        print("2")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newController = storyboard.instantiateViewController(withIdentifier: "sendAlbum") as! SendAlbumTableViewController
        
        var transferPic: UIImage!
        for cell in myCollectionView.visibleCells{
            let indexPriv = myCollectionView.indexPath(for: cell)
            let currentcell = myCollectionView.cellForItem(at: indexPriv!) as! AlbumImagePreviewFullViewCell
            
            transferPic = currentcell.imgView.image
        }
        newController.picToSend = transferPic
        
        self.present(newController, animated: true, completion: nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor=UIColor.black
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing=0
        layout.minimumLineSpacing=0
        layout.scrollDirection = .horizontal
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(AlbumImagePreviewFullViewCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.isPagingEnabled = true
        
        //  myCollectionView.scrollToItem(at: x, at: .left, animated: true)
        
        self.view.addSubview(myCollectionView)
        self.view.addSubview(addButton)
        self.view.addSubview(sendFriendButton)
        self.view.addSubview(addAlbumButton)
        addButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        addButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10)
        
        //        myCollectionView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.RawValue(UInt8(UIView.AutoresizingMask.flexibleWidth.rawValue) | UInt8(UIView.AutoresizingMask.flexibleHeight.rawValue)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let x = passedContentOffset
        DispatchQueue.main.async {
            self.myCollectionView.scrollToItem(at: x, at: .left, animated: false)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.urlArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! AlbumImagePreviewFullViewCell
        let mainImageUrl = URL(string: (self.urlArr[indexPath.item] as! String))
        cell.imgView.kf.setImage(with: mainImageUrl)
        
        cell.senderView?.translatesAutoresizingMaskIntoConstraints = false
        cell.senderView?.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        cell.senderView?.topAnchor.constraint(equalTo: cell.topAnchor, constant: 30).isActive = true
        cell.senderView?.widthAnchor.constraint(equalToConstant: 70).isActive = true
        cell.senderView?.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let sender = sentArray[indexPath.row]
    
        
        let databaseRef = Database.database().reference()
        databaseRef.child("users").child(sender).observeSingleEvent(of: .value) { (snapshot) in
            let dictionary = snapshot.value as? [String: AnyObject]
            let profilePicURL = (dictionary!["profilePic"] as? String)!
            let url = URL(string: profilePicURL)
            DispatchQueue.main.async {
                cell.senderView.kf.setImage(with: url)
            }
        }
        
        cell.contentView.bringSubviewToFront(cell.senderView)
        let tap = UITapGestureRecognizer(target:self, action: #selector(handleTap(_:)))
        tap.numberOfTapsRequired = 1
        cell.isUserInteractionEnabled = true
        cell.senderView.isUserInteractionEnabled = true
        cell.senderView?.asCircle()
        cell.senderView?.addGestureRecognizer(tap)
      
        return cell
    }
    
    func sendRequest(requestTo: String){
        let dbRef = Database.database().reference()
        if let currentUser = Auth.auth().currentUser?.uid{
            let myDataRef = dbRef.child("users").child(currentUser)
            
            myDataRef.observeSingleEvent(of: .value) { (snapshot) in
                let myData = snapshot.value as! Dictionary<String, String>
                let userFriendRequestRef = dbRef.child("FriendRequest").child(requestTo).child(currentUser)
                
                userFriendRequestRef.updateChildValues(myData)
            }
        }
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let databaseRef = Database.database().reference()
        let currentUser = Auth.auth().currentUser
        let uid = currentUser?.uid
        var username: String!
        var userClicked: String!
        
        for cell in myCollectionView.visibleCells{
            let indexPath = myCollectionView.indexPath(for: cell)
            let currentCell = cell as! AlbumImagePreviewFullViewCell
            let uidClicked = sentArray[indexPath!.row]
            if uid == uidClicked{
                return
            }
            
            databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
                let myData = snapshot.value as! NSDictionary
                username = (myData["username"] as! String)
                
                databaseRef.child("users").child(uidClicked).observeSingleEvent(of: .value) { (snapshot) in
                    let myData = snapshot.value as! NSDictionary
                    userClicked = (myData["username"] as! String)
                    databaseRef.child("Friends").child(username).observeSingleEvent(of: .value) { (snapshot) in
                        if snapshot.hasChild(uidClicked){
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let newController = storyboard.instantiateViewController(withIdentifier: "myFriend") as! FriendViewController
                            newController.labelText = userClicked
                            newController.profilePicImage = currentCell.senderView.image
                            self.present(newController, animated: true, completion: nil)
                        }
                        else{
                            let alert = UIAlertController(title: "Not Friends", message: "You are not friends with \(userClicked)", preferredStyle: .alert)
                            let requestAction = UIAlertAction(title: "Send Request", style: .default, handler: { action in
                                self.sendRequest(requestTo: userClicked!)
                            } )
                            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                            alert.addAction(requestAction)
                            alert.addAction(cancelAction)
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                    }
                }
            }
            
        }
        
        
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


class AlbumImagePreviewFullViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var scrollImg: UIScrollView!
    var imgView: UIImageView!
    var senderView: UIImageView!
    
    
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
        
        /**  let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
         doubleTapGest.numberOfTapsRequired = 2
         scrollImg.addGestureRecognizer(doubleTapGest) **/
        
        self.addSubview(scrollImg)
        
        imgView = UIImageView()
        imgView.image = UIImage(named: "user3")
        scrollImg.addSubview(imgView!)
        imgView.contentMode = .scaleAspectFit
        
        senderView = UIImageView()
        scrollImg.addSubview(senderView!)
        senderView.contentMode = .scaleAspectFit
        senderView.frame = self.bounds
        
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
