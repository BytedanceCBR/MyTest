//
//  CountryListVC.swift
//  Bubble
//
//  Created by linlin on 2018/6/15.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Reachability

class CountryListVC: BaseViewController {

    lazy private var searchConfigCache: YYCache? = {
        YYCache(name: "countryListHistory")
    }()


    lazy var navBar: SearchNavBar = {
        let result = SearchNavBar()
        result.searchInput.returnKeyType = .go
        result.searchInput.placeholder = "请输入城市名"
        result.searchable = true
        result.backBtn.rx.tap
                .subscribe({ [unowned self]  void in
                    self.onClose?(self)
                })
                .disposed(by: disposeBag)
        return result
    }()

    lazy var tableView: UITableView = {
        let result = UITableView()
        result.separatorStyle = .none
        result.sectionIndexBackgroundColor = UIColor.clear
        result.sectionIndexColor = hexStringToUIColor(hex: "#222222")
        return result
    }()

    lazy var locationBar: LocationBar = {
        let result = LocationBar()
        result.lu.addTopBorder(color: hexStringToUIColor(hex: "#f4f5f6"))
        return result
    }()

    lazy var dataSource: CountryListDataSource = {
        CountryListDataSource()
    }()

    let disposeBag = DisposeBag()

    var onClose: ((UIViewController) -> Void)?
    let onItemSelect = PublishSubject<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = UIColor.white
        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(58)
            } else {
                maker.height.equalTo(65)
            }
        }

        view.addSubview(locationBar)
        locationBar.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(locationBar.snp.bottom)
            maker.left.right.equalToSuperview()
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                maker.bottom.equalToSuperview()
            }
        }
        dataSource.onItemSelect = self.onItemSelect
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.register(BubbleCell.self, forCellReuseIdentifier: CountryListCellType.bubble.rawValue)
        tableView.register(CityItemCell.self, forCellReuseIdentifier: CountryListCellType.item.rawValue)
        tableView.reloadData()
        EnvContext.shared.client.generalBizconfig.generalCacheSubject
                .subscribe(onNext: { [unowned self] data in
                    if let data = data {
                        let history = EnvContext.shared.client.generalBizconfig.cityHistoryDataSource.getHistory()
                        let listData = (parseHistoryList(history) <*> parseHotCityList(data.hotCityList) <*> parseCityList(data.cityList))([])
                        self.dataSource.datas = listData
                        self.tableView.reloadData()
                    }
                })
                .disposed(by: disposeBag)

        EnvContext.shared.client.locationManager.currentCity
                .subscribe(onNext: { [unowned self] geocode in
                    if let geocode = geocode {
                        self.locationBar.countryLabel.text = geocode.city
                    }
                })
                .disposed(by: disposeBag)

        EnvContext.shared.client.locationManager.currentCity
                .skip(1)
                .subscribe(onNext: { geocode in
                    EnvContext.shared.toast.dismissToast()
                    if geocode != nil {
                        EnvContext.shared.toast.showToast("定位成功")
                    } else {
                        EnvContext.shared.toast.showToast("定位失败")
                    }
                })
                .disposed(by: disposeBag)

        locationBar.reLocateBtn.rx.tap
                .subscribe(onNext: { void in
                    if EnvContext.shared.client.reachability.connection != .none {
                        EnvContext.shared.toast.showLoadingToast("定位中")
                        EnvContext.shared.client.locationManager.requestCurrentLocation()
                    } else {
                        EnvContext.shared.toast.showToast("网络异常")
                    }
                })
                .disposed(by: disposeBag)

        navBar.searchInput.rx.text
                .debounce(0.3, scheduler: MainScheduler.instance)
                // 过滤输入法的不可见字符
                .map { $0?.filter { $0 != " " }.lowercased() }
                .subscribe(onNext: { [unowned self] s in
                    self.dataSource.setFilterCondition(filterStr: s)
                    self.tableView.reloadData()
                })
                .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class CountryListDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    fileprivate var datas: [CountryListNode] = [] {
        didSet {
            self.filteredData = nil
            self.filterStr = nil
        }
    }

    private var filteredData: [CountryListNode]?

    private var filterStr: String? = nil

    var onItemSelect: PublishSubject<Int>?

    func numberOfSections(in tableView: UITableView) -> Int {
        let theDatas = getDisplayDatas()
        return theDatas.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let theDatas = getDisplayDatas()
        switch theDatas[section].type {
        case .item:
            return theDatas[section].children?.count ?? 0
        case .bubble:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theDatas = getDisplayDatas()

        let sectionNode = theDatas[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionNode.type.rawValue, for: indexPath)
        switch sectionNode.type {
        case .bubble:
            if let theCell = cell as? BubbleCell, let nodes = sectionNode.children {
                theCell.setNodes(nodes: nodes) { [weak self] (cityId) in
                    self?.onItemSelect?.onNext(cityId)
                }
            }
        default:
            if let theCell = cell as? CityItemCell {
                theCell.label.text = sectionNode.children?[indexPath.row].label.uppercased()
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = getDisplayDatas()[indexPath.section]
        if node.type == .item {
            if let cityId = node.children?[indexPath.row].cityId {
                onItemSelect?.onNext(cityId)
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionNode = getDisplayDatas()[section]

        let result = HeaderView()
        result.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        result.label.text = sectionNode.label.uppercased()
        return result
    }

    fileprivate func getDisplayDatas() -> [CountryListNode] {
        if filterStr?.isEmpty ?? true {
            return datas
        } else {
            return filteredData ?? []
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return getDisplayDatas()[indexPath.section].type == .item
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return getDisplayDatas().map {
            $0.label.uppercased()
        }
    }

    func setFilterCondition(filterStr: String?) {
        self.filterStr = filterStr
        filteredData = datas.filter { node in
            node.type == .item
        }.map { node -> CountryListNode in
            let children = node.children?.filter { node in
                if let filterStr = self.filterStr {
                    let result = node.label.hasPrefix(filterStr) ||
                        node.simplePinyin?.hasPrefix(filterStr) ?? false ||
                        node.pinyin?.hasPrefix(filterStr) ?? false
                    return result
                } else {
                    return true
                }
            }
            return CountryListNode(
                    label: node.label,
                    type: node.type,
                    cityId: node.cityId,
                    pinyin: node.pinyin,
                    simplePinyin: node.simplePinyin,
                    children: children)
            }.filter { $0.children?.count ?? 0 > 0 }
    }
}

fileprivate typealias CityListNodeParser = ([CountryListNode]) -> [CountryListNode]
infix operator <*>: SequencePrecedence

fileprivate func <*>(l: @escaping CityListNodeParser, r: @escaping CityListNodeParser) -> CityListNodeParser {
    return { nodes in
        r(l(nodes))
    }
}

fileprivate func parseHotCityList(_ hotCityList: [HotCityItem]) -> ([CountryListNode]) -> [CountryListNode] {
    return { nodes in
        let hots = hotCityList.map {
            CountryListNode(
                    label: $0.name ?? "",
                    type: .bubble,
                    cityId: $0.cityId,
                    pinyin: nil,
                    simplePinyin: nil,
                    children: nil)
        }
        return nodes + [CountryListNode(
                label: "热门",
                type: .bubble,
                cityId: nil,
                pinyin: nil,
                simplePinyin: nil,
                children: hots)]
    }
}

fileprivate func parseHistoryList(_ nodes: [CountryListNode]) -> ([CountryListNode]) -> [CountryListNode] {
    return { theNodes in
        if nodes.count > 0 {
            return theNodes + [CountryListNode(
                label: "历史",
                type: .bubble,
                cityId: nil,
                pinyin: nil,
                simplePinyin: nil,
                children: nodes)]
        } else {
            return theNodes
        }
    }
}

fileprivate func parseCityList(_ cityList: [CityItem]) -> ([CountryListNode]) -> [CountryListNode] {
    return { nodes in
        let grouped = cityList
                .reduce([String: [CountryListNode]]()) { (result, item: CityItem) -> [String: [CountryListNode]] in
                    let node = CountryListNode(
                            label: item.name ?? "",
                            type: .item,
                            cityId: item.cityId,
                            pinyin: item.fullPinyin,
                            simplePinyin: item.simplePinyin,
                            children: nil)
                    if let identifer = item.simplePinyin.first {
                        return addArrayElementToMap(map: result, element: node, ofKey: "\(identifer)")
                    } else {
                        return addArrayElementToMap(map: result, element: node, ofKey: "*")
                    }
                }.map({ (e) -> CountryListNode in
                    let (key, nodes) = e
                    return CountryListNode(
                            label: key,
                            type: .item,
                            cityId: nil,
                            pinyin: nil,
                            simplePinyin: nil,
                            children: nodes)
                })
                .sorted { node, node2 in
                    node.label < node2.label
                }
        return nodes + grouped
    }
}

fileprivate func addArrayElementToMap<K: Hashable, T>(map: [K: [T]], element: T, ofKey: K) -> [K: [T]] {
    var map = map
    if let items = map[ofKey] {
        map[ofKey] = items + [element]
    } else {
        map[ofKey] = [element]
    }
    return map
}

class LocationBar: UIView {

    lazy var countryLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(16)
        result.textColor = hexStringToUIColor(hex: "#222222")
        return result
    }()

    lazy var poiIcon: UIImageView = {
        let result = UIImageView()
        result.image = #imageLiteral(resourceName: "group")
        return result
    }()

    lazy var reLocateBtn: UIButton = {
        let result = UIButton()
        result.backgroundColor = UIColor.clear
        result.titleLabel?.font = CommonUIStyle.Font.pingFangRegular(15)
        result.setTitle("重新定位", for: .normal)
        result.setTitleColor(hexStringToUIColor(hex: "#f85959"), for: .normal)
        return result
    }()

    lazy var bottomBar: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(countryLabel)
        countryLabel.snp.makeConstraints { maker in
            maker.left.equalTo(24)
            maker.top.equalTo(14)
            maker.height.equalTo(22)
        }

        addSubview(poiIcon)
        poiIcon.snp.makeConstraints { maker in
            maker.left.equalTo(countryLabel.snp.right).offset(2)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(20)
            maker.width.equalTo(20)
        }

        addSubview(reLocateBtn)
        reLocateBtn.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-24)
            maker.top.equalTo(14)
            maker.height.equalTo(22)
        }

        addSubview(bottomBar)
        bottomBar.snp.makeConstraints { (maker) in
            maker.top.equalTo(countryLabel.snp.bottom).offset(14)
            maker.bottom.left.right.equalToSuperview()
            maker.height.equalTo(8)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class CityItemCell: UITableViewCell {

    lazy var label: UILabel = {
        let result = UILabel()
        result.textColor = hexStringToUIColor(hex: "#222222")
        result.font = CommonUIStyle.Font.pingFangRegular(15)
        return result
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(24)
            maker.height.equalTo(20)
            maker.top.equalTo(12)
            maker.bottom.equalToSuperview().offset(-12)
            maker.right.equalTo(24)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate class BubbleCell: UITableViewCell {

    private lazy var rows: [UIView] = {
        []
    }()

    var disposeBag: DisposeBag?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        let bgView = UIView()
        bgView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        selectedBackgroundView = bgView
        self.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setNodes(nodes: [CountryListNode], itemClick: @escaping (Int) -> Void) {
        let rows = groups(items: nodes, rowCount: 4).map { nodes -> (UIView, () -> Void) in
            createRow(nodes: nodes, itemClick: itemClick)
        }
        rows.forEach { e in
            let (view, _) = e
            contentView.addSubview(view)
        }

        rows.forEach { e in
            let (_, loader) = e
            loader()
        }

        let rowViews = rows.map {
            $0.0
        }
        rowViews.snp.distributeViewsAlong(
                axisType: .vertical,
                fixedSpacing: 5,
                leadSpacing: 14,
                tailSpacing: 24)
        let viewCoint = rowViews.count
        rowViews.snp.makeConstraints { maker in
            if viewCoint == 1 {
                maker.top.equalTo(4)
                maker.bottom.equalToSuperview().offset(-24).priority(.high)
            }
            maker.left.right.equalToSuperview()
            maker.height.equalTo(28).priority(.high)
        }

    }

    func createRow(nodes: [CountryListNode], itemClick: @escaping (Int) -> Void) -> (UIView, () -> Void) {
        disposeBag = DisposeBag()
        if nodes.count == 0 {
            return (UIView(), {})
        }
        let rowView = UIView()

        let btns = nodes.map { [weak self] (node) -> BubbleBtn in
            let result = BubbleBtn()
            result.label.text = node.label
            if let disposeBag = self?.disposeBag {
                result.rx.controlEvent(UIControlEvents.touchUpInside)
                        .subscribe(onNext: { void in
                            if let cityId = node.cityId {
                                itemClick(cityId)
                            }
                        })
                        .disposed(by: disposeBag)
            }
            return result
        }

        let loader: () -> Void = {
            btns.forEach { (btn) in
                rowView.addSubview(btn)
            }
            btns.snp.distributeViewsAlong(
                axisType: .horizontal,
                fixedSpacing: 9,
                leadSpacing: 24,
                tailSpacing: -1)
            btns.snp.makeConstraints { maker in
                maker.width.equalTo(75).priority(.high)
                maker.height.equalTo(28).priority(.high)
                maker.top.bottom.equalToSuperview()
            }

            if btns.count == 1 {
                btns.first?.snp.makeConstraints { maker in
                    maker.left.equalTo(24)
                }
            }
        }

        return (rowView, loader)
    }

    fileprivate override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
        rows.forEach { view in
            view.removeFromSuperview()
        }
        rows.removeAll()
    }
}

fileprivate class BubbleBtn: UIControl {

    lazy var label: UILabel = {
        let result = UILabel()
        result.textAlignment = .center
        result.font = CommonUIStyle.Font.pingFangRegular(14)
        result.textColor = hexStringToUIColor(hex: "#505050")
        return result
    }()

    init() {
        super.init(frame: CGRect.zero)
        self.layer.cornerRadius = 4
        self.backgroundColor = UIColor.white
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.centerY.equalToSuperview()
            maker.left.equalTo(5)
            maker.right.equalToSuperview().offset(-5)
            maker.height.equalTo(14)
            maker.top.equalTo(7)
            maker.bottom.equalToSuperview().offset(-7)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate class HeaderView: UIView {
    lazy var label: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(16)
        result.textColor = hexStringToUIColor(hex: "#999999")
        return result
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(24)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(22)
            maker.top.equalTo(6)
            maker.bottom.equalToSuperview().offset(-6)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

