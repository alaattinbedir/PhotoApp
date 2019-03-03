//
//  AlbumCollectionViewCell.swift
//  PhotoApp
//
//  Created by Alaattin Bedir on 2.03.2019.
//  Copyright © 2019 Alaattin Bedir. All rights reserved.
//

import UIKit
import Photos

class AlbumCollectionViewCell: UICollectionViewCell {

    // MARK: - Outelts
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumNameLabel: UILabel!
    
    // MARK: - Public methods
    
    func setAlbum(_ album: PHAssetCollection) {
        albumNameLabel.text = album.localizedTitle!
        albumImageView.image = album.getCoverImgWithSize((albumImageView?.frame.size ?? nil)!)
    }

}
