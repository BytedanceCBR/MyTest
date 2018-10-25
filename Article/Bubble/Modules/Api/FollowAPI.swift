//
//  FollowAPI.swift
//  Bubble
//
//  Created by linlin on 2018/7/18.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

enum FollowActionType: Int {
    case newHouse = 1
    case ershouHouse = 2
    case rentHouse = 3
    case neighborhood = 4
    case newHousePriceChanged = 5
    case openFloorPan = 6

}

func requestFollow(
        houseType: HouseType,
        followId: String,
        actionType: FollowActionType) -> Observable<UserFollowResponse?> {
        let url = "\(EnvContext.networkConfig.host)/f100/api/user_follow?house_type=\(houseType.rawValue)"
//    let url = "http://m.quduzixun.com/f100/api/user_follow?house_type=\(houseType.rawValue)"
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: ["follow_id": followId,
                     "action_type": actionType.rawValue],
            method: "POST",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> UserFollowResponse? in
            if let payload = payload {
                let response = UserFollowResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func requestCancelFollow(
    houseType: HouseType,
    followId: String,
    actionType: FollowActionType) -> Observable<UserFollowResponse?> {
    let url = "\(EnvContext.networkConfig.host)/f100/api/cancel_user_follow?house_type=\(houseType.rawValue)"
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: ["follow_id": followId,
                     "action_type": actionType.rawValue],
            method: "POST",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> UserFollowResponse? in
            if let payload = payload {
                let response = UserFollowResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func requestFollowUpList(
        houseType: HouseType,
        searchId: String? = nil,
        offset: Int = 0,
        limit: Int = 10) -> Observable<UserFollowListResponse?> {

    let url = "\(EnvContext.networkConfig.host)/f100/api/get_user_follow?house_type=\(houseType.rawValue)"
    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: url,
                    params: ["house_type": houseType.rawValue,
                             "search_id": searchId ?? "",
                             "offset": offset,
                             "limit": limit],
                    method: "GET",
                    needCommonParams: true)
            .map({ (data) -> NSString? in
                NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            })
            .map({ (payload) -> UserFollowListResponse? in
                if let payload = payload {
                    let response = UserFollowListResponse(JSONString: payload as String)
                    return response
                } else {
                    return nil
                }
            })

}

func pageRequestFollowUpList(
        houseType: HouseType,
        limit: Int = 10) -> () -> Observable<UserFollowListResponse?> {
    var offset: Int = 0
    var searchId: String?

    return {
        return requestFollowUpList(
                houseType: houseType,
                searchId: searchId,
                offset: offset,
                limit: limit)
                .do(onNext: { (response) in
                    if response?.data?.hasMore ?? false == true {
                        offset = offset + limit
                    } else {
                        offset = offset + (response?.data?.items.count ?? 0)
                    }
                    searchId = response?.data?.searchId
                })
    }
}
