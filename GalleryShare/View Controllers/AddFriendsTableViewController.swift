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
        let databaseRef = Database.database().reference()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        let user = Auth.auth().currentUser
        let uid = user?.uid
        
        databaseRef.child("users").queryOrdered(byChild: "username").observe(.childAdded, with: { (snapshot) in
            
            self.usersArray.append(snapshot.value as? NSDictionary)
            self.searchUsers.insertRows(at: [IndexPath(row:self.usersArray.count-2, section:0)], with: UITableView.RowAnimation.automatic)
            
        }) { (error) in
            print(error.localizedDescription
            )
        }
        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.currentUsername = value?["username"] as! String
            
            databaseRef.child("Friends").child(self.currentUsername).queryOrdered(byChild: "username").observe(.childAdded) { (snapshot) in
                self.existingFriendsArray.append(snapshot.value as? NSDictionary)
            }
            
        }
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
                print(user?["username"])
                print(cell.Person.text)
            }
        }
        
        if let picURL = user?["profilePic"] as? String{
              let url = NSURL(string: picURL)
                  URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
                      
                      if error != nil{
                          return
                      }
                      DispatchQueue.main.async {
                          cell.profilePic?.image = UIImage(data: data!)
                      }
                      
                  }).resume()
        }
        
        
        cell.delegate = self
        return cell
    }
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        //update the search results
        filterContent(searchText: self.searchController.searchBar.text!)
    }
    func filterContent(searchText:String){
        self.filteredUsers = self.usersArray.filter{ user in
            let username = user!["username"] as? String
            return(username?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    
    
}
