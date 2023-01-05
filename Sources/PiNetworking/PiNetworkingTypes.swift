//
//  File.swift
//  
//
//  Created by Ignas Pileckas on 2023-01-05.
//

import Foundation

public enum APIError: Error {
    case unknown
    case urlError
    case decoding
    case known(_ error: ErrorResponse)
}

public struct ErrorResponse: Codable {
    let error: DecodedError
}

public struct DecodedError: Codable {
    let code: String
    let message: String
}

extension APIError {
    var code: String {
        switch self {
        case .urlError:
            return "urlError"
        case .unknown:
            return "unknown"
        case .decoding:
            return "decoding"
        case .known(let error):
            return error.error.code
        }
    }
    
    var message: String {
        switch self {
        case .unknown:
            return "An unknown error occured."
        case .decoding:
            return "Could not decode error response."
        case .known(let error):
            return error.error.message
        case .urlError:
            return ""
        }
    }
}

public enum RequestMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case post = "POST"
}

public protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var url: String { get }
    var method: RequestMethod { get }
    var additionalHeaders: [String: String]? { get }
}

public extension Endpoint {
    var scheme: String {
        return "https"
    }
    
    var headers: [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
        ]
        if let additionalHeaders {
            headers.merge(additionalHeaders) { (_, new) in new }
        }
        
        return headers
    }
}
