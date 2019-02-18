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
    
    var userCurrentCityText: YYCache? = {
        YYCache(name: "currentcitytext")
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


    @objc override init() {
        super.init()

    }



    @objc func onStart() {
        
        try? reachability.startNotifier()


        accountConfig.loadAccount()
        
        let categoryStartName = SSCommonLogic.feedStartCategory()
        
        if categoryStartName != "f_house_news", categoryStartName != nil{
            //请求推荐频道是否显示红点
            self.messageManager.startSyncCategoryBadge()
        }

        
//        EnvContext.shared.client.accountConfig.userInfo
//            .bind {[weak self] user in
//                if user == nil {
//                    self?.messageManager.stopSyncMessage()
//                } else {
//                    self?.messageManager.startSyncMessage()
//                }
//            }
//            .disposed(by: disposeBag)

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

    
    @objc
    func setUserInfo(user: TTAccountUserEntity?) {
        self.accountConfig.userInfo.accept(TTAccount.shared().user())
    }
    
    @objc func currentLocation() -> CLLocationCoordinate2D {
        
        if let location = locationManager.currentLocation.value {
            return location.coordinate
        }
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    
    deinit {
//        reachability.stopNotifier()
    }
}

