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
    let params = TracerParams.momoid() <|>
        toTracerParams(tracer.logPb ?? "be_null", key: "log_pb") <|>
        toTracerParams("house_info", key: "element_type") <|>
        toTracerParams(tracer.rank, key: "rank") <|>
        toTracerParams(tracer.originFrom ?? "be_null", key: "origin_from") <|>
        toTracerParams(tracer.originSearchId ?? "be_null", key: "origin_search_id") <|>
        toTracerParams(tracer.pageType, key: "page_type")
    let tracerEvaluationRecord = elementShowOnceRecord(params: params)
    
    return {
        if let outline = model?.data?.houseOverview,
            outline.list?.count ?? 0 > 0 {
//            !(outline.list?.allSatisfy(isEmptyOutline) ?? false) {
            let cellRender = curry(fillRentOutlineListCell)(outline)
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: [tracerEvaluationRecord],
                sectionTracer: nil,
                label: "",
                type: .node(identifier: PropertyListCell.identifier))
        }else {
            return nil
        }
    }
}

// 判断是否是无效的summary
func isEmptyOutline(model: Any) -> Bool {
    if let model = model as? FHRentDetailResponseDataHouseOverviewListDataModel {
        return model.content?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    } else {
        return true
    }
}

func convertRentDetailToErshouOutlineOverreview(model: FHRentDetailResponseDataHouseOverviewModel) -> ErshouOutlineOverreview? {
    if var ershouOutline = ErshouOutlineOverreview(JSON: [:]) {
        ershouOutline.reportUrl = model.reportUrl
        ershouOutline.list = []
        if let list = model.list {
            for item in list {
                if var listData = ErshouOutlineInfo(JSON: [:]), let tempItem = item as? FHRentDetailResponseDataHouseOverviewListDataModel {
                    listData.title = tempItem.title
                    listData.content = tempItem.content
                    ershouOutline.list?.append(listData)
                }
            }
        }
        return ershouOutline
    }
    
    return nil
}


func fillRentOutlineListCell(_ outLineOverreview:FHRentDetailResponseDataHouseOverviewModel,
                             cell: BaseUITableViewCell) -> Void {

    if let theCell = cell as? PropertyListCell {
        theCell.prepareForReuse()
        theCell.removeListBottomView(-20, true)
        func setInfoValue(_ keyText: String, _ valueText: String, _ infoView: HouseOutlineInfoView) {
            infoView.keyLabel.text = keyText
            infoView.valueLabel.text = valueText
            infoView.valueLabel.sizeToFit()
            infoView.showIconAndTitle(showen: !keyText.isEmpty)
        }
        
        let listView = outLineOverreview.list?.enumerated().map({ (e) -> HouseOutlineInfoView in
            let (_,outline) = e
            let re = HouseOutlineInfoView()
            if let outline = outline as? FHRentDetailResponseDataHouseOverviewListDataModel {
                setInfoValue(outline.title ?? "", outline.content ?? "", re)
            }
            return re
        })
        
        theCell.addRowView(rows: listView ?? [], fixedSpacing: 4, averageLayout: false)
        
        if let count = listView?.count, count == 1 {
            listView![0].snp.remakeConstraints { (maker) in
                maker.edges.equalToSuperview()
            }
        }
    }
}

class FHHouseRentSummaryHeaderCell: BaseUITableViewCell {
    
    var reportAction: (() -> Void)?
    
    open override class var identifier: String {
        return "rentSummaryHeaderCell"
    }
    
    var tracerParams:TracerParams?
    let disposeBag = DisposeBag()
    
    lazy var label: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(18)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    lazy var infoButton: UIButton = {
        let re = UIButton()
        re.setImage(UIImage(named: "info-outline-material"), for: .normal)
        
        re.setTitle("举报", for: .normal)
        let attriStr = NSAttributedString(
            string: "举报",
            attributes: [NSAttributedStringKey.font: CommonUIStyle.Font.pingFangRegular(12) ,
                         NSAttributedStringKey.foregroundColor: hexStringToUIColor(hex: "#299cff")])
        re.setAttributedTitle(attriStr, for: .normal)
        re.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5)
        return re
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        
        label.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.right.equalTo(self).offset(-60)
            maker.top.equalTo(20)
            maker.height.equalTo(26)
            maker.bottom.equalToSuperview().offset(0)
        }
        
        contentView.addSubview(infoButton)
        
        infoButton.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(label)
            maker.right.equalTo(self).offset(-25)
        }
        
        infoButton.rx.tap
            .subscribe(onNext: {[weak self] (void) in
                 self?.reportAction?()
                }).disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
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
