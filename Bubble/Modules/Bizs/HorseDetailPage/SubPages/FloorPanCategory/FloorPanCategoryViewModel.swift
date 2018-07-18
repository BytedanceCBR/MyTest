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

class FloorPanCategoryViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {

    weak var tableView: UITableView?

    weak var segmentedControl: FWSegmentedControl?

    weak var leftFilterView: UIView?

    var cellFactory: UITableViewCellFactory

    private let datas: BehaviorRelay<[TableRowNode]> = BehaviorRelay(value: [])

    private let items: BehaviorRelay<[FloorPan.Item]> = BehaviorRelay<[FloorPan.Item]>(value: [])

    private let disposeBag = DisposeBag()

    init(tableView: UITableView,
         segmentedControl: FWSegmentedControl,
         leftFilterView: UIView) {
        self.tableView = tableView
        self.segmentedControl = segmentedControl
        self.leftFilterView = leftFilterView
        self.cellFactory = getHouseDetailCellFactory()
        super.init()
        tableView.dataSource = self
        tableView.delegate = self

        cellFactory.register(tableView: tableView)

        setupLeftFilterPanel()
        items
                .filter {
                    $0.count > 0
                }
                .subscribe(onNext: { [unowned self] (items) in
                    let roomTypes = items.reduce([:], reduceToRoomTypes)
                    let roomCategorys = roomTypes.map {
                        $0.value
                    }.sorted(by: { (left, right) -> Bool in
                        left.roomCount < right.roomCount
                    })
                    let roomCategoryLabels = roomCategorys.map {
                        "\($0.roomCount)室(\($0.count))"
                    }
                    self.segmentedControl?.sectionTitleArray = ["全部"] + roomCategoryLabels

                    self.datas.accept(parseFloorPanItemsNode(data: items, disposeBag: self.disposeBag)())
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
                .debug()
                .subscribe(onNext: { [unowned self] response in
                    if let its = response?.data?.list {
                        self.items.accept(its)
                    }
                })
                .disposed(by: disposeBag)
    }

    func setupLeftFilterPanel() {
        let filterItems = ["全部",
                           "在售",
                           "待售",
                           "售磬"].map { (text) -> LeftFilterView in
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

    init() {
        super.init(frame: CGRect.zero)
        addSubview(label)
        label.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
            maker.height.equalTo(50)
        }
        setStyle(isSelected: isSelected)
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
