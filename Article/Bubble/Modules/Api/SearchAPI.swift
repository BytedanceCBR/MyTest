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

enum SearchSourceKey: String {
    case oldDetail = "old_detail"
    case neighborhoodDetail = "neighborhood_detail"
}

func requestSearch(
    offset: Int64 = 0,
    query: String = "",
    suggestionParams: String = "") -> Observable<HouseRecommendResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/search?"
    if !query.isEmpty {
        url = "\(url)\(query)"
    }
    print(url)
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: ["offset": offset,
                     "suggestion_params": suggestionParams],
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
        query: String = "",
        suggestionParams: String = "") -> () -> Observable<HouseRecommendResponse?> {
    var offset: Int64 = 0
    return {
        return requestSearch(
                offset: offset,
                query: query,
                suggestionParams: suggestionParams)
        .do(onNext: { (response) in
            if let count = response?.data?.items?.count {
                offset = offset + Int64(count)
            }
        })
    }
}
