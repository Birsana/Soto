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
    
    
    
    
   
    @IBOutlet var searchUsers: UITableView!
    
 let searchController = UISearchController(searchResultsController: nil)
    
 var usersArray = [NSDictionary?]()
    var filteredUsers = [NSDictionary?]()
    
    var databaseRef = Database.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        databaseRef.child("users").queryOrdered(byChild: "username").observe(.childAdded, with: { (snapshot) in
          
            self.usersArray.append(snapshot.value as? NSDictionary)
            self.searchUsers.insertRows(at: [IndexPath(row:self.usersArray.count-1, section:0)], with: UITableView.RowAnimation.automatic)
            
            
        }) { (error) in
         print(error.localizedDescription
            )
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        // Configure the cell...
        
        
        let user: NSDictionary?
if searchController.isActive && searchController.searchBar.text != ""{
    user = filteredUsers[indexPath.row]
        }
else{
    user = self.usersArray[indexPath.row]
        }
        
        cell.Person.text = user?["username"] as? String
        
        
       
        cell.delegate = self
        return cell
    }
    
 /**   class friendCell: UITableViewCell{
        
        @IBOutlet weak var addFriend: UIButton!
        
        
    } **/
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
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
