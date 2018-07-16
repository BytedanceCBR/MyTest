//
//  ErshouHouseDetailAPITests.swift
//  BubbleTests
//
//  Created by mawenlong on 2018/7/3.
//  Copyright © 2018年 linlin. All rights reserved.
//

import XCTest
@testable import Bubble
import RxSwift
class ErshouHouseDetailAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequestErshouHouseDetail() {
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestErshouHouseDetail(houseId: 6570464886776660237)
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                let houseImage = response?.data?.houseImage
                XCTAssertNotNil(houseImage)
                
                XCTAssertNotNil(response?.data?.coreInfo)
                
                XCTAssertNotNil(response?.data?.neighborhoodInfo)
                
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
