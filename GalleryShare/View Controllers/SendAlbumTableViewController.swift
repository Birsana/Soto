//
//  SendAlbumTableViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-22.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase


class SendAlbumTableViewController: UITableViewController, SendAlbumCellDelegate {
    func sendPic(album: String) {
        let currentUser = Auth.auth().currentUser
        let StorageRef = Storage.storage().reference()
        let DatabaseRef = Database.database().reference()
        let imageData = picToSend!.jpegData(compressionQuality: 1.0)
        var picURL: String?
        let imageName = NSUUID().uuidString
        let fromID = currentUser!.uid
        var toID: String?
        let picToSendStorageRef = StorageRef.child("albumMessages").child("\(imageName).jpg")
        
        DatabaseRef.child("Albums").child(username).queryOrdered(byChild: "name").queryEqual(toValue: album).observeSingleEvent(of: .value) { (snapshot) in
            let myData = snapshot.value as! NSDictionary
            let componentArray = myData.allKeys
            toID = componentArray.first as? String
            let uploadTask = picToSendStorageRef.putData(imageData!, metadata: nil) { (metadata, error) in
                
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                let size = metadata.size
                picToSendStorageRef.downloadURL { (url, error) in
                    guard let downloadURL = url
                        
                        else {
                            // Uh-oh, an error occurred!
                            return
                    }
                    picURL = downloadURL.absoluteString
                    let values = ["imageURL": picURL, "toID": toID]
                    DatabaseRef.child("sentAlbumPics").child(fromID).childByAutoId().updateChildValues(values)
                }
                
            }
            
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBOutlet var table: UITableView!
    
    var albums = [NSDictionary?]()
    var databaseRef = Database.database().reference()
    let user = Auth.auth().currentUser
    var picToSend: UIImage?
    var passedIndex = IndexPath()
    var passedArray = [UIImage]()
    var username = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let uid = Auth.auth().currentUser?.uid
        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.username = (dictionary["username"] as? String)!
                
                self.databaseRef.child("Albums").child(self.username).observe(.childAdded) { (snapshot) in
                    self.albums.append(snapshot.value as? NSDictionary)
                    self.table.insertRows(at: [IndexPath(row:self.albums.count-1, section:0)], with: UITableView.RowAnimation.automatic)
                }
            }
        }
        
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.albums.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendAlbumCell", for: indexPath) as! SendAlbumCell
        
        let album: NSDictionary?
        album = self.albums[indexPath.row]
        cell.albumName.text = album?["name"] as? String
        cell.delegate = self
        return cell
    }
    
    
    
}
