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
            .debug()
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                let imageGroup = response?.data?.imageGroup
                XCTAssertNotNil(imageGroup)
                XCTAssertEqual(imageGroup!.count, 4)

                XCTAssertNotNil(response?.data?.coreInfo)

                XCTAssertNotNil(response?.data?.timeLine)
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
