//
//  UdacityClient.swift
//  Virtual Tourist
//
//  Created by bhuvan on 19/04/2020.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation

class UdacityClient {
    
    // Authentication
    struct Auth {
        static let apiKey = "07c70c58268e3a27825cdbfe575a72fa"
        static let secretKey = "a113dd8b863f73a5"
    }
    
    static var totalPages: Int = 1
    
    // Endpoints
    enum EndPoints {
                        
        private static var baseURLString = "https://api.flickr.com/services/rest/"
        private var baseURL: URL {
            var baseURL = URL(string: EndPoints.baseURLString)!
            baseURL.appendQueryItem(name: "api_key", value: Auth.apiKey)
            baseURL.appendQueryItem(name: "format", value: "json")
            baseURL.appendQueryItem(name: "nojsoncallback", value: "1")
            return baseURL
        }
        
        // Methods
        case getPhotosList(latitude: Double, longitude: Double)
        
        
        var url: URL {
            switch self {
            case .getPhotosList(let lat, let lon):
                var photoListUrl = baseURL
                photoListUrl.appendQueryItem(name: "method", value: "flickr.photos.search")
                photoListUrl.appendQueryItem(name: "lat", value: "\(lat)")
                photoListUrl.appendQueryItem(name: "lon", value: "\(lon)")
                photoListUrl.appendQueryItem(name: "page", value: "\(Int.random(in: 1...UdacityClient.totalPages))")
                return photoListUrl
            }
        }
    }
    
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let responseData = data else {
                performUIUpdate {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: responseData)
                performUIUpdate {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(UdacityResponse.self, from: responseData)
                    performUIUpdate {
                        completion(nil, errorResponse)
                    }
                } catch {
                    performUIUpdate {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    
    // MARK: - Photos List
    class func getPhotosList(latitude: Double, longitude: Double, completion: @escaping (FlickrPhotosResponse?, Error?) -> Void) {
        
        let url = EndPoints.getPhotosList(latitude: latitude, longitude: longitude).url
        
        taskForGETRequest(url: url, responseType: FlickrPhotosResponse.self) { (response, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    
    // MARK: - Download Image
    class func downloadImage(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            performUIUpdate {
                completion(data, error)
            }
        }
        task.resume()
    }
    
}
