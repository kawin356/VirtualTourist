//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Kittikawin Sontinarakul on 18/4/2563 BE.
//  Copyright © 2563 Kittikawin Sontinarakul. All rights reserved.
//

import Foundation
import CoreLocation

class FlickrClient {
    
    enum Endpoint {
        static let baseURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&radius=10"
        static let apiKey = "&api_key=e9c8eb47e793130b2d4e827d294470fd"
        
        case searchImageFromLocation(String,String, Int)
        case downloadImage(Photo)
        
        var stringValue: String {
            switch self {
            case .searchImageFromLocation(let lat, let long, let page): return Endpoint.baseURL + Endpoint.apiKey + "&lat=\(lat)&lon=\(long)&per_page=200&page=\(page)"
            case .downloadImage(let photo): return "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_q.jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getImageFromLocation(coordinate: CLLocation, page: Int = 1, completion: @escaping (FlickrMain?, Error?) -> Void) {
        let lat = String(coordinate.coordinate.latitude)
        let long = String(coordinate.coordinate.longitude)
        let task = URLSession.shared.dataTask(with: Endpoint.searchImageFromLocation(lat, long,page).url) { (data, response, error) in
            guard let data = data else {
                return
            }
            let newData = data.subdata(in: 14..<data.count-1)
            //print(String(data: newData, encoding: .utf8)!)
            let decode = JSONDecoder()
            do {
                let object = try decode.decode(FlickrMain.self, from: newData)
                DispatchQueue.main.async {
                    completion(object, nil)
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                   completion(nil, error)
                }
                
            }
        }
        task.resume()
    }
    
    class func downloadImage(photo: Photo, completion: @escaping (Data) -> Void) {
        let url = Endpoint.downloadImage(photo).url
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            DispatchQueue.main.async {
                completion(data)
            }
        }
        task.resume()
    }
}
