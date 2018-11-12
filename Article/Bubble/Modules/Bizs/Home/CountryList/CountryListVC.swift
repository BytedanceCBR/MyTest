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
    
    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar()
        return re
    }()

    lazy var tableView: UITableView = {
        let result = UITableView()
        result.rowHeight = UITableViewAutomaticDimension
        result.separatorStyle = .none
        if CommonUIStyle.Screen.isIphoneX {
            result.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 34, right: 0)
        }
        result.sectionIndexBackgroundColor = UIColor.clear
        result.sectionIndexColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
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

    var requestDisposeBag = DisposeBag()


    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .default
        self.view.backgroundColor = UIColor.white
        
        navBar.title.text = "城市选择"
        self.view.addSubview(navBar)
        navBar.removeGradientColor()
        navBar.snp.makeConstraints { maker in
            
            maker.left.right.top.equalToSuperview()
            if #available(iOS 11, *) {
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            } else {
                maker.height.equalTo(65)
            }
        }

        navBar.backBtn.rx.tap.bind { [unowned self] void in
            self.onClose?(self)
        }.disposed(by: disposeBag)

        view.addSubview(locationBar)
        locationBar.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)

        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(locationBar.snp.bottom)
            maker.left.right.bottom.equalToSuperview()
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

                        let listData = (parseHistoryList(history) <*>
                            parseHotCityList(data.hotCityList) <*>
                            parseCityList(data.cityList))([])

                        self.dataSource.datas = listData
                        self.tableView.reloadData()
                    }
                })
                .disposed(by: disposeBag)

        EnvContext.shared.client.locationManager.currentCity
                .subscribe(onNext: { [unowned self] geocode in
                    if let geocode = geocode {
                        self.locationBar.countryLabel.text = geocode.city
                        self.locationBar.countryLabel.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
                        self.locationBar.countryBtn.isEnabled = true
                    }else {
                        self.locationBar.countryLabel.text = "定位失败"
                        self.locationBar.countryLabel.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
                        self.locationBar.countryBtn.isEnabled = false
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
                        EnvContext.shared.client.locationManager.requestCurrentLocation(true)
                    } else {
                        EnvContext.shared.toast.showToast("网络异常")
                    }
                })
                .disposed(by: disposeBag)
        
        let locationProcess: () -> Void = { [unowned self] in
            
            self.requestDisposeBag = DisposeBag()

            let gaodeCityId = EnvContext.shared.client.locationManager.currentCity.value?.citycode
            let cityName = EnvContext.shared.client.locationManager.currentCity.value?.city

            let lat = EnvContext.shared.client.locationManager.currentLocation.value?.coordinate.latitude
            let lng = EnvContext.shared.client.locationManager.currentLocation.value?.coordinate.longitude
            let params = TTNetworkManager.shareInstance()?.commonParamsblock() as? [String: Any]
            let locationResponseObv: Observable<GeneralConfigResponse?> = requestGeneralConfig(cityName: cityName,
                                                                                               cityId: nil,
                                                                                               gaodeCityId: gaodeCityId,
                                                                                               lat: lat,
                                                                                               lng: lng,
                                                                                               needCommonParams: false,
                                                                                               params: params ?? [:])
            locationResponseObv
                .subscribe(onNext: { [unowned self] response in
                    
                    let params = (self.dataSource.tracerParams ?? TracerParams.momoid()) <|>
                        toTracerParams("location", key: "query_type") <|>
                        toTracerParams(response?.data?.currentCityName ?? "be_null", key: "city")
                    
                    recordEvent(key: "city_filter", params: params)
                    
                    let generalBizConfig = EnvContext.shared.client.generalBizconfig
                    // 只在用户没有选择城市时才回设置城市
                    if let currentCityId = response?.data?.currentCityId {
                        if let theCityId = generalBizConfig.currentSelectCityId.value, theCityId != currentCityId {
                            generalBizConfig.currentSelectCityId.accept(Int(currentCityId))
                            generalBizConfig.setCurrentSelectCityId(cityId: Int(currentCityId))
                        }
                        self.navigationController?.popViewController(animated: true)
                        
                    }
                    
                    generalBizConfig.generalCacheSubject.accept(response?.data)
                    if let payload = response?.data?.toJSONString() {
                        self.searchConfigCache?.setObject(payload as NSString, forKey: "config")
                    }

                    //TODO: 暂时的解决方案，需要也加入到switcher中去
                    requestSearchFilterConfig()
                    }, onError: { error in
                        EnvContext.shared.toast.showToast("加载失败")
                })
                .disposed(by: self.requestDisposeBag)
        }

        func requestSearchFilterConfig() {
            requestSearchConfig()
                .timeout(5, scheduler: MainScheduler.instance)
                .subscribe(onNext: { (response) in
                    EnvContext.shared.client.configCacheSubject.accept(response?.data)
                }, onError: { (error) in
                    EnvContext.shared.toast.showToast("加载失败")
                })
                .disposed(by: self.requestDisposeBag)
        }
        
        locationBar.countryBtn.rx.tap
            .subscribe(onNext: {

                if EnvContext.shared.client.reachability.connection != .none {
                    locationProcess()
                } else {
                    EnvContext.shared.toast.showToast("网络异常")
                }

            })
            .disposed(by: self.disposeBag)
        
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

    var tracerParams = TracerParams.momoid() <|>
        toTracerParams("maintab", key: "page_type")

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
                theCell.setNodes(nodes: nodes) { [weak self] (node) in

                    let params = (self?.tracerParams ?? TracerParams.momoid()) <|>
                        toTracerParams(node.query.rawValue, key: "query_type") <|>
                        toTracerParams(node.label, key: "city")

                    recordEvent(key: "city_filter", params: params)
//                    print(params.paramsGetter([:]))
                    self?.onItemSelect?.onNext(node.cityId ?? -1)
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
            if let item = node.children?[indexPath.row], let cityId = item.cityId {
                onItemSelect?.onNext(cityId)
                let params = tracerParams <|>
                    toTracerParams("list", key: "query_type") <|>
                    toTracerParams(item.label, key: "city")
                recordEvent(key: "city_filter", params: params)
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

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
                    query: .history,
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
                    query: .hot,
                    cityId: $0.cityId,
                    pinyin: nil,
                    simplePinyin: nil,
                    children: nil)
        }
        return nodes + [CountryListNode(
                label: "热门",
                type: .bubble,
                query: .hot,
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
                query: .history,
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
                            query: .list,
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
                            query: .list,
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
        result.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return result
    }()
    
    lazy var countryBtn: UIButton = {
        let result = UIButton()
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
        result.setTitleColor(hexStringToUIColor(hex: "#299cff"), for: .normal)
        return result
    }()

    lazy var bottomBar: UIView = {
        let re = UIView()
        re.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        return re
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(reLocateBtn)
        addSubview(countryLabel)
        countryLabel.snp.makeConstraints { maker in
            maker.left.equalTo(24)
            maker.centerY.equalTo(reLocateBtn.snp.centerY)
        }

        addSubview(poiIcon)
        poiIcon.snp.makeConstraints { maker in
            maker.left.equalTo(countryLabel.snp.right).offset(2)
            maker.centerY.equalTo(reLocateBtn.snp.centerY)
            maker.height.equalTo(20)
            maker.width.equalTo(20)
            maker.top.equalTo(17)
            maker.bottom.equalTo(-17)
        }

        addSubview(countryBtn)
        countryBtn.snp.makeConstraints { maker in
            maker.left.equalTo(countryLabel).offset(-5)
            maker.right.equalTo(poiIcon).offset(5)
            maker.top.bottom.equalToSuperview()
        }
        
        reLocateBtn.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-24)
            maker.centerY.equalToSuperview()
        }

