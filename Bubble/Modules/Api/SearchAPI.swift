//
//  SearchAPI.swift
//  Bubble
//
//  Created by linlin on 2018/6/24.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

func requestSearch(
    offset: Int64 = 0,
    query: String = "") -> Observable<HouseRecommendResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/search?"
    if !query.isEmpty {
        url = "\(url)\(query)"
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: ["offset": offset],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> HouseRecommendResponse? in
            if let payload = payload {
                let response = HouseRecommendResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func pageRequestErshouHouseSearch(
    query: String = "") -> () ->  Observable<HouseRecommendResponse?> {
    var offset: Int64 = 0
    return {
        return requestSearch(
            offset: offset,
            query: query)
            .do(onNext: { (response) in
                if let count = response?.data?.items?.count {
                    offset = offset + Int64(count)
                }
            })
    }
}
