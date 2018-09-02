//
//  Movie.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 31/08/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation
import SwiftDate

struct Movie: Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let overview: String?
    let genre_ids: [Int]
    private let releaseDateRegion: DateInRegion?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case genre_ids
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDateRegion = "release_date"
    }
    
    var releaseDate: String {
        if let rs = releaseDateRegion {
            return rs.toString(.custom("MM/dd/yyyy"))
        }
        return ""
    }
    
    var hasOverview: Bool {
        return overview?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" != ""
    }
    
    var hasBackdropImage: Bool {
        return backdropPath != nil
    }
}

struct MovieGenres {
    let movie: Movie
    let genres: [Genre]
}

extension Movie {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)
        overview = try values.decode(String.self, forKey: .overview)
        genre_ids = try values.decode(Array.self, forKey: .genre_ids)
        posterPath = try values.decodeIfPresent(String.self, forKey: .posterPath)
        backdropPath = try values.decodeIfPresent(String.self, forKey: .backdropPath)
        let strDate = try values.decode(String.self, forKey: .releaseDateRegion)
        releaseDateRegion = DateInRegion(strDate)
    }
}

struct MoviePage: Decodable {
    let page: Int
    let total_results: Int
    let total_pages: Int
    let results: [Movie]
}
