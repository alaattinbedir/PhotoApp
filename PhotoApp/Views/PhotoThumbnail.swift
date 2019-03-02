//
//  PhotoThumbnailCollectionViewCell.swift
//  PhotoApp
//
//  Created by Melike Sardogan on 2.03.2019.
//  Copyright © 2019 Alaattin Bedir. All rights reserved.
//

import UIKit

class PhotoThumbnail: UICollectionViewCell {
    
    @IBOutlet var imageView : UIImageView!
    
    
    func setThumbnailImage(_ thumbnailImage: UIImage){
        self.imageView.image = thumbnailImage
    }
    
}
