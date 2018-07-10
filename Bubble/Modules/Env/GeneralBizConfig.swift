//
// Created by linlin on 2018/7/10.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import YYCache
import RxSwift
import RxCocoa
import TTNetworkManager
class GeneralBizConfig {

    lazy private var searchConfigCache: YYCache? = {
        YYCache(name: "config")
    }()

    let generalCacheSubject = BehaviorRelay<GeneralConfigData?>(value: nil)

    let currentSelectCityId = BehaviorRelay<Int?>(value: nil)

    weak var locationManager: LocationManager?

    let disposeBag = DisposeBag()

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }

    func load() {
        if let searchConfigCache = searchConfigCache {
            if !searchConfigCache.containsObject(forKey: "config") {
                fetchConfiguration()
            } else {
                let generalPayload = searchConfigCache.object(forKey: "general_config") as! String
                let generalConfig = GeneralConfigData(JSONString: generalPayload)
                generalCacheSubject.accept(generalConfig)
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
                    self.searchConfigCache?.setObject(payload as NSString, forKey: "general_config")

                }
                if let currentCityId = response?.data?.currentCityId {
                    self.currentSelectCityId.accept(Int(currentCityId))
                }
            }, onError: { error in
                    print(error)
            })
            .disposed(by: disposeBag)
    }

    func commonParams() -> () -> [AnyHashable: Any] {
        return { [weak self] in
            var re: [AnyHashable: Any] = [:]
            if let selectCityId = self?.currentSelectCityId.value {
                re["city_id"] = selectCityId
            }
            return re
        }
    }
}
