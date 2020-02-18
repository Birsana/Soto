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
                    toID = (myData[sendTo] as! String)
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
                            let values = ["imageURL": picURL, "toID": toID, "timestamp": timestamp.stringValue]
                            let values2 = ["imageURL": picURL, "fromID": fromID, "timestamp": timestamp.stringValue]
                            DatabaseRef.child("sentPics").child(fromID).childByAutoId().updateChildValues(values as [AnyHashable : Any])
                            DatabaseRef.child("sentPicsRef").child(toID!).childByAutoId().updateChildValues(values2 as [AnyHashable : Any])
                        }
                    }
                }
            }
        }
        else{
            DatabaseRef.child("usernames").observeSingleEvent(of: .value) { (snapshot) in
                let myData = snapshot.value as! NSDictionary
                toID = (myData[sendTo] as! String)
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
                        let values = ["imageURL": picURL, "toID": toID, "timestamp": timestamp.stringValue]
                        let values2 = ["imageURL": picURL, "fromID": fromID, "timestamp": timestamp.stringValue]
                        DatabaseRef.child("sentPics").child(fromID).childByAutoId().updateChildValues(values as [AnyHashable : Any])
                        DatabaseRef.child("sentPicsRef").child(toID!).childByAutoId().updateChildValues(values2 as [AnyHashable : Any])
                    }
                }
            }
        }
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        reloadStuff.shouldReload = true
    }
    
    
}

class SendTableViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet var table: UITableView!
    
    var friends = [NSDictionary?]()
    let databaseRef = Database.database().reference()
    let user = Auth.auth().currentUser
    var picToSend: UIImage?
    var username = ""
    var nameAtCell : String?
    var picsToSend = [UIImage]()
    var FriendsToSend = [String]()

    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredUsers = [NSDictionary?]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        //searchController.dimsBackgroundDuringPresentation = false
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.table.sectionHeaderHeight = 43.5
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.table.bounds.width, height: 43.5))
        let sendButton = UIButton(type: .system)
        sendButton.frame = CGRect(x: self.table.bounds.width/2 - 30, y: 10, width: 60, height: 43.5)
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.black, for: .normal)
        sendButton.addTarget(self, action: #selector(tapFunction(sender:)), for: .touchUpInside)
        view.addSubview(sendButton)
        return view
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
        
        cell.sendLabel = UILabel(frame: CGRect(x: cell.frame.maxX - 40, y: 8, width: 30, height: 30))
        
        cell.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -20).isActive = true
        cell.sendLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        cell.sendLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cell.sendLabel.layer.cornerRadius = cell.sendLabel.frame.width/2
        cell.sendLabel.layer.masksToBounds = true
        cell.sendLabel.layer.borderWidth = 1
        cell.sendLabel.layer.borderColor = UIColor.black.cgColor
        
        cell.addSubview(cell.sendLabel)
        
        cell.username.text = user?["username"] as? String
        nameAtCell = user?["username"] as? String
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let currentCell = myCollectionView.cellForItem(at: indexPath) as! SendCell
        let currentCell = tableView.cellForRow(at: indexPath) as! SendCell
        let friend = currentCell.username.text
        if self.FriendsToSend.contains(friend!){
            let itemToRemove = friend
            while self.FriendsToSend.contains(itemToRemove!) {
                if let itemToRemoveIndex = self.FriendsToSend.firstIndex(of: itemToRemove!) {
                    self.FriendsToSend.remove(at: itemToRemoveIndex)
                    currentCell.sendLabel.backgroundColor = UIColor.clear
                }
            }
        }
        else{
            self.FriendsToSend.append(friend!)
            currentCell.sendLabel.backgroundColor = UIColor.blue
        }
    }
    
    @objc func tapFunction(sender:UIButton!) {
        if FriendsToSend.count > 0{
            for user in FriendsToSend{
                sendPic(sendTo: user)
            }
        }
        else{
            print("no can do")
            return
        }
        
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
