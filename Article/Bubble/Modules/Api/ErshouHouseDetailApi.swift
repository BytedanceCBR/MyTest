//
//  ErshouHouseDetailApi.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/3.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper


func requestErshouHouseDetail(houseId: Int64, logPB: [String: Any]? = nil) -> Observable<ErshouHouseDetailResponse?> {
    let url = "\(EnvContext.networkConfig.host)/f100/api/house/info"
    var params = [String: Any]()
    if let logPB = logPB {
        params.merge(logPB) { (l, r) -> Any in
            r
        }
    }
    params["house_type"] = HouseType.secondHandHouse.rawValue
    params["house_id"] = houseId
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
//            params: ["house_type": HouseType.secondHandHouse.rawValue,
//                     "house_id": houseId],
            params: params,
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> ErshouHouseDetailResponse? in
            if let payload = payload {
                let response = ErshouHouseDetailResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}
