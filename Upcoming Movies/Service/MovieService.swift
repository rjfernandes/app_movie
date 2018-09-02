//
//  MovieService.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 30/08/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation
import RxSwift

class MovieService: Api {
    convenience init() {
        self.init(apiURL: AppConfig.apiURL)
    }
    
    override func queryString() -> [String : Any]? {
        return [ "api_key" : AppConfig.apiKey ]
    }
    
    /**
     * Get all genres
     */
    func genres() -> Observable<[Genre]> {
        return request(endpoint: "genre/movie/list").map({ (response: GenreResponse) in response.genres })
    }
    
    /**
     * Get a page with upcoming movies
     */
    func upcoming(page: Int) -> Observable<MoviePage> {
        return request(endpoint: "movie/upcoming", dictionary: [ "page": page ])
    }
    
    /**
     * Search a movie
     */
    func search(keyword: String, page: Int) -> Observable<MoviePage> {
        return request(endpoint: "search/movie", dictionary: [ "query" : keyword, "page": page ])
    }
}
