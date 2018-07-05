//
//  LocationManager.swift
//  Bubble
//
//  Created by linlin on 2018/6/27.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class LocationManager: NSObject, AMapLocationManagerDelegate {
    static let apiKey = "003c8c31d052f8882bfb2a1d712dea84"

    static let shared = LocationManager()

    private lazy var locationManager: AMapLocationManager = {
        AMapLocationManager()
    }()
    let currentLocation = BehaviorRelay<CLLocation?>(value: nil)
    let currentCity = BehaviorRelay<AMapLocationReGeocode?>(value: nil)

    private override init() {
        AMapServices.shared().apiKey = LocationManager.apiKey
        AMapServices.shared().enableHTTPS = true
        super.init()
    }


    func requestCurrentLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        locationManager.locationTimeout = 2

        locationManager.reGeocodeTimeout = 2
        locationManager.requestLocation(
            withReGeocode: true,
            completionBlock: { [weak self] (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in

                if let error = error {
                    let error = error as NSError

                    if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                        //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                        NSLog("定位错误:{\(error.code) - \(error.localizedDescription)};")
                        return
                    }
                    else if error.code == AMapLocationErrorCode.reGeocodeFailed.rawValue
                        || error.code == AMapLocationErrorCode.timeOut.rawValue
                        || error.code == AMapLocationErrorCode.cannotFindHost.rawValue
                        || error.code == AMapLocationErrorCode.badURL.rawValue
                        || error.code == AMapLocationErrorCode.notConnectedToInternet.rawValue
                        || error.code == AMapLocationErrorCode.cannotConnectToHost.rawValue {

                        //逆地理错误：在带逆地理的单次定位中，逆地理过程可能发生错误，此时location有返回值，regeocode无返回值，进行annotation的添加
                        NSLog("逆地理错误:{\(error.code) - \(error.localizedDescription)};")
                    }
                    else {
                        //没有错误：location有返回值，regeocode是否有返回值取决于是否进行逆地理操作，进行annotation的添加
                    }
                }

                self?.currentLocation.accept(location)

                self?.currentCity.accept(reGeocode)
        })
    }

}

func getDistanceString(distance: CLLocationDistance) -> String {
    return String(format: "%.1f公里", arguments: [distance / 1000])
}
