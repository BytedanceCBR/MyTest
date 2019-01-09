//
//  HouseRentTracer.swift
//  Article
//
//  Created by leo on 2018/11/21.
//

import Foundation
@objc
class HouseRentTracer: NSObject {
    var logPb: Any?
    var pageType: String
    @objc
    var houseType: String
    var houseId: Int64
    var stayPageParams: TracerParams?
    var cardType: String
    var enterFrom: String
    var elementFrom: String
    @objc
    var rank: String
    @objc
    var imprId: String
    var hasRecordGoDetail: Bool
    @objc
    var searchId: String?
    @objc
    var groupId: String?
    var originFrom : String?
    var originSearchId : String?
    var enterQuery: String?
    var searchQuery: String?
    var queryType: String?
    var time: String?
    var offset: String?
    var limit: String?
    init(pageType: String,
         houseType: String,
         cardType: String) {
        self.pageType = pageType
        self.houseType = houseType
        self.cardType = cardType
        self.enterFrom = "be_null"
        self.elementFrom = "be_null"
        self.rank = "be_null"
        self.hasRecordGoDetail = false
        self.searchId = "be_null"
        self.groupId = "be_null"
        self.originFrom = "be_null"
        self.imprId = "be_null"
        self.originSearchId = ""
        self.houseId = -1
    }

    func recordGoDetail() {
        if !hasRecordGoDetail {
            let params = TracerParams.momoid() <|>
                toTracerParams(self.pageType, key: "page_type") <|>
                toTracerParams("rent", key: "house_type") <|>
                toTracerParams(self.cardType, key: "card_type") <|>
                toTracerParams(self.enterFrom, key: "enter_from") <|>
                toTracerParams(self.elementFrom, key: "element_from") <|>
                toTracerParams(self.originFrom ?? "be_null", key: "origin_from") <|>
                toTracerParams(self.originSearchId ?? "be_null", key: "origin_search_id") <|>
                toTracerParams(self.logPb ?? "be_null", key: "log_pb") <|>
                toTracerParams(self.rank, key: "rank")
            stayPageParams = params <|> traceStayTime()
            recordEvent(key: "go_detail", params: params)
            hasRecordGoDetail = true
        }

    }

    func recordStayPage() {
        if let stayPageParams = stayPageParams {
            recordEvent(key: "stay_page", params: stayPageParams)
        }
        self.stayPageParams = nil
    }
}
