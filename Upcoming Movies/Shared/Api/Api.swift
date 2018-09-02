//
//  Api.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 31/08/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

protocol ApiProtocol {
    func apiURL() -> String
    func urlParams() -> String
}

class Api {
    
    private var apiURL = ""
    
    private var _isRequesting = false
    
    /**
     * Boolean flag that indicates it is in requesting
     */
    var isRequesting: Bool {
        return _isRequesting
    }
    
    /**
     * Initializate with a base URL
     */
    init(apiURL: String) {
        self.apiURL = apiURL
    }
    
    /**
     * Custom query string for request
     */
    func queryString() -> [String: Any]? {
        return nil
    }
    
    private func generateQueryString(dictionaries: [String: Any]?...) -> String {
        var components = URLComponents()
        
        components.queryItems = dictionaries
            .compactMap ({ dictionary in
                dictionary?.map({ (key, value ) in URLQueryItem(name: key, value: "\(value)") })
            })
            .flatMap({ $0 })

        return "\(components.url?.absoluteString ?? "")"
    }
    
    /**
     * Custom headers for request
     */
    func headers() -> [String: String]? {
        return nil
    }
    
    /**
     * Request a data from a given endpoint
     */
    func requestData(endpoint: String, method: HTTPMethod = .get, dictionary: [String: Any]? = nil, completion: @escaping (Data?, ApiError?) -> Void) {
        if (_isRequesting) {
            completion(nil, .error("Already started a request"))
            return
        }
        
        _isRequesting = true

        let qs = generateQueryString(dictionaries: queryString(), method == .get ? dictionary : nil)
        let url = "\(apiURL)\(endpoint)\(qs)"
    
        print("url: \(url)")
        print(dictionary ?? "")
        
        let aRequest = Alamofire.request(url, method: method, parameters: dictionary, encoding: JSONEncoding.default, headers: headers())
        
        aRequest.responseData { [weak self] response in
            print(response)
            self?._isRequesting = false
            do {
                switch response.result {
                case .success(let data):
                    if response.response?.statusCode ?? 200 >= 400 {
                        // Error
                        let error = try JSONDecoder().decode(ErrorModel.self, from: data)
                        completion(nil, .error(error.error))
                    }
                    else {
                        // Response OK. Process
                        completion(data, nil)
                    }
                case .failure(let error):
                    completion(nil, .error(error.localizedDescription))
                    break
                }
            }
            catch {
                completion(nil, .error("Inespecific Error"))
            }
        }
    }
    
    /**
     * Request a data from a given endpoint and transform it on a decodable model
     */
    func requestModel<T: Decodable>(endpoint: String, method: HTTPMethod = .get, dictionary: [String: Any]? = nil, completion: @escaping (T?, ApiError?) -> Void) {
        requestData(endpoint: endpoint, method: method, dictionary: dictionary) { (data, dtError) in
            if let dtError = dtError {
                completion(nil, dtError)
            }
            else if let data = data {
                do {
                    completion(try JSONDecoder().decode(T.self, from: data), nil)
                }
                catch {
                    print(error)
                    completion(nil, .error("Inespecific Error"))
                }
            }
        }
    }
    
    /**
     * Request a data from a given endpoint, transform it on a decodable model and emmits to a subscriber
     */
    func request<T: Decodable>(endpoint: String, method: HTTPMethod = .get, dictionary: [String: Any]? = nil) -> Observable<T> {
        return .create({ emitter -> Disposable in
            self.requestModel(endpoint: endpoint, method: method, dictionary: dictionary, completion: { (value: T?, error) in
                if let error = error {
                    emitter.onError(error)
                }
                else if let value = value {
                    emitter.onNext(value)
                }
                emitter.onCompleted()
            })
            
            return Disposables.create()
        })
    }
}
