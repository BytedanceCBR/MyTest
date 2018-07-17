//
// Created by linlin on 2018/7/10.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class GeneralBizConfig {

    static let CONFIG_KEY_SELECT_CITY_ID = "config_key_select_city_id"

    lazy private var searchConfigCache: YYCache? = {
        YYCache(name: "general_config")
    }()

    let generalCacheSubject = BehaviorRelay<GeneralConfigData?>(value: nil)

    let currentSelectCityId = BehaviorRelay<Int?>(value: nil)

    weak var locationManager: LocationManager?

    let disposeBag = DisposeBag()

    init(locationManager: LocationManager) {
        self.locationManager = locationManager

        currentSelectCityId
            .filter { $0 != nil }
            .subscribe(onNext: { [unowned self] (cityId) in
                self.setCurrentSelectCityId(cityId: cityId!)
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
                fetchConfiguration()
            }
        }
    }

    func cityNameById() -> (Int?) -> String? {
        return { [weak self] (cityId) in
            let cityItem = self?.generalCacheSubject.value?.cityList
                .first { $0.cityId == cityId }
            return cityItem?.name
        }
    }

    func fetchConfiguration() {
        requestGeneralConfig(cityId: nil,
                             gaodeCityId: locationManager?.currentCity.value?.citycode,
                             lat: locationManager?.currentLocation.value?.coordinate.latitude,
                             lng: locationManager?.currentLocation.value?.coordinate.longitude)
            .observeOn(CurrentThreadScheduler.instance)
            .subscribeOn(CurrentThreadScheduler.instance)
            .subscribe(onNext: { [unowned self] response in
                self.generalCacheSubject.accept(response?.data)
                if let payload = response?.data?.toJSONString() {
                    self.searchConfigCache?.setObject(payload as NSString, forKey: "config")

                }
                if let currentCityId = response?.data?.currentCityId {
                    if self.getCurrentSelectCityId() == nil {
                        self.currentSelectCityId.accept(Int(currentCityId))
                        self.setCurrentSelectCityId(cityId: Int(currentCityId))
                    }
                }
            }, onError: { error in
                    print(error)
            })
            .disposed(by: disposeBag)
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

    func commonParams() -> () -> [AnyHashable: Any] {
        return { [weak self] in
            var re: [AnyHashable: Any] = [:]
            if let selectCityId = self?.currentSelectCityId.value {
                re["city_id"] = selectCityId
            }
            re["app_id"] = "1370"
            re["aid"] = "1370"
            re["channel"] = "local_test"
            re["app_name"] = "F100"
            return re
        }
    }
}
