//
// Created by linlin on 2018/7/15.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
class FloorPanHouseTypeCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "FloorPanHouseTypeCell"
    }

    lazy var iconView: UIImageView = {
        let re = UIImageView()
        return re
    }()

    lazy var nameLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.textColor = hexStringToUIColor(hex: "#222222")
        re.textAlignment = .left
        return re
    }()

    lazy var roomSpaceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "#999999")
        re.textAlignment = .left
        return re
    }()

    lazy var priceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(14)
        re.textColor = hexStringToUIColor(hex: "#f85959")
        re.textAlignment = .left
        return re
    }()

    lazy var statusBGView: UIView = {
        let re = UIView()
        re.layer.cornerRadius = 2
        return re
    }()

    lazy var statusLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(10)
        return re
    }()

    private var request: BDWebImageRequest?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { maker in
            maker.left.equalTo(15)
            maker.top.equalTo(16)
            maker.bottom.equalTo(-15)
            maker.width.equalTo(100)
            maker.height.equalTo(75)
         }

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { maker in
            maker.left.equalTo(iconView.snp.right).offset(12)
            maker.top.equalTo(19)
            maker.height.equalTo(22)
            maker.right.equalTo(-15)
        }

        contentView.addSubview(roomSpaceLabel)
        roomSpaceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(iconView.snp.right).offset(12)
            maker.top.equalTo(nameLabel.snp.bottom)
            maker.right.equalTo(-15)
            maker.height.equalTo(17)
        }

        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(iconView.snp.right).offset(12)
            maker.height.equalTo(20)
            maker.top.equalTo(roomSpaceLabel.snp.bottom).offset(10)
            maker.bottom.equalTo(-18)
        }

        contentView.addSubview(statusBGView)
        statusBGView.snp.makeConstraints { maker in
            maker.right.equalTo(-18)
            maker.centerY.equalTo(priceLabel.snp.centerY)
            maker.height.equalTo(15)
            maker.width.equalTo(26)
            maker.left.equalTo(priceLabel.snp.right).offset(5)
        }

        statusBGView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.height.equalTo(10)
            maker.width.equalTo(20)
        }
    }

    func setImageIcon(url: String) {
        request = iconView.bd_setImage(with: URL(string: url), placeholder: #imageLiteral(resourceName: "default_image"))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        request = nil
        iconView.image = #imageLiteral(resourceName: "default_image")
    }
}

func parseFloorPanItemsNode(
        data: [FloorPan.Item],
        disposeBag: DisposeBag) -> () -> [TableRowNode] {
    return {
        let renders = data
                .map { curry(fillCell)($0) }
        let selector = data
                .map { curry(openDetailPage)($0.id)(disposeBag) }
        return zip(renders, selector).map {
            TableRowNode(
                    itemRender: $0.0,
                    selector: $0.1,
                    type: .node(identifier: FloorPanHouseTypeCell.identifier))
        }
    }
}

fileprivate func openDetailPage(
        floorPanId: String?,
        disposeBag: DisposeBag) -> () -> Void {
    return {
        if let floorPanId = floorPanId, let id = Int64(floorPanId) {
            openFloorPanCategoryDetailPage(floorPanId: id, disposeBag: disposeBag)()
        }
    }
}

fileprivate func fillCell(
        item: FloorPan.Item,
        cell: BaseUITableViewCell) {
    if let theCell = cell as? FloorPanHouseTypeCell {
        theCell.nameLabel.text = item.title
        theCell.roomSpaceLabel.text = item.squaremeter
        theCell.priceLabel.text = item.pricingPerSqm
        if let url = item.images?.first?.url {
            theCell.setImageIcon(url: url)
        }
    }
}
