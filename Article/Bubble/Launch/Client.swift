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


@objc class Client: NSObject {

    static let appId = "1370"

    lazy var searchConfigCache: YYCache? = {
        YYCache(name: "config")
    }()

    var sendPhoneNumberCache: YYCache? = {
        YYCache(name: "phonenumber")
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

    let currentCitySwitcher: CurrentCitySwitcher

//    let anrEye = ANREye()

    var did: String?
    var iid: String?

    @objc var commonParamsProvider: (() -> [AnyHashable: Any])?
 
    @objc var jumpToDiscovery: (() -> Void)?

    @objc override init() {
        currentCitySwitcher = CurrentCitySwitcher(currentCityId: nil)
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
        
        
        generalBizconfig.generalCacheSubject.skip(1).throttle(0.5, latest: false, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] data in
            if let dictValue = data?.toJSON()
            {
                FHHomeConfigManager.sharedInstance().acceptConfigDictionary(dictValue)
            }
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

        //TODO leo
        generalBizconfig.currentSelectCityId
            .subscribe(onNext: { [weak self] (cityId) in
//                if let cityId = cityId, self?.generalBizconfig.generalCacheSubject.value?.currentCityId ?? 0 != Int64(cityId){
////                    self?.generalBizconfig.fetchConfiguration()
////                    self?.fetchSearchConfig()
//                }
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

    @objc
    func currentCityName() -> String? {
        if let city = locationManager.currentCity.value?.city {
            return city
        }
        return "be_null"
    }

    @objc
    func currentProvince() -> String? {
        if let province = locationManager.currentCity.value?.province {
            return province
        }
        return "be_null"
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

    func commonParams() -> () -> [String: Any] {
        return { [weak self] in
            var re: [String: Any] = [:]
//            if let iid = self?.iid {
//                re["iid"] = iid
//            }
//            if let did = self?.did {
//                re["did"] = did
//            }
            return re
        }
    }

    func saveSearchConfigToCache(response: SearchConfigResponse?) {
        if let config = response?.data, response?.data?.filter != nil {
            if let payload = config.toJSONString() {
                self.searchConfigCache?.setObject(payload as NSString, forKey: "search_config")
            }
        }
    }

    func fetchSearchConfig() {
        requestSearchConfig()
                .observeOn(CurrentThreadScheduler.instance)
                .subscribeOn(CurrentThreadScheduler.instance)
                .retryOnConnect(timeout: 60)
                .retry(10)
                .subscribe(onNext: { [unowned self] response in
                    if response?.data?.filter != nil {
                        self.configCacheSubject.accept(response?.data)
                        self.saveSearchConfigToCache(response: response)
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

    // 定位城市和用户选择的是否是同一城市
    @objc func  locationSameAsChooseCity() -> Bool {
        
        
        guard let selectCityId = self.generalBizconfig.getCurrentSelectCityId() else {
            return false
        }
        
        guard let cityName = self.generalBizconfig.cityNameById()(selectCityId) else {
            return false
        }
        
        return LocationManager.shared.isSameCity(cityName: cityName)
        
    }
    
    @objc func currentLocation() -> CLLocationCoordinate2D {
        
        if let location = locationManager.currentLocation.value {
            return location.coordinate
        }
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    deinit {
        reachability.stopNotifier()
    }
}

