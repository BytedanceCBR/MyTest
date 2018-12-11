//
//  MapFindHouseFilterFactory.swift
//  NewsLite
//
//  Created by leo on 2018/10/25.
//

import Foundation
import RxSwift
import RxCocoa
@objc class MapFindHouseFilterFactory: NSObject {
    @objc func createFilterPanelViewModel(houseType: HouseType,  allCondition: Bool, isSortable: Bool) -> HouseFilterViewModel {
        return HouseFilterViewModel(houseType: houseType, allCondition: allCondition, isSortable: isSortable)
    }
}

//@objc protocol HouseFilterViewModelDelegate: NSObjectProtocol {
//    func onConditionChanged(condition: String)
//}

@objc class HouseFilterViewModel: NSObject {

//    @objc weak var delegate: HouseFilterViewModelDelegate? //FHHouseFilterDelegate?
    
    @objc weak var delegate : FHHouseFilterDelegate?

    private var conditionFilterViewModel: ConditionFilterViewModel?

    private var searchAndConditionFilterVM: SearchAndConditionFilterViewModel?

    private var houseType: HouseType = .secondHandHouse

    private let houseTypeState = BehaviorRelay<HouseType>(value: .secondHandHouse)

    let disposeBag = DisposeBag()

    var allKeys: Set<String> = []

    private lazy var searchFilterPanel: SearchFilterPanel = {
        let re = SearchFilterPanel()
        re.backgroundColor = UIColor.white
        return re
    }()

    // 搜索过滤器展现面版
    @objc lazy var filterPanelView: UIView = {
        let re = UIView()
        re.backgroundColor = UIColor.white
        return re
    }()


    /// 用户设置条件的面版
    @objc lazy var filterConditionPanel: UIControl = {
        let re = UIControl()
        re.backgroundColor = hexStringToUIColor(hex: kFHDarkIndigoColor, alpha: 0.3)
        re.isHidden = true
        return re
    }()

    lazy var searchSortBtn: UIButton = {
        let re = ExtendHotAreaButton()
        re.setImage(UIImage(named: "sort"), for: .normal)
        re.setImage(UIImage(named: "sort_selected"), for: .selected)
        re.setImage(UIImage(named: "sort_selected"), for: .highlighted)
        re.adjustsImageWhenHighlighted = false
        return re
    }()

    lazy var searchView: SortConditionPanel = {
        let searchView = SortConditionPanel()
        searchView.isHidden = true
        return searchView
    }()

    private var allCondition = false

