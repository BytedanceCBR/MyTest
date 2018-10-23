//
// Created by Siyu Wang on 2018/7/10.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

func requestUserInfo(query: String = "") -> Observable<UserInfoResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/2/user/info"
    if !query.isEmpty {
        url = "\(url)&\(query)"
    }
    if let theUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
        url = theUrl
    }
    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: url,
                    params: nil,
                    method: "GET",
                    needCommonParams: true)
            .map({ (data) -> NSString? in
                NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            })
            .map({ (payload) -> UserInfoResponse? in
                if let payload = payload {
                    let response = UserInfoResponse(JSONString: payload as String)
                    return response
                } else {
                    return nil
                }
            })
}
