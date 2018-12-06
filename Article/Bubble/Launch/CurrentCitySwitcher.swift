//
//  CurrentCitySwitcher.swift
//  NewsLite
//
//  Created by leo on 2018/11/6.
//

import Foundation
import RxSwift
import RxCocoa

enum CitySwitcherState {
    case normal
    case onStartSwitchCity
    case onRequestCityList
    case onRequestGeneralConfig
    case onFinishedRequestGeneralConfig(GeneralConfigResponse?)
    case onRequestFilterConfig
    case onFinishedRequestFilterConfig(SearchConfigResponse?)
    case onError(Error?)
}

class CurrentCitySwitcher {

    private var currentCityId: Int?
    private var switchToCityId: Int?

    private var state = BehaviorRelay<CitySwitcherState>(value: .normal)
    private var oldState = BehaviorRelay<CitySwitcherState>(value: .normal)

    let disposeBag = DisposeBag()
    var requestBag = DisposeBag()

    var generalConfigRsponse: GeneralConfigResponse?
    var searchConfigResponse: SearchConfigResponse?

    init(currentCityId: Int?) {
        self.currentCityId = currentCityId
        let oldAndNewState = Observable.combineLatest(oldState, state)
        state
            .withLatestFrom(oldAndNewState)
            .skip(1)
            .throttle(1, latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (s) in
                self.onStateChanged(state: s)
            })
            .disposed(by: disposeBag)
    }

    func onSetCurrentCityId(cityId: Int?)  {
        self.currentCityId = cityId
    }

    fileprivate func onStateChanged(state: (oldState: CitySwitcherState, state: CitySwitcherState)) {
        oldState.accept(state.state)

        switch state {
        case (.normal, .onStartSwitchCity):
            self.state.accept(.onRequestGeneralConfig)

        case (.onStartSwitchCity, .onRequestGeneralConfig):
            self.doRequestGeneralConfig(cityId: switchToCityId)

        case let (.onRequestGeneralConfig, .onFinishedRequestGeneralConfig(response)):
            self.generalConfigRsponse = response
            self.state.accept(.onRequestFilterConfig)

        case (.onFinishedRequestGeneralConfig, .onRequestFilterConfig):
            self.requestSearchCondition(cityId: switchToCityId)

        case let (.onRequestFilterConfig, .onFinishedRequestFilterConfig(response)):
            self.searchConfigResponse = response
            self.finishedFilterConfigAction()
            self.state.accept(.normal)

        case (.onFinishedRequestFilterConfig, .normal):
            return

        case (.onRequestFilterConfig, .onError):
            self.state.accept(.normal)
        case (.onRequestGeneralConfig, .onError):
            self.state.accept(.normal)

        case (.onError, .normal):
            self.switchToCityId = nil
            return

        case (_, .normal):
            return
        default:
            assertionFailure()
            return
        }
    }

    func switchCity(cityId: Int?) -> Observable<CitySwitcherState> {
        self.switchToCityId = cityId
        self.state.accept(.onStartSwitchCity)
        return Observable.create({ [unowned self] (obv) -> Disposable in
            self.state.bind(onNext: { (s) in
                switch s {
                case .onFinishedRequestFilterConfig, .onError:
                    obv.onNext(s)
                    obv.onCompleted()
                default:
                    return
                }

            }).disposed(by: self.disposeBag)
            return Disposables.create {
                self.requestBag = DisposeBag()
                self.state.accept(.normal)
            }
        })
    }

    func switchCityBy(lat: Double?, lng: Double?, gaodeCityId: String?) {
        
//        requestGeneralConfig(cityName: cityName,
//                             cityId: nil,
//                             gaodeCityId: gaodeCityId,
//                             lat: lat,
//                             lng: lng,
//                             needCommonParams: false,
//                             params: params ?? [:])
    }

    fileprivate func finishedFilterConfigAction() {
        self.currentCityId = switchToCityId
        EnvContext.shared.client.generalBizconfig.currentSelectCityId.accept(self.currentCityId)
        if let currentCityId = self.currentCityId {
            EnvContext.shared.client.generalBizconfig.setCurrentSelectCityId(cityId: currentCityId)
        }
        EnvContext.shared.client.configCacheSubject.accept(searchConfigResponse?.data)
        EnvContext.shared.client.generalBizconfig.generalCacheSubject.accept(generalConfigRsponse?.data)
        
        self.updateSearchCondition(response: searchConfigResponse)
        self.updateGeneralConfig(response: generalConfigRsponse)
    }



    // MARK: 城市列表配置，首页频道配置q
    fileprivate func doRequestGeneralConfig(cityId: Int?) {
        requestGeneralConfig(cityId: "\(cityId ?? 122)", needCommonParams: false)
            .timeout(5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (response) in
                self.generalConfigRsponse = response
                if let response = response {
                    self.state.accept(.onFinishedRequestGeneralConfig(response))
                } else {
                    self.state.accept(.onError(nil))
                }
                self.generalConfigRsponse = response
            }, onError: { (error) in
                self.state.accept(.onError(error))
            })
            .disposed(by: requestBag)
    }

    // MARK: 搜索条件配置
    fileprivate func requestSearchCondition(cityId: Int?) {
//        state.accept(.onRequestFilterConfig)
        requestSearchConfig(
            gaodeCityName: nil,
            geoCityId: nil,
            cityId: cityId)
            .timeout(5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (response) in
                self.searchConfigResponse = response
                if let response = response {
                    self.state.accept(.onFinishedRequestFilterConfig(response))
                } else {
                    self.state.accept(.onError(nil))
                }
            }, onError: { (error) in
                self.state.accept(.onError(error))
            })
            .disposed(by: requestBag)
    }

    fileprivate func updateSearchCondition(response: SearchConfigResponse?) {
        let client = EnvContext.shared.client
        client.saveSearchConfigToCache(response: response)
    }
    
    fileprivate func updateGeneralConfig(response: GeneralConfigResponse?) {
        EnvContext.shared.client.generalBizconfig.saveGeneralConfig(response: response)
    }

}

protocol CitySwitcherListener {
    func onFinishedSwitchToCity(cityId: String)

    func onSwitchCityError(oldCityId: String)
}

fileprivate protocol Action {
    func onAction()
}


fileprivate class SwitchCityTask {

}
