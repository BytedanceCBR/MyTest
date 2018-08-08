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

    lazy var nameLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(24)
        re.textColor = hexStringToUIColor(hex: "#222222")
        re.numberOfLines = 2
        return re
    }()

    lazy var subNameLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#999999")
        return re
    }()

    lazy var locationIcon: UIButton = {
        let re = UIButton()
        re.setImage(#imageLiteral(resourceName: "group"), for: .normal)
        return re
    }()

    lazy var priceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(18)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        re.textAlignment = .right
        return re
    }()

    lazy var monthUpLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(14)
        re.textColor = hexStringToUIColor(hex: "#f85959")
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

        addBottomLine()

        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.right.equalTo(-15)
            maker.top.equalTo(21)
            maker.width.greaterThanOrEqualTo(95).priority(.high)
        }

        contentView.addSubview(monthUpTrend)
        monthUpTrend.snp.makeConstraints { maker in
            maker.top.equalTo(priceLabel.snp.bottom).offset(7)
            maker.right.equalTo(-15)
            maker.width.height.equalTo(12)
        }

        contentView.addSubview(monthUpLabel)
        monthUpLabel.snp.makeConstraints { maker in
            maker.height.equalTo(20)
            maker.centerY.equalTo(monthUpTrend.snp.centerY)
            maker.right.equalTo(monthUpTrend.snp.left)
        }

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(15)
            maker.right.equalTo(priceLabel.snp.left).offset(-5)
            maker.height.equalTo(34)
        }

        contentView.addSubview(subNameLabel)
        subNameLabel.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(nameLabel.snp.bottom).offset(6)
            maker.height.equalTo(17)
            maker.bottom.equalTo(-16)
        }

        contentView.addSubview(subNameLabelButton)
        subNameLabelButton.snp.makeConstraints { maker in
            maker.edges.equalTo(subNameLabel.snp.edges)
        }

        contentView.addSubview(locationIcon)
        locationIcon.snp.makeConstraints { maker in
            maker.left.equalTo(subNameLabel.snp.right).offset(4)
            maker.height.width.equalTo(16)
            maker.top.equalTo(nameLabel.snp.bottom).offset(6.5)
            maker.right.equalTo(monthUpLabel.snp.left).offset(-5)
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


func parseNeighborhoodNameNode(_ data: NeighborhoodDetailData, disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        let cellRender = oneTimeRender(curry(fillNeighborhoodNameCell)(data)(disposeBag))
        return TableSectionNode(items: [cellRender], selectors: nil, label: "", type: .node(identifier: NeighborhoodNameCell.identifier))
    }
}

func oneTimeRender(_ parser: @escaping (BaseUITableViewCell) -> Void) -> (BaseUITableViewCell) -> Void {
    var executed = false
    return { (cell) in
        if !executed {
            parser(cell)
            executed = true
        }
    }
}

func fillNeighborhoodNameCell(_ data: NeighborhoodDetailData, disposeBag: DisposeBag, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NeighborhoodNameCell {
        theCell.nameLabel.text = data.name
        theCell.subNameLabel.text = data.neighborhoodInfo?.address
        theCell.priceLabel.text = data.neighborhoodInfo?.pricingPerSqm
        theCell.locationIcon.rx.tap
                .bind { [unowned disposeBag] recognizer in
                    if let lat = data.neighborhoodInfo?.gaodeLat,
                            let lng = data.neighborhoodInfo?.gaodeLng {
                        openMapPage(lat: lat, lng: lng, disposeBag: disposeBag)()
                    }

                }
                .disposed(by: disposeBag)
        theCell.subNameLabelButton.rx.tap
                .debug("bbb")
                .bind { [unowned disposeBag] recognizer in
                    if let lat = data.neighborhoodInfo?.gaodeLat,
                       let lng = data.neighborhoodInfo?.gaodeLng {
                        openMapPage(lat: lat, lng: lng, disposeBag: disposeBag)()
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
                    theCell.monthUpLabel.textColor = hexStringToUIColor(hex: "#f85959")
                    theCell.monthUpTrend.image = #imageLiteral(resourceName: "monthup_trend_up")
                } else {
                    theCell.monthUpLabel.textColor = hexStringToUIColor(hex: "#79d35f")
                    theCell.monthUpTrend.image = #imageLiteral(resourceName: "monthup_trend_down")
                }
            }
        }
    }
}
