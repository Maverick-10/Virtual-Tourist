//
//  FlickrPhotos.swift
//  Virtual Tourist
//
//  Created by bhuvan on 19/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation


struct FlickrPhotosResponse: Codable {
    let photos: FlickrPhotos
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case photos
        case status = "stat"
    }
}

struct FlickrPhotos: Codable {
    let total: String
    let pages: Int
    let photoList: [FlickrPhoto]
    
    enum CodingKeys: String, CodingKey {
        case total
        case pages
        case photoList = "photo"
    }
}


struct FlickrPhoto: Codable {
    let photoId: String
    let title: String
    let farmId: Int
    let serverId: String
    let secretId: String
        
    enum CodingKeys: String, CodingKey {
        case photoId = "id"
        case title
        case farmId = "farm"
        case serverId = "server"
        case secretId = "secret"
    }
    
    func getImageUrl() -> URL {
        let imageUrlString = "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoId)_\(secretId)_z.jpg"
        return URL(string: imageUrlString)!
    }
}
