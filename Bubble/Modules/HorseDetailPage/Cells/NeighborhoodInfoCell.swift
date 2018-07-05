//
//  NeighborhoodInfoCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/4.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import BDWebImage
class NeighborhoodInfoCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "NeighborhoodInfoCell"
    }

    lazy var nameKey: UILabel = {
        let re = UILabel()
        return re
    }()

    lazy var nameValue: UILabel = {
        let re = UILabel()
        return re
    }()

    lazy var priceKeyLabel: UILabel = {
        let re = UILabel()
        return re
    }()

    lazy var priceValueLabel: UILabel = {
        let re = UILabel()
        return re
    }()

    lazy var monthUpKeyLabel: UILabel = {
        let re = UILabel()
        return re
    }()

    lazy var monthUpValueLabel: UILabel = {
        let re = UILabel()
        return re
    }()

    lazy var mapImageView: UIImageView = {
        let re = UIImageView()

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
            maker.width.equalTo(56)
         }

        contentView.addSubview(monthUpValueLabel)
        monthUpValueLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(monthUpKeyLabel.snp.centerY)
            maker.left.equalTo(monthUpKeyLabel.snp.right).offset(10)
            maker.height.equalTo(20)
            maker.right.equalToSuperview().offset(-15)
         }

        contentView.addSubview(mapImageView)
        mapImageView.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(150)
            maker.top.equalTo(monthUpValueLabel.snp.bottom).offset(16)
         }
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

}

func parseNeighborhoodInfoNode(_ ershouHouseData: ErshouHouseData) -> () -> TableSectionNode {
    return {
        let render = curry(fillNeighborhoodInfoCell)(ershouHouseData.neighborhoodInfo)
        return TableSectionNode(items: [render], label: "", type: .node(identifier: NeighborhoodInfoCell.identifier))
    }
}

func fillNeighborhoodInfoCell(_ data: NeighborhoodInfo?, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NeighborhoodInfoCell {
        theCell.nameValue.text = data?.name
        theCell.priceValueLabel.text = data?.pricingPerSqm
//        theCell.monthUpValueLabel.text = data?.monthUp
        if let url = data?.gaodeImageUrl {
            theCell.mapImageView.bd_setImage(with: URL(string: url))
        }
    }
}
