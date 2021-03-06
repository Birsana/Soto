//
//  FriendCellsViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-10-23.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//
import UIKit
import Foundation
import Firebase
import Alamofire

class FriendCellsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var myCollectionViewFriends: UICollectionView!
    
    var username = ""
    var friendArray = [NSDictionary?]()
    
    var profilePicURL = [String]()
    var usernameArray = [String]()
    
    var userDictionary: [String: String] = [:]
    
    var filtered: [String: String] = [:]
    var isSearching: Bool = false
    let defaultImage = UIImage(named: "account")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/4 - 10, height: 100)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        
        
        viewLoadSetUp()
        myCollectionViewFriends.delegate = self
        myCollectionViewFriends.translatesAutoresizingMaskIntoConstraints = false
        myCollectionViewFriends.dataSource = self
        myCollectionViewFriends.isPagingEnabled = true
        myCollectionViewFriends.collectionViewLayout = flowLayout
        
        
        
        myCollectionViewFriends.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        myCollectionViewFriends.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        myCollectionViewFriends.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        let searchBar = UISearchBar(frame: CGRect(x: 0, y:0, width: myCollectionViewFriends.frame.width, height: 40))
        view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
    }
    func viewLoadSetUp(){
        
        let databaseRef = Database.database().reference()
        let user = Auth.auth().currentUser
        let uid = user?.uid
        
        databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                self.username = (dictionary["username"] as? String)!
                
                databaseRef.child("Friends").child(self.username).queryOrdered(byChild: "username").observe(.childAdded, with: { (snapshot) in
                    //print (snapshot)
                    self.friendArray.append(snapshot.value as? NSDictionary)
                    DispatchQueue.main.async {
                        for friend in self.friendArray{
                            if !self.usernameArray.contains(friend?["username"] as! String){
                                self.usernameArray.append(friend?["username"] as! String)
                            }
                            if !self.profilePicURL.contains(friend?["profilePic"] as! String){
                                self.profilePicURL.append(friend?["profilePic"] as! String)
                            }
                        }
                        
                        self.userDictionary = self.makeDict(arr1: self.usernameArray, arr2: self.profilePicURL)
                        self.myCollectionViewFriends.reloadData()
                        
                    }
                }) { (error) in
                    print(error.localizedDescription
                    )
                    
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
         myCollectionViewFriends.reloadData()
         
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
         myCollectionViewFriends.reloadData()
         
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
    
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ACell", for: indexPath) as! PersonImageCell
        
         
         cell.username?.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
         cell.username?.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
         
         if isSearching{
             let nameToUse = Array(filtered.keys)[indexPath.row]
             cell.username?.text = nameToUse
             
             let profileImageUrl = Array(filtered.values)[indexPath.row]
             
             let url = URL(string: profileImageUrl)
             
             cell.profilePic?.image = nil
             cell.profilePic?.kf.setImage(with: url, placeholder: defaultImage)
             
             cell.profilePic?.asCircle()
             return cell
             
            
         }
         else{
             
             let nameToUse = Array(userDictionary.keys)[indexPath.row]
             cell.username?.text = nameToUse
             
             let profileImageUrl = Array(userDictionary.values)[indexPath.row]
             
             let url = URL(string: profileImageUrl)
             cell.profilePic?.image = nil
             cell.profilePic?.kf.setImage(with: url, placeholder: defaultImage)
             cell.profilePic?.asCircle()
             
             return cell
         }
         
     }
     
     
     
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let newController = storyboard.instantiateViewController(withIdentifier: "myFriend") as! FriendViewController
         let currentcell = myCollectionViewFriends.cellForItem(at: indexPath) as! PersonImageCell
         newController.labelText = currentcell.username?.text
         newController.profilePicImage = currentcell.profilePic?.image

         
         self.present(newController, animated: true, completion: nil)
     }
}
