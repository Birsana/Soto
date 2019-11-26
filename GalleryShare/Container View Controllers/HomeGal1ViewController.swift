//
//  HomeGal1ViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-11-14.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
class HomeGal1ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    public var screenHeightHalf: CGFloat {
        return UIScreen.main.bounds.height/3
    }
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    //fileprivate var previousPreheatRect = CGRect.zero
    
    
    var numFetch = 0
    
    var myCollectionView: UICollectionView!
    var imageArray=[UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.includeAssetSourceTypes = .typeiTunesSynced
        allPhotosOptions.includeAssetSourceTypes = .typeUserLibrary
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
        numFetch = fetchResult.count
        
        self.title = "Photos"
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        
        var thisFrame = CGRect(x: 0, y: 0,  width: self.view.frame.width, height: self.view.frame.height)
        myCollectionView = UICollectionView(frame: thisFrame, collectionViewLayout: layout)
        myCollectionView.collectionViewLayout = layout
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor=UIColor.white
        myCollectionView.alwaysBounceVertical = true
        
        
        
        self.view.addSubview(myCollectionView)
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numFetch
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        
        thumbnailSize = CGSize(width: cell.frame.width, height: cell.frame.height)
        
        let asset = fetchResult.object(at: indexPath.item)
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ImagePreviewVC()
        vc.passedContentOffset = indexPath
        vc.fetchResult = self.fetchResult
        self.present(vc, animated: true, completion: nil)
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
}
