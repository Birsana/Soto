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

class FriendCellsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let search = searchBar.text!
        print(search)
        filtered.removeAll(keepingCapacity: false)
        filtered = usernameArray.filter { $0.contains(search.lowercased())}
        print(filtered)
        print(usernameArray)
        isSearching = (filtered.count ==  0) ? false: true
        myCollectionViewFriends.reloadData()
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching{
            
            print("Count is", filtered.count)
            return filtered.count
        }
        else{
            return self.friendArray.count
        }
    }
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidth : CGFloat = 97

        let numberOfCells = floor(self.view.frame.size.width / cellWidth)
        let edgeInsets = (self.view.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)

        return UIEdgeInsets(top: 15, left: edgeInsets, bottom: 0, right: edgeInsets)
    }
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

       /** let noOfCellsInRow = self.friendArray.count

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow)) **/

        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ACell", for: indexPath) as! PersonImageCell
        cell.username?.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        cell.username?.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        
        cell.username?.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        cell.username?.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        
        cell.profilePic?.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        cell.profilePic?.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
       
        if isSearching{
            let nameToUse = filtered[indexPath.row]
            cell.username?.text = nameToUse
            return cell
            
        }
        else{
       
       
        let nameToUse = usernameArray[indexPath.row]
        cell.username?.text = nameToUse
        
        let profileImageUrl = profilePicURL[indexPath.row]
        
        
            
        let url = NSURL(string: profileImageUrl)
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            
            if error != nil{
                return
            }
            DispatchQueue.main.async {
                cell.profilePic?.image = UIImage(data: data!)
            }
            
        }).resume()
        
        cell.profilePic?.asCircle()
        return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newController = storyboard.instantiateViewController(withIdentifier: "myFriend") as! FriendViewController
        newController.labelText = usernameArray[indexPath.row]
        self.present(newController, animated: true, completion: nil)
    }
   
    
    

    @IBOutlet weak var myCollectionViewFriends: UICollectionView!
    
    var username = ""
    var friendArray = [NSDictionary?]()

    var profilePicURL = [String]()
    var usernameArray = [String]()
    
    var filtered = [String]()
    var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width/4 - 10, height: 100)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        
        
        viewLoadSetUp()
        myCollectionViewFriends.delegate = self
        myCollectionViewFriends.translatesAutoresizingMaskIntoConstraints = false
        myCollectionViewFriends.dataSource = self
        myCollectionViewFriends.isPagingEnabled = true
        myCollectionViewFriends.collectionViewLayout = flowLayout
        //myCollectionViewFriends.layer.borderWidth = 2
        myCollectionViewFriends.layer.cornerRadius = 8
       // myCollectionViewFriends.layer.borderColor = UIColor.black.cgColor
        
        let searchBar = UISearchBar(frame: CGRect(x: 0, y:0, width: myCollectionViewFriends.frame.width, height: 40))
        view.addSubview(searchBar)
        searchBar.delegate = self
    }
    func viewLoadSetUp(){
           
           let databaseRef = Database.database().reference()
           let user = Auth.auth().currentUser
           let uid = Auth.auth().currentUser?.uid
           
           databaseRef.child("users").child(uid!).observeSingleEvent(of: .value) { (snapshot) in
               if let dictionary = snapshot.value as? [String: AnyObject]{
                   self.username = (dictionary["username"] as? String)!
                   
                   databaseRef.child("Friends").child(self.username).queryOrdered(byChild: "username").observe(.childAdded, with: { (snapshot) in
                       //print (snapshot)
                       let myData = snapshot.value as! NSDictionary
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
                           
                           self.myCollectionViewFriends.reloadData()
                           
                       }
                       
                       
                   }) { (error) in
                       print(error.localizedDescription
                       )
                       
                   }
               }
           }
           
           
       }
}
