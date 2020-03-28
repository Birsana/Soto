//
//  AddFriendsTableViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-11.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage

extension AddFriendsTableViewController: FriendCellDelegate{
    func addFriend(friend: String, dbRef: DatabaseReference) {
        if let currentUser = Auth.auth().currentUser?.uid{
            let myDataRef = dbRef.child("users").child(currentUser)
            
            myDataRef.observeSingleEvent(of: .value) { (snapshot) in
                let myData = snapshot.value as! Dictionary<String, String>
                let userFriendRequestRef = dbRef.child("FriendRequest").child(friend).child(currentUser)
                userFriendRequestRef.updateChildValues(myData)
                
            }
        }
    }
}

class AddFriendsTableViewController: UITableViewController, UISearchResultsUpdating {
    var currentUsername = ""
    @IBOutlet var searchUsers: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var usersArray = [NSDictionary?]()
    var filteredUsers = [NSDictionary?]()
    var existingFriendsArray = [NSDictionary?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive && searchController.searchBar.text != ""{
            return filteredUsers.count
        }
        return self.usersArray.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        
        let user: NSDictionary?
        if searchController.isActive && searchController.searchBar.text != ""{
            user = filteredUsers[indexPath.row]
        }
        else{
            user = self.usersArray[indexPath.row]
        }
        if user?["username"] as? String != self.currentUsername{
            cell.Person.text = user?["username"] as? String
        }
        for user in existingFriendsArray{
            if user?["username"] as? String == cell.Person.text{
                cell.addFriend.isHidden = true
                
            }
        }
        
        
        cell.Person.translatesAutoresizingMaskIntoConstraints = false
        cell.Person.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        cell.Person.widthAnchor.constraint(equalToConstant: 75).isActive = true
        cell.Person.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 50).isActive = true
        
        let picURL = URL(string:((user?["profilePic"] as? String)!))
        cell.profilePic.kf.setImage(with: picURL)
        cell.profilePic.translatesAutoresizingMaskIntoConstraints = false
        cell.profilePic.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cell.profilePic.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cell.profilePic.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        cell.profilePic.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
        //cell.profilePic.asCircle()
        
        
        
        cell.delegate = self
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {    
        //update the search results
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    func filterContent(searchText:String){
        
        let searchTextLower = searchText.lowercased()
        self.filteredUsers.removeAll()
        let databaseRef = Database.database().reference()
        databaseRef.child("users").queryOrdered(byChild: "username").queryStarting(atValue: searchTextLower).queryEnding(atValue: "\(searchTextLower)\u{f8ff}").queryLimited(toLast: 5).observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            self.filteredUsers.append(snapshot.value as? NSDictionary)
            self.tableView.reloadData()
        }) { (error) in
            print(error.localizedDescription
            )
        }
        
        
    }
    
}
