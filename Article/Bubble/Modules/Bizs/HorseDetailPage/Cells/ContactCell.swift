//
//  ContactCell.swift
//  Bubble
//
//  Created by linlin on 2018/7/2.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
class ContactCell: BaseUITableViewCell {

    open override class var identifier: String {
        return "ContactCell"
    }

    lazy var phoneNumberLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangSemibold(20)
        result.textColor = hexStringToUIColor(hex: "#299cff")
        return result
    }()

    lazy var descLabel: UILabel = {
        let result = UILabel()
        result.font = CommonUIStyle.Font.pingFangRegular(12)
        result.textColor = hexStringToUIColor(hex: "#8a9299")
        result.text = "最新开盘、户型及优惠信息，免费致电售楼处"
        return result
    }()

    lazy var phoneCallBtn: UIButton = {
        let result = UIButton()
        result.setImage(UIImage(named: "phone"), for: .normal)
        return result
    }()

    var disposeBag = DisposeBag()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")

        let maskView = UIView()
        maskView.backgroundColor = UIColor.white
        contentView.addSubview(maskView)
        maskView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalToSuperview()
            maker.bottom.equalToSuperview()
        }

        maskView.addSubview(phoneCallBtn)
        phoneCallBtn.snp.makeConstraints { maker in
            maker.right.equalToSuperview().offset(-20)
            maker.top.equalTo(20)
            maker.bottom.equalToSuperview().offset(-20)
            maker.height.width.equalTo(50)
         }

        maskView.addSubview(phoneNumberLabel)
        phoneNumberLabel.snp.makeConstraints { maker in
            maker.height.equalTo(28)
            maker.left.equalTo(20)
            maker.top.equalTo(20)
            maker.right.equalTo(phoneCallBtn.snp.left)
        }

        maskView.addSubview(descLabel)
        descLabel.snp.makeConstraints { maker in
            maker.height.equalTo(22)
            maker.left.equalTo(20)
            maker.top.equalTo(phoneNumberLabel.snp.bottom).offset(4)
            maker.right.equalTo(phoneCallBtn.snp.left)
         }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

func parseNewHouseContactNode(_ newHouseData: NewHouseData,traceExt: TracerParams = TracerParams.momoid(), courtId: String) -> () -> TableSectionNode? {
    return {
        
        if let phone = newHouseData.contact?.phone, phone.count > 0 {
            
            let params = TracerParams.momoid() <|>
                    toTracerParams("call_page", key: "element_type") <|>
                    traceExt
            let cellRender = curry(fillNewHouseContactCell)(newHouseData)(traceExt)(courtId)
            return TableSectionNode(
                    items: [cellRender],
                    selectors: nil,
                    tracer: [elementShowOnceRecord(params: params)],
                    sectionTracer: nil,
                    label: "",
                    type: .node(identifier: ContactCell.identifier))
        }else {
            
            return nil
        }
    }
}

func fillNewHouseContactCell(_ data: NewHouseData, traceParams: TracerParams, courtId: String, cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? ContactCell {
        
        let traceParamsDic = traceParams.paramsGetter([:])

        theCell.phoneNumberLabel.text = data.contact?.phone
        theCell.descLabel.text = data.contact?.noticeDesc
        theCell.phoneCallBtn.rx.tap
                .subscribe(onNext: {void in
                    if let phone = data.contact?.phone {
                        Utils.telecall(phoneNumber: phone)
                    }
                    
                    var traceParams = traceParams <|> EnvContext.shared.homePageParams
                        .exclude("house_type")
                        .exclude("element_type")
                        .exclude("maintab_search")
                        .exclude("search")
                        .exclude("filter")
                    traceParams = traceParams <|>
                        toTracerParams("new_detail", key: "page_type")

                    recordEvent(key: "click_call", params: traceParams)
                })
                .disposed(by: theCell.disposeBag)
    }
}
