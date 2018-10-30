//
// Created by linlin on 2018/7/15.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
class FloorPanHouseTypeCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "FloorPanHouseTypeCell"
    }

    lazy var iconView: UIImageView = {
        let re = UIImageView()
        re.image = #imageLiteral(resourceName: "default_image")
        re.layer.borderColor = hexStringToUIColor(hex: kFHSilver2Color).cgColor
        re.layer.borderWidth = 0.5
        return re
    }()

    lazy var nameLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(16)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        re.textAlignment = .left
        return re
    }()

    lazy var roomSpaceLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
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
    
//    lazy var bottomLine: UIView = {
//        let re = UIView()
//        re.backgroundColor = hexStringToUIColor(hex: "#f3f3f3")
//        return re
//    }()

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
            maker.right.equalTo(-15)
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
        
//        contentView.addSubview(bottomLine)
//        bottomLine.snp.makeConstraints { maker in
//            maker.left.equalTo(iconView)
//            maker.height.equalTo(0.5)
//            maker.right.equalTo(statusBGView)
//
//        }

    }

    func setImageIcon(url: String?) {
        if let url = url {
            request = iconView.bd_setImage(with: URL(string: url), placeholder: #imageLiteral(resourceName: "default_image"))
        } else {
            iconView.image = #imageLiteral(resourceName: "default_image")

        }

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
        logPBVC: Any?,
        isHiddenBottomBar: Bool = true,
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        disposeBag: DisposeBag,
        bottomBarBinder: @escaping FollowUpBottomBarBinder,
        params: TracerParams = TracerParams.momoid()) -> () -> [TableRowNode] {
    return {
        let renders = data
                .map { curry(fillCell)($0) }
        let selector = data
                .enumerated()
                .map { (e) -> (TracerParams) -> Void in
                    let (offset, item) = e
                    let myParams = params <|>
                        toTracerParams(offset, key: "rank")
                    return curry(openDetailPage)(item.id)(logPBVC)(isHiddenBottomBar)(navVC)(followPage)(disposeBag)(bottomBarBinder)(myParams)
                }
        
        let records = data
            .filter { $0.id != nil }
            .enumerated()
            .map { (e) -> ElementRecord in
                let (offset, item) = e
                let theParams = EnvContext.shared.homePageParams <|>
                    params <|>
                    toTracerParams(offset, key: "rank") <|>
                        toTracerParams("left_pic", key: "card_type") <|>
                        toTracerParams("house_model", key: "element_type") <|>
                        toTracerParams("house_model", key: "house_type") <|>
                        toTracerParams("house_model_list", key: "page_type") <|>
                        toTracerParams("house_model_list", key: "enter_from") <|>
                        toTracerParams(item.id ?? "be_null", key: "group_id")
                return onceRecord(key: TraceEventName.house_show, params: theParams.exclude("enter_from").exclude("element_from"))
        }
        let processors = zip(selector, records)
        return zip(renders, processors).map {
            TableRowNode(
                    itemRender: $0.0,
                    selector: $0.1.0,
                    tracer: $0.1.1,
                    type: .node(identifier: FloorPanHouseTypeCell.identifier),
                    editor: nil)
        }
    }
}

fileprivate func openDetailPage(
        floorPanId: String?,
        logPbVC: Any?,
        isHiddenBottomBar: Bool = true,
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        disposeBag: DisposeBag,
        bottomBarBinder: @escaping FollowUpBottomBarBinder,
        params: TracerParams = TracerParams.momoid()) -> (TracerParams) -> Void {
    return { (theParams) in
        if let floorPanId = floorPanId, let id = Int64(floorPanId) {
            let theParams = theParams <|>
                params <|>
                toTracerParams(floorPanId, key: "group_id") <|>
                toTracerParams("house_model", key: "element_from") <|>
                toTracerParams("left_pic", key: "card_type") <|>
                toTracerParams("house_model_list", key: "enter_from") <|>
                beNull(key: "log_pb")


            followPage.accept("house_model_detail")
            openFloorPanCategoryDetailPage(
                floorPanId: id,
                isHiddenBottomBtn: isHiddenBottomBar,
                logPbVC: logPbVC,
                disposeBag: disposeBag,
                navVC: navVC,
                followPage: followPage,
                bottomBarBinder: bottomBarBinder,
                params: theParams)()
        }
    }
}

fileprivate func fillCell(
        item: FloorPan.Item,
        cell: BaseUITableViewCell) {
    if let theCell = cell as? FloorPanHouseTypeCell {
        theCell.nameLabel.text = item.title
        if let squaremeter = item.squaremeter {
            theCell.roomSpaceLabel.text = "建面 \(squaremeter)"
        }else {
            theCell.roomSpaceLabel.text = ""
        }
        
        theCell.priceLabel.text = item.pricingPerSqm
        if let url = item.images?.first?.url {
            theCell.setImageIcon(url: url)
        } else {
            theCell.setImageIcon(url: nil)
        }
        
        guard let saleStatus = item.saleStatus else {
            theCell.statusLabel.text = ""
            theCell.statusBGView.backgroundColor = UIColor.clear
            return
        }
        theCell.statusLabel.text = saleStatus.content
        theCell.statusLabel.textColor = hexStringToUIColor(hex: saleStatus.textColor ?? "#ffffff")
        theCell.statusBGView.backgroundColor = hexStringToUIColor(hex: saleStatus.backgroundColor ?? "#ffffff")
        
    }
}
