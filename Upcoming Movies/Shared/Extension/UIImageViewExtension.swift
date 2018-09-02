//
//  UIImageViewExtension.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 31/08/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import UIKit
import Kingfisher

enum TmdbSizeMode: String {
    case original
    case w200
    case w500
}

extension UIImageView {
    
    /**
     * Load an image from tmdb database
     */
    func tmdbImage(uri: String, sizeMode: TmdbSizeMode, contentMode: UIViewContentMode = .scaleAspectFill,  placeholder: UIImage = #imageLiteral(resourceName: "ic_placeholder_movie")) {
        let url = URL(string: "https://image.tmdb.org/t/p/\(sizeMode.rawValue)\(uri)")
        self.contentMode = .center
        kf.setImage(with: url, placeholder: placeholder) { [unowned self] (_, error, _, _) in
            if error == nil {
                self.contentMode = contentMode
            }
        }
    }
}
