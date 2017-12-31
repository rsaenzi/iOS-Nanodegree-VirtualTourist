//
//  RequestGetPhotos.swift
//  VirtualTourist
//
//  Created by Rigoberto Sáenz Imbacuán on 12/31/17.
//  Copyright © 2017 Rigoberto Sáenz Imbacuán. All rights reserved.
//

import Foundation

typealias CompletionGetPhotos = (_ result: GetSingleStudentResult) -> ()

// MARK: Request
class RequestGetPhotos {
    
    static func get(latitude: Double, longitude: Double, completion: @escaping CompletionGetPhotos) {
        
        let endpoint = ApiEndpoint.getPhotos(latitude: latitude, longitude: longitude)
        Request.shared.request(endpoint) { result in
            
            switch result {
            case .success(let jsonString, _):
                
                guard let studentResults = decode(from: jsonString) else {
                    call(completion, returning: .errorJsonDecoding)
                    return
                }
                
                call(completion, returning: .success(studentResults: studentResults))
                
            case .errorRequest:
                call(completion, returning: .errorRequest)
                
            case .errorDataDecoding:
                call(completion, returning: .errorDataDecoding)
                
            case .errorInvalidStatusCode:
                call(completion, returning: .errorInvalidStatusCode)
                
            case .errorNoStatusCode:
                call(completion, returning: .errorNoStatusCode)
            }
        }
    }
    
    private static func call(_ completion: @escaping CompletionGetPhotos, returning result: GetSingleStudentResult) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
}

// MARK: JSON Decoding
extension RequestGetPhotos {
    
    private static func decode(from jsonString: String) -> ResponseGetPhotos? {
        
        let decoder = JSONDecoder()
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        var object: ResponseGetPhotos?
        do {
            object = try decoder.decode(ResponseGetPhotos.self, from: jsonData)
        } catch {
            print(error)
            return nil
        }
        
        return object
    }
}

// MARK: Result
enum GetSingleStudentResult {
    case success(studentResults: ResponseGetPhotos)
    
    case errorRequest
    case errorDataDecoding
    case errorInvalidStatusCode
    case errorNoStatusCode
    case errorJsonDecoding
}
