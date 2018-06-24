//
//  ConfigurationAPI.swift
//  Bubble
//
//  Created by linlin on 2018/6/22.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import TTNetworkManager
import ObjectMapper

func requestSearchConfig(cityId: String = "133") -> Observable<SearchConfigResponse?> {
    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: "http://10.6.131.78:7881/api/search_config",
                    params: ["city_id": cityId],
                    method: "GET",
                    needCommonParams: false)
            .map({ (data) -> NSString? in
                NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            })
            .map({ (payload) -> SearchConfigResponse? in
                if let payload = payload {
                    print(payload)
                    let response = SearchConfigResponse(JSONString: payload as String)
                    return response
                } else {
                    return nil
                }
            })
}
