//
// Created by linlin on 2018/7/2.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
class NewHouseInfoCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "NewHouseInfo"
    }

    var priceChangeNotifyRelay: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)

    var openChangeNotifyRelay: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)

    let labelKeyFontSize: CGFloat = 12

    let labelKeyLeftPandding: CGFloat = 15

    let labelKeyTextColor = hexStringToUIColor(hex: "#999999")

    var disposeBag = DisposeBag()

    lazy var pricingPerSqmKeyLabel: UILabel = {
        let result = UILabel()
        result.text = "均价"
        result.font = CommonUIStyle.Font.pingFangRegular(labelKeyFontSize)
        result.textColor = labelKeyTextColor
        return result
    }()

    lazy var pricingPerSqmLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(16)
        result.textColor = hexStringToUIColor(hex: "#f85959")
        result.textAlignment = .left
        return result
    }()

    lazy var openDateKey: UILabel = {
        let result = UILabel()
        result.text = "开盘"
        result.font = CommonUIStyle.Font.pingFangRegular(labelKeyFontSize)
        result.textColor = labelKeyTextColor
        return result
    }()

    lazy var openDataLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(15)
        result.textColor = hexStringToUIColor(hex: "#222222")
        return result
    }()

    lazy var courtAddressKey: UILabel = {
        let result = UILabel()
        result.text = "地址"
        result.font = CommonUIStyle.Font.pingFangRegular(labelKeyFontSize)
        result.textColor = labelKeyTextColor
        return result
    }()

    lazy var courtAddressLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(15)
        result.textColor = hexStringToUIColor(hex: "#222222")
        result.numberOfLines = 0
        return result
    }()

    lazy var moreBtn: UIButton = {
        let result = UIButton()
        let attriStr = NSAttributedString(
                string: "更多楼盘信息",
                attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(14) ,
                             NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#999999")])
        result.setAttributedTitle(attriStr, for: .normal)
        result.backgroundColor = hexStringToUIColor(hex: "#f6f7f8")
        result.layer.cornerRadius = 5
        return result
    }()

    lazy var priceChangedNotify: UIButton = {
        let result = UIButton()
        let attriStr = NSAttributedString(
                string: "变价通知",
                attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16) ,
                             NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#222222")])
        result.setAttributedTitle(attriStr, for: .normal)
        return result
    }()

    lazy var verticalLineView: UIView = {
        let result = UIView()
        result.backgroundColor = hexStringToUIColor(hex: "#e8e8e8")
        return result
    }()

    lazy var openNotify: UIButton = {
        let result = UIButton()
        result.setTitle("开盘通知", for: .normal)
        let attriStr = NSAttributedString(
                string: "开盘通知",
                attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16) ,
                             NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#222222")])
        result.setAttributedTitle(attriStr, for: .normal)
        return result
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(pricingPerSqmKeyLabel)
        pricingPerSqmKeyLabel.snp.makeConstraints { maker in
            maker.top.equalTo(19)
            maker.left.equalTo(labelKeyLeftPandding)
            maker.height.equalTo(17)
            maker.width.lessThanOrEqualTo(24).priority(.high)
        }

        contentView.addSubview(pricingPerSqmLabel)
        pricingPerSqmLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(pricingPerSqmKeyLabel.snp.centerY)
            maker.left.equalTo(pricingPerSqmKeyLabel.snp.right).offset(10)
            maker.right.equalTo(-15)
            maker.height.equalTo(22)
        }

        contentView.addSubview(openDateKey)
        openDateKey.snp.makeConstraints { maker in
            maker.top.equalTo(pricingPerSqmKeyLabel.snp.bottom).offset(18)
            maker.left.equalTo(labelKeyLeftPandding)
            maker.height.equalTo(17)
        }

        contentView.addSubview(openDataLabel)
        openDataLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(openDateKey.snp.centerY)
            maker.left.equalTo(openDateKey.snp.right).offset(10)
            maker.right.equalTo(-15)
            maker.height.equalTo(22)
        }

        contentView.addSubview(courtAddressKey)
        courtAddressKey.snp.makeConstraints { maker in
            maker.top.equalTo(openDateKey.snp.bottom).offset(18)
            maker.left.equalTo(labelKeyLeftPandding)
            maker.height.equalTo(17)
            maker.width.equalTo(24)
        }

        contentView.addSubview(courtAddressLabel)
        courtAddressLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(courtAddressKey.snp.centerY)
            maker.left.equalTo(courtAddressKey.snp.right).offset(10)
            maker.right.equalTo(-15)
            maker.height.equalTo(22)
        }

        contentView.addSubview(moreBtn)
        moreBtn.snp.makeConstraints { maker in
            maker.top.equalTo(courtAddressKey.snp.bottom).offset(16)
            maker.left.equalTo(15)
            maker.right.equalToSuperview().offset(-15)
            maker.height.equalTo(36)
        }

        contentView.addSubview(priceChangedNotify)
        priceChangedNotify.snp.makeConstraints { maker in
            maker.top.equalTo(moreBtn.snp.bottom)
            maker.left.bottom.equalToSuperview()
            maker.height.equalTo(54)
            maker.right.equalTo(contentView.snp.centerX)
        }

        contentView.addSubview(verticalLineView)
        verticalLineView.snp.makeConstraints { maker in
            maker.centerX.equalTo(contentView.snp.centerX)
            maker.width.equalTo(1)
            maker.top.equalTo(moreBtn.snp.bottom).offset(12)
            maker.bottom.equalToSuperview().offset(-12)
        }

        contentView.addSubview(openNotify)
        openNotify.snp.makeConstraints { maker in
            maker.left.equalTo(contentView.snp.centerX)
            maker.right.bottom.equalToSuperview()
            maker.height.equalTo(54)
            maker.top.equalTo(moreBtn.snp.bottom)
        }

        openChangeNotifyRelay
            .skip(1)
            .bind { [unowned self] b in
                self.openNotify
                    .setAttributedTitle(setContentByStatus(
                        text: "开盘通知",
                        status: !b), for: .normal)
            }
            .disposed(by: disposeBag)

        priceChangeNotifyRelay
            .skip(1)
            .bind { [unowned self] b in
                self.priceChangedNotify
                    .setAttributedTitle(setContentByStatus(
                        text: "变价通知",
                        status: !b), for: .normal)
            }
            .disposed(by: disposeBag)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}