//        addSubview(bottomBar)
//        bottomBar.snp.makeConstraints { (maker) in
//            maker.top.equalTo(countryLabel.snp.bottom).offset(14)
//            maker.bottom.left.right.equalToSuperview()
//            maker.height.equalTo(8)
//        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class CityItemCell: UITableViewCell {

    lazy var label: UILabel = {
        let result = UILabel()
        result.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
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

    let disposeBag: DisposeBag = DisposeBag()


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

    func setNodes(nodes: [CountryListNode], itemClick: @escaping (CountryListNode) -> Void) {
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
                fixedSpacing: 12,
                leadSpacing: 14,
                tailSpacing: 24)
        let viewCoint = rowViews.count
        rowViews.snp.makeConstraints { maker in
            if viewCoint == 1 {
                maker.top.equalTo(12)
                maker.bottom.equalToSuperview().offset(-10).priority(.high)
            }
            maker.left.right.equalToSuperview()
            maker.height.equalTo(28).priority(.high)
        }

    }

    func createRow(nodes: [CountryListNode], itemClick: @escaping (CountryListNode) -> Void) -> (UIView, () -> Void) {
        
        rows.forEach { view in
            view.removeFromSuperview()
        }
        rows.removeAll()
    
        if nodes.count == 0 {
            return (UIView(), {})
        }
        let rowView = UIView()

        let btns = nodes.map { [weak self] (node) -> BubbleBtn in
            let result = BubbleBtn()
            result.label.text = node.label
            if let theDisposeBag = self?.disposeBag {

                result.rx.controlEvent(.touchUpInside)
//                    .debug()
                    .subscribe(onNext: { void in
                        itemClick(node)
                    })
                    .disposed(by: theDisposeBag)

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
                maker.width.equalTo(75 * CommonUIStyle.Screen.widthScale).priority(.high)
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

}

fileprivate class BubbleBtn: UIControl {

    lazy var label: UILabel = {
        let result = UILabel()
        result.textAlignment = .center
        result.font = CommonUIStyle.Font.pingFangRegular(14 * CommonUIStyle.Screen.widthScale)
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
        result.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        return result
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.equalTo(24)
            maker.height.equalTo(22)
            maker.top.equalTo(6)
            maker.bottom.equalTo(-6)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

