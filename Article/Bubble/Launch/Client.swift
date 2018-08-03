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
import Reachability


extension Notification.Name {
    static let discovery = Notification.Name("jump_to_discovery")
}


class Client: NSObject {

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

    lazy var reachability: Reachability = {
        let re = Reachability()!
        return re
    }()

    var did: String?
    var iid: String?

    @objc var commonParamsProvider: (() -> [AnyHashable: Any])?

    @objc var jumpToDiscovery: (() -> Void)?

    @objc override init() {
        super.init()
        locationManager.currentLocation
                .filter { $0 != nil }
                .debug("currentLocation")
                .subscribe(onNext: { [weak self] (cityId) in
                    self?.generalBizconfig.fetchConfiguration()
                    self?.setCommonNetwork()
                })
                .disposed(by: disposeBag)
        generalBizconfig.currentSelectCityId
                .subscribe(onNext: { [weak self] (cityId) in
                    if let cityId = cityId, self?.generalBizconfig.generalCacheSubject.value?.currentCityId ?? 0 != Int64(cityId){
                        self?.generalBizconfig.fetchConfiguration()
                    }
                    self?.fetchSearchConfig()
                    self?.setCommonNetwork()
                })
                .disposed(by: disposeBag)

        NotificationCenter.default.rx
                .notification(.discovery)
                .subscribe(onNext: { [unowned self] notification in
                    self.jumpToDiscovery?()
                }).disposed(by: disposeBag)

//        TTRoute.registerEntry("fschema://house_list", withObjClass: CategoryListPageVC.self)
    }

    @objc func setCommonNetwork() {
        let commonParams = NetworkCommonParams.monoid()
                <- locationManager.locationParams()
                <- generalBizconfig.commonParams()
                <- self.commonParams()
        commonParamsProvider = commonParams.params
//        TTNetworkManager.shareInstance().commonParams = commonParams.params()
    }

    @objc func onStart() {
        try? reachability.startNotifier()
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
                channel: "local_test") { [weak self] (did, iid) in
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
        requestSearchConfig()
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

    deinit {
        reachability.stopNotifier()
    }
}

