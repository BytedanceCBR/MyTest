//
//  FHMultiImagesInfoCell.swift
//  Article
//
//  Created by 张静 on 2018/9/13.
//

import UIKit
import RxSwift
import RxCocoa

class FHMultiImagesInfoCell: BaseUITableViewCell {
    
    override open class var identifier: String {
        return "FHMultiImagesInfoCell"
    }
    
    
    override var isTail: Bool {
        didSet {
            
            if bottomView.superview == nil {
                return
            }
            let height = isTail ? 30 : 10
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
    
    lazy var secondImageView: UIImageView = {
        let re = UIImageView()
        re.contentMode = .scaleAspectFill
        re.layer.cornerRadius = 4
        re.layer.masksToBounds = true
        re.layer.borderWidth = 0.5
        re.layer.borderColor = hexStringToUIColor(hex: kFHSilver2Color).cgColor
        return re
    }()
    
    lazy var thirdImageView: UIImageView = {
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
        label.font = CommonUIStyle.Font.pingFangMedium(16)
        label.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return label
    }()
    
    lazy var extendTitle: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangMedium(12)
        label.textColor = hexStringToUIColor(hex: kFHBattleShipGreyColor)
        return label
    }()
    
    lazy var areaLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(10)
        label.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
        return label
    }()
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
//        label.textAlignment = .right
        label.font = CommonUIStyle.Font.pingFangMedium(16)
        label.textColor = hexStringToUIColor(hex: kFHCoralColor)
        return label
    }()
    
    lazy var roomSpaceLabel: UILabel = {
        let label = UILabel()
        label.font = CommonUIStyle.Font.pingFangRegular(10)
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
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(10)
        }
        
        self.contentView.addSubview(majorImageView)
        self.contentView.addSubview(secondImageView)
        self.contentView.addSubview(thirdImageView)

        majorImageView.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(20)
            maker.top.equalTo(headView.snp.bottom)
//            maker.height.equalTo(majorImageView.snp.width).multipliedBy(3 / 4)
            maker.height.equalTo(90 * CommonUIStyle.Screen.widthScale)

        }
        
        secondImageView.snp.makeConstraints { maker in
            maker.left.equalTo(majorImageView.snp.right).offset(4)
            maker.top.bottom.equalTo(majorImageView)
            maker.width.height.equalTo(majorImageView)

        }
        
        thirdImageView.snp.makeConstraints { maker in
            maker.left.equalTo(secondImageView.snp.right).offset(4)
            maker.right.equalToSuperview().offset(-20)
            maker.top.bottom.equalTo(majorImageView)
            maker.width.height.equalTo(majorImageView)
        }
        
        let infoPanel = UIView()
        contentView.addSubview(infoPanel)
        infoPanel.snp.makeConstraints { maker in
            maker.left.equalToSuperview().offset(20)
            maker.right.equalToSuperview().offset(-20)
            maker.top.equalTo(majorImageView.snp.bottom).offset(15)
            maker.bottom.equalTo(bottomView.snp.top)
        }
        
        infoPanel.addSubview(majorTitle)
        infoPanel.addSubview(priceLabel)

        majorTitle.snp.makeConstraints { maker in
            maker.left.top.equalToSuperview()
            maker.height.equalTo(16)
        }
        
        priceLabel.snp.makeConstraints { maker in
            maker.right.equalToSuperview()
            maker.centerY.equalTo(majorTitle)
            maker.left.equalTo(majorTitle.snp.right).offset(15)
            maker.height.equalTo(16)
            
        }
        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        infoPanel.addSubview(extendTitle)
        extendTitle.snp.makeConstraints { maker in
            maker.left.equalToSuperview()
            maker.top.equalTo(priceLabel.snp.bottom).offset(6)
            maker.height.equalTo(17)
            
        }

        roomSpaceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        roomSpaceLabel.setContentHuggingPriority(.required, for: .horizontal)
        infoPanel.addSubview(roomSpaceLabel)
        roomSpaceLabel.snp.makeConstraints { maker in
            maker.right.equalToSuperview()
            maker.left.equalTo(extendTitle.snp.right).offset(15)
            maker.height.equalTo(12)
            maker.centerY.equalTo(extendTitle)

        }
        
        infoPanel.addSubview(areaLabel)
        areaLabel.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(roomSpaceLabel.snp.bottom).offset(12)
            maker.height.equalTo(10)
            maker.bottom.equalTo(bottomView.snp.top)
            
        }
        
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


