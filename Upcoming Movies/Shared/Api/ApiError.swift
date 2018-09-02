//
//  ApiError.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 31/08/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation

enum ApiError: Error {
    case success
    case error(String)
    
    var localizedDescription: String {
        switch self {
        case .success:
            return ""
        case .error(let strError):
            return strError
        }
    }
}

struct ErrorModel: Decodable {
    let error: String
}
