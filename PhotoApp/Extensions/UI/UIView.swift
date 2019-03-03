//
//  UIView.swift
//  PhotoApp
//
//  Created by Alaattin Bedir on 2.03.2019.
//  Copyright © 2019 Alaattin Bedir. All rights reserved.
//

import UIKit

extension UIView {
    
    // MARK: - Public methods    
    func roundedCorners() {
        self.layer.cornerRadius = self.bounds.size.height/2
        self.clipsToBounds = true
    }
    
}
