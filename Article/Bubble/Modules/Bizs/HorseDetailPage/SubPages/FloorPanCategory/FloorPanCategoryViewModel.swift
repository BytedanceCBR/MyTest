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

fileprivate var allFilter: Filter = { _ in true }

fileprivate func <*>(l: @escaping Filter, r: @escaping Filter) -> Filter {
    return { item in
        l(item) && r(item)
    }
}

fileprivate func filterContent(content: String?, item: FloorPan.Item) -> Bool {
    return content == item.title || content == "全部"
}

fileprivate func filterByRoomCount(count: Int, item: FloorPan.Item)  -> Bool {
    return item.roomCount == count || count == -1000
}

class FloorPanCategoryViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {

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
    
    let followStatus: BehaviorRelay<Result<Bool>>

    init(tableView: UITableView,
         navVC: UINavigationController?,
         segmentedControl: FWSegmentedControl,
         leftFilterView: UIView,
         followStatus: BehaviorRelay<Result<Bool>>) {
        self.tableView = tableView
        self.navVC = navVC
        self.segmentedControl = segmentedControl
        self.leftFilterView = leftFilterView
        self.cellFactory = getHouseDetailCellFactory()
        self.followStatus = followStatus
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
                
                self.datas.accept(parseFloorPanItemsNode(data: its.filter(f), navVC: self.navVC, disposeBag: self.disposeBag, followStatus: followStatus)())

                self.segmentedControl?.indexChangeBlock = { [unowned self] (index) in
                    if index == 0 {
                        self.typeFilter.accept(allFilter)
                    } else {
                        self.typeFilter.accept(curry(filterByRoomCount)(roomTypes[index + 1]?.roomCount ?? -1000))
                    }
                }
            }, onError: { (error) in
                    print(error)
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
    }

    func request(courtId: Int64) {
        requestNewHouseFloorPan(houseId: courtId)
                .subscribe(onNext: { [unowned self] response in
                    if let its = response?.data?.list {
                        self.items.accept(its)
                    }
                })
                .disposed(by: disposeBag)
    }

    func setupLeftFilterPanel() {
        let leftFilterConditions = ["全部",
                                    "在售",
                                    "待售",
                                    "售磬"]
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
        datas.value[indexPath.row].selector?()
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        re.textColor = hexStringToUIColor(hex: "#f85959")
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
            label.textColor = hexStringToUIColor(hex: "#f85959")
            self.backgroundColor = hexStringToUIColor(hex: "#ffffff")
        } else {
            label.textColor = hexStringToUIColor(hex: "#222222")
            self.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
