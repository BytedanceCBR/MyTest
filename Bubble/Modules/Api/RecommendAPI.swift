//
// Created by linlin on 2018/6/19.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import TTNetworkManager
import ObjectMapper

func requestHouseRecommend() -> Observable<HouseRecommendResponse?> {
    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: "http://m.quduzixun.com/api/ershoufang/recommend?city_id=133",
                    params: ["city_id": "133"],
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
