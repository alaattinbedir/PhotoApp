//
//  PhotoAlbumViewController.swift
//  PhotoApp
//
//  Created by Alaattin Bedir on 2.03.2019.
//  Copyright © 2019 Alaattin Bedir. All rights reserved.
//

import UIKit
import Photos
import ObjectMapper
import SnapKit
import SVProgressHUD

let reuseIdentifier = "PhotoCell"

class PhotoAlbumViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Vars & Lets
    private var albumFound : Bool = false
    private var assetCollection: PHAssetCollection = PHAssetCollection()
    private var photosAsset: PHFetchResult<PHAsset>!
    private var assetThumbnailSize:CGSize!
    private var imageArray = [UIImage]()
    var albums: PHAssetCollection = PHAssetCollection()
    var albumName: String?
    private let numberOfCellsPerRow: CGFloat = 4
    var selectedCollection: PHAssetCollection?
    private var photos: PHFetchResult<PHAsset>!
    private var numbeOfItemsInRow = 4
    
    

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    
    // MARK: - Actions
    @IBAction func camera(_ sender: Any) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            //load the camera interface
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        }else{
            //no camera available
            let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(alertAction)in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func photoAlbum(_ sender: Any) {
        let picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.delegate = self
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Private methods
//    private func grabPhotos(){
//        imageArray = []
//
//        DispatchQueue.global(qos: .background).async {
//            print("This is run on the background queue")
//            let imgManager=PHImageManager.default()
//
//            let requestOptions=PHImageRequestOptions()
//            requestOptions.isSynchronous=true
//            requestOptions.deliveryMode = .highQualityFormat
//
//            let fetchOptions=PHFetchOptions()
//            fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
//
//            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//            print(fetchResult)
//            print(fetchResult.count)
//            if fetchResult.count > 0 {
//                for i in 0..<fetchResult.count{
//                    imgManager.requestImage(for: fetchResult.object(at: i) as PHAsset, targetSize: CGSize(width:500, height: 500),contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
//
//                        if let image = image {
//                            self.imageArray.append(image)
//                        }
//                    })
//                }
//            } else {
//                print("You got no photos.")
//            }
//            print("imageArray count: \(self.imageArray.count)")
//
//            DispatchQueue.main.async {
//                print("This is run on the main queue, after the previous code in outer block")
//                self.collectionView.reloadData()
//            }
//        }
//    }
    
    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.prepareCollectionView()
        self.fetchImagesFromGallery(collection: self.selectedCollection)
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.scrollDirection == .vertical ? flowLayout.minimumInteritemSpacing : flowLayout.minimumLineSpacing
            let cellWidth = (view.frame.width - max(0, numberOfCellsPerRow - 1)*horizontalSpacing)/numberOfCellsPerRow
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }

        //Check if the folder exists, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName ?? "PhotoApp")
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let first_Obj:AnyObject = collection.firstObject{
            //found the album
            self.albumFound = true
            self.assetCollection = first_Obj as! PHAssetCollection
        }else{
            //Album placeholder for the asset collection, used to reference collection in completion handler
            var albumPlaceholder:PHObjectPlaceholder!
            //create the folder
            NSLog("\nFolder \"%@\" does not exist\nCreating now...", albumName ?? "PhptpApp")
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName ?? "PhotoApp")
                albumPlaceholder = request.placeholderForCreatedAssetCollection
            },
                                                   completionHandler: {(success:Bool, error:Error?) in
                                                    if(success){
                                                        print("Successfully created folder")
                                                        self.albumFound = true
                                                        let collection = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder.localIdentifier], options: nil)
                                                        self.assetCollection = collection.firstObject!
                                                    }else{
                                                        print("Error creating folder")
                                                        self.albumFound = false
                                                    }
            })
        }
        
//        self.grabPhotos()
        
    }

    private func prepareCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib.init(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
    }
    
    private func fetchImagesFromGallery(collection: PHAssetCollection?) {
        DispatchQueue.main.async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            if let collection = collection {
                self.photos = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            } else {
                self.photos = PHAsset.fetchAssets(with: fetchOptions)
            }
            self.collectionView.reloadData()
        }
    }
    
//    fileprivate func loadPhotos() {
//        
//        SVProgressHUD.show()
//        
//        // Get size of the collectionView cell for thumbnail image
//        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
//            let cellSize = layout.itemSize
//            self.assetThumbnailSize = CGSize(width: cellSize.width, height: cellSize.height)
//        }
//        
//        //fetch the photos from collection
//        self.navigationController?.hidesBarsOnTap = false   //!! Use optional chaining
//        self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
//        
//        if let photoCnt = self.photosAsset?.count{
//            if(photoCnt == 0){
////                self.noPhotosLabel.isHidden = false
//            }else{
////                self.noPhotosLabel.isHidden = true
//            }
//        }
//        self.collectionView.reloadData()
//        SVProgressHUD.dismiss()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        loadPhotos()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "viewLargePhoto"){
            if let controller:PhotoViewController = segue.destination as? PhotoViewController{
                if let cell = sender as? UICollectionViewCell{
                    if let indexPath: IndexPath = self.collectionView.indexPath(for: cell){
                        controller.index = indexPath.item
                        controller.photosAsset = self.photos
                        controller.assetCollection = self.selectedCollection
                    }
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
        
    //MARK: UIImagePicker Delegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        //Implement if allowing user to edit the selected image
//        guard let editedImage = info[.editedImage] as? UIImage else {
//            return
//        }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            PHPhotoLibrary.shared().performChanges({
                let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photosAsset) {
                    albumChangeRequest.addAssets([assetPlaceholder!] as NSArray)
                }
            }, completionHandler: {(success, error)in
                DispatchQueue.main.async(execute: {
                    NSLog("Adding Image to Library -> %@", (success ? "Sucess":"Error!"))
                    picker.dismiss(animated: true, completion: nil)
                })
            })
            
        })
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Extensions
// MARK: - UICollectionViewDataSource
extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photos = photos {
            return photos.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell
        cell?.setImage(photos.object(at: indexPath.row))
        
        return cell!
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        var count: Int = 0
//        if(self.photosAsset != nil){
//            count = self.photosAsset.count
//        }
//        return count;
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//
//        let totalCellWidth = 80 * collectionView.numberOfItems(inSection: 0)
//        let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)
//
//        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//        let rightInset = leftInset
//
//        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
//
//    }
    
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell: PhotoThumbnail = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoThumbnail
//
//        //Modify the cell
//        let asset: PHAsset = self.photosAsset[indexPath.item]
//
//        // Create options for retrieving image (Degrades quality if using .Fast)
//        //        let imageOptions = PHImageRequestOptions()
//        //        imageOptions.resizeMode = PHImageRequestOptionsResizeMode.Fast
//        PHImageManager.default().requestImage(for: asset, targetSize: self.assetThumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: {(result, info)in
//            if let image = result {
//                cell.setThumbnailImage(image)
//            }
//        })
//        return cell
//    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoAlbumViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoViewController = UIStoryboard.main.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        photoViewController.title = albums.localizedTitle
        photoViewController.index = indexPath.row
        photoViewController.photosAsset = self.photos
        photoViewController.assetCollection = self.selectedCollection
        
        self.navigationController?.pushViewController(photoViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (Int(UIScreen.main.bounds.size.width) - (numbeOfItemsInRow - 1)) / numbeOfItemsInRow
        return CGSize(width: width, height: width)
    }
    
}





