//
// Created by linlin on 2018/7/10.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

func defaultCityId() -> String {
    guard let channel = Bundle.main.infoDictionary?["CHANNEL_NAME"] as? String else{
        return "786"
    }
    if "local_test" ==  channel {
        return "122"
    }
    return "786"

}

class GeneralBizConfig {

    static let CONFIG_KEY_SELECT_CITY_ID = "config_key_select_city_id"

    lazy private var searchConfigCache: YYCache? = {
        YYCache(name: "general_config")
    }()

    let generalCacheSubject = BehaviorRelay<GeneralConfigData?>(value: nil)

    let currentSelectCityId = BehaviorRelay<Int?>(value: nil)

    weak var locationManager: LocationManager?

    let disposeBag = DisposeBag()

    var disposeBagConfig = DisposeBag()

    let cityHistoryDataSource = CountryListHistoryDataSource()

    var hasSetTemporySelectCity = false

    var tempCityIdValue : String? = defaultCityId()

    init(locationManager: LocationManager) {

        self.locationManager = locationManager
        // 监控城市列表选择
        currentSelectCityId
            .skip(1)
//            .ifEmpty(default: 122)
            .filter { $0 != nil }
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] (cityId) in
                if let item = self.cityItemById()(cityId) {
                    self.cityHistoryDataSource.addHistory(item: item, maxSaveCount: 10)
                    //TODO leo
//                    if let generalConfig = EnvContext.shared.client.generalBizconfig.generalCacheSubject.value {
//                        if let currentCityId = generalConfig.currentCityId, Int(currentCityId) != cityId {
//                            self.fetchConfiguration()
//                        }
//                    }
                    EnvContext.shared.client.currentCitySwitcher.onSetCurrentCityId(cityId: cityId)
                }
            })
            .disposed(by: disposeBag)
    }

    func load() {
        if let searchConfigCache = searchConfigCache {
            if !searchConfigCache.containsObject(forKey: "config") {
                fetchConfiguration()
            } else {
                let generalPayload = searchConfigCache.object(forKey: "config") as! String
                let generalConfig = GeneralConfigData(JSONString: generalPayload)
                generalCacheSubject.accept(generalConfig)
                currentSelectCityId.accept(getCurrentSelectCityId())
                if CLLocationManager.authorizationStatus() == .denied {
                    fetchConfiguration()
                }
            }
        }
    }

    func cityNameById() -> (Int?) -> String? {
        return { [weak self] (cityId) in
            if self?.generalCacheSubject.value == nil,
                let generalPayload = self?.searchConfigCache?.object(forKey: "config") as? String {
                let generalConfig = GeneralConfigData(JSONString: generalPayload)
                self?.generalCacheSubject.accept(generalConfig)
            }
            let cityItem = self?.generalCacheSubject.value?.cityList
                .first { $0.cityId == cityId }
            if cityId != nil {
//                assert(cityItem != nil)
            }
            return cityItem?.name
        }
    }

    func cityItemById() -> (Int?) -> CityItem? {
        return { [weak self] (cityId) in
            if self?.generalCacheSubject.value == nil,
                let generalPayload = self?.searchConfigCache?.object(forKey: "config") as? String {
                let generalConfig = GeneralConfigData(JSONString: generalPayload)
                self?.generalCacheSubject.accept(generalConfig)
            }
            let cityItem = self?.generalCacheSubject.value?.cityList
                .first { $0.cityId == cityId }
            if cityId != nil {
                assert(cityItem != nil)
            }
            return cityItem
        }
    }

    func fetchConfiguration() {
        disposeBagConfig = DisposeBag()
        requestGeneralConfig(cityId: nil,
                             gaodeCityId: locationManager?.currentCity.value?.citycode,
                             lat: locationManager?.currentLocation.value?.coordinate.latitude,
                             lng: locationManager?.currentLocation.value?.coordinate.longitude)
            .observeOn(CurrentThreadScheduler.instance)
            .subscribeOn(CurrentThreadScheduler.instance)
            .retryOnConnect(timeout: 60)
            .retry(50)
            .subscribe(onNext: { [unowned self] response in
                self.generalCacheSubject.accept(response?.data)

                // 只在用户没有选择城市时才回设置城市
                if let currentCityId = response?.data?.currentCityId {
                    if self.getCurrentSelectCityId() == nil && !self.hasSetTemporySelectCity {
                        self.currentSelectCityId.accept(Int(currentCityId))

                        if let _ =  self.locationManager?.currentLocation.value {
                            self.setCurrentSelectCityId(cityId: Int(currentCityId))
                            self.hasSetTemporySelectCity = true
                        }
                    } else {
                        self.hasSetTemporySelectCity = true
                    }
                }
                EnvContext.shared.client.fetchSearchConfig()

                self.generalCacheSubject.accept(response?.data)
                self.saveGeneralConfig(response: response)

                }, onError: { error in
                    //                print(error)
//                    assertionFailure("搜索配置请求异常")
            })
            .disposed(by: disposeBagConfig)
    }
    
    func saveGeneralConfig(response: GeneralConfigResponse?) {
        if let payload = response?.data?.toJSONString(), !payload.isEmpty {
            self.searchConfigCache?.setObject(payload as NSString, forKey: "config")
        }
    }

    func setCurrentSelectCityId(cityId: Int) {
        UserDefaults.standard.set(cityId, forKey: GeneralBizConfig.CONFIG_KEY_SELECT_CITY_ID)
        UserDefaults.standard.synchronize()
    }

    func getCurrentSelectCityId() -> Int? {
        let cityId = UserDefaults.standard
            .integer(forKey: GeneralBizConfig.CONFIG_KEY_SELECT_CITY_ID)
        return cityId == 0 ? nil : cityId
    }

    func tryClearCityIdForLocation() {
        self.tempCityIdValue = nil
        if nil == getCurrentSelectCityId() {
            self.currentSelectCityId.accept(nil)
        }
    }

    func commonParams() -> () -> [AnyHashable: Any] {
        return { [weak self] in
            var re: [AnyHashable: Any] = [:]

            if let selectCityId = self?.currentSelectCityId.value {
                re["city_id"] = selectCityId
            } else {
                re["city_id"] = self?.tempCityIdValue
            }
            re["app_id"] = "1370"
            re["aid"] = "1370"
            re["channel"] = Bundle.main.infoDictionary?["CHANNEL_NAME"]
            re["app_name"] = "f100"
            re["source"] = "app"
            return re
        }
    }

}
