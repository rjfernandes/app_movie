//
//  MainPresenter.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 31/08/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation
import RxSwift

class MainPresenter: MainPresenterProtocol {
    
    private class PaginateResult {
        var page = 0 {
            didSet {
                pagesToLoad = pagesToLoad.filter { $0 > page }
            }
        }

        var pages = 0
        var pagesToLoad = Set<Int>()
        
        var isLastPage: Bool {
            return page == pages
        }
        
        func addPageToLoad() {
            pagesToLoad.insert(page + 1)
        }
        
        func nextPageToLoad() -> Int? {
            if pagesToLoad.isEmpty {
                return nil
            }
            
            return pagesToLoad.sorted().first(where: { $0 > page })
        }
    }
    
    private lazy var movieService = MovieService()
    private lazy var disposeBag = DisposeBag()
    
    private let view: MainViewProtocol
    
    private let upcomingPaginate = PaginateResult()
    private let searchPaginate = PaginateResult()
    
    private var upcomingMovies = [Movie]()
    private var searchMovies = [Movie]()
    
    private var keyword = ""
    private var listGenres = [Genre]()

    private var canLoadNextPage: Bool {
        return !paginate.isLastPage || paginate.page == 0
    }
    
    private var hasKeyword: Bool {
        return keyword != ""
    }
    
    private var dataset: [Movie] {
        return hasKeyword ? searchMovies : upcomingMovies
    }
    
    private var paginate: PaginateResult {
        return hasKeyword ? searchPaginate : upcomingPaginate
    }

    init(view: MainViewProtocol) {
        self.view = view
    }
    
    /**
     * Request all genres
     */
    func genres() {
        view.loadingGenres()
        movieService.genres().subscribe(onNext: { [ unowned self ] items in
            self.listGenres += items
            self.view.afterLoadingGenres()
        }, onError: { [ unowned self ] error in
            self.view.afterError(error: error)
        }).disposed(by: disposeBag)
    }
    
    var hasMorePages: Bool {
        return !paginate.isLastPage
    }
    
    var currentPage: Int {
        return paginate.page
    }
    
    var moviesCount: Int {
        return dataset.count
    }
    
    func canDownloadNextPage(index: Int) -> Bool {
        return index == dataset.count - 1
    }
    
    func movieGenresBy(index: Int) -> MovieGenres {
        let movie = dataset[index]
        return MovieGenres(movie: movie, genres: genresBy(ids: movie.genre_ids))
    }
    
    private func genresBy(ids: [Int]) -> [Genre] {
        return listGenres.filter({ ids.contains($0.id) })
    }
    
    func search(keyword: String?) {
        self.keyword = keyword?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        paginate.page = 0
        if hasKeyword {
            searchMovies.removeAll()
        }
        view.refreshView()
        nextPage()
    }
    
    func clearSearch() {
        keyword = ""
        view.setViewForSearch(isSearching: false)
        view.refreshView()
    }
    
    func nextPage() {
        if !canLoadNextPage {
            return
        }
        else if movieService.isRequesting {
            // Put on a buffer to download after this request was finished
            paginate.addPageToLoad()
            return
        }
        
        requestMovies(page: paginate.page + 1)
    }
    
    private func requestMovies(page: Int) {
        
        if hasKeyword {
            view.searchingMovies()
        }
        else {
            view.loadingMovies()
        }
        
        let observer = hasKeyword ? movieService.search(keyword: keyword, page: page) : movieService.upcoming(page: page)
        
        view.setViewForSearch(isSearching: hasKeyword)
        
        observer.subscribe(onNext: { [unowned self] in
            self.setPaginate(page: $0)
        }, onError: { [ unowned self ] error in
            self.view.afterError(error: error)
        }).disposed(by: disposeBag)
    }
    
    func requestAfterFail() {
        if listGenres.isEmpty {
            genres()
        }
        else {
            nextPage()
        }
    }
    
    private func setPaginate(page: MoviePage) {
        paginate.page = page.page
        paginate.pages = page.total_pages
        if hasKeyword && paginate.page == 1 {
            searchMovies.removeAll()
        }
        
        if hasKeyword {
            searchMovies += page.results
        }
        else {
            upcomingMovies += page.results
        }
        
        if page.total_results == 0 && page.page == 1 {
            view.moviesNotFound()
        }
        else if paginate.isLastPage {
            view.hideLoading()
        }
        
        view.refreshView()
        
        if let page = paginate.nextPageToLoad() {
            requestMovies(page: page)
        }
    }
}
