//
//  NeighborhoodInfoCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
class NeighborhoodInfoCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "NeighborhoodInfoCell"
    }

    lazy var nameKey: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#999999")
        re.text = "名称"
        return re
    }()

    lazy var nameValue: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#222222")
        return re
    }()

    lazy var priceKeyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#999999")
        re.text = "均价"
        return re
    }()

    lazy var priceValueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    lazy var monthUpKeyLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#999999")
        re.text = "环比"
        return re
    }()

    lazy var monthUpValueLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        return re
    }()

    lazy var monthUpTrend: UIImageView = {
        let re = UIImageView()
        return re
    }()

    lazy var mapImageView: UIImageView = {
        let re = UIImageView()
        return re
    }()

    lazy var mapViewGesture: UITapGestureRecognizer = {
        let re = UITapGestureRecognizer()
        return re
    }()


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameKey)
        nameKey.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalToSuperview()
            maker.height.equalTo(20)
            maker.width.equalTo(28)
         }

        contentView.addSubview(nameValue)
        nameValue.snp.makeConstraints { maker in
            maker.left.equalTo(nameKey.snp.right).offset(10)
            maker.height.equalTo(20)
            maker.right.equalToSuperview().offset(-15)
        }

        contentView.addSubview(priceKeyLabel)
        priceKeyLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(nameKey.snp.bottom).offset(10)
            maker.height.equalTo(20)
            maker.width.equalTo(28)
         }

        contentView.addSubview(priceValueLabel)
        priceValueLabel.snp.makeConstraints { [unowned contentView] maker in
            maker.centerY.equalTo(priceKeyLabel.snp.centerY)
            maker.height.equalTo(20)
            maker.right.equalTo(contentView.snp.centerX)
            maker.left.equalTo(priceKeyLabel.snp.right).offset(10)
         }

        contentView.addSubview(monthUpKeyLabel)
        monthUpKeyLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(priceValueLabel.snp.centerY)
            maker.height.equalTo(20)
            maker.left.equalTo(priceValueLabel.snp.right).offset(15)
            maker.width.equalTo(28)
         }

        contentView.addSubview(monthUpValueLabel)
        monthUpValueLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(monthUpKeyLabel.snp.centerY)
            maker.left.equalTo(monthUpKeyLabel.snp.right).offset(10)
            maker.height.equalTo(20)
         }

        contentView.addSubview(monthUpTrend)

        monthUpTrend.snp.makeConstraints { maker in
            maker.left.equalTo(monthUpValueLabel.snp.right).offset(1)
            maker.centerY.equalTo(priceKeyLabel.snp.centerY)
            maker.width.height.equalTo(12)
        }


        contentView.addSubview(mapImageView)
        mapImageView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(150)
            maker.top.equalTo(monthUpValueLabel.snp.bottom).offset(16)
         }
        mapImageView.addGestureRecognizer(mapViewGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

func parseNeighborhoodInfoNode(_ ershouHouseData: ErshouHouseData, navVC: UINavigationController?) -> () -> TableSectionNode {
    let disposeBag = DisposeBag()
    return {
        let params = TracerParams.momoid() <|>
            toTracerParams("neighborhood_detail", key: "element_type") <|>
            toTracerParams(ershouHouseData.logPB ?? "be_null", key: "log_pb")
        let render = curry(fillNeighborhoodInfoCell)(ershouHouseData.neighborhoodInfo)
        let selector = {
            if let lat = ershouHouseData.neighborhoodInfo?.gaodeLat,
                let lng = ershouHouseData.neighborhoodInfo?.gaodeLng {
                let theParams = params <|>
                    toTracerParams("map_list", key: "click_type") <|>
                        toTracerParams("old_detail", key: "enter_from")

                let clickParams = theParams <|>
                    toTracerParams("map", key: "click_type")
                recordEvent(key: "click_map", params: clickParams)
                openMapPage(lat: lat, lng: lng, traceParams: theParams, disposeBag: disposeBag)()
            }
        }

        return TableSectionNode(
                items: [render],
                selectors: [selector],
                tracer: [elementShowOnceRecord(params: params)],
                label: "",
                type: .node(identifier: NeighborhoodInfoCell.identifier))
    }
}

func fillNeighborhoodInfoCell(_ data: NeighborhoodInfo?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NeighborhoodInfoCell {
        theCell.nameValue.text = data?.name
        theCell.priceValueLabel.text = data?.pricingPerSqm

        if let url = data?.gaodeImageUrl {
            theCell.mapImageView.bd_setImage(with: URL(string: url), placeholder: #imageLiteral(resourceName: "default_image"))
        }

        if let monthUp = data?.monthUp {
            let absValue = abs(monthUp) * 100
            if absValue == 0 {
                theCell.monthUpValueLabel.text = "持平"
                theCell.monthUpTrend.isHidden = true
            } else {
                theCell.monthUpValueLabel.text = String(format: "%.2f%%", arguments: [absValue])
                theCell.monthUpTrend.isHidden = false
                if monthUp > 0 {
                    theCell.monthUpValueLabel.textColor = hexStringToUIColor(hex: "#f85959")
                    theCell.monthUpTrend.image = #imageLiteral(resourceName: "monthup_trend_up")
                } else {
                    theCell.monthUpValueLabel.textColor = hexStringToUIColor(hex: "#79d35f")
                    theCell.monthUpTrend.image = #imageLiteral(resourceName: "monthup_trend_down")
                }
            }
        }
    }
}
