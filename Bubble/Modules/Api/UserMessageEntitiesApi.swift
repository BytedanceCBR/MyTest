//
//  UserMessageEntitiesApi.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import TTNetworkManager
import ObjectMapper

func requestUserUnread(query: String = "") -> Observable<UserUnreadMessageResponse?> {
    var url = "http://m.quduzixun.com/f100/api/msg/unread"
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
        .map({ (payload) -> UserUnreadMessageResponse? in
            if let payload = payload {
                let response = UserUnreadMessageResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}


func requestUserList(listId: String = "", minCursor: String = "", limit: String="0", query: String = "") -> Observable<UserListMessageResponse?> {
    var url = "http://m.quduzixun.com/f100/api/msg/list?list_id=\(listId)&minCursor=\(minCursor)&limit=\(limit)"
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
        .map({ (payload) -> UserListMessageResponse? in
            if let payload = payload {
                let response = UserListMessageResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}
