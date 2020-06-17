//
//  FlickrPhotoDetailResponse.swift
//  Virtual Tourist
//
//  Created by bhuvan on 19/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct FlickrPhotoDetailResponse: Codable {
    let sizes: FlickrPhotoSizeResponse
    let status: String
    enum CodingKeys: String, CodingKey {
        case sizes
        case status = "stat"
    }
}

struct FlickrPhotoSizeResponse: Codable  {
    let size: [FlickrPhotoDetail]
}

struct FlickrPhotoDetail: Codable {
    let label: String
    let source: String
}


