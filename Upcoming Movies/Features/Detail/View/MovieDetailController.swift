//
//  MovieDetailController.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 31/08/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import UIKit

class MovieDetailController: UITableViewController {
    
    var items = [String]()
    
    var movieGenres: MovieGenres!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        title = "Movie Overview"
        items += [ movieGenres.movie.hasBackdropImage ? "movieCell" : "movieCellOnlyPoster" ]
        if movieGenres.movie.hasOverview {
            items += [ "overviewCell" ]
        }
        
        tableView.reloadData()
    }
    
    private func setupView() {
        automaticRowHeight()
        navigationItem.largeTitleDisplayMode = .never
        let hasBackdropImage = movieGenres.movie.hasBackdropImage
        registerCell(nibName: hasBackdropImage ? "MovieWithBackdrop" : "MovieWithOnlyPoster", forIdentifier: hasBackdropImage ? "movieCell" : "movieCellOnlyPoster")
    }

}

extension MovieDetailController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: items[indexPath.row], for: indexPath)
        (cell as? MovieCell)?.movieGenres = movieGenres
        (cell as? MovieCell)?.selectionStyle = .none
        (cell as? MovieCell)?.vwSeparator.isHidden = true
        (cell as? OverviewCell)?.movie = movieGenres.movie
        return cell
    }
}