func fillMultiHouseItemCell(item: HouseItemInnerEntity,
                            isLastCell: Bool = false,
                            isNewHouse: Bool = false,
                            cell: BaseUITableViewCell) {
    
    if let cell = cell as? FHMultiImagesInfoCell {
        
        cell.majorTitle.text = item.displayTitle
        cell.extendTitle.text = isNewHouse ? item.displayDescription : item.displaySubtitle
        cell.isTail = isLastCell

        if let count = item.tags?.count, count > 0 {
            
            var tagString: String = ""
            var height: CGFloat = 0
            
            item.tags?.enumerated().forEach { (offset, tagItem) in
                
                var content: String = ""
                if offset == 0 {
                    content = tagItem.content
                }else {
                    content = " · \(tagItem.content)"
                }
                tagString.append(content)
                
                let label = UILabel()
                label.numberOfLines = 0
                label.font = CommonUIStyle.Font.pingFangRegular(10)
                label.text = tagString
                label.width = UIScreen.main.bounds.width - 40
                label.sizeToFit()
                let size = label.frame.size
                if size.height > height {
                    if offset != 0 {
                        tagString.removeLast(content.count)
                    }else {
                        
                    }
                    if offset == 0 {
                        height = size.height
                    }
                }
            }
            cell.areaLabel.text = tagString
            
        }
        
        cell.priceLabel.text = isNewHouse ? item.displayPricePerSqm : item.displayPrice
        cell.roomSpaceLabel.text = isNewHouse ? "" : item.displayPricePerSqm
        var imagesForThree = isNewHouse ? item.images : item.houseImage
        cell.majorImageView.bd_setImage(with: URL(string: imagesForThree?.first?.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
        var secondUrl = ""
        if let count = imagesForThree?.count,count > 1 {
            secondUrl = imagesForThree?[1].url ?? ""
        }
        cell.secondImageView.bd_setImage(with: URL(string: secondUrl), placeholder: #imageLiteral(resourceName: "default_image"))
        var thirdUrl = ""
        if let count = imagesForThree?.count,count > 2 {
            thirdUrl = imagesForThree?[2].url ?? ""
        }
        cell.thirdImageView.bd_setImage(with: URL(string: thirdUrl), placeholder: #imageLiteral(resourceName: "default_image"))
        
    }

}


func parseMultiHouseListItemNode(
    _ data: [HouseItemInnerEntity]?,
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        let params = tracerParams <|>
            toTracerParams("old", key: "house_type") <|>
            toTracerParams("left_pic", key: "card_type")
        
        
        let selectors = data?
            .filter { $0.id != nil }
            .enumerated()
            .map { (e) -> (TracerParams) -> Void in
                let (offset, item) = e
                return openErshouHouseDetailPage(
                    houseId: Int64(item.id ?? "")!,
                    logPB: item.logPB,
                    disposeBag: disposeBag,
                    tracerParams: params <|>
                        toTracerParams(offset, key: "rank") <|>
                        toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                        toTracerParams(item.logPB ?? "be_null", key: "log_pb"),
                    navVC: navVC)
        }
        
        
        
        let records = data?
            .filter {
                $0.id != nil
            }
            .enumerated()
            .map { (e) -> ElementRecord in
                let (offset, item) = e
                let theParams = params <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    toTracerParams(item.logPB ?? "be_null", key: "log_pb")
                return onceRecord(key: TraceEventName.house_show, params: theParams.exclude("element_from").exclude("enter_from"))
        }
        
        let count = data?.count ?? 0
        if let renders = data?.enumerated().map({ (index, item) in
            curry(fillMultiHouseItemCell)(item)(index == count - 1)(false)
        }), let selectors = selectors {
            return TableSectionNode(
                items: renders,
                selectors: selectors,
                tracer: records,
                sectionTracer: nil,
                label: "精选好房",
                type: .node(identifier: FHMultiImagesInfoCell.identifier))
        } else {
            return nil
        }
    }
}
