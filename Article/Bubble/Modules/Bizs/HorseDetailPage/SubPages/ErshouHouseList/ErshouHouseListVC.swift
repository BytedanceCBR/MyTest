//
// Created by linlin on 2018/7/12.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxCocoa
import RxSwift

class ErshouHouseListVC: BaseSubPageViewController, PageableVC {
    
    var hasMore = true

    var footIndicatorView: LoadingIndicatorView? = {
        let re = LoadingIndicatorView()
        return re
    }()

    let neighborhoodId: String

    let houseId: String?

    var ershouHouseListViewModel: ErshouHouseListViewModel?

    lazy var searchFilterPanel: SearchFilterPanel = {
        let result = SearchFilterPanel()
        return result
    }()

    lazy var conditionPanelView: UIView = {
        let result = UIView()
        result.backgroundColor = hexStringToUIColor(hex: "#222222", alpha: 0.3)
        return result
    }()

    let searchAndConditionFilterVM = SearchAndConditionFilterViewModel()

    var conditionFilterViewModel: ConditionFilterViewModel?

    let theHouseType = BehaviorRelay<HouseType>(value: .secondHandHouse)
    
    let searchSource: SearchSourceKey

    init(title: String?,
         neighborhoodId: String,
         houseId: String? = nil,
         searchSource: SearchSourceKey,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.neighborhoodId = neighborhoodId
        self.houseId = houseId
        self.searchSource = searchSource
        super.init(identifier: neighborhoodId, isHiddenBottomBar: true, bottomBarBinder: bottomBarBinder)
        if let title = title {
            self.navBar.title.text = title
        } else {
            self.navBar.title.text = "同小区房源"
        }

        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
    }

    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = true
        self.hidesBottomBarWhenPushed = true
        self.ttHideNavigationBar = true
        ershouHouseListViewModel = ErshouHouseListViewModel(tableView: tableView, navVC: self.navigationController)
        ershouHouseListViewModel?.onDataLoaded = self.onDataLoaded()
        ershouHouseListViewModel?.title
            .bind(to: self.navBar.title.rx.text)
            .disposed(by: disposeBag)
        
        ershouHouseListViewModel?.requestErshouHouseList(
            query: "exclude_id[]=\(houseId ?? "")&exclude_id[]=\(neighborhoodId)&neighborhood_id=\(neighborhoodId)&house_id=\(houseId ?? "")&house_type=\(HouseType.secondHandHouse.rawValue)&search_source=\(searchSource.rawValue)",
            condition: nil)
        
        self.conditionFilterViewModel = ConditionFilterViewModel(
                conditionPanelView: conditionPanelView,
                searchFilterPanel: searchFilterPanel,
                searchAndConditionFilterVM: searchAndConditionFilterVM)
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(navBar)
        navBar.removeGradientColor()
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.left.right.top.equalToSuperview()
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            } else {
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(65)
            }
        }

        view.addSubview(searchFilterPanel)
        searchFilterPanel.snp.makeConstraints { maker in
            maker.top.equalTo(navBar.snp.bottom)
            maker.left.right.equalToSuperview()
            maker.height.equalTo(40)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(searchFilterPanel.snp.bottom)
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
        }

        view.addSubview(conditionPanelView)
        conditionPanelView.snp.makeConstraints { maker in
            maker.top.equalTo(searchFilterPanel.snp.bottom)
            maker.left.right.bottom.equalToSuperview()
        }
        conditionPanelView.isHidden = true

        Observable
                .zip(theHouseType, EnvContext.shared.client.configCacheSubject)
                .filter { (e) in
                    let (_, config) = e
                    return config != nil
                }
                .map { (e) -> ([SearchConfigFilterItem]?) in
                    let (_, config) = e
                    return config?.filter?.filter { $0.text != "区域" }
                }
                .map { items in
                    let result: [SearchConditionItem] = items?
                            .map(transferSearchConfigFilterItemTo) ?? []
                    let panelData: [[Node]] = items?.map {
                        if let options = $0.options {
                            return transferSearchConfigOptionToNode(
                                    options: options,
                                    isSupportMulti: $0.supportMulti)
                        } else {
                            return []
                        }
                    } ?? []
                    return (result, panelData)
                }
                .subscribe(onNext: { [unowned self] (items: ([SearchConditionItem], [[Node]])) in
                    let reload: () -> Void = { [weak self] in
                        self?.conditionFilterViewModel?.reloadConditionPanel()
                    }
                    zip(items.0, items.1).forEach({ (e) in
                        let (item, nodes) = e
                        item.onClick = self.conditionFilterViewModel?.initSearchConditionItemPanel(reload: reload, item: item, data: nodes)
                    })
                    self.conditionFilterViewModel?.filterConditions = items.0
                    self.conditionFilterViewModel?.reloadConditionPanel()
                })
                .disposed(by: disposeBag)

        searchAndConditionFilterVM.queryCondition
                .skip(2)
                .map { [unowned self] (result) in
                    "house_type=\(self.theHouseType.value.rawValue)&neighborhood_id=\(self.neighborhoodId)" + result
                }
                .debounce(0.01, scheduler: MainScheduler.instance)
                .subscribe(onNext: { [unowned self] query in
                    self.ershouHouseListViewModel?.requestErshouHouseList(query: query, condition: nil)
                }, onError: { error in
                    print(error)
                }, onCompleted: {

                })
                .disposed(by: disposeBag)


        self.searchAndConditionFilterVM.sendSearchRequest()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadMore() {
        ershouHouseListViewModel?.pageableLoader?()
    }

    
}
