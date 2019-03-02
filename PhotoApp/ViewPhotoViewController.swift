//
//  ViewPhotoViewController.swift
//  PhotoApp
//
//  Created by Melike Sardogan on 2.03.2019.
//  Copyright © 2019 Alaattin Bedir. All rights reserved.
//

import UIKit

class ViewPhotoViewController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    
    @IBAction func cancel(_ sender: Any) {
        print("cancel")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func exportImage(_ sender: Any) {
        print("export")
    }
    
    @IBAction func trashImage(_ sender: Any) {
        print("trash")
    }
    
    
}




