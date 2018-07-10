//
//  ViewController.swift
//  FlickrPhotos
//
//  Created by Manikanta Sanisetty on 12/06/2018.
//  Copyright © 2018 Manikanta Sanisetty. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {

    ///IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewHeightConstraint: NSLayoutConstraint!
    
    ///Variables
    let photosPerPage = 20
    var currentPage = 0
    var totalPhotos = 0
    var photos: [Photo] = []
    var isFetchingPhotos = false
    var selectedPhoto: Photo!
    let imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set custom layout delegate
        if let layout = collectionView.collectionViewLayout as? PhotoGridCustomLayout {
            layout.delegate = self
        }
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        imageCache.countLimit = 200
        if let dateString = CommonDateFormatter.getStringFrom(date: getYesterdayDate()) {
            getInterestingnessPhotos(onDate: dateString)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = Localized.photos
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIds.photoDetailsSegueId, let vc = segue.destination as? PhotoDetailsViewController {
            let image = imageCache.object(forKey: selectedPhoto.id as NSString)
            selectedPhoto.image = image
            vc.photo = selectedPhoto
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     Get yesterday date.
     
     @return date Yesterday date.
     */
    private func getYesterdayDate() -> Date {
        guard let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
            fatalError("Invalid date")
        }
        return yesterdayDate
    }
    
    /**
     Get list of interestingness photos for a given date.
     
     @param date Date.
     */
    private func getInterestingnessPhotos(onDate date: String) {
        isFetchingPhotos = true
        showLoadingView()
        NetworkManager.shared.getInterestingPhotos(onDate: date, pageNumber: currentPage + 1, numberOfPhotosPerPage: photosPerPage, onSuccess: { [weak self] (totalNumberOfPhotos, currentPage, photos) in
            DispatchQueue.main.async {
                self?.hideLoadingView()
                self?.isFetchingPhotos = false
                self?.totalPhotos = totalNumberOfPhotos
                self?.currentPage = currentPage
                self?.photos.append(contentsOf: photos)
                self?.collectionView.reloadData()
            }
            }, onError: {[weak self] (error: Error?) in
                DispatchQueue.main.async {
                    self?.hideLoadingView()
                    self?.showAlert(withTitle: Localized.error, andMessage: error?.localizedDescription ?? Localized.genericErrorMessage)
                }
        })
    }
    
    /**
     Load image for given photo data at indexPath.
     
     @param photo Photo information.
     @param indexPath IndexPath of a cell.
     */
    private func loadImage(forPhoto photo: Photo, atIndexPath indexPath: IndexPath, onCompletion: @escaping (_ image: UIImage)->Void) {
        if let image = imageCache.object(forKey: photo.id as NSString) {
            onCompletion(image)
        } else {
            NetworkManager.shared.getPhotoImage(withPhotoId: photo.id, secret: photo.secret, farmId: photo.farm, serverId: photo.server, onSuccess: {[weak self] (image) in
                onCompletion(image)
                DispatchQueue.main.async {
                    self?.imageCache.setObject(image, forKey: photo.id as NSString)
                    self?.collectionView.reloadItems(at: [indexPath])
                }
                }, onError: { (error: Error?) in
                    print("Unable to download photo: \(photo.title)")
            })
        }
    }
    
    private func showLoadingView() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.loadingViewHeightConstraint.constant = 65
            self?.loadingView.alpha = 1.0
        }, completion: nil)
    }
    
    private func hideLoadingView() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.loadingViewHeightConstraint.constant = 0
            self?.loadingView.alpha = 0.0
        }, completion: nil)
    }
}

extension PhotosViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReusableCellIdentifiers.photosCollectionViewCellReuseId, for: indexPath) as? PhotosCollectionViewCell else {
            fatalError("Could not dequeue cell with identifier: \(ReusableCellIdentifiers.photosCollectionViewCellReuseId)")
        }
        let photo = photos[indexPath.row]
        cell.photoImageView.image = #imageLiteral(resourceName: "PlaceholderImage")
        loadImage(forPhoto: photo, atIndexPath: indexPath, onCompletion: { (image) in
            DispatchQueue.main.async {
                cell.photoImageView.image = image
            }
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1, !isFetchingPhotos, let dateString = CommonDateFormatter.getStringFrom(date: getYesterdayDate()) {
            getInterestingnessPhotos(onDate: dateString)
        }
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPhoto = photos[indexPath.row]
        performSegue(withIdentifier: SegueIds.photoDetailsSegueId, sender: nil)
    }
}

extension PhotosViewController: PhotoGridCustomLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        if let image = imageCache.object(forKey: photo.id as NSString) {
            let height = image.size.height
            return height
        }
        return UIScreen.main.bounds.width/2
    }
}

//extension PhotosViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: UIScreen.main.bounds.width/2 - 1, height: UIScreen.main.bounds.width/2 - 1)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1.0
//    }
//}
