//
//  UserMessageEntitiesApi.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

func requestUserUnread(query: String = "") -> Observable<UserUnreadMessageResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/msg/unread"
    if !query.isEmpty {
        url = "\(url)&\(query)"
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
        .map({ (payload) -> UserUnreadMessageResponse? in
            if let payload = payload {
                let response = UserUnreadMessageResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func requestCategroyRefreshTip(query: String = "") -> Observable<CategroyRefreshTipResponse?> {
    var streamUrlV: String = "v78" //默认streamversion 是 78
    if let streamVersion = ArticleURLSetting.streamAPIVersionString() {
        streamUrlV = "v" + streamVersion
    }
    var url = "\(EnvContext.networkConfig.host)/2/article/\(streamUrlV)/refresh_tip/"
    
    if !query.isEmpty {
        url = "\(url)&\(query)"
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
        .map({ (payload) -> CategroyRefreshTipResponse? in
            if let payload = payload {
                let response = CategroyRefreshTipResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func requestUserMessageList(
    listId: String = "",
    searchId: String? = nil,
    minCursor: String = "0",
    limit: String="10",
    query: String = "") -> Observable<UserListMessageResponse?> {
    var url = "\(EnvContext.networkConfig.host)/f100/api/msg/list?list_id=\(listId)&max_cursor=\(minCursor)&limit=\(limit)"
    if let theSearchId = searchId {
        url = "\(url)&search_id=\(theSearchId)"
    }
    if !query.isEmpty {
        url = "\(url)&\(query)"
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
        .map({ (payload) -> UserListMessageResponse? in
            if let payload = payload {
                let response = UserListMessageResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}


func pageRequestUserMessageList(
    listId: String = "",
    limit: String="10",
    query: String = "") -> () -> Observable<UserListMessageResponse?> {
    var course: String = "0"
    var searchId: String?
    return {
        return requestUserMessageList(
            listId: listId,
            searchId: searchId,
            minCursor: course,
            limit: limit,
            query: query)
            .do(onNext: { (response) in
                course = response?.data?.minCursor ?? ""
                searchId = response?.data?.searchId
            })
    }
}

func requestSystemNotification(listId: String, maxCoursor: String = "0") -> Observable<SystemNotificationResponse?> {
    let url = "\(EnvContext.networkConfig.host)/f100/api/v2/msg/system_list"
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: ["max_cursor": maxCoursor,
                     "list_id": listId],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> SystemNotificationResponse? in
            if let payload = payload {
                let response = SystemNotificationResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}
