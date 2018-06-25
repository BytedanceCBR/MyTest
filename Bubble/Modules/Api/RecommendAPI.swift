//
// Created by linlin on 2018/6/19.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import TTNetworkManager
import ObjectMapper

func requestHouseRecommend() -> Observable<HouseRecommendResponse1?> {
    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: "http://m.quduzixun.com/f100/api/recommend",
                    params: ["city_id": "133"],
                    method: "GET",
                    needCommonParams: true)
            .map({ (data) -> NSString? in
                let result = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                return result
            })
            .map({ (payload) -> HouseRecommendResponse1? in
                if let payload = payload {
                    let response = HouseRecommendResponse1(JSONString: payload as String)
                    return response
                } else {
                    return nil
                }
            })
}

func requestSuggestion(
        cityId: Int,
        horseType: Int,
        query: String? = nil) -> Observable<SuggestionResponse?> {
    var params: [String : Any] = [
            "city_id": cityId,
            "house_type": horseType,
            "source": "app"]
    if let query = query {
        params["query"] = query
    }
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: "http://m.quduzixun.com/f100/api/get_suggestion",
            params: params,
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> SuggestionResponse? in
            if let payload = payload {
                let response = SuggestionResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}
