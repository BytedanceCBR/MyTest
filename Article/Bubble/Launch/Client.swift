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
    
    @objc lazy var messageManager: MessageEventManager = {
       let re = MessageEventManager()
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

//    let anrEye = ANREye()

    var did: String?
    var iid: String?

    @objc var commonParamsProvider: (() -> [AnyHashable: Any])?
 
    @objc var jumpToDiscovery: (() -> Void)?

    @objc override init() {
        super.init()
        setCommonNetwork()
        locationManager.currentLocation
                .filter { $0 != nil }
                .subscribe(onNext: { [weak self] (cityId) in
                    self?.generalBizconfig.fetchConfiguration()
                    self?.setCommonNetwork()
                })
                .disposed(by: disposeBag)


        NotificationCenter.default.rx
                .notification(.discovery)
                .subscribe(onNext: { [unowned self] notification in
                    self.jumpToDiscovery?()
                }).disposed(by: disposeBag)
    }

    @objc func setCommonNetwork() {
        let commonParams = NetworkCommonParams.monoid()
                <- locationManager.locationParams()
                <- generalBizconfig.commonParams()
                <- self.commonParams()
        commonParamsProvider = commonParams.params
    }

    @objc func onStart() {
        
        try? reachability.startNotifier()

        generalBizconfig.currentSelectCityId
            .subscribe(onNext: { [weak self] (cityId) in
                if let cityId = cityId, self?.generalBizconfig.generalCacheSubject.value?.currentCityId ?? 0 != Int64(cityId){
                    self?.generalBizconfig.fetchConfiguration()
                    self?.fetchSearchConfig()
                }
                self?.setCommonNetwork()
            })
            .disposed(by: disposeBag)

        setupLocationManager()
        generalBizconfig.load()
        if let searchConfigCache = searchConfigCache {
            if !searchConfigCache.containsObject(forKey: "config") {
//                fetchSearchConfig()
            } else {
                let configPayload = searchConfigCache.object(forKey: "search_config") as! String
                let config = SearchConfigResponseData(JSONString: configPayload)
                assert(config != nil)
                if let config = config {
                    configCacheSubject.accept(config)
                }
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
        
        //请求推荐频道是否显示红点
        self.messageManager.startSyncCategoryBadge()
        
        EnvContext.shared.client.accountConfig.userInfo
            .bind {[weak self] user in
                if user == nil {
                    self?.messageManager.stopSyncMessage()
                } else {
                    self?.messageManager.startSyncMessage()
                }
            }
            .disposed(by: disposeBag)

    }

    func loadSearchCondition() {
        if let searchConfigCache = searchConfigCache,
            configCacheSubject.value == nil,
            let configPayload = searchConfigCache.object(forKey: "search_config") as? String {
            let config = SearchConfigResponseData(JSONString: configPayload)
            assert(config != nil)
            if let config = config {
                configCacheSubject.accept(config)
            } else {
                EnvContext.shared.toast.showToast("the search filter is empty")
            }
        }
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

    func fetchSearchConfig() {
        requestSearchConfig()
                .observeOn(CurrentThreadScheduler.instance)
                .subscribeOn(CurrentThreadScheduler.instance)
                .retryOnConnect(timeout: 60)
                .retry(10)
                .subscribe(onNext: { [unowned self] response in
                    if let config = response?.data, response?.data?.filter != nil {
                        self.configCacheSubject.accept(response?.data)
                        if let payload = config.toJSONString() {
                            self.searchConfigCache?.setObject(payload as NSString, forKey: "search_config")
                        }
                    }
                }, onError: { error in
//                    print(error)
//                    assertionFailure()
                })
                .disposed(by: disposeBag)
    }

    private func setupLocationManager() {
        locationManager.requestCurrentLocation()
    }
    
    @objc
    func setUserInfo(user: TTAccountUserEntity?) {
        self.accountConfig.userInfo.accept(TTAccount.shared().user())
    }

    deinit {
        reachability.stopNotifier()
    }
}

