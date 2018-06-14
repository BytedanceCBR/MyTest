//
// Created by linlin on 2018/6/14.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import SnapKit

class SingleImageInfoCell: UITableViewCell {

    lazy var majorImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    lazy var majorTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(16)
        label.textColor = hexStringToUIColor(hex: "#222222")
        return label
    }()

    lazy var extendTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "#505050")
        return label
    }()

    lazy var areaLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "#505050")
        return label
    }()

    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.red
        label.font = CommonUIStyle.Font.pingFangMedium(14)
        label.textColor = hexStringToUIColor(hex: "#f85959")
        return label
    }()

    lazy var roomSpaceLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "#999999")
        return label
    }()

    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return view
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(majorImageView)

        self.contentView.addSubview(lineView)
        lineView.snp.makeConstraints { maker in
            maker.height.equalTo(1)
            maker.bottom.equalToSuperview()
            maker.left.equalToSuperview().offset(15)
            maker.right.equalToSuperview().offset(-15)
        }

        majorImageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(15)
            maker.top.equalToSuperview().offset(16)
            maker.bottom.equalToSuperview().offset(-16)
            maker.width.equalTo(114)
            maker.height.equalTo(85)
        }
        majorImageView.image = #imageLiteral(resourceName: "house-1")

        let infoPanel = UIView()
        self.addSubview(infoPanel)
        infoPanel.snp.makeConstraints { maker in
            maker.left.equalTo(majorImageView.snp.right).offset(5)
            maker.top.bottom.equalToSuperview()
            maker.right.equalToSuperview().offset(-15)
        }

        infoPanel.addSubview(majorTitle)
        majorTitle.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.height.equalTo(23)
            maker.top.equalToSuperview().offset(13)
        }
        majorTitle.text = "远洋沁山水 满五唯一 南北通透"

        infoPanel.addSubview(extendTitle)
        extendTitle.snp.makeConstraints { [unowned majorTitle] maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(majorTitle.snp.bottom).offset(5)
            maker.height.equalTo(17)
        }
        extendTitle.text = "2室一厅/120平/南北/公园"

        infoPanel.addSubview(areaLabel)
        areaLabel.snp.makeConstraints { [unowned extendTitle] maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(extendTitle.snp.bottom).offset(5)
            maker.height.equalTo(17)
        }
        areaLabel.text = "海淀-魏公村"

        infoPanel.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { [unowned areaLabel] maker in
            maker.left.equalToSuperview()
            maker.top.equalTo(areaLabel.snp.bottom).offset(5)
            maker.height.equalTo(17)
        }

        priceLabel.text = "650万"

        infoPanel.addSubview(roomSpaceLabel)
        roomSpaceLabel.snp.makeConstraints { [unowned priceLabel] maker in
            maker.left.equalTo(priceLabel.snp.right).offset(5)
            maker.top.equalTo(priceLabel.snp.top)
            maker.height.equalTo(17)
        }
        roomSpaceLabel.text = "56420元/平"
    }
}
