//
// Created by linlin on 2018/7/13.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FloorPanInfoViewModel: NSObject, UITableViewDelegate, UITableViewDataSource {

    let datas: BehaviorRelay<[TableSectionNode]> = BehaviorRelay(value: [])

    let disposeBag = DisposeBag()

    weak var tableView: UITableView?

    var cellFactory: UITableViewCellFactory

    var newHouseData: NewHouseData

    init(tableView: UITableView,
         newHouseData: NewHouseData) {
        self.tableView = tableView
        self.newHouseData = newHouseData
        self.cellFactory = getHouseDetailCellFactory()
        super.init()
        cellFactory.register(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        datas
                .subscribe(onNext: { [unowned self] datas in
                    self.tableView?.reloadData()
                })
                .disposed(by: disposeBag)
    }

    func request(floorPanId: String, newHouseData: NewHouseData) {
        if let floorPanId = Int64(floorPanId) {
            requestNewHouseMoreDetail(houseId: floorPanId)
                    .subscribe(onNext: { [unowned self] response in
                        if let data = response?.data {
                            let sectionParser = DetailDataParser.monoid()
                                    <- parseNewHouseNameNode(newHouseData)
                                    <- parsePropertiesNode(properties: parseFirstNode(data))
                                    <- parsePropertiesNode(properties: parseSecondNode(data))
                                    <- parsePropertiesNode(properties: parseThirdNode(data))
                                    <- parsePropertiesNode(properties: parseFourthNode(data))
                                    <- parsePermitListNode(data)
                                    <- parseDisclaimerNode(newHouseData)
                            self.datas.accept(sectionParser.parser([]))
                        }
                    })
                    .disposed(by: disposeBag)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.value.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.value[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch datas.value[indexPath.section].type {
        case let .node(identifier):
            let cell = cellFactory.dequeueReusableCell(
                    identifer: identifier,
                    tableView: tableView,
                    indexPath: indexPath)
            datas.value[indexPath.section].items[indexPath.row](cell)
            return cell
        default:
            return CycleImageCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        datas.value[indexPath.section].selectors?[indexPath.row]()
    }
}

fileprivate func parseFirstNode(_ detail: CourtMoreDetail) -> [(String, String)] {
    return [("开发商", propertyValue(detail.developerName)),
            ("楼盘状态", propertyValue(detail.saleStatus)),
            ("参考价格", propertyValue(detail.pricingPerSqm)),
            ("开盘时间", propertyValue(detail.openDate)),
            ("交房时间", propertyValue(detail.deliveryDate))]
}

fileprivate func parseSecondNode(_ detail: CourtMoreDetail) -> [(String, String)] {
    return [("环线", propertyValue(detail.circuitDesc)),
            ("楼盘地址", propertyValue(detail.generalAddress)),
            ("售楼地址", propertyValue(detail.saleAddress))]
}

fileprivate func parseThirdNode(_ detail: CourtMoreDetail) -> [(String, String)] {
    return [("物业类型", propertyValue(detail.properyType)),
            ("项目特色", propertyValue(detail.featureDesc)),
            ("建筑类别", propertyValue(detail.buildingCategory)),
            ("装修状况", propertyValue(detail.decoration)),
            ("建筑类型", propertyValue(detail.buildingType)),
            ("产权年限", propertyValue(detail.propertyRight))]
}

fileprivate func parseFourthNode(_ detail: CourtMoreDetail) -> [(String, String)] {
    return [("物业公司", propertyValue(detail.propertyName)),
            ("物业费用", propertyValue(detail.propertyPrice)),
            ("水电燃气", propertyValue(detail.powerWaterGasDesc)),
            ("供暖方式", propertyValue(detail.heating)),
            ("绿化率", propertyValue(detail.greenRatio)),
            ("车位情况", propertyValue(detail.parkingNum)),
            ("容积率", propertyValue(detail.plotRatio)),
            ("楼栋信息", propertyValue(detail.buildingDesc))]
}

var propertyValue: (String?) -> String = { input in
    valueWithDefault(value: input, defaultValue: "-")
}

fileprivate func valueWithDefault<V>(value: V?, defaultValue: V) -> V {
    return value != nil ? value! : defaultValue
}

