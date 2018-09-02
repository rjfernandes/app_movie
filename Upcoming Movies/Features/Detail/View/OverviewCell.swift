//
//  OverviewCell.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 31/08/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import UIKit

class OverviewCell: UITableViewCell {
    
    @IBOutlet weak var lblOverview: UILabel!
    
    var movie: Movie! {
        didSet {
            lblOverview.text = movie.overview
        }
    }
}
