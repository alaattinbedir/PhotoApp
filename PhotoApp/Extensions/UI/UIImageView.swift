//
//  File.swift
//  PhotoApp
//
//  Created by Melike Sardogan on 3.03.2019.
//  Copyright © 2019 Alaattin Bedir. All rights reserved.
//

import UIKit

extension UIImageView {
    
    // MARK: - Public methods  
    func setRounded(round: Float) {
        self.layer.cornerRadius = CGFloat(round)
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor        
        self.clipsToBounds = true
    }
    
    func setCircled() {
        self.layer.cornerRadius = (self.frame.width / 2)
        self.layer.masksToBounds = true
    }
}
