//
//  AlbumContainerViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-11-08.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Firebase

class AlbumContainerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
           searchBar.setShowsCancelButton(true, animated: true)
           isSearching = true
       }
       func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
           searchBar.setShowsCancelButton(false, animated: true)
           isSearching = false
       }
       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.text = nil
           searchBar.endEditing(true)
           isSearching = false
           myCollectionView.reloadData()
           
       }
       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           let search = searchBar.text!
           filtered.removeAll(keepingCapacity: false)
           filtered = userDictionary.filter { $0.key.lowercased().contains(search.lowercased())}
        
           
           if search == ""{
               isSearching = false
               
           }
         else{
        isSearching = true
         }
           //isSearching = (filtered.count ==  0) ? false: true
           myCollectionView.reloadData()
           
       }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching{
            return filtered.count
        }
        else{
        return self.userDictionary.count
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           let cellWidth : CGFloat = 97
           
           let numberOfCells = floor(self.view.frame.size.width / cellWidth)
           let edgeInsets = (self.view.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)
           
           return UIEdgeInsets(top: 15, left: edgeInsets, bottom: 0, right: edgeInsets)
       }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = myCollectionView.cellForItem(at: indexPath) as! AlbumPersonCell
        let userClicked = currentCell.username.text
        var uidClicked: String!
        let databaseRef = Database.database().reference()
        let currentUser = Auth.auth().currentUser
        let uid = currentUser?.uid
        
        var username: String!

        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            let myData = snapshot.value as! NSDictionary
            username = (myData["username"] as! String)
            if userClicked == username{
                return
            }
            databaseRef.child("usernames").observeSingleEvent(of: .value) { (snapshot) in
                let myData = snapshot.value as! NSDictionary
                uidClicked = (myData[userClicked] as! String)
                databaseRef.child("Friends").child(username).observeSingleEvent(of: .value) { (snapshot) in
                    if snapshot.hasChild(uidClicked){
                         let storyboard = UIStoryboard(name: "Main", bundle: nil)
                         let newController = storyboard.instantiateViewController(withIdentifier: "myFriend") as! FriendViewController
                        newController.labelText = currentCell.username?.text
                        newController.profilePicImage = currentCell.profilePic?.image
                        self.present(newController, animated: true, completion: nil)
                    }
                    else{
                        let alert = UIAlertController(title: "Not Friends", message: "You are not friends with \(currentCell.username.text!)", preferredStyle: .alert)
                        let requestAction = UIAlertAction(title: "Send Request", style: .default, handler: { action in
                            self.sendRequest(requestTo: userClicked!)
                        } )
                        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                        alert.addAction(requestAction)
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)

                    }
                }
                
            }
        }
          
       }
    
    func sendRequest(requestTo: String){
        let dbRef = Database.database().reference()
        if let currentUser = Auth.auth().currentUser?.uid{
            let myDataRef = dbRef.child("users").child(currentUser)
            
            myDataRef.observeSingleEvent(of: .value) { (snapshot) in
                let myData = snapshot.value as! Dictionary<String, String>
                let userFriendRequestRef = dbRef.child("FriendRequest").child(requestTo).child(currentUser)
                
                userFriendRequestRef.updateChildValues(myData)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nocrash", for: indexPath) as! AlbumPersonCell
         cell.username.translatesAutoresizingMaskIntoConstraints = false
         cell.username?.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
         cell.username?.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
               
               cell.layer.borderWidth = 2
               
               
               
               if isSearching{
                //print(filtered.keys)
                   let nameToUse = Array(filtered.keys)[indexPath.row]
                   cell.username?.text = nameToUse
                   
                   let profileImageUrl = Array(filtered.values)[indexPath.row]
                   
                   let url = URL(string: profileImageUrl)
                   
                    cell.profilePic?.image = nil
                   cell.profilePic?.kf.setImage(with: url)
                   
                   cell.profilePic?.asCircle()
                   return cell
                   
                  
               }
               else{
                   
                   let nameToUse = Array(userDictionary.keys)[indexPath.row]
                   cell.username?.text = nameToUse
                   
                   let profileImageUrl = Array(userDictionary.values)[indexPath.row]
                   
                   let url = URL(string: profileImageUrl)
                   cell.profilePic?.image = nil
                   cell.profilePic?.kf.setImage(with: url)
                   cell.profilePic?.asCircle()
                   
                   return cell
               }
               
    }
    

    @IBOutlet weak var myCollectionView: UICollectionView!
    var username = ""
    var friendArray = [NSDictionary?]()
    
    var profilePicURL = [String]()
    var usernameArray = [String]()
    
    var userDictionary: [String: String] = [:]
    
    var filtered: [String: String] = [:]
    var isSearching: Bool = false
    
    var albumID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/4 - 10, height: 100)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        
        myCollectionView.delegate = self
        myCollectionView.translatesAutoresizingMaskIntoConstraints = false
        myCollectionView.dataSource = self
        myCollectionView.isPagingEnabled = true
        myCollectionView.collectionViewLayout = flowLayout
        //myCollectionViewFriends.layer.borderWidth = 2
        //myCollectionViewFriends.layer.cornerRadius = 8
        // myCollectionViewFriends.layer.borderColor = UIColor.black.cgColor
        
        
        myCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        myCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        myCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        
        let searchBar = UISearchBar(frame: CGRect(x: 0, y:0, width: myCollectionView.frame.width, height: 40))
               view.addSubview(searchBar)
               searchBar.delegate = self
               searchBar.backgroundImage = UIImage()
        
        viewLoadSetUp()
    }
    
    func viewLoadSetUp(){
        let databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser
        let uid = Auth.auth().currentUser?.uid
        databaseRef.child("AlbumsRef").child(albumID!).observeSingleEvent(of: .value) { (snapshot) in
            let myData = snapshot.value as! NSDictionary
            self.usernameArray = Array(myData.allValues as! [String])
                for user in self.usernameArray{
                    databaseRef.child("usernames").observe(.value) { (snapshot) in
                         let myData = snapshot.value as! NSDictionary
                        let id = myData[user] as! String
                        databaseRef.child("users").child(id).observeSingleEvent(of: .value) { (snapshot) in
                            let myData = snapshot.value as! NSDictionary
                            let picURL = myData["profilePic"] as! String
                            self.profilePicURL.append(myData["profilePic"] as! String)
                            if self.profilePicURL.count == self.usernameArray.count{
                                self.userDictionary = self.makeDict(arr1: self.usernameArray, arr2: self.profilePicURL)
                                DispatchQueue.main.async {
                                    print(self.userDictionary.count)
                                    self.myCollectionView.reloadData()
                                }
                            }
                        }
                    }
                }
        }
        
    }
    func makeDict(arr1: [String], arr2: [String]) -> [String: String]{
        var dictionary: [String: String] = [:]
        for (index, element) in arr1.enumerated() {
            dictionary[element] = arr2[index]
        }
        return dictionary
    }

}
