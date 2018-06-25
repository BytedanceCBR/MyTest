//
//  SearchAPI.swift
//  Bubble
//
//  Created by linlin on 2018/6/24.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import TTNetworkManager
import ObjectMapper

func requestSearch(cityId: String = "133", query: String = "") -> Observable<HouseRecommendResponse?> {
    var url = "http://m.quduzixun.com/f100/api/search?city_id=\(cityId)"
    if !query.isEmpty {
        url = "\(url)&\(query)"
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: nil,
            method: "GET",
            needCommonParams: false)
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
