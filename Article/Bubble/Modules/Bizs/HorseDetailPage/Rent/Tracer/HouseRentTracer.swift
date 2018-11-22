//
//  HouseRentTracer.swift
//  Article
//
//  Created by leo on 2018/11/21.
//

import Foundation

class HouseRentTracer {
    var logPb: Any?
    var pageType: String
    var houseType: String
    var stayPageParams: TracerParams
    var cardType: String
    init(pageType: String,
         houseType: String,
         cardType: String) {
        self.pageType = pageType
        self.houseType = houseType
        self.cardType = cardType
        stayPageParams = TracerParams.momoid()
    }

    func recordGoDetail() {

    }

    func recordStayPage() {

    }
}
