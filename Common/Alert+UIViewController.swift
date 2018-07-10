//
//  Alert+UIViewController.swift
//  FlickrPhotos
//
//  Created by Manikanta Sanisetty on 12/06/2018.
//  Copyright © 2018 Manikanta Sanisetty. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(withTitle title:String, andMessage message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: Localized.ok, style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
