//
// Created by linlin on 2018/6/29.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import TTNetworkManager
import ObjectMapper


func requestNewHouseDetail(houseId: Int) -> Observable<HouseDetailResponse?> {
    let url = "http://m.quduzixun.com/f100/api/court/info"
    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: url,
                    params: ["house_type": HouseType.newHouse.rawValue,
                             "court_id": houseId],
                    method: "GET",
                    needCommonParams: false)
            .map({ (data) -> NSString? in
                NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            })
            .map({ (payload) -> HouseDetailResponse? in
                if let payload = payload {
                    let response = HouseDetailResponse(JSONString: payload as String)
                    return response
                } else {
                    return nil
                }
            })
}
