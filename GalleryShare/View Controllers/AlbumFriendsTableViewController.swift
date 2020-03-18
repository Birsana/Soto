//
//  AlbumFriendsTableViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-18.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase


extension AlbumFriendsTableViewController: AlbumCellDelegate{
    func appendFriend(friendToAdd: String, add: Bool) {
        if add{
            addedFriends.append(friendToAdd)
        }
        else{
            while addedFriends.contains(friendToAdd) {
                if let itemToRemoveIndex = addedFriends.firstIndex(of: friendToAdd) {
                    addedFriends.remove(at: itemToRemoveIndex)
                }
            }
        }
    }
    
    
}


class AlbumFriendsTableViewController: UITableViewController, UISearchResultsUpdating {
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
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var usersArray = [NSDictionary?]()
    var filteredUsers = [NSDictionary?]()
    var addedFriends = [String]()
    
    @IBAction func done(_ sender: Any) {
        if let presenter = presentingViewController as? CreateAlbumViewController {
            presenter.friendsToShareWith = addedFriends
        }
        self.dismiss(animated: false, completion: nil)
        
        
    }
    
    @IBOutlet var addFriends: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let databaseRef = Database.database().reference()
        searchController.searchResultsUpdater = self
        //searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        let user = Auth.auth().currentUser
        let uid = user?.uid
        
        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let authUsername = value?["username"] as! String
            
            databaseRef.child("Friends").child(authUsername).queryOrdered(byChild: "username").observe(.childAdded) { (snapshot) in
                self.usersArray.append(snapshot.value as? NSDictionary)
                self.addFriends.insertRows(at: [IndexPath(row:self.usersArray.count-1, section:0)], with: UITableView.RowAnimation.automatic)
            }
            
        }
        
    }
    
    // MARK: - Table view data source
    
    //MAKE THE TABLE VIEW THE CONTAINER
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != ""{
            return filteredUsers.count
        }
        return self.usersArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
        let user: NSDictionary?
        
        if searchController.isActive && searchController.searchBar.text != ""{
            user = filteredUsers[indexPath.row]
        }
        else{
            user = self.usersArray[indexPath.row]
        }
        cell.username.text = user?["username"] as? String
        cell.username.translatesAutoresizingMaskIntoConstraints = false
        cell.username.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        cell.username.widthAnchor.constraint(equalToConstant: 75).isActive = true
        cell.username.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 50).isActive = true
        
        cell.checkbox.borderStyle = .square
        cell.checkbox.checkedBorderColor = .black
        cell.checkbox.uncheckedBorderColor = .black
        cell.checkbox.checkmarkStyle = .tick
        
        cell.checkbox.translatesAutoresizingMaskIntoConstraints = false
        cell.checkbox.widthAnchor.constraint(equalToConstant: 30).isActive = true
        cell.checkbox.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cell.checkbox.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -10).isActive = true
        cell.checkbox.topAnchor.constraint(equalTo: cell.topAnchor, constant: (cell.bounds.height-30)/2).isActive = true
        
        if addedFriends.contains(cell.username.text!){
            cell.checkbox.isChecked = true
        }
        
        
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: cell.bounds.size.width, height: 40))
        title.textColor = UIColor.black
        title.textAlignment = .center
        cell.contentView.addSubview(title)
        
        let profileUrl = user?["profilePic"] as! String
        let url = URL(string: profileUrl)
        cell.profilePic.kf.setImage(with: url)
        
        cell.profilePic.translatesAutoresizingMaskIntoConstraints = false
        cell.profilePic.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cell.profilePic.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cell.profilePic.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        cell.profilePic.leftAnchor.constraint(equalTo: cell.leftAnchor).isActive = true
        
        cell.delegate = self
        return cell
    }
    
    
    
}
