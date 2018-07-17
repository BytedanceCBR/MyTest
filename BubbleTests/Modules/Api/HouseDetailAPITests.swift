//
//  HouseDetailAPITests.swift
//  BubbleTests
//
//  Created by linlin on 2018/6/29.
//  Copyright © 2018年 linlin. All rights reserved.
//

import XCTest
@testable import Bubble
import RxSwift
class HouseDetailAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequestNewHouseDetail() {
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestNewHouseDetail(houseId: 15303579811814)
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                let imageGroup = response?.data?.imageGroup
                XCTAssertNotNil(imageGroup)
                XCTAssertEqual(imageGroup!.count, 4)

                XCTAssertNotNil(response?.data?.coreInfo)

                XCTAssertNotNil(response?.data?.timeLine)
                XCTAssertNotNil(response?.data?.globalPricing)
            }, onError: { (error) in
                XCTAssert(false)
            }, onCompleted: {
                exp.fulfill()
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testRequestNewHousePrice() {
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestNewHousePrice(houseId: 6573911052528910605, count: 10)
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                XCTAssertNotNil(response?.data?.hasMore)
                XCTAssertNotNil(response?.data?.list?.first?.agencyName)
                XCTAssertNotNil(response?.data?.list?.first?.fromUrl)

            }, onError: { (error) in
                XCTAssert(false)
            }, onCompleted: {
                exp.fulfill()
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testRequestNewHouseTimeLine() {
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestNewHouseTimeLine(houseId: 6573911052528910605, count: 10, page: 0)
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                XCTAssertNotNil(response?.data?.hasMore)
                XCTAssertNotNil(response?.data?.list?.first?.title)
                XCTAssertNotNil(response?.data?.list?.first?.desc)
                
            }, onError: { (error) in
                XCTAssert(false)
            }, onCompleted: {
                exp.fulfill()
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testRequestNewHouseFloorPan() {
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestNewHouseFloorPan(houseId: 6573911052528910605)
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
//                XCTAssertNotNil(response?.data?.hasMore)
                XCTAssertNotNil(response?.data?.list?.first?.saleStatus)
                XCTAssertNotNil(response?.data?.list?.first?.images)
                
            }, onError: { (error) in
                XCTAssert(false)
            }, onCompleted: {
                exp.fulfill()
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testRequestNewHouseComment() {
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestNewHouseComment(houseId: 6573911052528910605, count: 10, page: 0)
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                XCTAssertNotNil(response?.data?.hasMore)
                XCTAssertNotNil(response?.data?.list?.first?.userName)
                XCTAssertNotNil(response?.data?.list?.first?.content)
                
            }, onError: { (error) in
                XCTAssert(false)
            }, onCompleted: {
                exp.fulfill()
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testRequestNewHouseMoreDetail() {
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestNewHouseMoreDetail(houseId: 6573911052528910605)
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                XCTAssertNotNil(response?.data?.heating)
                XCTAssertNotNil(response?.data?.saleStatus)
                XCTAssertNotNil(response?.data?.openDate)

                
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
