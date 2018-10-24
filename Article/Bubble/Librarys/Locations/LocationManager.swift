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
    // local test
//        static let apiKey = "003c8c31d052f8882bfb2a1d712dea84"
    // release
    static let apiKey = "69c1887b8d0d2d252395c58e3da184dc"

    static let shared = LocationManager()

    private lazy var locationManager: AMapLocationManager = {
        AMapLocationManager()
    }()
    let currentLocation = BehaviorRelay<CLLocation?>(value: nil)
    let currentCity = BehaviorRelay<AMapLocationReGeocode?>(value: nil)

    let disposeBag = DisposeBag()

    private override init() {
        AMapServices.shared().apiKey = LocationManager.apiKey
        AMapServices.shared().enableHTTPS = true
        AMapServices.shared()?.crashReportEnabled = false 
        super.init()
        NotificationCenter.default.rx
            .notification(Notification.Name.UIApplicationDidBecomeActive)
            .skip(1)
            .subscribe(onNext: { [weak self] (notify) in
                if self?.currentLocation.value == nil {
                    self?.requestCurrentLocation()
                }
            })
            .disposed(by: disposeBag)
    }


    func requestCurrentLocation(_ showAlert: Bool = false) {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        locationManager.locationTimeout = 2

        locationManager.reGeocodeTimeout = 2
        locationManager.requestLocation(
            withReGeocode: true,
            completionBlock: { [weak self] (location: CLLocation?, reGeocode: AMapLocationReGeocode?, error: Error?) in

                if let error = error {
                    let error = error as NSError

                    switch CLLocationManager.authorizationStatus() {
                    case .notDetermined, .restricted, .denied:
                        if showAlert {
                            showLocationGuideAlert()
                        }
                        break

                    case .authorizedWhenInUse, .authorizedAlways:
                        break
                    }

                    if error.code == AMapLocationErrorCode.locateFailed.rawValue {
                        //定位错误：此时location和regeocode没有返回值，不进行annotation的添加
                        NSLog("定位错误:{\(error.code) - \(error.localizedDescription)};")

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

                if let _ = reGeocode {
                    EnvContext.shared.client.generalBizconfig.tryClearCityIdForLocation()
                }

                self?.currentCity.accept(reGeocode)

                self?.currentLocation.accept(location)
        })
    }


    func locationParams() -> () -> [AnyHashable: Any] {
        return { [weak self] in
            var params: [AnyHashable: Any]  = [:]
            if let lat = self?.currentLocation.value?.coordinate.latitude,
                let lng = self?.currentLocation.value?.coordinate.longitude {
                params["gaode_lat"] = lat
                params["gaode_lng"] = lng
                params["latitude"] = lat
                params["longitude"] = lng
            }
            if let gaodeCityId = self?.currentCity.value?.citycode {
                params["gaode_city_id"] = gaodeCityId
            }
            return params
        }
    }

}

//- (void)amapLocationManager:(AMapLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;
//{
//
//}

func getDistanceString(distance: CLLocationDistance) -> String {
    return String(format: "%.1f公里", arguments: [distance / 1000])
}

func showLocationGuideAlert() {
    let alertVC = TTThemedAlertController(title: "无定位权限，请前往系统设置开启", message: nil, preferredType: .alert)
    alertVC.addAction(withTitle: "取消", actionType: .cancel, actionBlock: {
        
    })
    alertVC.addAction(withTitle: "立刻前往", actionType: .normal, actionBlock: {
        
        if let url = URL(string: UIApplicationOpenSettingsURLString),UIApplication.shared.canOpenURL(url) {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    })
    if let topVC = TTUIResponderHelper.topmostViewController() {
        alertVC.show(from: topVC, animated: true)
    }
    
}
