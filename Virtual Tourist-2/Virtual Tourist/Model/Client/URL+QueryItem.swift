//
//  URL+QueryParameter.swift
//  Virtual Tourist
//
//  Created by bhuvan on 20/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

extension URL {

    @discardableResult
    mutating func appendQueryItem(name: String, value: String?) -> URL {

        guard var urlComponents = URLComponents(string: absoluteString) else { return self }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: name, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        self = urlComponents.url!
        
        return self
    }
}
