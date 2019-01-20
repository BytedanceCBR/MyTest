//
//  HouseRentTracer.swift
//  Article
//
//  Created by leo on 2018/11/21.
//

import Foundation
@objc
class HouseRentTracer: NSObject, NSCopying {

    @objc
    var logPb: Any?
    @objc
    var pageType: String
    @objc
    var houseType: String
    @objc
    var houseId: Int64
    @objc
    var ttTrackStayTime: TimeInterval = 0
    var stayPageParams: TracerParams?
    @objc
    var cardType: String
    @objc
    var enterFrom: String
    @objc
    var elementFrom: String
    @objc
    var rank: String
    @objc
    var imprId: String
    @objc
    var hasRecordGoDetail: Bool
    @objc
    var searchId: String?
    @objc
    var groupId: String?
    @objc
    var originFrom : String?
    @objc
    var originSearchId : String?
    @objc
    var enterQuery: String?
    @objc
    var searchQuery: String?
    @objc
    var queryType: String?
    @objc
    var time: String?
    @objc
    var offset: String?
    @objc
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

            stayPageParams = params
            recordEvent(key: "go_detail", params: params)
            hasRecordGoDetail = true
        }

    }

    func recordStayPage() {

        if let stayPageParams = stayPageParams {
            let trackTime = Int64(self.ttTrackStayTime * 1000)
            recordEvent(key: "stay_page", params: stayPageParams <|> toTracerParams(trackTime, key: "stay_time"))
            self.ttTrackStayTime = 0
        }
        
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let tracer = HouseRentTracer(pageType: self.pageType, houseType: self.houseType, cardType: self.cardType)
        tracer.logPb = self.logPb
        tracer.houseId = self.houseId
        tracer.ttTrackStayTime = self.ttTrackStayTime
        tracer.stayPageParams = self.stayPageParams
        tracer.enterFrom = self.enterFrom
        tracer.elementFrom = self.elementFrom
        tracer.rank = self.rank
        tracer.imprId = self.imprId
        tracer.hasRecordGoDetail = self.hasRecordGoDetail
        tracer.searchId = self.searchId
        tracer.groupId = self.groupId
        tracer.originFrom = self.originFrom
        tracer.originSearchId = self.originSearchId
        tracer.enterQuery = self.enterQuery
        tracer.enterQuery = self.searchQuery
        tracer.queryType = self.queryType
        tracer.time = self.time
        tracer.offset = self.offset
        tracer.limit = self.limit
        return tracer
    }

}
