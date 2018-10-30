//
// Created by linlin on 2018/7/13.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

fileprivate struct RoomType {
    let roomCount: Int
    let count: Int
}

infix operator <*>: SequencePrecedence

fileprivate typealias Filter = (FloorPan.Item) -> Bool

fileprivate var allFilter: Filter = { _ in
    true
}

fileprivate func <*>(l: @escaping Filter, r: @escaping Filter) -> Filter {
    return { item in
        l(item) && r(item)
    }
}

fileprivate func filterContent(content: String?, item: FloorPan.Item) -> Bool {
    return content == item.saleStatus?.content || content == "不限"
}

fileprivate func filterByRoomCount(count: Int, item: FloorPan.Item)  -> Bool {
    return item.roomCount == count
}

class FloorPanCategoryViewModel: NSObject, UITableViewDataSource, UITableViewDelegate, TableViewTracer {

    var followPage: BehaviorRelay<String> = BehaviorRelay(value: "house_model_list")

    weak var tableView: UITableView?

    weak var segmentedControl: FWSegmentedControl?

    weak var leftFilterView: UIView?

    var cellFactory: UITableViewCellFactory

    private let datas: BehaviorRelay<[TableRowNode]> = BehaviorRelay(value: [])

    private let items: BehaviorRelay<[FloorPan.Item]> = BehaviorRelay<[FloorPan.Item]>(value: [])

    private let disposeBag = DisposeBag()

    private var statusFilter = BehaviorRelay<Filter>(value: allFilter)
    
    private let typeFilter = BehaviorRelay<Filter>(value: allFilter)

    private let categoryFilter: Observable<Filter>
    
    private weak var navVC: UINavigationController?
    
    let bottomBarBinder: FollowUpBottomBarBinder

    var logPB: Any?
    
    var isHiddenBottomBar: Bool

    init(tableView: UITableView,
         navVC: UINavigationController?,
         isHiddenBottomBar: Bool = true,
         logPBVC: Any? = "be_null",
         followPage: BehaviorRelay<String>,
         segmentedControl: FWSegmentedControl,
         leftFilterView: UIView,
         bottomBarBinder: @escaping FollowUpBottomBarBinder) {
        self.followPage = followPage
        self.tableView = tableView
        self.isHiddenBottomBar = isHiddenBottomBar
        tableView.rowHeight = 0
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        
        self.navVC = navVC
        self.segmentedControl = segmentedControl
        self.leftFilterView = leftFilterView
        self.cellFactory = getHouseDetailCellFactory()
        self.bottomBarBinder = bottomBarBinder
        categoryFilter = Observable
            .combineLatest(statusFilter, typeFilter)
            .map({ (e) -> Filter in
                let (l, r) = e
                return l <*> r
            })
        super.init()
        tableView.dataSource = self
        tableView.delegate = self

        cellFactory.register(tableView: tableView)

        //侧边条件过滤初始化
        setupLeftFilterPanel()

        //顶部横向过滤器初始化
        Observable.combineLatest(items.filter { $0.count > 0 } , categoryFilter)
            .subscribe(onNext: { [unowned self] (e) in
                let (its, f) = e
                let roomTypes = its.reduce([:], reduceToRoomTypes)
                let roomCategorys = roomTypes.map {
                    $0.value
                    }.sorted(by: { (left, right) -> Bool in
                        left.roomCount < right.roomCount
                    })
                let roomCategoryLabels = roomCategorys.map {
                    "\($0.roomCount)室(\($0.count))"
                }
                self.segmentedControl?.sectionTitleArray = ["全部"] + roomCategoryLabels
                
                if its.filter(f).count < 1 {

                    EnvContext.shared.toast.showToast("暂无相关房型~")
                }
//                print(its.filter(f))
                self.datas.accept(parseFloorPanItemsNode(
                    data: its.filter(f),
                    logPBVC: logPBVC,
                    isHiddenBottomBar: self.isHiddenBottomBar,
                    navVC: self.navVC,
                    followPage: self.followPage,
                    disposeBag: self.disposeBag,
                    bottomBarBinder: bottomBarBinder,
                    params: TracerParams.momoid() <|>
                        toTracerParams(self.logPB ?? "be_null", key: "log_pb"))())

                self.segmentedControl?.indexChangeBlock = { [unowned self] (index) in
                    if index == 0 {
                        self.typeFilter.accept(allFilter)
                    } else {
                        self.typeFilter.accept(curry(filterByRoomCount)(roomCategorys[index - 1].roomCount))
                    }
                }
            }, onError: { (error) in
//                    print(error)
            })
            .disposed(by: disposeBag)
        
        datas
            .subscribe(onNext: { [unowned self] nodes in
                self.reloadData()
            })
            .disposed(by: disposeBag)
        
    }
    
