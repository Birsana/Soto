//
//  SendAlbumTableViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-22.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase


class SendAlbumTableViewController: UITableViewController, UISearchResultsUpdating, SendAlbumCellDelegate {
    func sendPic(album: String) {
        let currentUser = Auth.auth().currentUser
        let StorageRef = Storage.storage().reference()
        let DatabaseRef = Database.database().reference()
        let imageData = picToSend?.jpegData(compressionQuality: 1.0)
        var picURL: String?
        let imageName = NSUUID().uuidString
        let fromID = currentUser!.uid
        var toID: String?
        let picToSendStorageRef = StorageRef.child("albumMessages").child("\(imageName).jpg")
        
        if picsToSend.count > 0{
            for image in picsToSend{
                let imageDataM = image.jpegData(compressionQuality: 1.0)
                let imageNameM = NSUUID().uuidString
                let picToSendStorageRefM = StorageRef.child("albumMessages").child("\(imageNameM).jpg")

                DatabaseRef.child("Albums").child(username).queryOrdered(byChild: "name").queryEqual(toValue: album).observeSingleEvent(of: .value) { (snapshot) in
                               let myData = snapshot.value as! NSDictionary
                               let componentArray = myData.allKeys
                               toID = componentArray.first as? String
                               let uploadTask = picToSendStorageRefM.putData(imageDataM!, metadata: nil) { (metadata, error) in
                                   
                                   guard let metadata = metadata else {
                                       // Uh-oh, an error occurred!
                                       return
                                   }
                                   let size = metadata.size
                                   picToSendStorageRefM.downloadURL { (url, error) in
                                       guard let downloadURL = url
                                           
                                           else {
                                               // Uh-oh, an error occurred!
                                               return
                                       }
                                       picURL = downloadURL.absoluteString
                                       let values = ["imageURL": picURL, "fromID": fromID]
                                       DatabaseRef.child("sentAlbumPics").child(toID!).childByAutoId().updateChildValues(values)
                                   }
                                   
                               }
                               
                           }
            }
        }
        else{
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
                        let values = ["imageURL": picURL, "fromID": fromID]
                        DatabaseRef.child("sentAlbumPics").child(toID!).childByAutoId().updateChildValues(values)
                    }
                    
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
    //var passedIndex = IndexPath()
    //var passedArray = [UIImage]()
    var username = ""
    
    var picsToSend = [UIImage]()
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredAlbums = [NSDictionary?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
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
        if searchController.isActive && searchController.searchBar.text != ""{
            return filteredAlbums.count
        }
        return self.albums.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendAlbumCell", for: indexPath) as! SendAlbumCell
        
        let album: NSDictionary?
        if searchController.isActive && searchController.searchBar.text != ""{
            album = filteredAlbums[indexPath.row]
        }
        else{
            album = self.albums[indexPath.row]
        }
        cell.albumName.text = album?["name"] as? String
        cell.delegate = self
        return cell
    }
    func updateSearchResults(for searchController: UISearchController) {
        //update the search results
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    func filterContent(searchText:String){
        self.filteredAlbums = self.albums.filter{ album in
            let albumName = album!["name"] as? String
            return(albumName?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    
    
}

//CHANGE FIREBASE LAYOUT SEND ALBUM PICS
