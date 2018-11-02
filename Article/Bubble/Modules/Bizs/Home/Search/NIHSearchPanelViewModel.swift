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
    
    @objc init (searchPanel:HomePageSearchPanel,viewController:UIViewController)
    {
        self.suspendSearchBar = searchPanel
        self.baseVC = viewController
        super.init()
        
        searchLocation()
        bindSearchEvent()
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
                } else {
                    let defaultStr = "选择城市"
                    self.suspendSearchBar.countryLabel.text = defaultStr
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func openCountryList() {
        let vc = CountryListVC()
        vc.onClose = { [weak self] _ in
            self?.baseVC.navigationController?.popViewController(animated: true)
        }
        vc.onItemSelect
            .subscribe(onNext: { [weak self] i in
                EnvContext.shared.client.generalBizconfig.currentSelectCityId.accept(i)
                EnvContext.shared.client.generalBizconfig.setCurrentSelectCityId(cityId: i)
                self?.baseVC.navigationController?.popViewController(animated: true)
            })
            .disposed(by: self.disposeBag)
        self.baseVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openSearchPanel() {
        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
            toTracerParams("maintab_search", key: "origin_from")
        self.recordClickHouseSearch()
        let vc = SuggestionListVC(isFromHome: .enterSuggestionTypeHome)

        let tracerParams = TracerParams.momoid() <|>
            toTracerParams("click", key: "enter_type") <|>
            toTracerParams("maintab_search", key: "element_from") <|>
            toTracerParams("maintab", key: "enter_from") <|>
            toTracerParams("be_null", key: "log_pb")

        vc.tracerParams = tracerParams
        

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

    fileprivate func recordClickHouseSearch() {
        let params = EnvContext.shared.homePageParams <|>
            toTracerParams("maintab", key: "page_type")
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
            vc.navBar.searchInput.placeholder = searchBarPlaceholder(houseType)
        } else {
            vc.navBar.searchInput.placeholder = associationalWord
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
    
}
