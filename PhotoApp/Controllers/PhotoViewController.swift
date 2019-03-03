//
//  PhotoViewController.swift
//  PhotoApp
//
//  Created by Alaattin Bedir on 2.03.2019.
//  Copyright © 2019 Alaattin Bedir. All rights reserved.
//

import UIKit
import Photos

class PhotoViewController: UIViewController {
    
    // MARK: - Vars & Lets
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<PHAsset>!
    var index: Int = 0
    
    // MARK: - Outlets
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    
    // MARK: - Actions
    @IBAction func exportImage(_ sender: Any) {
        print("export")
    }
    
    @IBAction func trashImage(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default,
                                      handler: {(alertAction)in
                                        PHPhotoLibrary.shared().performChanges({
                                            //Delete Photo
                                            if let request = PHAssetCollectionChangeRequest(for: self.assetCollection){
                                                request.removeAssets(at: IndexSet([self.index]))
                                            }
                                        },
                                                                               completionHandler: {(success, error)in
                                                                                NSLog("\nDeleted Image -> %@", (success ? "Success":"Error!"))
                                                                                alert.dismiss(animated: true, completion: nil)
                                                                                if(success){
                                                                                    // Move to the main thread to execute
                                                                                    DispatchQueue.main.async(execute: {
                                                                                        self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
                                                                                        if let navController = self.navigationController {
                                                                                            navController.popToRootViewController(animated: true)
                                                                                        }
                                                                                    })
                                                                                }else{
                                                                                    print("Error: \(error ?? "" as! Error)")
                                                                                }
                                        })
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(alertAction)in
            //Do not delete photo
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK - Life Cycles Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftItemsSupplementBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = true
        
        self.displayPhoto()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - Business Logic Methods
    func displayPhoto(){        
        let screenSize: CGSize = UIScreen.main.bounds.size
        let targetSize = CGSize(width: screenSize.width, height: screenSize.height)
        
        let imageManager = PHImageManager.default()
        imageManager.requestImage(for: self.photosAsset[self.index], targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: {
            (result, info)->Void in
            self.photoImageView.image = result
        })
    }
    
}




