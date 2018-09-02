//
//  MovieCell.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 31/08/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!

    @IBOutlet weak var vwPoster: UIView!
    @IBOutlet weak var imgPoster: UIImageView?
    @IBOutlet weak var nslPosterWidth: NSLayoutConstraint?
    @IBOutlet weak var nslPosterHeight: NSLayoutConstraint?

    @IBOutlet weak var imgBackdrop: UIImageView?
    @IBOutlet weak var lblReleaseDate: UILabel!

    @IBOutlet weak var lblGenres: UILabel!
    @IBOutlet weak var nslGenresHeight: NSLayoutConstraint?
    @IBOutlet weak var vwSeparator: UIView!
    
    var movieGenres: MovieGenres! {
        didSet {
            let movie = movieGenres.movie
            lblTitle.text = movie.title
            lblReleaseDate.text = "Release date: \(movie.releaseDate)"
            if let posterPath = movie.posterPath {
                vwPoster.isHidden = false
                nslPosterWidth?.constant = 84
                nslPosterHeight?.constant = 124
                imgPoster?.tmdbImage(uri: posterPath, sizeMode: .w200, contentMode: .scaleAspectFit)
            }
            else {
                vwPoster.isHidden = true
                nslPosterWidth?.constant = 0
                nslPosterHeight?.constant = 0
            }
            
            if let backdropPath = movie.backdropPath {
                imgBackdrop?.tmdbImage(uri: backdropPath, sizeMode: .w500)
            }

            if movieGenres.genres.count == 0 {
                lblGenres.isHidden = true
                nslGenresHeight?.constant = 0
            }
            else {
                lblGenres.isHidden = false
                lblGenres.text = "Genre\(movieGenres.genres.count == 1 ? "" : "s"): \(movieGenres.genres.map({ $0.name }).joined(separator: ", "))"
                nslGenresHeight?.constant = 16
            }
        }
    }
}
