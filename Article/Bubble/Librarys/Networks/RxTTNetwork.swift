//
//  RxTTNetwork.swift
//  Bubble
//
//  Created by linlin on 2018/6/11.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift

extension TTNetworkManager: ReactiveCompatible {

}

extension Reactive where Base: TTNetworkManager {

    func requestForBinary(
        url: String,
        params: [String: Any]? = nil,
        method: String = "GET",
        needCommonParams: Bool = false) -> Observable<Data> {
        return Observable.create({ (observable) -> Disposable in
            let task = TTNetworkManager.shareInstance()
                .requestForBinary(
                    withURL: url,
                    params: params,
                    method: method,
                    needCommonParams: needCommonParams,
                    callback: { (error, response) in
                        if let error = error {
                            observable.onError(error)
                        } else {
                            if let response = response as? Data {
                                observable.onNext(response)
                                observable.onCompleted()
                            } else {
                                assertionFailure("网络数据读取失败")
                                observable.onCompleted()
                            }
                        }
                })
            return Disposables.create {
                task?.cancel()
            }
        })
    }
    
    func requestForModel(
        url: String,
        params: [String: Any]? = nil,
        method: String = "post",
        needCommonParams: Bool = false) -> Observable<Data> {
        return Observable.create({ (observable) -> Disposable in
            let task = TTNetworkManager.shareInstance()
                .requestForBinary(
                    withURL: url,
                    params: params,
                    method: method,
                    needCommonParams: needCommonParams,
                    requestSerializer: AWEPostDataHttpRequestSerializer.self,
                    responseSerializer: TTNetworkManager.shareInstance().defaultBinaryResponseSerializerClass,
                    autoResume: true,
                    callback: { (error, response) in
                        if let error = error {
                            observable.onError(error)
                        } else {
                            if let response = response as? Data {
                                observable.onNext(response)
                                observable.onCompleted()
                            } else {
                                assertionFailure("网络数据读取失败")
                                observable.onCompleted()
                            }
                        }
                })
            return Disposables.create {
                task?.cancel()
            }
        })
    }

    func requestForModel<R>(
        url: String,
        params: [String: Any]? = nil,
        method: String = "get",
        needCommonParams: Bool = false,
        responseSerializer: @escaping (Data) -> R) -> Observable<R> {
        return requestForBinary(
            url: url,
            params: params,
            method: method,
            needCommonParams: needCommonParams)
            .flatMap({ (data) -> Observable<R> in
                .just(responseSerializer(data))
            })
    }

    func postJson<R>(url: String,
                     params: [String: Any]? = nil,
                     method: String = "get",
                     needCommonParams: Bool = false,
                     responseSerializer: @escaping  ((Data) -> R)) -> Observable<R> {
        return Observable.create({ (observable) -> Disposable in
            let task = TTNetworkManager.shareInstance()
                .requestForBinary(
                    withURL: url,
                    params: params,
                    method: method,
                    needCommonParams: needCommonParams,
                    requestSerializer: AWEPostDataHttpRequestSerializer.self,
                    responseSerializer: TTNetworkManager.shareInstance().defaultBinaryResponseSerializerClass,
                    autoResume: true,
                    callback: { (error, response) in

                })

            return Disposables.create {
                task?.cancel()
            }
        })
    }
}
