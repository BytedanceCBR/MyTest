//
//  NIHSearchPanelViewModel.swift
//  NewsLite
//
//  Created by 谢飞 on 2018/9/10.
//

import UIKit
import RxSwift
import RxCocoa

class NIHSearchPanelViewModel: NSObject {
    
    var suspendSearchBar: HomePageSearchPanel
    
    var baseVC: UIViewController
    
    let disposeBag = DisposeBag()
    
    var listDataRequestDisposeBag = DisposeBag()
    
    var currentCityName:String = ""

    var showLoadingAlert: ((String) -> Void)?
    var dismissLoadingAlert: (() -> Void)?
    
    private var homePageRollScreen:[HomePageRollScreen] = []
    
    @objc init (searchPanel:HomePageSearchPanel,viewController:UIViewController)
    {
        self.suspendSearchBar = searchPanel
        self.baseVC = viewController
        super.init()
        
        searchLocation()
        bindSearchEvent()
        
        registerPullDownNoti()
        registerChangeCity()
        
        EnvContext.shared.client.generalBizconfig.load()
    }
    
    private func bindSearchEvent() {
        suspendSearchBar.changeCountryBtn.rx.tap
            .subscribe(onNext: openCountryList)
            .disposed(by: disposeBag)
        suspendSearchBar.searchBtn.rx.tap
            .subscribe(onNext: openSearchPanel)
            .disposed(by: disposeBag)
    }
    
    private func searchLocation()
    {
        let generalBizConfig = EnvContext.shared.client.generalBizconfig
        generalBizConfig.currentSelectCityId
            .map(generalBizConfig.cityNameById())
            .subscribe(onNext: { [unowned self] (city) in
                if let city = city {
                    self.suspendSearchBar.countryLabel.text = city
                    EnvContext.shared.client.userCurrentCityText?.setObject(city as NSCoding, forKey: "usercurrentcity")
                } else {
                    if self.suspendSearchBar.countryLabel.text == "", self.suspendSearchBar.countryLabel.text == "深圳"
                    {
                        return
                    }
                    switch CLLocationManager.authorizationStatus() {
                    case .notDetermined, .restricted, .denied:
                        if EnvContext.shared.client.generalBizconfig.currentSelectCityId.value == nil
                        {
                            if EnvContext.shared.client.reachability.connection == .none
                            {
                                self.suspendSearchBar.countryLabel.text = "深圳"
                            }
                        }
                        break
                        
                    case .authorizedWhenInUse, .authorizedAlways:
                        self.suspendSearchBar.countryLabel.text = ""
                        break
                    }
                }
                let size = self.suspendSearchBar.countryLabel.sizeThatFits(CGSize(width: 200, height: 20))
                let sizeW = size.width >= 28 ? size.width : 28
                self.suspendSearchBar.countryLabel.snp.updateConstraints({ (maker) in
                    maker.width.equalTo(sizeW)
                })
            })
            .disposed(by: disposeBag)
    }
    
