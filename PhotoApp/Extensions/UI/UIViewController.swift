//
//  UIViewController.swift
//  PhotoApp
//
//  Created by Alaattin Bedir on 2.03.2019.
//  Copyright © 2019 Alaattin Bedir. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: - Public methods    
    func showAlertWith(message: AlertMessage , style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: message.title, message: message.body, preferredStyle: style)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithCompletionHandler(message: AlertMessage, style: UIAlertController.Style = .alert, handler: @escaping ((UIAlertAction) -> Void)) {
        let alertController = UIAlertController(title: message.title, message: message.body, preferredStyle: style)
        let action = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
