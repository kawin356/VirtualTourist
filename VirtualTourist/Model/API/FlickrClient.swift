//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Kittikawin Sontinarakul on 18/4/2563 BE.
//  Copyright © 2563 Kittikawin Sontinarakul. All rights reserved.
//

import Foundation
import CoreLocation


//https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg

class FlickrClient {
    
    
    
    enum Endpoint {
        static let baseURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&api_key=e9c8eb47e793130b2d4e827d294470fd&radius=10"
        static let apiKey = "e9c8eb47e793130b2d4e827d294470fd"
        
        case searchImageFromLocation(String,String)
        case downloadImage(Photo)
        
        var stringValue: String {
            switch self {
            case .searchImageFromLocation(let lat,let long): return Endpoint.baseURL + "&lat=\(lat)&lon=\(long)&per_page=20"
            case .downloadImage(let photo): return "https://farm\(photo.farm).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_q"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getImageFromLocation(coordinate: CLLocation, completion: @escaping ([Photo]?, Error?) -> Void) {
        let lat = String(coordinate.coordinate.latitude)
        let long = String(coordinate.coordinate.longitude)
        let task = URLSession.shared.dataTask(with: Endpoint.searchImageFromLocation(lat, long).url) { (data, response, error) in
            guard let data = data else {
                return
            }
            let newData = data.subdata(in: 14..<data.count-1)
            //print(String(data: newData, encoding: .utf8)!)
            let decode = JSONDecoder()
            do {
                let object = try decode.decode(Image.self, from: newData)
                completion(object.photos.photo, nil)
            } catch {
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    class func downloadImage(photo: Photo, completion: @escaping (Data) -> Void) {
//        let task = URLSession.shared.dataTask(with: Endpoint.downloadImage(photo)) { (data, response, error) in
//            guard let data = data else {
//                return
//            }
//            completion(data)
//        }
//        task.
    }
}
