//
//  RentFacilityCell.swift
//  NewsLite
//
//  Created by leo on 2018/11/20.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
class RentFacilityCell: BaseUITableViewCell {


    open override class var identifier: String {
        return "rentFacilityCell"
    }

    lazy var facilityItemView: FHRowsView = {
        let re = FHRowsView(rowCount: 5)
        return re
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.addSubview(facilityItemView)
        facilityItemView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview();
        }
    }
}


func parseRentFacilityCellNode(model: FHRentDetailResponseModel?,
                               tracer: HouseRentTracer) -> () -> TableSectionNode? {
    let facilities = model?.data?.facilities as? [FHRentDetailResponseDataFacilitiesModel]
    let render = curry(fillRentFacilityCell)(facilities)
    let params = EnvContext.shared.homePageParams <|>
        toTracerParams(tracer.logPb ?? "be_null", key: "log_pb") <|>
        toTracerParams("house_facility", key: "element_type") <|>
        toTracerParams(tracer.pageType, key: "page_type")
    let tracerEvaluationRecord = elementShowOnceRecord(params: params)

    return {
        if (model?.data?.facilities?.count ?? 0) != 0 {
            return TableSectionNode(
                items: [render],
                selectors: nil,
                tracer:[tracerEvaluationRecord],
                sectionTracer: nil,
                label: "",
                type: .node(identifier: RentFacilityCell.identifier))
        } else {
            return nil
        }
    }
}

func fillRentFacilityCell(facilities: [FHRentDetailResponseDataFacilitiesModel]?, cell: BaseUITableViewCell) {
    if let theCell = cell as? RentFacilityCell {

        let items: [FHHouseRentFacilityItemView] = facilities?.map({ (model) -> FHHouseRentFacilityItemView in
            let strickoutLable = StrickoutLabel()
            strickoutLable.textColor = hexStringToUIColor(hex: "#a0aab3")
            strickoutLable.font = CommonUIStyle.Font.pingFangRegular(14)
            let re = FHHouseRentFacilityItemView(strickoutLabel: strickoutLable)
            if model.enabled {
                re.label.text = model.name
                re.strickoutLabel.isHidden = true
            } else {
                if let name = model.name {
                    re.strickoutLabel.text = name
                    re.strickoutLabel.isHidden = false
                }
            }

            if let url = model.iconUrl {
                re.iconView.bd_setImage(with: URL(string: url))
            }
            return re
        }) ?? []
        theCell.facilityItemView.add(items)
    }
}
