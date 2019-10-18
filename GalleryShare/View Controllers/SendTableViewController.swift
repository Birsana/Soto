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
        var StorageRef = Storage.storage().reference()
        var DatabaseRef = Database.database().reference()
        let imageData = picToSend!.jpegData(compressionQuality: 1.0)
        var picURL: String?
        let imageName = NSUUID().uuidString
        let fromID = currentUser!.uid
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        var toID: String?
        let picToSendStorageRef = StorageRef.child("users").child("imageMessages").child("\(imageName).jpg")
        
        
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
                                //DatabaseRef.child("sentPics").childByAutoId().updateChildValues(values)
                                DatabaseRef.child("sentPics").child(fromID).childByAutoId().updateChildValues(values)
                             }
                         }
            
        }
    
        //if let vc = (storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? MainTabViewController) {
          //  self.present(vc, animated: false, completion: nil)
       // }
        self.dismiss(animated: true, completion: nil)

    }
    
    
}

class SendTableViewController: UITableViewController {
    
    @IBOutlet var table: UITableView!
    
    var friends = [NSDictionary?]()
    var databaseRef = Database.database().reference()
    let user = Auth.auth().currentUser
    var picToSend: UIImage?
    var passedIndex = IndexPath()
    var username = ""
    var nameAtCell : String?
    var passedArray = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
           
           user = self.friends[indexPath.row]
           
           cell.username.text = user?["username"] as? String
           nameAtCell = user?["username"] as? String
           //cell.myTableViewController = self
        
           cell.delegate = self
           return cell
           }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.friends.count
    }

  
}
