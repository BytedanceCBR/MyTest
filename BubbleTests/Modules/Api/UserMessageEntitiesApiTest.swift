//
//  UserMessageEntitiesApi.swift
//  BubbleTests
//
//  Created by mawenlong on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import XCTest
@testable import Bubble
import RxSwift


class UserMessageEntitiesApi: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMsgUnread() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestUserUnread(query: "")
            .debug()
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                let courtItemOne = response?.data?.unread?.first
                XCTAssertNotNil(courtItemOne)
                
                XCTAssertNotNil(courtItemOne?.dateStr)
                XCTAssertNotNil(courtItemOne?.content)
                XCTAssertNotNil(courtItemOne?.id)
            }, onError: { (error) in
                XCTAssert(false)
            }, onCompleted: {
                exp.fulfill()
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testMsgList() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestUserList(listId: "303", minCursor: "", limit: "10", query: "")
            .debug()
            .subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response?.data)
                XCTAssertNotNil(response?.data?.minCursor)
                XCTAssertNotNil(response?.data?.hasMore)

                let courtItemOne = response?.data?.items?.first
                XCTAssertNotNil(courtItemOne)
                XCTAssertNotNil(courtItemOne?.dateStr)
                XCTAssertNotNil(courtItemOne?.title)
                XCTAssertNotNil(courtItemOne?.id)
                
                let courtItemInnerOne = response?.data?.items?.first?.items?.first
                XCTAssertNotNil(courtItemInnerOne)
                XCTAssertNotNil(courtItemInnerOne?.description)
                XCTAssertNotNil(courtItemInnerOne?.title)
                XCTAssertNotNil(courtItemInnerOne?.id)
                
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
