//
//  NeighborhoodNameCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/7.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
class NeighborhoodNameCell: BaseUITableViewCell {
    open override class var identifier: String {
        return "NeighborhoodNameCell"
    }

    let leftMarge: CGFloat = 20
    let rightMarge: CGFloat = -20

    lazy var nameLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(24)
        re.textColor = hexStringToUIColor(hex: "#081f33")
        re.numberOfLines = 2
        return re
    }()

    lazy var subNameLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey3Color)
        return re
    }()

//    lazy var locationIcon: UIButton = {
//        let re = UIButton()
//        re.setImage(#imageLiteral(resourceName: "group"), for: .normal)
//        re.isHidden = true
//        return re
//    }()

    lazy var priceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(18)
        re.textColor = hexStringToUIColor(hex: "#ff5b4c")
        re.textAlignment = .right
        return re
    }()

    lazy var monthUp: UILabel = {
        let re = UILabel()
        re.text = "环比上月"
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#a1aab3")
        re.textAlignment = .right
        return re
    }()
    
    lazy var monthUpLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#a1aab3")
        re.textAlignment = .right
        return re
    }()

    lazy var monthUpTrend: UIImageView = {
        let re = UIImageView()
        return re
    }()

    lazy var subNameLabelButton: UIButton = {
        let re = UIButton()
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // addBottomLine()

        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.right.equalTo(rightMarge)
            maker.top.equalTo(21)
            maker.width.greaterThanOrEqualTo(95).priority(.high)
        }

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { maker in
            maker.left.equalTo(leftMarge)
            maker.top.equalTo(15)
            maker.right.equalTo(priceLabel.snp.left).offset(-5)
            maker.height.equalTo(34)
        }

        contentView.addSubview(subNameLabel)
        contentView.addSubview(monthUp)

        subNameLabel.snp.makeConstraints { maker in
            maker.left.equalTo(leftMarge)
            maker.top.equalTo(nameLabel.snp.bottom).offset(6)
            maker.height.equalTo(17)
            maker.bottom.equalTo(-16)
            maker.right.equalTo(monthUp.snp.left).offset(-10)

        }

        contentView.addSubview(subNameLabelButton)
        subNameLabelButton.snp.makeConstraints { maker in
            maker.edges.equalTo(subNameLabel.snp.edges)
        }
        
        contentView.addSubview(monthUpTrend)
        monthUpTrend.snp.makeConstraints { maker in
            maker.centerY.equalTo(subNameLabel)
            maker.right.equalTo(rightMarge)
            maker.width.height.equalTo(12)
        }
        
        monthUpLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        monthUpLabel.setContentHuggingPriority(.required, for: .horizontal)
        contentView.addSubview(monthUpLabel)
        monthUpLabel.snp.makeConstraints { maker in
            maker.height.equalTo(20)
            maker.centerY.equalTo(monthUpTrend.snp.centerY)
            maker.right.equalTo(monthUpTrend.snp.left)
        }
        
        monthUp.snp.makeConstraints { maker in
            maker.height.equalTo(20)
            maker.centerY.equalTo(monthUpTrend.snp.centerY)
            maker.right.equalTo(monthUpLabel.snp.left).offset(-3)
        }

//        contentView.addSubview(locationIcon)
//        locationIcon.snp.makeConstraints { maker in
//            maker.left.equalTo(subNameLabel.snp.right).offset(4)
//            maker.height.width.equalTo(16)
//            maker.top.equalTo(nameLabel.snp.bottom).offset(6.5)
//            maker.right.equalTo(monthUpLabel.snp.left).offset(-5)
//         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


func parseNeighborhoodNameNode(_ data: NeighborhoodDetailData,traceExtension: TracerParams = TracerParams.momoid(),navVC: UINavigationController? = EnvContext.shared.rootNavController,disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        let cellRender = oneTimeRender(curry(fillNeighborhoodNameCell)(data)(traceExtension)(navVC)(disposeBag))
        let paramsHoseDeal = TracerParams.momoid() <|>
            toTracerParams("house_deal", key: "element_type") <|>
            toTracerParams("neighborhood_detail", key: "page_type") <|>
        traceExtension
        
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            tracer: [elementShowOnceRecord(params: paramsHoseDeal)],
            label: "",
            type: .node(identifier: NeighborhoodNameCell.identifier))
    }
}

func fillNeighborhoodNameCell(_ data: NeighborhoodDetailData,traceExtension: TracerParams = TracerParams.momoid(),navVC: UINavigationController?, disposeBag: DisposeBag, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NeighborhoodNameCell {
        theCell.nameLabel.text = data.name
        theCell.subNameLabel.text = data.neighborhoodInfo?.address

        theCell.priceLabel.text = data.neighborhoodInfo?.pricingPerSqm
        let params = TracerParams.momoid() <|>
            toTracerParams("neighborhood_detail", key: "enter_from") <|>
            toTracerParams(selectTraceParam(traceExtension, key: "log_pb") ?? "be_null", key: "log_pb") <|>
            toTracerParams(data.id ?? "be_null", key: "group_id") <|>
            toTracerParams("house_info", key: "element_from") <|>
            toTracerParams("address", key: "click_type")
        let clickMapParams = EnvContext.shared.homePageParams <|>
            params <|>
            beNull(key: "map_tag")

        theCell.subNameLabelButton.rx.tap
                .bind { [unowned disposeBag] recognizer in
                    if let lat = data.neighborhoodInfo?.gaodeLat,
                       let lng = data.neighborhoodInfo?.gaodeLng {
                        recordEvent(key: "click_map", params: clickMapParams)

                        openMapPage(
                            navVC: navVC,
                            lat: lat,
                            lng: lng,
                            title: data.name ?? "",
                            clickMapParams: clickMapParams,
                            traceParams: params,
                            openMapType:.defautFirstType,
                            disposeBag: disposeBag)(TracerParams.momoid())
                    }

                }
                .disposed(by: disposeBag)
        if let monthUp = data.neighborhoodInfo?.monthUp {
            let absValue = abs(monthUp) * 100
            if absValue == 0 {
                theCell.monthUpLabel.text = "持平"
                theCell.monthUpTrend.isHidden = true
            } else {
                theCell.monthUpLabel.text = String(format: "%.2f%%", arguments: [absValue])
                theCell.monthUpTrend.isHidden = false
                if monthUp > 0 {
                    theCell.monthUpTrend.image = #imageLiteral(resourceName: "monthup_trend_up")
                } else {
                    theCell.monthUpTrend.image = #imageLiteral(resourceName: "monthup_trend_down")
                }
            }
        }
    }
}
