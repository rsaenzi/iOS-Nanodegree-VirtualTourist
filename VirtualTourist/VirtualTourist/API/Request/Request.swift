//
//  Request.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/31/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import Foundation

typealias RequestCompletion = (_ result: RequestResult) -> ()

class Request {
    
    static let shared = Request()
    
    func request(_ endpoint: ApiEndpoint, successStatusCode: Int = 200, _ completion: @escaping RequestCompletion) {
        
        // Print all request info
        print("Request to: \(endpoint.request.httpMethod!) \(endpoint.url)")
        if let headers = endpoint.request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        if let rawBody = endpoint.request.httpBody, let body = String(data: rawBody, encoding: .utf8) {
            print("Body: \(body)")
        }
        
        // Creates the data task
        let task = URLSession.shared.dataTask(with: endpoint.request) { data, response, error in
            print("Response from: \(endpoint.request.httpMethod!) \(endpoint.url)")
            
            // Detect any request error
            guard error == nil, let data = data else {
                completion(.errorRequest)
                return
            }
            
            // Transforms raw data into string
            guard let jsonString = String(data: data, encoding: .utf8) else {
                completion(.errorDataDecoding)
                return
            }
            print("Json String:\n\(jsonString)")
            
            // Fetch status code from response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.errorNoStatusCode)
                return
            }
            print("Status Code:\(httpResponse.statusCode)")
            
            // Status code must be valid
            guard httpResponse.statusCode == successStatusCode else {
                completion(.errorInvalidStatusCode(statusCode: httpResponse.statusCode))
                return
            }
            
            // Return the json string
            completion(.success(jsonString: jsonString, statusCode: httpResponse.statusCode))
        }
        
        // Start the data task
        task.resume()
    }
}

enum RequestResult {
    case success(jsonString: String, statusCode: Int)
    
    case errorRequest
    case errorNoStatusCode
    case errorInvalidStatusCode(statusCode: Int)
    case errorDataDecoding
}
