//
//  CommonDateFormatter.swift
//  FlickrPhotos
//
//  Created by Manikanta Sanisetty on 12/06/2018.
//  Copyright © 2018 Manikanta Sanisetty. All rights reserved.
//

import UIKit

enum DateFormat: String {
    case defaultStyle = "yyyy-MM-dd"
}

class CommonDateFormatter: NSObject {
    class func getStringFrom(date: Date, withFormatter dateFormat: String = DateFormat.defaultStyle.rawValue) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.string(from: date)
        return date
    }
}
