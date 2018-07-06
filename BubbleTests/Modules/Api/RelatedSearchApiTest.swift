//
//  RelatedSearchApiTest.swift
//  BubbleTests
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import XCTest
@testable import Bubble
import RxSwift

class RelatedSearchApiTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRelatedHouse() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestRelatedHouseSearch(houseId: "6569032107446944013", offset:"0",  query: "")
            .debug()
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                let courtItems = response?.data?.items
                XCTAssertNotNil(courtItems)
                let courtItemOne = response?.data?.items?.first
                XCTAssertNotNil(courtItemOne)
                
                XCTAssertNotNil(courtItemOne?.title)
                XCTAssertNotNil(courtItemOne?.id)
                XCTAssertNotNil(courtItemOne?.displayTitle)
       
            }, onError: { (error) in
                XCTAssert(false)
            }, onCompleted: {
                exp.fulfill()
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testRelatedCourt() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestRelatedCourtSearch(courtId: "6573911428842045710", offset:"0",  query: "")
            .debug()
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                let courtItems = response?.data?.items
                XCTAssertNotNil(courtItems)
                let courtItemOne = response?.data?.items?.first
                XCTAssertNotNil(courtItemOne)
                
                XCTAssertNotNil(courtItemOne?.title)
                XCTAssertNotNil(courtItemOne?.id)
                XCTAssertNotNil(courtItemOne?.displayTitle)

            }, onError: { (error) in
                XCTAssert(false)
            }, onCompleted: {
                exp.fulfill()
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testRelatedNeighborhood() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestRelatedNeighborhoodSearch(neighborhoodId: "6569027970076360974", offset:0,  query: "")
            .debug()
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                let courtItems = response?.data?.items
                XCTAssertNotNil(courtItems)
                let courtItemOne = response?.data?.items?.first
                XCTAssertNotNil(courtItemOne)
                
                XCTAssertNotNil(courtItemOne?.name)
                XCTAssertNotNil(courtItemOne?.id)
                XCTAssertNotNil(courtItemOne?.displayTitle)
                
            }, onError: { (error) in
                XCTAssert(false)
            }, onCompleted: {
                exp.fulfill()
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
