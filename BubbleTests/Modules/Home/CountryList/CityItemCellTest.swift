//
//  CityItemCellTest.swift
//  BubbleTests
//
//  Created by linlin on 2018/6/26.
//  Copyright © 2018年 linlin. All rights reserved.
//

import XCTest
@testable import Bubble

class CityItemCellTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetCountryListNode() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let inputs = ["1", "1", "1", "1", "1", "1"]
        let result = groups(items: inputs, rowCount: 4)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.last?.count, 2)

    }

}