    func reloadData() {
        tableView?.reloadData()
        tableView?.setContentOffset(CGPoint.zero, animated: true)
    }

    func request(courtId: Int64) {
        if EnvContext.shared.client.reachability.connection == .none
        {
            return
        }
        EnvContext.shared.toast.showLoadingToast("正在加载")
        requestNewHouseFloorPan(houseId: courtId)
                .subscribe(onNext: { [unowned self] response in
                    if let its = response?.data?.list {
                        self.items.accept(its)
                    }
                    EnvContext.shared.toast.dismissToast()
                })
                .disposed(by: disposeBag)
    }

    func setupLeftFilterPanel() {
        let leftFilterConditions = ["不限",
                                    "在售",
                                    "待售",
                                    "售罄"]
        let filterItems = leftFilterConditions
                .map { (text) -> LeftFilterView in
                    let re = LeftFilterView()
                    re.label.text = text
                    return re
                }

        filterItems.forEach { [unowned self] in
            self.leftFilterView?.addSubview($0)
        }

        filterItems.snp.distributeViewsAlong(axisType: .vertical, fixedSpacing: 0, averageLayout: false)
        filterItems.snp.makeConstraints { maker in
            maker.width.equalToSuperview()
        }
        filterItems.first?.isSelected = true


        func resetSelectItem(itemView: [LeftFilterView], selectedIndex: Int) {
            filterItems.enumerated().forEach { e in
                let (offset, v) = e
                v.isSelected = false
                if selectedIndex == offset {
                    v.isSelected = true
                }
            }
        }

        filterItems.enumerated().forEach { e in
            let (offset, v) = e
            v.tapGesture.rx.event
                    .bind { [unowned self] _ in
                        resetSelectItem(itemView: filterItems, selectedIndex: offset)
                        self.statusFilter.accept(curry(filterContent)(leftFilterConditions[offset]))
                    }
                    .disposed(by: disposeBag)
        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch datas.value[indexPath.row].type {
        case let .node(identifier):
            let cell = cellFactory.dequeueReusableCell(
                    identifer: identifier,
                    tableView: tableView,
                    indexPath: indexPath)
            datas.value[indexPath.row].itemRender(cell)
            return cell
        default:
            return CycleImageCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let params = TracerParams.momoid() <|>
            toTracerParams(indexPath.row, key: "rank")
        datas.value[indexPath.row].selector?(params)
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 105
    }
//    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row < datas.value.count {
            callTracer(tracer: datas.value[indexPath.row].tracer, traceParams: EnvContext.shared.homePageParams)
        }
    }

    func cleanData() {
        self.datas.accept([])
    }

}

fileprivate func reduceToRoomTypes(rooms: [Int: RoomType], item: FloorPan.Item) -> [Int: RoomType] {
    var rooms = rooms
    var theType: RoomType? = nil
    if let roomType = rooms[item.roomCount] {
        theType = RoomType(roomCount: item.roomCount, count: roomType.count + 1)
    } else {
        theType = RoomType(roomCount: item.roomCount, count: 1)
    }
    rooms[item.roomCount] = theType
    return rooms
}

class LeftFilterView: UIView {

    var isSelected: Bool = false {
        didSet {
            setStyle(isSelected: isSelected)
        }
    }

    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(15)
        re.textColor = hexStringToUIColor(hex: kFHClearBlueColor)
        re.textAlignment = .center
        return re
    }()

    lazy var tapGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
            maker.height.equalTo(50)
        }
        setStyle(isSelected: isSelected)
        addGestureRecognizer(tapGesture)
    }

    func setStyle(isSelected: Bool) {
        if isSelected {
            label.textColor = hexStringToUIColor(hex: kFHClearBlueColor)
            self.backgroundColor = hexStringToUIColor(hex: "#ffffff")
        } else {
            label.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
            self.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
