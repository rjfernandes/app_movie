//
//  MainController.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 30/08/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FontAwesome_swift

class MainController: UITableViewController {
    
    enum ExtraCellType {
        case none
        case requestingGenres
        case requestingMovies
        case searching
        case moviesNotFound
        case error
        
        func rows() -> Int {
            return self == .none ? 0 : 1
        }
        
        func identifier() -> (identifier: String, icon: FontAwesome?, title: String?) {
            switch self {
                case .requestingGenres:
                    return ("cellRequesting", nil, "Requesting movies...")
                case .requestingMovies:
                    return ("cellRequesting", nil, "Requesting movies...")
                case .searching:
                    return ("cellRequesting", nil, "Searching movies...")
                case .moviesNotFound:
                    return ("cellNoMovies", .film, nil)
                case .error:
                    return ("cellError", .exclamationCircle, nil)
                default:
                    return ("", nil, nil)
            }
        }
    }
    
    private lazy var presenter: MainPresenterProtocol = MainPresenter(view: self)
    private lazy var searchController = UISearchController(searchResultsController: nil)
    private lazy var disposeBag = DisposeBag()
    
    private var extraCell = ExtraCellType.requestingGenres {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var isSearchActive = false {
        didSet {
            if isSearchActive == oldValue {
                return
            }
            else if !isSearchActive {
                presenter.clearSearch()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter.genres()
    }
    
    private func setupView() {
        automaticRowHeight()
        registerCell(nibName: "MovieWithBackdrop", forIdentifier: "movieCell")
        registerCell(nibName: "MovieWithOnlyPoster", forIdentifier: "movieCellOnlyPoster")

        searchController.searchBar.tintColor = .white
        let searchObserver = searchController
                                .searchBar
                                .rx
                                .text
                                .debounce(0.3, scheduler: MainScheduler.instance)

        searchObserver
            .filter({ $0?.count ?? 0 >= 3 })
            .subscribe(onNext: { [weak self] keyword in
                self?.presenter.search(keyword: keyword)
            })
            .disposed(by: disposeBag)
        
        searchObserver
            .filter({ $0?.isEmpty ?? false })
            .subscribe(onNext: { [weak self] keyword in
                self?.presenter.clearSearch()
            })
            .disposed(by: disposeBag)
        
        searchController
            .searchBar
            .rx
            .cancelButtonClicked
            .subscribe(onNext: { [weak self] _ in
                self?.presenter.clearSearch()
            }).disposed(by: disposeBag)
        
    
        searchController.searchBar.barStyle = .black
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

// MARK: Presenter Protocol implementation



extension MainController: MainViewProtocol {

    func loadingGenres() {
        extraCell = .requestingGenres
    }
    
    func afterLoadingGenres() {
        presenter.nextPage()
    }

    func loadingMovies() {
        extraCell = .requestingMovies
    }
    
    func searchingMovies() {
        extraCell = .searching
    }
    
    func moviesNotFound() {
        extraCell = .moviesNotFound
    }
    
    func hideLoading() {
        extraCell = .none
    }
    
    func afterError(error: Error) {
        extraCell = .error
    }
    
    func refreshView() {
        tableView.reloadData()
    }
    
    func setViewForSearch(isSearching: Bool) {
        title = isSearching ? "Search Movies" : "Upcoming Movies"
    }
}

// MARK: TableView Implementation

extension MainController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.moviesCount + extraCell.rows()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        if indexPath.row == presenter.moviesCount {
            // Extra cell
            let extraInfo = extraCell.identifier()
            cell = tableView.dequeueReusableCell(withIdentifier: extraInfo.identifier, for: indexPath)
            
            // set animation indicator view
            (cell.viewWithTag(5) as? UIActivityIndicatorView)?.startAnimating()
            
            // set icon
            (cell.viewWithTag(10) as? UILabel)?.setIcon(name: extraInfo.icon, size: 24)
            
            // set label
            (cell.viewWithTag(20) as? UILabel)?.text = extraInfo.title
            return cell
        }
        else {
            let movieGenres = presenter.movieGenresBy(index: indexPath.row)
            cell = tableView.dequeueReusableCell(withIdentifier: movieGenres.movie.hasBackdropImage ? "movieCell" : "movieCellOnlyPoster", for: indexPath)
            (cell as? MovieCell)?.movieGenres = movieGenres
        }
        
        cell.contentView.setNeedsLayout()
        cell.contentView.layoutIfNeeded()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if presenter.canDownloadNextPage(index: indexPath.row) {
            presenter.nextPage()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row < presenter.moviesCount {
            performSegue(withIdentifier: "MoviesDetail", sender: presenter.movieGenresBy(index: indexPath.row))
        }
        else if extraCell == .error {
            presenter.requestAfterFail()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MovieDetailController, let movieGenres = sender as? MovieGenres {
            controller.movieGenres = movieGenres
        }
    }
}
