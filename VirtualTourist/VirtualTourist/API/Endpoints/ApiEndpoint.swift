//
//  ApiEndpoint.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/30/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import Foundation

// MARK: API Keys
private let flickrApiKey = "7eb8dab12fc44bd81156e980a43965dc"
private let methodName = "flickr.photos.search"

// MARK: Endpoints
enum ApiEndpoint {
    
    /// To get photos near to a specific location
    case getPhotos(latitude: Double, longitude: Double, page: Int, perPage: Int)
}

// MARK: URL Components
extension ApiEndpoint {
    
    private var scheme: String {
        return "https"
    }
    
    private var host: String {
        switch self {
            
        case .getPhotos:
            return "api.flickr.com"
        }
    }
    
    private var path: String {
        switch self {
            
        case .getPhotos:
            return "/services/rest/"
        }
    }
    
    private var queryItems: [URLQueryItem]? {
        switch self {
            
        case .getPhotos(let latitude, let longitude, let page, let perPage):
            
            var queries = [URLQueryItem]()
            queries.append(URLQueryItem(name: "method", value: methodName))
            queries.append(URLQueryItem(name: "api_key", value: flickrApiKey))
            queries.append(URLQueryItem(name: "format", value: "json"))
            queries.append(URLQueryItem(name: "extras", value: "url_m"))
            queries.append(URLQueryItem(name: "page", value: "\(page)"))
            queries.append(URLQueryItem(name: "per_page", value: "\(perPage)"))
            queries.append(URLQueryItem(name: "nojsoncallback", value: "\(1)"))
            queries.append(URLQueryItem(name: "lat", value: "\(latitude)"))
            queries.append(URLQueryItem(name: "lon", value: "\(longitude)"))
            
            guard queries.count > 0 else {
                return nil
            }
            return queries
        }
    }
    
    var url: URL {
        let url = NSURLComponents()
        url.scheme = self.scheme
        url.host = self.host
        url.path = self.path
        url.queryItems = self.queryItems
        return url.url!
    }
}

// MARK: Request Components
extension ApiEndpoint {
    
    private var httpMethod: String {
        switch self {
            
        case .getPhotos:
            return "GET"
        }
    }
    
    private var httpBody: Data? {
        switch self {
            
        case .getPhotos:
            return nil
        }
    }
    
    private var headers: [String: String]? {
        var headers = [String: String]()
        headers["Accept"] = "application/json"
        headers["Content-type"] = "application/json"
        return headers
    }
    
    var request: URLRequest {
        let request = NSMutableURLRequest()
        request.url = self.url
        request.httpMethod = self.httpMethod
        request.httpBody = self.httpBody
        if let headers = self.headers {
            for (header, value) in headers {
                request.setValue(value, forHTTPHeaderField: header)
            }
        }
        return request as URLRequest
    }
}

// MARK: JSON Encoding
extension ApiEndpoint {
    
    private func encodeToJson<T: Encodable>(_ object: T) -> String? {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        guard let jsonData = try? encoder.encode(object) else {
            return nil
        }
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        
        guard jsonString.count > 0 else {
            return nil
        }
        
        return jsonString
    }
}

// MARK: - Helpers
private extension String {
    
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
