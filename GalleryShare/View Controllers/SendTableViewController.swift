//
//  SendTableViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-12.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

extension SendTableViewController: SendCellDelegate{
    func sendPic(sendTo: String) {
        
        let currentUser = Auth.auth().currentUser
        let StorageRef = Storage.storage().reference()
        let DatabaseRef = Database.database().reference()
        let imageData = picToSend?.jpegData(compressionQuality: 1.0)
        var picURL: String?
        let imageName = NSUUID().uuidString
        let fromID = currentUser!.uid
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        var toID: String?
        let picToSendStorageRef = StorageRef.child("imageMessages").child("\(imageName).jpg")
        
        if picsToSend.count > 0{
            for image in picsToSend{
                let imageDataM = image.jpegData(compressionQuality: 1.0)
                let imageNameM = NSUUID().uuidString
                let picToSendStorageRefM = StorageRef.child("imageMessages").child("\(imageNameM).jpg")
                DatabaseRef.child("usernames").observeSingleEvent(of: .value) { (snapshot) in
                    let myData = snapshot.value as! NSDictionary
                    toID = myData[sendTo] as! String
                    let uploadTask = picToSendStorageRefM.putData(imageDataM!, metadata: nil)
                    {metadata, error in
                        
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
                            let values = ["imageURL": picURL, "toID": toID]
                            DatabaseRef.child("sentPics").child(fromID).childByAutoId().updateChildValues(values)
                        }
                    }
                }
            }
        }
        else{
            DatabaseRef.child("usernames").observeSingleEvent(of: .value) { (snapshot) in
                let myData = snapshot.value as! NSDictionary
                toID = myData[sendTo] as! String
                let uploadTask = picToSendStorageRef.putData(imageData!, metadata: nil)
                {metadata, error in
                    
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
                        DatabaseRef.child("sentPics").child(fromID).childByAutoId().updateChildValues(values)
                    }
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}

class SendTableViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet var table: UITableView!
    
    var friends = [NSDictionary?]()
    let databaseRef = Database.database().reference()
    let user = Auth.auth().currentUser
    var picToSend: UIImage?
    var passedIndex = IndexPath()
    var username = ""
    var nameAtCell : String?
    var passedArray = [UIImage]()
    var picsToSend = [UIImage]()
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredUsers = [NSDictionary?]()
    
    
    
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
                
                self.databaseRef.child("Friends").child(self.username).observe(.childAdded, with: { (snapshot) in
                    
                    self.friends.append(snapshot.value as? NSDictionary)
                    self.table.insertRows(at: [IndexPath(row:self.friends.count-1, section:0)], with: UITableView.RowAnimation.automatic)
                    
                    
                }) { (error) in
                    print(error.localizedDescription
                    )
                    
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SendCell", for: indexPath) as! SendCell
        
        let user: NSDictionary?
        if searchController.isActive && searchController.searchBar.text != ""{
            user = filteredUsers[indexPath.row]
        }
        else{
            user = self.friends[indexPath.row]
        }
        cell.username.text = user?["username"] as? String
        nameAtCell = user?["username"] as? String
        
        cell.delegate = self
        return cell
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != ""{
            return filteredUsers.count
        }
        return self.friends.count
    }
    func updateSearchResults(for searchController: UISearchController) {
        //update the search results
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    func filterContent(searchText:String){
        self.filteredUsers = self.friends.filter{ user in
            let username = user!["username"] as? String
            return(username?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    
    
}