func parseNewHouseCoreInfoNode(
    _ newHouseData: NewHouseData,
    floorPanId: String,
    priceChangeHandler: @escaping (BehaviorRelay<Bool>) -> Void,
    openCourtNotify: @escaping (BehaviorRelay<Bool>) -> Void,
    disposeBag: DisposeBag,
    navVC: UINavigationController?) -> () -> TableSectionNode {
    return {
        let cellRender = curry(fillNewHouseCoreInfoCell)(newHouseData)(floorPanId)(priceChangeHandler)(openCourtNotify)(disposeBag)(navVC)
        return TableSectionNode(
            items: [cellRender],
            selectors: nil,
            label: "",
            type: .node(identifier: NewHouseInfoCell.identifier))
    }
}

func fillNewHouseCoreInfoCell(
        _ data: NewHouseData,
        floorPanId: String,
        priceChangeHandler: @escaping (BehaviorRelay<Bool>) -> Void,
        openCourtNotify: @escaping (BehaviorRelay<Bool>) -> Void,
        disposeBag: DisposeBag,
        navVC: UINavigationController?,
        cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NewHouseInfoCell {
        theCell.pricingPerSqmLabel.text = data.coreInfo?.pricingPerSqm
        theCell.openDataLabel.text = data.coreInfo?.constructionOpendate
        theCell.courtAddressLabel.text = data.coreInfo?.courtAddress
        theCell.moreBtn.rx.tap
            .subscribe(onNext: curry(openFloorPanInfoPage)(floorPanId)(data)(disposeBag)(navVC))
            .disposed(by: theCell.disposeBag)

        theCell.priceChangedNotify
                .setAttributedTitle(setContentByStatus(
                text: "变价通知",
                status: data.userStatus?.pricingSubStauts ?? 0 == 0), for: .normal)

        theCell.openNotify
                .setAttributedTitle(setContentByStatus(
                text: "开盘通知",
                status: data.userStatus?.courtOpenSubStatus ?? 0 == 0), for: .normal)

        theCell.openNotify.rx.tap
                .subscribe { event in
                    openCourtNotify(theCell.openChangeNotifyRelay)
                }
                .disposed(by: disposeBag)
        theCell.priceChangedNotify.rx.tap
                .subscribe { event in
                    priceChangeHandler(theCell.priceChangeNotifyRelay)
                }
                .disposed(by: disposeBag)

    }
}

fileprivate func setContentByStatus(text: String, status: Bool) -> NSMutableAttributedString {
    let color = status ? hexStringToUIColor(hex: "#222222") : hexStringToUIColor(hex: "#999999")
    let re = NSMutableAttributedString(
            string: text,
            attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(16),
                         NSAttributedStringKey.foregroundColor: color])
    return re
}

fileprivate func createButtonAttributeText(text: String, textColor: String, font: UIFont) -> NSMutableAttributedString {
    let re = NSMutableAttributedString(
            string: text,
            attributes: [NSAttributedStringKey.font: font,
                         NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: textColor)])
    return re
}
