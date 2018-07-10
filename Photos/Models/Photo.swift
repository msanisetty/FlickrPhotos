//
//  Photo.swift
//  FlickrPhotos
//
//  Created by Manikanta Sanisetty on 12/06/2018.
//  Copyright © 2018 Manikanta Sanisetty. All rights reserved.
//

import UIKit

class Photo: Decodable {
    var id: String
    var ownerId: String
    var secret: String
    var server: String
    var farm: Int
    var title: String
    var ownerName: String
    var date: String = ""
    var image: UIImage?
    
    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner"
        case secret
        case server
        case farm
        case title
        case ownerName = "ownername"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.ownerId = try container.decode(String.self, forKey: .ownerId)
        self.secret = try container.decode(String.self, forKey: .secret)
        self.server = try container.decode(String.self, forKey: .server)
        self.farm = try container.decode(Int.self, forKey: .farm)
        self.title = try container.decode(String.self, forKey: .title)
        self.ownerName = try container.decode(String.self, forKey: .ownerName)
    }
}