    private func openCountryList() {
        let vc = CountryListVC()
        vc.onClose = { [weak self] _ in
            self?.baseVC.navigationController?.popViewController(animated: true)
        }
        vc.onItemSelect
            .subscribe(onNext: { [unowned self] i in
//                EnvContext.shared.toast.showModeLoadingToast("正在切换城市")
                EnvContext.shared.client.currentCitySwitcher
                    .switchCity(cityId: i)
                    .subscribe(onNext: { (state) in
                        switch state {
                        case .onRequestCityList:
                            self.baseVC.navigationController?.popViewController(animated: true)
                        case .onFinishedRequestFilterConfig:
                            FHHomeConfigManager.sharedInstance().openCategoryFeedStart()
                            return
                        case .onError:
                            DispatchQueue.main
                                .asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
                                    EnvContext.shared.toast.dismissToast()
                                    EnvContext.shared.toast.showToast("网络异常，城市切换失败")
                            }
                            return
                        default:
                            return
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: self.disposeBag)
        self.baseVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openSearchPanel() {
        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
            toTracerParams("maintab_search", key: "origin_from")
        var rollText = "be_null"
        if self.suspendSearchBar.searchTitleIndex >= 0 && self.suspendSearchBar.searchTitleIndex < self.suspendSearchBar.searchTitles.count {
            rollText = self.suspendSearchBar.searchTitles[self.suspendSearchBar.searchTitleIndex]
        }
        self.recordClickHouseSearch(rollText: rollText)
        let vc = SuggestionListVC(isFromHome: .enterSuggestionTypeHome)

        let tracerParams = TracerParams.momoid() <|>
            toTracerParams("click", key: "enter_type") <|>
            toTracerParams("maintab_search", key: "element_from") <|>
            toTracerParams("maintab", key: "enter_from") <|>
            toTracerParams("be_null", key: "log_pb")

        vc.tracerParams = tracerParams
        
        let index = self.suspendSearchBar.searchTitleIndex
        if index >= 0 && index < self.homePageRollScreen.count {
            vc.homePageRollData = self.homePageRollScreen[index]
        }

        let nav = self.baseVC.navigationController
        nav?.pushViewController(vc, animated: true)
        vc.navBar.backBtn.rx.tap
            .subscribe(onNext: { [weak nav] void in
                EnvContext.shared.toast.dismissToast()
                nav?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
        vc.onSuggestSelect = { [weak self, unowned vc] (query, condition, associationalWord, houseSearchParams) in


            let paramsWithCategoryType = tracerParams <|>
                toTracerParams(categoryEnterNameByHouseType(houseType: vc.houseType.value), key: "category_name")
            let hsp = houseSearchParams <|>
                toTracerParams("maintab", key: "page_type")
            self?.openCategoryList(
                houseType: vc.houseType.value,
                condition: condition ?? "",
                query: query,
                associationalWord: (associationalWord?.isEmpty ?? true) ? nil : associationalWord,
                houseSearchParams: hsp,
                tracerParams: paramsWithCategoryType)
        }
    }

    fileprivate func recordClickHouseSearch(rollText:String = "be_null") {
        let params = EnvContext.shared.homePageParams <|>
            toTracerParams("maintab", key: "page_type") <|>
            toTracerParams(rollText, key: "hot_word")
        recordEvent(key: "click_house_search", params: params)
    }
    
    
    private func openCategoryList(
        houseType: HouseType,
        condition: String,
        query: String,
        associationalWord: String? = nil,
        houseSearchParams: TracerParams,
        tracerParams: TracerParams) {
        let vc = CategoryListPageVC(
            isOpenConditionFilter: true,
            associationalWord: associationalWord)
        vc.allParams = ["houseSearch": houseSearchParams.paramsGetter([:])]
        vc.tracerParams = tracerParams
        vc.houseType.accept(houseType)
        vc.suggestionParams = condition
        vc.queryString = query
        vc.navBar.isShowTypeSelector = false
        if associationalWord?.isEmpty ?? true {
            vc.navBar.setSearchPlaceHolderText(text: searchBarPlaceholder(houseType))
        } else {
            vc.navBar.setSearchPlaceHolderText(text: associationalWord)
        }
        let nav = self.baseVC.navigationController
        nav?.pushViewController(vc, animated: true)
        vc.navBar.backBtn.rx.tap
            .subscribe(onNext: { [weak nav] void in
                EnvContext.shared.toast.dismissToast()
                nav?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func registerPullDownNoti() {
        // TTRefreshView+HomePage 进行下拉以及是否是首页判断
        NotificationCenter.default.rx.notification(.homePagePullDown).subscribe(onNext: {[weak self] (noti) in
            if let userInfo = noti.userInfo {
                if let needPullDownData = userInfo["needPullDownData"] as? Bool {
                    if needPullDownData {
                        self?.requestHomePageRollScreen()
                    }
                }
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    func registerChangeCity()
    {
        EnvContext.shared.client.generalBizconfig.generalCacheSubject.skip(1).throttle(0.8, latest: false, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] data in
            if let cityName = data?.currentCityName {
                if cityName != self?.currentCityName {
                    self?.requestHomePageRollScreen()
                    self?.currentCityName = cityName
                }
            }
        })
            .disposed(by: disposeBag)
    }
    
    func requestHomePageRollScreen()
    {
        listDataRequestDisposeBag = DisposeBag()
        let cityId = EnvContext.shared.client.generalBizconfig.currentSelectCityId.value
        requestHomePageRollScreenData(cityId: cityId ?? 122).subscribe(onNext: {[weak self](response) in
            var listData:[HomePageRollScreen] = []
            if let tempListData = response?.data?.data {
                listData = tempListData
            }
            self?.homePageRollScreen = listData
            var searchTitles:[String] = []
            for item in listData {
                if let contentText = item.text {
                    searchTitles.append(contentText)
                }
            }
            self?.suspendSearchBar.searchTitles = searchTitles
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: listDataRequestDisposeBag)
    }
}
