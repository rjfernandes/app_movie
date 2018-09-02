//
//  MainProtocol.swift
//  Upcoming Movies
//
//  Created by Robson Fernandes on 31/08/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import Foundation

protocol MainViewProtocol {
    /**
     * Boolean flag that indicates it is in search mode
     */
    func setViewForSearch(isSearching: Bool)
    
    /**
     * Refresh a view
     */
    func refreshView()
    
    /**
     * Indicates when is requesting genres
     */
    func loadingGenres()
    
    /**
     * Trigged after request all genres
     */
    func afterLoadingGenres()

    /**
     * Indicates when is requesting upcoming movies
     */
    func loadingMovies()
    
    /**
     * Indicates when is requesting a search for movies
     */
    func searchingMovies()
    
    /**
     * Indicates when last request returns no movies
     */
    func moviesNotFound()
    
    /**
     * Indicates when there no more pages to request
     */
    func hideLoading()
    
    /**
     * Trigged when occorring any error on request
     */
    func afterError(error: Error)
}

protocol MainPresenterProtocol {
    /**
     * Request all genres
     */
    func genres()

    /**
     * Current movie page from pagination
     */
    var currentPage: Int { get }
    
    /**
     * Count movies until last page downloaded
     */
    var moviesCount: Int { get }

    /**
     * Indicate if can download next result page from api
     */
    func canDownloadNextPage(index: Int) -> Bool

    /**
     * Get a movie and genres by a given index
     */
    func movieGenresBy(index: Int) -> MovieGenres

    /**
     * Search movies with a keyword
     */
    func search(keyword: String?)

    /**
     * Clear search
     */
    func clearSearch()

    /**
     * Load next page of movies
     */
    func nextPage()
    
    /**
     * Request a failed resource again
     */
    func requestAfterFail()
}