    init(houseType: HouseType,
         allCondition: Bool,
         isSortable: Bool) {

        self.houseType = houseType
        self.houseTypeState.accept(houseType)
        self.allCondition = allCondition
        super.init()
        EnvContext.shared.client.loadSearchCondition()
        self.searchAndConditionFilterVM = SearchAndConditionFilterViewModel()
        self.conditionFilterViewModel = ConditionFilterViewModel(
            conditionPanelView: self.filterConditionPanel,
            searchFilterPanel: searchFilterPanel,
            searchAndConditionFilterVM: searchAndConditionFilterVM!)
        filterPanelView.addSubview(searchFilterPanel)

        if isSortable {
            filterPanelView.addSubview(searchSortBtn)
            searchSortBtn.snp.makeConstraints { (make) in
                make.centerY.equalTo(filterPanelView).offset(4)
                make.right.equalTo(-20)
                make.width.height.equalTo(20)
            }
            searchFilterPanel.snp.makeConstraints { (make) in
                make.left.top.bottom.equalToSuperview()
                make.right.equalTo(searchSortBtn.snp.left)
            }
            //初始化搜索条件面板
            setupSortCondition()
            bindSearchBtnBehavior()
        } else {
            searchFilterPanel.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        //为了
        if EnvContext.shared.client.configCacheSubject.value == nil {
            EnvContext.shared.client.configCacheSubject
                .skip(1)
                .bind { (_) in
                    self.resetConditionData()
                }
                .disposed(by: disposeBag)
        } else {
            self.resetConditionData()
        }
        self.bindConditionChangeDelegate()
        self.conditionFilterViewModel?.conditionPanelWillDisplay = { [weak self] in
            self?.delegate?.onConditionWillPanelDisplay()
        }
    }

    fileprivate func bindSearchBtnBehavior() {

    }

    fileprivate func setupSortCondition() {

        filterConditionPanel.addSubview(searchView)
        searchView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalToSuperview()
            maker.height.equalTo(433)
        }
        self.conditionFilterViewModel?.sortPanelView = searchView
        self.conditionFilterViewModel?.searchSortBtn = searchSortBtn
        self.searchSortBtn.rx.tap
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] void in
                self?.conditionFilterViewModel?.openOrCloseSortPanel()
                self?.delegate?.onConditionWillPanelDisplay()
            })
            .disposed(by: disposeBag)

        searchView.snp.updateConstraints({ (maker) in
            maker.height.equalTo(categulateSortPanelHeight(by: houseType))
        })
        if let options = filterSortCondition(by: houseType)?.first?.options {
            let nodes: [Node] = transferSearchConfigOptionToNode(
                options: options,
                rate: 1,
                isSupportMulti: false)
            if let orderConditions = nodes.first {
                searchView.setSortConditions(nodes: orderConditions.children)
            } else {

            }
        }

    }
    
    @objc
    func setFilterPanelBottomLineHidden(_ isHidden: Bool) {
        self.searchFilterPanel.bottomLine?.isHidden = isHidden
    }

    @objc
    func resetSortCondition(queryParams: [String: Any]?) {
        if let queryParams = queryParams {
            searchView.setSelectedConditions(conditions: queryParams)
            self.conditionFilterViewModel?.setSortBtnSelected()
        }
    }

    fileprivate func filterSortCondition(by houseType: HouseType) -> [SearchConfigFilterItem]? {
        switch houseType {
        case .neighborhood:
            return EnvContext.shared.client.configCacheSubject.value?.neighborhoodFilterOrder
        case .newHouse:
            return EnvContext.shared.client.configCacheSubject.value?.courtFilterOrder
        case .rentHouse:
            return EnvContext.shared.client.configCacheSubject.value?.rentFilterOrder
        default:
            return EnvContext.shared.client.configCacheSubject.value?.filterOrder
        }
    }

    fileprivate func categulateSortPanelHeight(by houseType: HouseType) -> CGFloat {
        if let condition = filterSortCondition(by: houseType)?.first?.options?.first?.options {
            return CGFloat(45 * condition.count + 15)
        } else {
            return 433
        }
    }

    fileprivate func bindConditionChangeDelegate() {
        searchAndConditionFilterVM?.queryCondition
            .skip(1)
            .map {  (result) -> String in
                return result
//                return "house_type=\(self.houseTypeState.value.rawValue)" + result// + self.queryString
            }
            .debounce(0.1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] query in
                self.delegate?.onConditionChanged( query)
            })
            .disposed(by: disposeBag)
    }

    func configByHouseType(houseType: HouseType, configs: SearchConfigResponseData?) -> [SearchConfigFilterItem]? {
        if let configs = configs {
            switch houseType {
            case HouseType.newHouse:
                return configs.courtFilter
            case HouseType.secondHandHouse:
                return configs.filter
            case HouseType.neighborhood:
                return configs.neighborhoodFilter
            case HouseType.rentHouse:
                return configs.rentFilter
            default:
                return configs.filter
            }
        } else {
            return nil
        }
    }

    func resetConditionData() {
        Observable
            .zip(houseTypeState, EnvContext.shared.client.configCacheSubject)
            .filter { (e) in
                let (_, config) = e
                return config != nil
            }
            .map { [unowned self] (e) -> ( [SearchConfigFilterItem]?) in
                let (type, config) = e
                self.searchAndConditionFilterVM?.pageType = houseTypeString(type)
                return self.configByHouseType(houseType: type, configs: config)
            }
            .map { items in //
                let filteredItems = items?.filter { $0.text != "区域" || self.allCondition}

                let result: [SearchConditionItem] = filteredItems?
                    .map(transferSearchConfigFilterItemTo) ?? []
                let panelData: [[Node]] = filteredItems?.map {
                    if let options = $0.options {
                        return transferSearchConfigOptionToNode(
                            options: options,
                            rate: $0.rate,
                            isSupportMulti: $0.supportMulti)
                    } else {
                        return []
                    }
                    } ?? []
                return (result, panelData)
            }
            // 绑定点击事件，实现弹出相应的条件选择控件
            .subscribe(onNext: { [unowned self] (items: ([SearchConditionItem], [[Node]])) in
                let reload: () -> Void = { [weak self] in
                    self?.conditionFilterViewModel?.reloadConditionPanel()
                }
                let ns = items.1.reduce([], { (result, nodes) -> [Node] in
                    result + nodes
                })
                self.allKeys = self.allKeysFromNodes(nodes: ns)
                zip(items.0, items.1)
                    .enumerated()
                    .forEach({ [unowned self] (e) in
                        let (offset, (item, nodes)) = e
                        item.onClick = self.conditionFilterViewModel?.initSearchConditionItemPanel(
                            index: offset,
                            reload: reload,
                            item: item,
                            data: nodes)
                    })
                self.conditionFilterViewModel?.filterConditions = items.0
                self.conditionFilterViewModel?.reloadConditionPanel()
            })
            .disposed(by: disposeBag)
    }

    @objc
    func resetFilterCondition(queryParams paramObj: [AnyHashable: Any], updateFilterOnly: Bool) {
        if let params = paramObj as? [String: Any] {
            self.conditionFilterViewModel?.setSelectedItem(items: params)
            self.conditionFilterViewModel?.pullConditionsFromPanels(udpateFilterOnly: updateFilterOnly)
        }
    }
    
    @objc
    func getConditions() -> String? {
        let queryString = self.conditionFilterViewModel?.searchAndConditionFilterVM.queryCondition.value
        return queryString
    }
    
    @objc
    func closeConditionFilterPanel() {
        self.conditionFilterViewModel?.closeConditionFilterPanel(index: -1);
    }

    @objc
    func getNoneFilterQuery( params: [String: Any]?) -> String {
        return getNoneFilterConditionString(params: params, conditionsKeys: self.allKeys)
    }
    
    @objc
    func cleanSortCondition() {
        self.conditionFilterViewModel?.cleanSortCondition()
    }

    func allKeysFromNodes(nodes: [Node]) -> Set<String> {
        return nodes.reduce([], { (result, node) -> Set<String> in
            var theResult = result
            if !node.children.isEmpty {
                let keys = allKeysFromNodes(nodes: node.children)
                keys.forEach({ (key) in
                    theResult.insert(key)
                })
            }
            if let key = node.key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                theResult.insert(key)
            }
            return theResult
        })
    }

}
