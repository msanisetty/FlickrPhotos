//
//  PhotosViewModel.swift
//  FlickrPhotos
//
//  Created by Manikanta Sanisetty on 13/06/2018.
//  Copyright © 2018 Manikanta Sanisetty. All rights reserved.
//

import Foundation

class PhotosViewModel {
    
    private var photos: [Photo] = []
    private var currentPage: Int = 0
    private let photosPerPage = 20
    
    private var cellViewModels: [PhotosCellViewModel] = [] {
        didSet {
            self.reloadCollectionViewClosure?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.showLoadingView?()
        }
    }
    
    var numberOfItems: Int {
        return cellViewModels.count
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var selectedPhoto: Photo!
    var reloadCollectionViewClosure: (()->Void)?
    var showLoadingView: (()->Void)?
    var showAlertClosure: (()->Void)?
    
    func initFetch() {
        self.isLoading = true
        if let dateString = CommonDateFormatter.getStringFrom(date: getYesterdayDate()) {
            NetworkManager.shared.getInterestingPhotos(onDate: dateString, pageNumber: currentPage + 1, numberOfPhotosPerPage: photosPerPage, onSuccess: { [weak self] (totalNumberOfPhotos, currentPage, photos) in
                self?.isLoading = false
            }, onError: { [weak self] (error) in
                self?.isLoading = false
                
            })
        }
    }
    
    func getCellViewModel(atIndexPath indexPath: IndexPath) -> PhotosCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
//    func createCellViewModel(photo: Photo) -> PhotosCellViewModel {
//        
//    }
    
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
}

struct PhotosCellViewModel {
    
}
