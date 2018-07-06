//
//  SearchConfigTests.swift
//  BubbleTests
//
//  Created by linlin on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import XCTest
@testable import Bubble
import RxSwift
class SearchConfigTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequestSearchConfig() {
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestSearchConfig(cityId: "133")
            .observeOn(CurrentThreadScheduler.instance)
            .subscribeOn(CurrentThreadScheduler.instance)
            .subscribe(onNext: { [unowned self] response in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data?.filter)
                XCTAssertNotNil(response?.data?.courtFilter)
                XCTAssertNotNil(response?.data?.neighborhoodFilter)
                XCTAssertNotNil(response?.data?.filter)
            }, onError: { (error) in
                XCTAssert(false)
            }, onCompleted: {
                exp.fulfill()
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
}
