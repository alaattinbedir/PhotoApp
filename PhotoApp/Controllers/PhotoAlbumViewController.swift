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
    public var albums: PHAssetCollection = PHAssetCollection()
    public var albumName: String?
    public var selectedCollection: PHAssetCollection?
    private var albumFound : Bool = false
    private var assetThumbnailSize:CGSize!
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
    
    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareCollectionView()
        self.fetchImagesFromGallery(collection: self.selectedCollection)
        
        //Check if the folder exists, if not, create it
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName ?? "PhotoApp")
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let first_Obj:AnyObject = collection.firstObject{
            //found the album
            self.albumFound = true
            self.albums = first_Obj as! PHAssetCollection
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
                                                        self.albums = collection.firstObject!
                                                    }else{
                                                        print("Error creating folder")
                                                        self.albumFound = false
                                                    }
            })
        }
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
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
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
            PHPhotoLibrary.shared().performChanges({
                let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
                if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.albums, assets: self.photos) {
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





