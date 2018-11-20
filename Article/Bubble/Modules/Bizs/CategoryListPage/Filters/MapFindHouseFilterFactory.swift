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
    @objc func createFilterPanelViewModel(houseType: HouseType) -> HouseFilterViewModel {
        return HouseFilterViewModel(houseType: houseType)
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

    var houseType: HouseType = .secondHandHouse {
        didSet {
            houseTypeState.accept(houseType)
        }
    }

    private let houseTypeState = BehaviorRelay<HouseType>(value: .secondHandHouse)

    let disposeBag = DisposeBag()

    var allKeys: Set<String> = []

    // 搜索过滤器展现面版
    @objc lazy var filterPanelView: UIView = {
        let re = SearchFilterPanel()
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

    init(houseType: HouseType) {
        self.houseType = houseType
        super.init()
        self.searchAndConditionFilterVM = SearchAndConditionFilterViewModel()
        self.conditionFilterViewModel = ConditionFilterViewModel(
            conditionPanelView: self.filterConditionPanel,
            searchFilterPanel: self.filterPanelView as! SearchFilterPanel,
            searchAndConditionFilterVM: searchAndConditionFilterVM!)
        self.resetConditionData()
        self.bindConditionChangeDelegate()
    }

    func bindConditionChangeDelegate() {
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

    func resetConditionData() {
        Observable
            .zip(houseTypeState, EnvContext.shared.client.configCacheSubject)
            //            .debug("resetConditionData")
            .filter { (e) in
                let (_, config) = e
                //                assert(config != nil)
                return config != nil
            }
            .map { [unowned self] (e) -> ( [SearchConfigFilterItem]?) in
                let (type, config) = e
                self.searchAndConditionFilterVM?.pageType = houseTypeString(type)

                switch type {
                case HouseType.newHouse:
                    return config?.courtFilter
                case HouseType.secondHandHouse:
                    return config?.filter
                case HouseType.neighborhood:
                    return config?.neighborhoodFilter
                default:
                    return config?.filter
                }

            }
            .map { items in //
                let filteredItems = items?.filter { $0.text != "区域" }

                let result: [SearchConditionItem] = filteredItems?
                    // TODO: 暂时使用text过滤区域
                    .filter { $0.text != "区域" }
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
                            index: offset + 1,
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
        return self.conditionFilterViewModel?.searchAndConditionFilterVM.queryCondition.value
    }
    
    @objc
    func closeConditionFilterPanel() {
        self.conditionFilterViewModel?.closeConditionFilterPanel(index: -1);
    }

    @objc
    func getNoneFilterQuery( params: [String: Any]?) -> String {
        return getNoneFilterConditionString(params: params, conditionsKeys: self.allKeys)
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
