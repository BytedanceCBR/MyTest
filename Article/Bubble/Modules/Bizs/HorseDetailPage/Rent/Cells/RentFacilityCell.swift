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


func parseRentFacilityCellNode(tracer: HouseRentTracer) -> () -> TableSectionNode? {
    let render = curry(fillRentFacilityCell)
    let params = EnvContext.shared.homePageParams <|>
        toTracerParams(tracer.logPb ?? "be_null", key: "log_pb") <|>
        toTracerParams("house_facility", key: "element_type") <|>
        toTracerParams(tracer.pageType, key: "page_type")
    let tracerEvaluationRecord = elementShowOnceRecord(params: params)

    return {
        return TableSectionNode(
            items: [render],
            selectors: nil,
            tracer:[tracerEvaluationRecord],
            sectionTracer: nil,
            label: "",
            type: .node(identifier: RentFacilityCell.identifier))
    }
}

func fillRentFacilityCell(cell: BaseUITableViewCell) {
    if let theCell = cell as? RentFacilityCell {
        var items: [FHHouseRentFacilityItemView] = []
        var itemView = FHHouseRentFacilityItemView()
        itemView.label.text = "床";
        itemView.iconView.image = UIImage(named: "bed")
        items.append(itemView)
        itemView = FHHouseRentFacilityItemView()
        itemView.label.text = "床";
        itemView.iconView.image = UIImage(named: "bed")
        items.append(itemView)
        itemView = FHHouseRentFacilityItemView()
        itemView.label.text = "床";
        itemView.iconView.image = UIImage(named: "bed")
        items.append(itemView)
        itemView = FHHouseRentFacilityItemView()
        itemView.label.text = "床";
        itemView.iconView.image = UIImage(named: "bed")
        items.append(itemView)
        itemView = FHHouseRentFacilityItemView()
        itemView.label.text = "床";
        itemView.iconView.image = UIImage(named: "bed")
        items.append(itemView)
        itemView = FHHouseRentFacilityItemView()
        itemView.label.text = "床";
        itemView.iconView.image = UIImage(named: "bed")
        items.append(itemView)
        itemView = FHHouseRentFacilityItemView()
        itemView.label.text = "床";
        itemView.iconView.image = UIImage(named: "bed")
        items.append(itemView)
        itemView = FHHouseRentFacilityItemView()
        itemView.label.text = "床";
        itemView.iconView.image = UIImage(named: "bed")
        items.append(itemView)
        itemView = FHHouseRentFacilityItemView()
        itemView.label.text = "床";
        itemView.iconView.image = UIImage(named: "bed")
        items.append(itemView)
        itemView = FHHouseRentFacilityItemView()
        itemView.label.text = "床";
        itemView.iconView.image = UIImage(named: "bed")
        items.append(itemView)
        theCell.facilityItemView.add(items)
    }
}
