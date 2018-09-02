//
//  Upcoming_MoviesTests.swift
//  Upcoming MoviesTests
//
//  Created by Robson Fernandes on 02/09/18.
//  Copyright © 2018 ArcTouch. All rights reserved.
//

import XCTest
import RxSwift
@testable import Upcoming_Movies

class Upcoming_MoviesTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    var service: MovieService!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        disposeBag = DisposeBag()
        service = MovieService()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testUpcomingMovies() {
        let expectation = XCTestExpectation(description: "Request upcoming movies has more than 1 movie")
        
        service.upcoming(page: 1).subscribe(onNext: { page in
            XCTAssertGreaterThan(page.total_results, 1)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testSearchBackToTheFutureMovie() {
        let expectation = XCTestExpectation(description: "Search Back to the Future movie at first page")
        let movieTitle = "Back to the Future"
                
        service.search(keyword: movieTitle, page: 1).subscribe(onNext: { page in
            let movie = page.results.first(where: { $0.title == movieTitle })
            XCTAssertNotNil(movie)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testSearchNotFoundForMeuFilmeEmSantaCatarina() {
        let expectation = XCTestExpectation(description: "Search Not Found for movie Meu Filme em Santa Catarina")
        let movieTitle = "Meu Filme em Santa Catarina"
        
        service.search(keyword: movieTitle, page: 1).subscribe(onNext: { page in
            XCTAssertEqual(page.total_results, 0)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFailForSimultaneouslyRequest() {
        let expectation = XCTestExpectation(description: "Fail on request after request")
        
        let number1 = Int(arc4random_uniform(1000))
        let keyword1 = "Meu Filme em Santa Catarina \(number1)"
        
        let number2 = Int(arc4random_uniform(10000))
        let keyword2 = "Datas de casamento para noivas e padrinhos \(number2)"
        
        service.search(keyword: keyword1, page: 1).subscribe(onNext: { [unowned self] _ in
            self.service.search(keyword: keyword2, page: 1).subscribe(onNext: { _ in
                XCTAssert(false, "Both requests were done sucessfully")
                expectation.fulfill()
            }, onError: { _ in
                XCTAssert(true, "Fails at request #2")
                expectation.fulfill()
            })
            .disposed(by: self.disposeBag)
        }, onError: { _ in
            XCTAssert(true, "Fails at request #1")
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        
        wait(for: [expectation], timeout: 10.0)
    }




}
