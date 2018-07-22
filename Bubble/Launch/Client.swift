//
//  Client.swift
//  Bubble
//
//  Created by linlin on 2018/6/22.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class Client {

    static let appId = "1370"

    lazy private var searchConfigCache: YYCache? = {
        YYCache(name: "config")
    }()

    let configCacheSubject = BehaviorRelay<SearchConfigResponseData?>(value: nil)

    let disposeBag = DisposeBag()

    var hoseType: HouseType = .secondHandHouse

    lazy var locationManager: LocationManager = {
        LocationManager.shared
    }()

    lazy var generalBizconfig: GeneralBizConfig = {
        let re = GeneralBizConfig(locationManager: locationManager)
        return re
    }()

    lazy var accountConfig: AccountConfig = {
        let re = AccountConfig()
        return re
    }()

    var did: String?
    var iid: String?

    init() {
        locationManager.currentLocation
            .subscribe(onNext: { [weak self] _ in
                self?.generalBizconfig.fetchConfiguration()
                self?.setCommonNetwork()
            })
            .disposed(by: disposeBag)
        generalBizconfig.currentSelectCityId
            .subscribe(onNext: { [weak self] _ in
                self?.generalBizconfig.fetchConfiguration()
                self?.setCommonNetwork()
            })
            .disposed(by: disposeBag)
    }

    func setCommonNetwork() {
        let commonParams = NetworkCommonParams.monoid()
            <- locationManager.locationParams()
            <- generalBizconfig.commonParams()
            <- self.commonParams()
        TTNetworkManager.shareInstance().commonParams = commonParams.params()
    }

    @objc func onStart() {
        setupLocationManager()
        generalBizconfig.load()
        if let searchConfigCache = searchConfigCache {
            if !searchConfigCache.containsObject(forKey: "config") {
                fetchSearchConfig()
            } else {
                let configPayload = searchConfigCache.object(forKey: "search_config") as! String
                let config = SearchConfigResponseData(JSONString: configPayload)
                configCacheSubject.accept(config)
            }
        }

        TTInstallIDManager.sharedInstance().start(
                withAppID: Client.appId,
                channel: "local_test",
                appName: "F100") { [weak self] (did, iid) in
                    if let did = did, let iid = iid {
                        self?.did = did
                        self?.iid = iid
                        self?.setCommonNetwork()
                        AccountConfig.setupAccountConfig(did: did, iid: iid, appId: Client.appId)
                    } else {
                        assertionFailure()
                    }
                }

        accountConfig.loadAccount()
//        currentSelectedCityId.accept(UserDefaults.standard.integer(forKey: "selected_city_id"))
//        currentSelectedCityId
//                .subscribe(onNext: { (cityId) in
//                    UserDefaults.standard.set(cityId, forKey: "selected_city_id")
//                    UserDefaults.standard.synchronize()
//                })
//                .disposed(by: disposeBag)
    }

    func commonParams() -> () -> [AnyHashable: Any] {
        return { [weak self] in
            var re: [AnyHashable: Any] = [:]
            if let iid = self?.iid {
                re["iid"] = iid
            }
            if let did = self?.did {
                re["did"] = did
            }
            return re
        }
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

    private func setupLocationManager() {
        locationManager.requestCurrentLocation()
    }
}

