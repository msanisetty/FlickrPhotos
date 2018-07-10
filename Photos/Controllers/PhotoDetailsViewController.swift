//
//  PhotoDetailsViewController.swift
//  FlickrPhotos
//
//  Created by Manikanta Sanisetty on 12/06/2018.
//  Copyright © 2018 Manikanta Sanisetty. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    ///IBOutlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    ///Variables
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load UI.
        photoImageView.image = photo.image
        titleLabel.text = photo.title
        ownerNameLabel.text = photo.ownerName
        dateLabel.text = photo.date
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Set photo image data to nil.
        photo.image = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
