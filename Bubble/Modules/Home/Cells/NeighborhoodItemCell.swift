//
// Created by linlin on 2018/6/14.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import SnapKit
import BDWebImage
import YYText
import CoreGraphics
import RxSwift
class NeighborhoodItemCell: BaseUITableViewCell {

    override open class var identifier: String {
        return "NeighborhoodItemCell"
    }

    var imageRequest: BDWebImageRequest?

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
        label.numberOfLines = 0
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "#707070")
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


        self.contentView.addSubview(lineView)
        lineView.snp.makeConstraints { maker in
            maker.height.equalTo(0.5)
            maker.bottom.equalToSuperview()
            maker.left.equalToSuperview().offset(15)
            maker.right.equalToSuperview().offset(-15)
        }

        self.contentView.addSubview(majorImageView)
        majorImageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(15)
            maker.top.equalToSuperview().offset(16)
            maker.bottom.equalTo(-16)
            maker.width.equalTo(114)
            maker.height.equalTo(85)
        }

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

        infoPanel.addSubview(extendTitle)
        extendTitle.snp.makeConstraints { [unowned majorTitle] maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(majorTitle.snp.bottom).offset(5)
            maker.height.equalTo(17)
        }

        infoPanel.addSubview(areaLabel)
        areaLabel.snp.makeConstraints { [unowned extendTitle] maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(extendTitle.snp.bottom).offset(5)
            maker.width.greaterThanOrEqualTo(100)
            maker.height.equalTo(15)
        }
        infoPanel.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { [unowned areaLabel] maker in
            maker.left.equalToSuperview()
            maker.top.equalTo(areaLabel.snp.bottom).offset(5)
            maker.height.equalTo(17)
        }


        infoPanel.addSubview(roomSpaceLabel)
        roomSpaceLabel.snp.makeConstraints { [unowned priceLabel] maker in
            maker.left.equalTo(priceLabel.snp.right).offset(5)
            maker.top.equalTo(priceLabel.snp.top)
            maker.height.equalTo(17)
        }
    }

    func setImageByUrl(_ url: String) {
        imageRequest = majorImageView.bd_setImage(with: URL(string: url), placeholder: #imageLiteral(resourceName: "default_image"))
    }

    override func prepareForReuse() {
        imageRequest?.cancel()
        imageRequest = nil
    }
}

func parseNeighborhoodItemNode(_ items: [NeighborhoodInnerItemEntity]?, disposeBag: DisposeBag) -> () -> TableSectionNode?  {
    return {
        let selectors = items?
                .filter { $0.id != nil }
                .map { Int64($0.id!) }
                .map { openNeighborhoodDetailPage(neighborhoodId: $0!, disposeBag: disposeBag) }
        if let renders = items?.map(curry(fillNeighborhoodItemCell)), let selectors = selectors {
            return TableSectionNode(
                    items: renders,
                    selectors: selectors,
                    label: "新房房源",
                    type: .node(identifier: NeighborhoodItemCell.identifier))
        } else {
            return nil
        }
    }
}

func parseNeighborhoodRowItemNode(_ items: [NeighborhoodInnerItemEntity]?, disposeBag: DisposeBag) -> [TableRowNode]  {
    let selectors = items?
        .filter { $0.id != nil }
        .map { Int64($0.id!) }
        .map { openNeighborhoodDetailPage(neighborhoodId: $0!, disposeBag: disposeBag) }
    if let renders = items?.map(curry(fillNeighborhoodItemCell)), let selectors = selectors {
        return zip(selectors, renders).map({ (e) -> TableRowNode in
            let (selector, render) = e
            return TableRowNode(
                itemRender: render,
                selector: selector,
                type: .node(identifier: NeighborhoodItemCell.identifier))
        })
    } else {
        return []
    }
}


func fillNeighborhoodItemCell(_ item: NeighborhoodInnerItemEntity, cell: BaseUITableViewCell) {
    if let theCell = cell as? NeighborhoodItemCell{
        theCell.majorTitle.text = item.displayTitle
        theCell.extendTitle.text = item.displaySubtitle

        theCell.areaLabel.text = item.displayStatusInfo
        theCell.priceLabel.text = item.displayPrice

        if let img = item.images?.first , let url = img.url {
            theCell.setImageByUrl(url)
        }
    }
}



