//
// Created by linlin on 2018/6/14.
// Copyright (c) 2018 linlin. All rights reserved.
//

import UIKit
import SnapKit
import CoreGraphics
import RxSwift
class NeighborhoodItemCell: BaseUITableViewCell {

    override open class var identifier: String {
        return "NeighborhoodItemCell"
    }

    override var isTail: Bool {
        didSet {
            
            let height = isTail ? 20 : 0
            
            bottomView.snp.updateConstraints { maker in
                maker.height.equalTo(height)
            }
            
        }
    }
    
    lazy var majorImageView: UIImageView = {
        let re = UIImageView()
        re.contentMode = .scaleAspectFill
//        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
        re.layer.borderWidth = 0.5
        re.layer.borderColor = hexStringToUIColor(hex: kFHSilver2Color).cgColor
        return re
    }()
    
    lazy var majorTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(16)
        label.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return label
    }()
    
    lazy var extendTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: "737a80")
        return label
    }()
    
    lazy var areaLabel: YYLabel = {
        let label = YYLabel()
        label.numberOfLines = 0
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        label.lineBreakMode = NSLineBreakMode.byWordWrapping//按照单词分割换行，保证换行时的单词完整。
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangMedium(16)
        label.textColor = hexStringToUIColor(hex: kFHCoralColor)
        return label
    }()
    
    lazy var roomSpaceLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(12)
        label.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        return label
    }()
    
    lazy var headView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        return view
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isTail = false
        
        self.contentView.addSubview(headView)
        headView.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(20)
        }
        
        self.contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { maker in
            maker.top.equalTo(105)
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(0)
        }
        
        self.contentView.addSubview(majorImageView)
        majorImageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(20)
            maker.top.equalTo(headView.snp.bottom)
//            maker.bottom.equalTo(bottomView.snp.top)
            maker.width.equalTo(114)
            maker.height.equalTo(85)
        }
        
        let infoPanel = UIView()
        contentView.addSubview(infoPanel)
        infoPanel.snp.makeConstraints { maker in
            maker.left.equalTo(majorImageView.snp.right).offset(15)
            maker.top.equalTo(majorImageView)
            maker.bottom.equalToSuperview()
            maker.right.equalToSuperview().offset(-15)
        }
        
        infoPanel.addSubview(majorTitle)
        majorTitle.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(16)
            
        }
        
        infoPanel.addSubview(extendTitle)
        extendTitle.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(majorTitle.snp.bottom).offset(8)
            maker.height.equalTo(17)
            
        }
        
        infoPanel.addSubview(areaLabel)
        areaLabel.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(extendTitle.snp.bottom).offset(5)
            maker.height.equalTo(15)
            
        }
        
        infoPanel.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.top.equalTo(areaLabel.snp.bottom).offset(5)
            maker.height.equalTo(24)
            maker.width.lessThanOrEqualTo(130)

        }
        roomSpaceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        roomSpaceLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        infoPanel.addSubview(roomSpaceLabel)
        roomSpaceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(priceLabel.snp.right).offset(7)
            maker.bottom.equalTo(priceLabel.snp.bottom).offset(-2)
            maker.height.equalTo(19)
        }
        
    }

}

//func parseNeighborhoodItemNode(_ items: [NeighborhoodInnerItemEntity]?, navVC: UINavigationController?, disposeBag: DisposeBag) -> () -> TableSectionNode?  {
//    return {
//        let theParams = TracerParams.momoid()
//
//        let selectors = items?
//                .filter { $0.id != nil }
//                .enumerated()
//                .map { (e) -> TableCellSelectedProcess in
//                let (offset, item) = e
//                return openNeighborhoodDetailPage(
//                            neighborhoodId: Int64(item.id!)!,
//                            logPB: item.logPB,
//                            disposeBag: disposeBag,
//                            tracerParams: theParams <|>
//                                toTracerParams(offset, key: "rank") <|>
//                                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
//                                toTracerParams(item.logPB ?? "be_null", key: "log_pb"),
//                            navVC: navVC)
//                }
//        let count = items?.count ?? 0
//        if let renders = items?.enumerated().map( { (index, item) in
//
//            curry(fillNeighborhoodItemCell)(item)(index == count - 1)
//
//        }), let selectors = selectors {
//            return TableSectionNode(
//                    items: renders,
//                    selectors: selectors,
//                    tracer: nil,
//                    label: "新房房源",
//                    type: .node(identifier: NeighborhoodItemCell.identifier))
//        } else {
//            return nil
//        }
//    }
//}

//小区列表数据解析
func parseNeighborhoodRowItemNode(
    _ items: [NeighborhoodInnerItemEntity]?,
    searchIdDetail: String? = "be_null",
    traceParams: TracerParams,
    disposeBag: DisposeBag,
    houseSearchParams: TracerParams?,
    navVC: UINavigationController?) -> [TableRowNode]  {
    let params = traceParams <|>
        toTracerParams("neighborhood", key: "house_type") <|>
        toTracerParams("left_pic", key: "card_type") 
//        beNull(key: "element_type")


    let selectors = items?
        .filter { $0.id != nil }
        .enumerated()
        .map { (offset, item) in
            openNeighborhoodDetailPage(
                neighborhoodId: Int64(item.id!)!,
                logPB: item.logPB,
            disposeBag: disposeBag,
            tracerParams: params <|>
                toTracerParams(item.fhSearchId ?? searchIdDetail, key: "search_id") <|>
                toTracerParams("be_null", key: "element_from") <|>
                toTracerParams(item.logPB ?? "be_null", key: "log_pb"),
            houseSearchParams: houseSearchParams,
            navVC: navVC)
        }


    
    let records = items?
        .filter { $0.id != nil }
        .enumerated()
        .map { (e) -> ElementRecord in
            let (_, item) = e
            let theParams = params <|>
                //                toTracerParams(offset, key: "rank") <|>
                toTracerParams(item.logPB ?? "be_null", key: "log_pb") <|>
                toTracerParams(item.fhSearchId ?? searchIdDetail, key: "search_id") <|>
                //                toTracerParams("neighborhood_list", key: "page_type") <|>
                toTracerParams(item.id ?? "be_null", key: "group_id")
            return onceRecord(key: TraceEventName.house_show, params: theParams.exclude("enter_from").exclude("element_from"))
    }
    let count = items?.count ?? 0
    if let renders = items?.enumerated().map( { (index, item) in
        curry(fillNeighborhoodItemCell)(item)(index == count - 1)
    }),
        let selectors = selectors ,
        let records = records {
        let items = zip(selectors, records)
        
        return zip(renders, items).map { (e) -> TableRowNode in
            let (render, item) = e
            return TableRowNode(
                itemRender: render,
                selector: item.0,
                tracer: item.1,
                type: .node(identifier: NeighborhoodItemCell.identifier),
                editor: nil)
        }
    } else {
        return []
    }
}


func fillNeighborhoodItemCell(_ item: NeighborhoodInnerItemEntity,
                              isLastCell: Bool = false,
                              cell: BaseUITableViewCell) {
    if let theCell = cell as? NeighborhoodItemCell{
        theCell.majorTitle.text = item.displayTitle
        theCell.extendTitle.text = item.displaySubtitle
        theCell.isTail = isLastCell

        theCell.areaLabel.text = item.displayStatusInfo
        theCell.priceLabel.text = item.displayPrice
        theCell.majorImageView.bd_setImage(with: URL(string: item.images?.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))

    }
}



