//
//  Client.swift
//  Bubble
//
//  Created by linlin on 2018/6/22.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import YYCache
import RxSwift
import RxCocoa
class Client {

    lazy private var searchConfigCache: YYCache? = {
        YYCache(name: "config")
    }()

    let configCacheSubject = BehaviorRelay<SearchConfigResponseData?>(value: nil)

    let generalCacheSubject = BehaviorRelay<GeneralConfigData?>(value: nil)

    let disposeBag = DisposeBag()

    init() {
    }

    func onStart() {
        if let searchConfigCache = searchConfigCache {
            if !searchConfigCache.containsObject(forKey: "config") {
                fetchSearchConfig()
            } else {
                let configPayload = searchConfigCache.object(forKey: "search_config") as! String
                let config = SearchConfigResponseData(JSONString: configPayload)
                configCacheSubject.accept(config)

                let generalPayload = searchConfigCache.object(forKey: "general_config") as! String
                let generalConfig = GeneralConfigData(JSONString: generalPayload)
                generalCacheSubject.accept(generalConfig)
            }
        }

        fetchGeneralConfig()
    }

    private func fetchSearchConfig() {
        requestSearchConfig(cityId: "133")
                .observeOn(CurrentThreadScheduler.instance)
                .subscribeOn(CurrentThreadScheduler.instance)
                .subscribe(onNext: { [unowned self] response in
                    self.configCacheSubject.accept(response?.data)
                    if let payload = response?.data?.toJSONString() {
                        self.searchConfigCache?.setObject(payload as NSString, forKey: "search_config")
                    }
                }, onError: { error in
                    print(error)
                })
                .disposed(by: disposeBag)
    }

    private func fetchGeneralConfig() {
        requestGeneralConfig()
            .debug("requestGeneralConfig")
            .observeOn(CurrentThreadScheduler.instance)
            .subscribeOn(CurrentThreadScheduler.instance)
            .subscribe(onNext: { [unowned self] response in
                self.generalCacheSubject.accept(response?.data)
                if let payload = response?.data?.toJSONString() {
                    self.searchConfigCache?.setObject(payload as NSString, forKey: "general_config")
                }
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}
