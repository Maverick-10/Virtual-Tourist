//
//  UdacityResponse.swift
//  Virtual Tourist
//
//  Created by bhuvan on 19/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

struct UdacityResponse: Codable {
    let status: String
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case status = "stat"
        case code
        case message
    }
}

extension UdacityResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
