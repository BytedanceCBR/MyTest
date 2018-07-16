//
//  NeighborhoodDetailEntitiesApiTest.swift
//  BubbleTests
//
//  Created by mawenlong on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import XCTest
@testable import Bubble
import RxSwift


class NeighborhoodDetailEntitiesApiTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNeighborhoodDetail() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestNeighborhoodDetail(neighborhoodId: "6569027969963213063",  query: "")
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                XCTAssertNotNil(response?.data?.baseInfo)
                XCTAssertNotNil(response?.data?.coreInfo)
                XCTAssertNotNil(response?.data?.statsInfo)
                XCTAssertNotNil(response?.data?.neighborhoodInfo)
                XCTAssertNotNil(response?.data?.totalSales)
       
            }, onError: { (error) in
                XCTAssert(false)
            }, onCompleted: {
                exp.fulfill()
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testNeighborhoodTotalSales() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestNeighborhoodTotalSales(neighborhoodId: "6569028179917291780",  query: "")
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                XCTAssertNotNil(response?.data?.hasMore)
                XCTAssertNotNil(response?.data?.list?.first)
                XCTAssertNotNil(response?.data?.list?.first?.squaremeter)
                XCTAssertNotNil(response?.data?.list?.first?.pricing)
    
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
