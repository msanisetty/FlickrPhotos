//
//  NetworkManager.swift
//  FlickrPhotos
//
//  Created by Manikanta Sanisetty on 12/06/2018.
//  Copyright © 2018 Manikanta Sanisetty. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {
    // Singleton NetworkManager
    static let shared = NetworkManager()

    // Key contants
    struct Keys {
        static let apiKey = "api_key"
        static let secret = "secret"
        static let method = "method"
        static let intrest = "flickr.interestingness.getList"
        static let date = "date"
        static let ownerName = "owner_name"
        static let perPage = "per_page"
        static let page = "page"
        static let extras = "extras"
        static let format = "format"
        static let dateKey = "date"
        static let nojsoncallback = "nojsoncallback"
        static let jsonKey = "json"
    }
    
    /// Variables
    fileprivate var baseURL = "https://api.flickr.com/services/rest/"
    fileprivate let apiKey = "6b991ce05c0d41493b5d8fbc721a9de1"
    fileprivate let secret = "090f2d50e24d02ef"
    
    /**
     Get list of intresting photos for given date.
     
     @param date Date to filter list.
     @param pageNumber Current page number.
     @param numberOfPhotosPerPage Total number of pages in list.
     */
    func getInterestingPhotos(onDate: String, pageNumber: Int, numberOfPhotosPerPage: Int, onSuccess: @escaping (_ totalNumberOfPhotos: Int, _ currentPage: Int, _ photos: [Photo])-> Void, onError: @escaping (_ error: Error?)->Void) {
        var urlComponents = URLComponents(string: baseURL)
        urlComponents?.queryItems = [URLQueryItem(name: Keys.method, value: Keys.intrest),
                                     URLQueryItem(name: Keys.apiKey, value: apiKey),
                                     URLQueryItem(name: Keys.dateKey, value: onDate),
                                     URLQueryItem(name: Keys.perPage, value: "\(numberOfPhotosPerPage)"),
                                     URLQueryItem(name: Keys.page, value: "\(pageNumber)"),
                                     URLQueryItem(name: Keys.extras, value: "owner_name"),
                                     URLQueryItem(name: Keys.format, value: Keys.jsonKey),
                                     URLQueryItem(name: Keys.nojsoncallback, value: "1")]
        
        let getPhotosTask = URLSession.shared.dataTask(with: (urlComponents?.url)!, completionHandler: { (data, response, error) in
            if error != nil {
                onError(error)
                return
            }
            
            do {
                // Decode response data
                let decoder = JSONDecoder()
                let dict = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                let photosDict = dict["photos"] as! [String: Any]
                let totalNumberOfPhotos = photosDict["total"] as? Int ?? 0
                let currentPage = photosDict["page"] as? Int ?? 0
                let photosInfoArrayDict = photosDict["photo"] as! [Any]
                let photosInfoArrayData = try JSONSerialization.data(withJSONObject: photosInfoArrayDict, options: .prettyPrinted)
                let photos = try decoder.decode([Photo].self, from: photosInfoArrayData)
                _ = photos.map({ (photo) -> Photo in
                    photo.date = onDate
                    return photo
                })
                onSuccess(totalNumberOfPhotos, currentPage, photos)
            } catch let error {
                onError(error)
            }
        })
        getPhotosTask.resume()
    }
    
    /**
     Get photo image data.
     
     @param photoId Identification number to identify photo.
     @param secret Secret id.
     @param farmId Farm id.
     @param serverId Idetification number to identify Server.
     */
    func getPhotoImage(withPhotoId id: String, secret: String, farmId: Int, serverId: String, onSuccess: @escaping (_ image: UIImage)-> Void, onError: @escaping (_ error: Error?)->Void) {
        let urlString = "https://farm\(farmId).staticflickr.com/\(serverId)/\(id)_\(secret).jpg"
        let url = URL(string: urlString)!
        let imageTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if error != nil {
                onError(error)
                return
            }
            
            let image = UIImage(data: data!)
            onSuccess(image!)
            
        })
        imageTask.resume()
    }
    
}
