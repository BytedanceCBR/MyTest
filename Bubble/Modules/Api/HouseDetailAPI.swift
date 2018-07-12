//
// Created by linlin on 2018/6/29.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import TTNetworkManager
import ObjectMapper


func requestNewHouseDetail(houseId: Int64) -> Observable<HouseDetailResponse?> {
    let url = "\(EnvContext.networkConfig.host)/api/court/info"
    return TTNetworkManager.shareInstance().rx
            .requestForBinary(
                    url: url,
                    params: ["house_type": HouseType.newHouse.rawValue,
                             "court_id": houseId],
                    method: "GET",
                    needCommonParams: true)
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

func requestNewHousePrice(houseId: Int64, count: Int64, page: Int64 = 0) -> Observable<CourtPriceResponse?> {
    let url = "\(EnvContext.networkConfig.host)/api/court/pricing"
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: [
                "court_id": houseId,
                "page": page,
                "count": count],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> CourtPriceResponse? in
            if let payload = payload {
                let response = CourtPriceResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func pageRequestNewHousePrice(houseId: Int64, count: Int64 = 15) -> () ->  Observable<CourtPriceResponse?> {
    var offset: Int64 = 0
    return {
        return requestNewHousePrice(houseId: houseId, count: count, page: offset)
            .do(onNext: { (response) in
                offset = offset + 1
            })
    }
}

func requestNewHouseTimeLine(houseId: Int64, count: Int64, page: Int64 = 0) -> Observable<CourtTimelineResponse?> {
    let url = "\(EnvContext.networkConfig.host)/api/court/timeline"
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: [
                "court_id": houseId,
                "count": count,
                "page": page
                ],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> CourtTimelineResponse? in
            if let payload = payload {
                let response = CourtTimelineResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func pageRequestNewHouseTimeLine(houseId: Int64, count: Int64 = 15) -> () ->  Observable<CourtTimelineResponse?> {
    var offset: Int64 = 0
    return {
        return requestNewHouseTimeLine(houseId: houseId, count: count, page: offset)
                .do(onNext: { (response) in
                    offset = offset + 1
                })
    }
}

func requestNewHouseFloorPan(houseId: Int64) -> Observable<CourtFloorPanResponse?> {
    let url = "\(EnvContext.networkConfig.host)/api/court/floorplan"
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: [
                "court_id": houseId,
            ],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> CourtFloorPanResponse? in
            if let payload = payload {
                let response = CourtFloorPanResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func requestNewHouseComment(houseId: Int64, count: Int64, page: Int64 = 0) -> Observable<CourtComentResponse?> {
    let url = "\(EnvContext.networkConfig.host)/api/court/comment"
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: [
                "court_id": houseId,
                "count": count,
                "page": page
            ],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> CourtComentResponse? in
            if let payload = payload {
                let response = CourtComentResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}

func pageRequestNewHouseComment(houseId: Int64, count: Int64) -> () ->  Observable<CourtComentResponse?> {
    var offset: Int64 = 0
    return {
        return requestNewHouseComment(houseId: houseId, count: count, page: offset)
                .do(onNext: { (response) in
                    if let count = response?.data?.list?.count, count > 0 {
                        offset = offset + 1
                    }
                })
    }
}


func requestNewHouseMoreDetail(houseId: Int64) -> Observable<CourtMoreDetailResponse?> {
    let url = "\(EnvContext.networkConfig.host)/api/court/detail"
    return TTNetworkManager.shareInstance().rx
        .requestForBinary(
            url: url,
            params: [
                "court_id": houseId,
            ],
            method: "GET",
            needCommonParams: true)
        .map({ (data) -> NSString? in
            NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        })
        .map({ (payload) -> CourtMoreDetailResponse? in
            if let payload = payload {
                let response = CourtMoreDetailResponse(JSONString: payload as String)
                return response
            } else {
                return nil
            }
        })
}
