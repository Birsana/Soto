//
//  FriendRequestsTableViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-14.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import FirebaseMessaging

extension FriendRequestsTableViewController: RequestCellDelegate{
    func declineFriend(requester: String, dbRef: DatabaseReference) {
        let user = Auth.auth().currentUser
        let uid = user?.uid
    
        dbRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String
            
            dbRef.child("FriendRequest").child(username!).queryOrdered(byChild: "username").queryEqual(toValue: requester).observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                let myData = snapshot.value as! NSDictionary
                let componentArray = myData.allKeys
                let toDelete = componentArray.first as? String
        dbRef.child("FriendRequest").child(username!).child(toDelete!).removeValue()
                
                
            })
        }
   
    
        }
    func acceptFriend(requester: String, dbRef: DatabaseReference) {
        
        let user = Auth.auth().currentUser
        let uid = user?.uid
        
        if let currentUser = Auth.auth().currentUser?.uid{
            let myDataRef = dbRef.child("users").child(currentUser)
            //let myDataRef2 = dbRef.child("users").child(requester)
            dbRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let username = value?["username"] as? String
            
            myDataRef.observeSingleEvent(of: .value) { (snapshot) in
                let myData = snapshot.value as! Dictionary<String, String>
                let userFriendRequestRef = dbRef.child("Friends").child(requester).child(currentUser)
                userFriendRequestRef.updateChildValues(myData)
        
                    dbRef.child("users").queryOrdered(byChild: "username").queryEqual(toValue: requester).observeSingleEvent(of: .value, with: { (snapshot) in
                        let myData = snapshot.value as! NSDictionary
                        let componentArray = myData.allKeys
                        let otherUID = componentArray.first as? String
                        
                        let matchingRef = dbRef.child("Friends").child(username!).child(otherUID!)
                        let myDataRef2 = dbRef.child("users").child(otherUID!)
                        
                        myDataRef2.observeSingleEvent(of: .value, with: { (snapshot) in
                            let myData2 = snapshot.value as! Dictionary<String, String>
                            matchingRef.updateChildValues(myData2)
                            
                            self.subscribeNotifications(UID: uid!, friendUID: otherUID!)
                            
                        })
                    })
                    
                    dbRef.child("FriendRequest").child(username!).queryOrdered(byChild: "username").queryEqual(toValue: requester).observeSingleEvent(of: .value, with: { (snapshot) in
                        print(snapshot)
                        let myData = snapshot.value as! NSDictionary
                        let componentArray = myData.allKeys
                        let toDelete = componentArray.first as? String
                        dbRef.child("FriendRequest").child(username!).child(toDelete!).removeValue()
                        UserDefaults.standard.set(true, forKey: "hasFriends")
                        UserDefaults.standard.synchronize()
                    })
                }
                
        
        }
        }
        
        
    }
      
    }
    


class FriendRequestsTableViewController: UITableViewController {
    
    @IBOutlet var table: UITableView!
    var friendRequests = [NSDictionary?]()
    let databaseRef = Database.database().reference()
    let user = Auth.auth().currentUser
    let uid = Auth.auth().currentUser?.uid
    var username = ""
  
   
    func subscribeNotifications(UID: String, friendUID: String){
        let data = ["topics": "\(UID)-\(friendUID)"]
        let dataFriend = ["topics": "\(friendUID)-\(UID)"]
       databaseRef.child("notifications").child(uid!).childByAutoId().updateChildValues(data)
       databaseRef.child("notifications").child(friendUID).childByAutoId().updateChildValues(dataFriend)
       Messaging.messaging().subscribe(toTopic: "\(UID)-\(friendUID)"){ error in
          print("Subscribed")
        }
    }
    
 
    func deleteCell(cell: UITableViewCell){
        if let delIndexPath = tableView.indexPath(for: cell){
            friendRequests.remove(at: delIndexPath.row)
            tableView.deleteRows(at: [delIndexPath], with: .fade)
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.username = (dictionary["username"] as? String)!
                self.databaseRef.child("FriendRequest").child(self.username).observe(.childAdded, with: { (snapshot) in
                    self.friendRequests.append(snapshot.value as? NSDictionary)

                    self.table.insertRows(at: [IndexPath(row:self.friendRequests.count-1, section:0)], with: UITableView.RowAnimation.automatic)
                    
                    
                }) { (error) in
                    print(error.localizedDescription
                    )
                }
                
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
        return self.friendRequests.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! RequestCell
        
         let user: NSDictionary?
        
        user = self.friendRequests[indexPath.row]
        
        cell.Person.text = user?["username"] as? String
        cell.Person.translatesAutoresizingMaskIntoConstraints = false
        cell.Person.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cell.Person.heightAnchor.constraint(equalToConstant: 20).isActive = true
        cell.Person.centerXAnchor.constraint(equalTo: cell.centerXAnchor, constant: 1).isActive = true
        cell.Person.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
        
        cell.profilePic.asCircle()
        
        let profileImageUrl = user?["profilePic"] as! String
        let url = URL(string: profileImageUrl)
        cell.profilePic?.kf.setImage(with: url)
        
        
        cell.myTableViewController = self
        cell.delegate = self
        return cell
        }
 
/*
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
*/
}
