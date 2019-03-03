//
//  APPhotoCollectionViewCell.swift
//  PhotoApp
//
//  Created by Alaattin Bedir on 2.03.2019.
//  Copyright © 2019 Alaattin Bedir. All rights reserved.
//

import UIKit
import Photos

class PhotoCollectionViewCell: UICollectionViewCell {

    // MARK: - Outelts
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    // MARK: - Vars & Lets
    override var isSelected: Bool {
        didSet {
            self.checkmarkImageView.isHidden = isSelected ? false : true
        }
    }
    
    // MARK: - Cell lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.checkmarkImageView.roundedCorners()
        self.isSelected = false
    }
    
    // MARK: - Public methods
    func setImage(_ asset: PHAsset) {
        self.photoImageView.image = asset.getAssetThumbnail(size: CGSize(width: self.frame.width * 3, height: self.frame.height * 3))
    }
    
    func setImage(_ image: UIImage) {
        self.photoImageView.image = image
    }

}
