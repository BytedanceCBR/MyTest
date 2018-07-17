//
//  AccountAPITests.swift
//  BubbleTests
//
//  Created by linlin on 2018/7/17.
//  Copyright © 2018年 linlin. All rights reserved.
//

import XCTest
@testable import Bubble
import RxSwift
class AccountAPITests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequestSmsCode() {
        let disposeBag = DisposeBag()
        let exp = self.expectation(description: "")
        requestSMSVerifyCode(mobileString: "18649111370", oldMobile: nil, bdCodeType: 24, captcha: nil)
            .debug()
            .subscribe(onNext: { (_) in

            }, onError: { (error) in
                XCTAssertNil(error)
            }, onCompleted: {
                exp.fulfill()
            }).disposed(by: disposeBag)
        waitForExpectations(timeout: 3, handler: nil)
    }
    

    
}
