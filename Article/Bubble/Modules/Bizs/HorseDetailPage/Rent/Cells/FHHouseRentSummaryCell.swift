//
//  FHHouseRentSummary.swift
//  Article
//
//  Created by leo on 2018/11/20.
//

import UIKit
import SnapKit
import RxSwift
class FHHouseRentSummaryCell: BaseUITableViewCell {

    lazy var titleView: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "081f33")
        return re
    }()

    lazy var dotIcon: UIImageView = {
        let re = UIImageView()
        re.image = UIImage(named: "rectangle-11")
        return re
    }()

    lazy var contentLabel: UILabel = {
        let re = UILabel()
        re.numberOfLines = 6
        re.font = CommonUIStyle.Font.pingFangRegular(14)
        re.textColor = hexStringToUIColor(hex: "737a80")
        return re
    }()


    open override class var identifier: String {
        return "rentSummaryCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.addSubview(dotIcon)
        dotIcon.snp.makeConstraints { (make) in
            make.left.top.equalTo(20);
            make.height.equalTo(8)
            make.width.equalTo(10)
        }

        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.left.equalTo(dotIcon.snp.right).offset(4)
            make.top.equalTo(10)
            make.height.equalTo(26)
            make.right.equalTo(-20)
        }

        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(titleView.snp.bottom).offset(2)
            make.bottom.equalTo(-14)
        }
    }

}


func parseRentSummaryCellNode(model: FHRentDetailResponseModel?,
                              tracer: HouseRentTracer) -> () -> TableSectionNode? {

    let houseOverview: [FHRentDetailResponseDataHouseOverviewModel]? = model?.data?.houseOverview as? [FHRentDetailResponseDataHouseOverviewModel]
    let renders = houseOverview?.map({ (model) -> ((BaseUITableViewCell) -> Void) in
        curry(fillRentSummaryCell)(model)
    })
//    let render = curry(fillRentSummaryCell)
    let params = EnvContext.shared.homePageParams <|>
        toTracerParams(tracer.logPb ?? "be_null", key: "log_pb") <|>
        toTracerParams("house_info", key: "element_type") <|>
        toTracerParams(tracer.pageType, key: "page_type")
    let tracerEvaluationRecord = elementShowOnceRecord(params: params)
    return {
        return TableSectionNode(
            items: renders ?? [],
            selectors: nil,
            tracer:[tracerEvaluationRecord],
            sectionTracer: nil,
            label: "",
            type: .node(identifier: FHHouseRentSummaryCell.identifier))
    }
}

func fillRentSummaryCell(model: FHRentDetailResponseDataHouseOverviewModel, cell: BaseUITableViewCell) {
    if let theCell = cell as? FHHouseRentSummaryCell {
        theCell.titleView.text = model.title
        theCell.contentLabel.text = model.content
    }
}

class FHHouseRentSummaryHeaderCell: BaseUITableViewCell {

    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(18)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()

    lazy var reportBtn: UIButton = {
        let re  = UIButton()
        re.setImage(UIImage(named: "info-outline-report"), for: .normal)
        return re
    }()

    lazy var reportLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangRegular(12)
        re.textColor = hexStringToUIColor(hex: "299cff")
        re.text = "举报"
        return re
    }()

    let disposeBag = DisposeBag()

    var reportAction: (() -> Void)?

    open override class var identifier: String {
        return "rentSummaryHeaderCell"
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        contentView.addSubview(label)
        contentView.addSubview(reportBtn)
        contentView.addSubview(reportLabel)

        label.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(20)
            maker.height.equalTo(26)
            maker.bottom.equalToSuperview()
            maker.right.equalTo(reportBtn.snp.left).offset(10)
        }

        reportBtn.snp.makeConstraints { (make) in
            make.right.equalTo(reportLabel.snp.left).offset(-5)
            make.centerY.equalTo(label)
            make.height.width.equalTo(12)
        }

        reportLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.centerY.equalTo(label)
            make.height.equalTo(17)
        }

        reportBtn.rx.tap
            .bind { [weak self] void in
                self?.reportAction?()
            }.disposed(by: disposeBag)
    }
}


func parseRentSummaryHeaderCellNode(_ label: String,
                                    reportAction: (() -> Void)?) -> () -> TableSectionNode? {
    let render = curry(fillRentSummaryHeaderCell)(label)(reportAction)
    return {
        return TableSectionNode(
            items: [render],
            selectors: nil,
            tracer:nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: FHHouseRentSummaryHeaderCell.identifier))
    }
}

func fillRentSummaryHeaderCell(label: String,
                               reportAction: (() -> Void)?,
                               cell: BaseUITableViewCell) {
    if let theCell = cell as? FHHouseRentSummaryHeaderCell {
        theCell.label.text = label
        theCell.reportAction = reportAction
    }
}
