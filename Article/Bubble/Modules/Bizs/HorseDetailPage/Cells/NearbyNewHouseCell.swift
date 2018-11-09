//
//  NearbyNewHouseCell.swift
//  Article
//
//  Created by 张元科 on 2018/11/8.
//

import UIKit
import SnapKit
import CoreGraphics
import RxSwift
import RxCocoa

class NearbyNewHouseCell: BaseUITableViewCell {
    
    override open class var identifier: String {
        return "NearbyNewHouseCell"
    }
    
    lazy var majorImageView: UIImageView = {
        let re = UIImageView()
        re.contentMode = .scaleAspectFill
        re.layer.cornerRadius = 4
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
        label.font = CommonUIStyle.Font.pingFangMedium(14)
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
            maker.height.equalTo(0)
        }
        
        self.contentView.addSubview(bottomView)
        bottomView.snp.makeConstraints { maker in
            maker.top.equalTo(90)
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(20)
        }
        
        self.contentView.addSubview(majorImageView)
        majorImageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(20)
            maker.top.equalTo(headView.snp.bottom)
            maker.width.equalTo(120)
            maker.height.equalTo(90)
        }
        
        let infoPanel = UIView()
        contentView.addSubview(infoPanel)
        infoPanel.snp.makeConstraints { maker in
            maker.left.equalTo(majorImageView.snp.right).offset(16)
            maker.top.equalTo(majorImageView)
            maker.bottom.equalTo(bottomView.snp.top)
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
            maker.height.equalTo(12)
        }
        
        infoPanel.addSubview(priceLabel)
        infoPanel.addSubview(roomSpaceLabel)
        
        priceLabel.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.top.equalTo(extendTitle.snp.bottom).offset(10)
            maker.height.equalTo(14)
            maker.width.lessThanOrEqualTo(130)
        }
        
        roomSpaceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        roomSpaceLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        roomSpaceLabel.snp.makeConstraints { maker in
            maker.left.equalTo(priceLabel.snp.right).offset(7)
            maker.bottom.equalTo(priceLabel.snp.bottom).offset(-2)
            maker.height.equalTo(12)
        }
        
        infoPanel.addSubview(areaLabel)
        areaLabel.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(priceLabel.snp.bottom).offset(10)
            maker.height.equalTo(10)
        }
    }
    
    override func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

func parseNearbyNewHouseListNode(
    _ data: RelatedCourtResponse?,
    traceExtension: TracerParams = TracerParams.momoid(),
    navVC: UINavigationController?,
    disposeBag: DisposeBag) -> () -> TableSectionNode? {
    return {
        if let datas = data?.data?.items?.take(5), datas.count > 0 {
            
            let theDatas = datas.map({ (item) -> CourtItemInnerEntity in
                var newItem = item
                newItem.fhSearchId = data?.data?.searchId
                return newItem
            })
            let params = TracerParams.momoid() <|>
                toTracerParams("related", key: "element_type") <|>
            traceExtension
            
            // add by zyk:注意埋点
            let selectors = theDatas
                .filter { $0.id != nil }
                .enumerated()
                .map { (e) -> (TracerParams) -> Void in
                    let (offset, item) = e
                    let id = item.id
                    let houseId = Int64(id ?? "0")
                    return openNewHouseDetailPage(
                        houseId: houseId ?? 0,
                        logPB: item.logPB as? [String: Any],
                        disposeBag: disposeBag,
                        tracerParams: TracerParams.momoid(),
                        navVC:navVC)
            }
            
            let renders = theDatas.enumerated().map({ (index, item) in
                curry(fillNearbyNewHouseCell)(item)(params)(navVC)
            })
            return TableSectionNode(
                items: renders,
                selectors: selectors,
                tracer: [elementShowOnceRecord(params:params)],
                label: "",
                type: .node(identifier: NearbyNewHouseCell.identifier))
        } else {
            return nil
        }
    }
}

fileprivate func fillNearbyNewHouseCell(
    item: CourtItemInnerEntity,
    params: TracerParams,
    navVC: UINavigationController?,
    cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? NearbyNewHouseCell {
        /*
        theCell.tracerParams = params
        theCell.itemReuseIdentifier = "floorPan"
        theCell.collectionViewCellRenders = items.take(5).map({ (entity) -> CollectionViewCellRender in
            curry(fillSearchInNeighborhoodItemCell)(entity)(params)(navVC)(params)
        })
        theCell.itemSelectors = items.take(5).enumerated().map { e -> (DisposeBag) -> Void in
            let (offset, item) = e
            return curry(searchInNeighborhoodItemCellSelector)(offset)(item)(params)(navVC)
        }
        // 详情页猜你喜欢house_show埋点
        theCell.itemRecorders = items.take(5).enumerated().map { e -> (TracerParams) -> Void in
            let (offset, item) = e
            let params = EnvContext.shared.homePageParams <|>
                toTracerParams("new", key: "house_type") <|>
                toTracerParams("slide", key: "card_type") <|>
                toTracerParams("new_detail", key: "page_type") <|>
                toTracerParams("related", key: "element_type") <|>
                toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                toTracerParams(item.logPB ?? "be_null", key: "log_pb") <|>
                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                toTracerParams(offset, key: "rank")
            return onceRecord(key: TraceEventName.house_show, params: params.exclude("enter_from").exclude("element_from"))
        }
         */
        theCell.majorTitle.text = item.displayTitle
        theCell.extendTitle.text = item.displayDescription

        // 一行显示不完，截断后继续添加
        let text = NSMutableAttributedString()
        var height: CGFloat = 0
        let dotAttributedString = createTagAttributeTextNormal(content: " · ",fontSize: 10.0)
        let attrTexts = item.tags?.enumerated().map({ (arg) -> NSAttributedString in
            let (_, item) = arg
            return createTagAttributeTextNormal(content: item.content,fontSize: 10.0)
        })
        attrTexts?.enumerated().forEach { (e) in
            let (offset, tag) = e
            if offset > 0 {
                text.append(dotAttributedString)
            }
            text.append(tag)
            let tagLayout = YYTextLayout(containerSize: CGSize(width: UIScreen.main.bounds.width - 176, height: CGFloat.greatestFiniteMagnitude), text: text)
            let lineHeight = tagLayout?.textBoundingSize.height ?? 0
            // 只显示一行
            if lineHeight > height {
                if offset == 0 {
                    height = lineHeight
                } else {
                    // 删除： · tag
                    if text.length - (tag.length + 3) >= 0 {
                        text.deleteCharacters(in: NSRange(location: text.length - (tag.length + 3), length: tag.length + 3))
                    }
                }
            }
        theCell.areaLabel.attributedText = text
        
        theCell.priceLabel.text = item.displayPricePerSqm
        theCell.majorImageView.bd_setImage(with: URL(string: item.courtImage?.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
        }
    }
}
