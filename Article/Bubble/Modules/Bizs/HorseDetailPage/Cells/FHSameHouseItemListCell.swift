//
//  FHSameHouseItemListCell.swift
//  Article
//
//  Created by 张静 on 2018/11/29.
//

import UIKit
import RxSwift
import RxCocoa

class FHSameHouseItemListCell: BaseUITableViewCell, RefreshableTableViewCell {

    let disposeBag = DisposeBag()
    var refreshCallback: CellRefreshCallback?
    var navVC: UINavigationController?
    var tracerParams: TracerParams = TracerParams.momoid()
    var ershouHasMore: Bool = false
    var rentHasMore: Bool = false
    
    var ershouFooter: FHOpenAllView?
    var rentFooter: FHOpenAllView?

    var secondItemList: [HouseItemInnerEntity] = []
    var rentItemList: [FHRentSameNeighborhoodResponseDataItemsModel] = []
    
    var ershouCache: [IndexPath] = []
    var rentCache: [IndexPath] = []
    
    var houseType: HouseType = .secondHandHouse {
        
        didSet {
            
            if houseType == .secondHandHouse {
                ershouTableView.isHidden = false
                rentTableView.isHidden = true
                var height = secondItemList.count > 0 ? secondItemList.count * 105 : 0
                if secondItemList.count > 0 {
                    
                    height += ershouHasMore ? 68 : 20
                }

                bgView.snp.updateConstraints { (maker) in
                    maker.height.equalTo(height)
                }
                self.ershouBtn.isSelected = true
                self.rentBtn.isSelected = false
                
                if let superview = self.superview?.superview {
                    
                    let point = self.convert(CGPoint.zero, to: superview)
                    let index = Int(UIScreen.main.bounds.size.height - point.y - 70) / 105
                    if index > 0 {
                        
                        for i in 0 ..< index {
                            
                            let indexPath = IndexPath(row: i, section: 0)
                            addErshouHouseShowLog(indexPath)
                        }
                    }
                }
                
                
            }else if houseType == .rentHouse {
                ershouTableView.isHidden = true
                rentTableView.isHidden = false
                var height = rentItemList.count > 0 ? rentItemList.count * 105 : 0
                if rentItemList.count > 0 {
                    
                    height += rentHasMore ? 68 : 20
                }

                bgView.snp.updateConstraints { (maker) in
                    maker.height.equalTo(height)
                }
                self.ershouBtn.isSelected = false
                self.rentBtn.isSelected = true
                
                if let superview = self.superview?.superview {

                    let point = self.convert(CGPoint.zero, to: superview)
                    let index = Int(UIScreen.main.bounds.size.height - point.y - 70) / 105
                    if index > 0 {
                        
                        for i in 0 ..< index {
                            
                            let indexPath = IndexPath(row: i, section: 0)
                            addRentHouseShowLog(indexPath)
                        }
                    }
                    
                    
                }
            }

        }
    }
    
    
    open override class var identifier: String {
        return "FHSameHouseItemListCell"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        
        ershouTableView.dataSource = self
        ershouTableView.delegate = self
        rentTableView.dataSource = self
        rentTableView.delegate = self
        
        ershouTableView.isScrollEnabled = false
        rentTableView.isScrollEnabled = false

        ershouTableView.register(SingleImageInfoCell.self, forCellReuseIdentifier: "sameHouseItem")
        rentTableView.register(SingleImageInfoCell.self, forCellReuseIdentifier: "sameHouseItem")
    }
    
    func setupUI() {
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { maker in
            maker.left.equalTo(20)
            maker.top.equalTo(20)
            maker.height.equalTo(26)
        }
        
        rentBtn.isHidden = true
        ershouBtn.isHidden = true

        contentView.addSubview(rentBtn)
        rentBtn.snp.makeConstraints { (maker) in
            maker.right.equalTo(-20)
            maker.centerY.equalTo(titleLabel)
            maker.height.equalTo(26)
        }
        
        contentView.addSubview(ershouBtn)
        ershouBtn.snp.makeConstraints { (maker) in
            maker.right.equalTo(ershouBtn.snp.left).offset(-20)
            maker.centerY.equalTo(titleLabel)
            maker.height.equalTo(26)
        }
        
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { (maker) in
            maker.top.equalTo(titleLabel.snp.bottom)
            maker.left.right.equalToSuperview()
            maker.height.equalTo(100)
            maker.bottom.equalToSuperview()
        }
        
        bgView.addSubview(rentTableView)
        rentTableView.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(100)
        }
        
        bgView.addSubview(ershouTableView)
        ershouTableView.snp.makeConstraints { maker in
            maker.left.right.top.equalToSuperview()
            maker.height.equalTo(100)
        }
        
        let ershouFooter = FHOpenAllView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 68))
        ershouTableView.tableFooterView = ershouFooter
        self.ershouFooter = ershouFooter
        
        let rentFooter = FHOpenAllView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 68))
        rentTableView.tableFooterView = rentFooter
        rentFooter.isHidden = true
        self.rentFooter = rentFooter

        ershouBtn.rx.tap
            .bind { [weak self] void in
                self?.ershouBtnDidClick()
            }.disposed(by: disposeBag)
        
        rentBtn.rx.tap
            .bind { [weak self] void in
                self?.rentBtnDidClick()
            }.disposed(by: disposeBag)
        
    }
    
    func addErshouHouseShowLog(_ indexPath: IndexPath) {

        if self.ershouCache.contains(indexPath) || secondItemList.count < 1 || indexPath.row < 0 || indexPath.row >= secondItemList.count {
            return
        }
        let model = secondItemList[indexPath.row]
        var paramDict:[String: Any] = [:]
        paramDict["house_type"] = "old"
        paramDict["card_type"] = "left_pic"
        paramDict["page_type"] = "neighborhood_detail"
        paramDict["element_type"] = "same_neighborhood"
        paramDict["log_pb"] = model.logPB ?? "be_null"
        paramDict["rank"] = indexPath.row
        paramDict["impr_id"] = getImprIdFromLogPb(model.logPB)
        paramDict["group_id"] = getGroupIdFromLogPb(model.logPB)
        paramDict["search_id"] = getSearchIdFromLogPb(model.logPB)
        paramDict["origin_from"] = selectTraceParam(EnvContext.shared.homePageParams, key: "origin_from") ?? "be_null"
        paramDict["origin_search_id"] = selectTraceParam(EnvContext.shared.homePageParams, key: "origin_search_id") ?? "be_null"
        recordEvent(key: "house_show", params: paramDict)
        ershouCache.append(indexPath)

    }
    
    func addRentHouseShowLog(_ indexPath: IndexPath) {
        
        if self.rentCache.contains(indexPath) || rentItemList.count < 1 || indexPath.row < 0 || indexPath.row >= rentItemList.count {
            return
        }
        let model = rentItemList[indexPath.row]
        var paramDict:[String: Any] = [:]
        paramDict["house_type"] = "rent"
        paramDict["card_type"] = "left_pic"
        paramDict["page_type"] = "neighborhood_detail"
        paramDict["element_type"] = "same_neighborhood"
        paramDict["log_pb"] = model.logPb ?? "be_null"
        paramDict["impr_id"] = getImprIdFromLogPb(model.logPb)
        paramDict["group_id"] = getGroupIdFromLogPb(model.logPb)
        paramDict["search_id"] = getSearchIdFromLogPb(model.logPb)
        paramDict["rank"] = indexPath.row
        paramDict["origin_from"] = selectTraceParam(EnvContext.shared.homePageParams, key: "origin_from") ?? "be_null"
        paramDict["origin_search_id"] = selectTraceParam(EnvContext.shared.homePageParams, key: "origin_search_id") ?? "be_null"
        recordEvent(key: "house_show", params: paramDict)
        rentCache.append(indexPath)

    }
    
    func ershouBtnDidClick() {
        
        if self.houseType == .secondHandHouse {
            return
        }
        if self.secondItemList.count > 0 {

            self.houseType = .secondHandHouse
        }
        
        self.refreshCell()

    }
    
    func rentBtnDidClick() {
        
        if self.houseType == .rentHouse {
            return
        }
        if self.rentItemList.count > 0 {
            
            self.houseType = .rentHouse
            
        }
        self.refreshCell()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgView: UIView = {
        let re = UIView()
        return re
    }()
    
    lazy var titleLabel: UILabel = {
        let re = UILabel()
        re.font = CommonUIStyle.Font.pingFangMedium(18)
        re.textColor = hexStringToUIColor(hex: kFHDarkIndigoColor)
        return re
    }()
    
    lazy var ershouBtn: UIButton = {
        let re = UIButton()
        re.setTitle("二手房", for: .normal)
        re.setTitle("二手房", for: .highlighted)
        re.titleLabel?.font = CommonUIStyle.Font.pingFangMedium(14)
        re.setTitleColor(hexStringToUIColor(hex: kFHCoolGrey3Color), for: .normal)
        re.setTitleColor(hexStringToUIColor(hex: kFHClearBlueColor), for: .selected)
        return re
    }()
    
    lazy var rentBtn: UIButton = {
        let re = UIButton()
        re.setTitle("租房", for: .normal)
        re.setTitle("租房", for: .highlighted)
        re.titleLabel?.font = CommonUIStyle.Font.pingFangRegular(14)
        re.setTitleColor(hexStringToUIColor(hex: kFHCoolGrey3Color), for: .normal)
        re.setTitleColor(hexStringToUIColor(hex: kFHClearBlueColor), for: .selected)
        return re
    }()
    
    lazy var ershouTableView: UITableView = {
        let re = UITableView(frame: CGRect.zero, style: .plain)
        re.estimatedRowHeight = 0
        re.estimatedSectionHeaderHeight = 0
        re.estimatedSectionFooterHeight = 0
        re.separatorStyle = .none
        if #available(iOS 11.0, *) {
            re.contentInsetAdjustmentBehavior = .never
        }
        return re
    }()
    
    lazy var rentTableView: UITableView = {
        let re = UITableView(frame: CGRect.zero, style: .plain)
        re.estimatedRowHeight = 0
        re.estimatedSectionHeaderHeight = 0
        re.estimatedSectionFooterHeight = 0
        re.separatorStyle = .none
        if #available(iOS 11.0, *) {
            re.contentInsetAdjustmentBehavior = .never
        }
        return re
    }()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension FHSameHouseItemListCell: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView == self.ershouTableView {
            return self.secondItemList.count > 0 ? 1 : 0
        }else if tableView == self.rentTableView {
            return self.rentItemList.count > 0 ? 1 : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.ershouTableView {
            return self.secondItemList.count
        }else if tableView == self.rentTableView {
            return self.rentItemList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sameHouseItem", for: indexPath)
        if let theCell = cell as? SingleImageInfoCell {
            
            if tableView == self.ershouTableView {

                let model = secondItemList[indexPath.row]
                fillSameSecondHouseItemCell(model, isFirstCell: indexPath.row == 0, isLastCell: indexPath.row == secondItemList.count - 1, cell: theCell)
                return theCell
            }else if tableView == self.rentTableView {

                let model = rentItemList[indexPath.row]
                fillSameRentHouseItemCell(model, isFirstCell: indexPath.row == 0, isLastCell: indexPath.row == rentItemList.count - 1, cell: theCell)
                return theCell
            }
            

        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.ershouTableView {

            let model = secondItemList[indexPath.row]
            let params = TracerParams.momoid() <|>
                toTracerParams("left_pic", key: "card_type") <|>
                toTracerParams("neighborhood_detail", key: "enter_from") <|>
                toTracerParams("same_neighborhood", key: "element_from") <|>
                toTracerParams(model.logPB ?? "be_null", key: "log_pb") <|>
                toTracerParams(indexPath.row, key: "rank") <|>
            EnvContext.shared.homePageParams
            jump2ErshouHouseDetailPage(offset: indexPath.row, item: model, params: params, navVC: self.navVC, disposeBag: disposeBag)

        }else if tableView == self.rentTableView {

            let model = rentItemList[indexPath.row]
            var tracer: [String: Any] = [:]
            tracer["card_type"] = "left_pic"
            tracer["enter_from"] = "neighborhood_detail"
            tracer["element_from"] = "same_neighborhood"
            tracer["log_pb"] = model.logPb ?? "be_null"
            tracer["rank"] = indexPath.row
            tracer["origin_from"] = selectTraceParam(EnvContext.shared.homePageParams, key: "origin_from") ?? "be_null"
            tracer["origin_search_id"] = selectTraceParam(EnvContext.shared.homePageParams, key: "origin_search_id") ?? "be_null"

            let info = ["tracer": tracer]
            let userInfo = TTRouteUserInfo(info: info)
            TTRoute.shared()?.openURL(byPushViewController: URL(string: "fschema://rent_detail?house_id=\(model.id ?? "")"), userInfo: userInfo)
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 105
    }
    
}

fileprivate func jump2ErshouHouseDetailPage(
    offset: Int,
    item: HouseItemInnerEntity,
    followStatus: BehaviorRelay<Result<Bool>>? = nil,
    params: TracerParams,
    navVC: UINavigationController?,
    disposeBag: DisposeBag) {
    let theParams = params <|>
        toTracerParams("slide", key: "card_type") <|>
    params
    if let id = item.id, let houseId = Int64(id) {
        openErshouHouseDetailPage(
            houseId: houseId,
            logPB: item.logPB,
            followStatus: followStatus,
            disposeBag: disposeBag,
            tracerParams: theParams <|>
                toTracerParams(item.logPB ?? "be_null", key: "log_pb") <|>
                toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                toTracerParams(offset, key: "rank"),
            navVC: navVC)(TracerParams.momoid())
    }
}


func parseSameHouseItemListNode(
    _ title: String,
    navVC: UINavigationController?,
    ershouData: [HouseItemInnerEntity]?,
    ershouDataTotal: Int,
    ershouHasMore: Bool = false,
    rentData: [FHRentSameNeighborhoodResponseDataItemsModel]?,
    rentDataTotal: String,
    rentHasMore: Bool = false,
    disposeBag: DisposeBag,
    tracerParams: TracerParams,
    ershouCallBack: @escaping () -> Void,
    rentCallBack: @escaping () -> Void,
    filter: (() -> Bool)? = nil) -> () -> TableSectionNode? {
    return {
        
        if ershouData?.count ?? 0 < 1 && rentData?.count ?? 0 < 1 {
            return nil
        }
        
        let cellRender = curry(fillSameHouseItemListCell)(title)(navVC)(ershouData ?? [])(ershouDataTotal)(ershouHasMore)(ershouCallBack)(rentData ?? [])(rentDataTotal)(rentHasMore)(rentCallBack)(disposeBag)(tracerParams)
        return TableSectionNode(
            items: [cellRender],
            selectors: [],
            tracer: nil,
            sectionTracer: nil,
            label: "",
            type: .node(identifier: FHSameHouseItemListCell.identifier))
    }
}

func fillSameHouseItemListCell(_ title: String,
                               navVC: UINavigationController?,
                               ershouData: [HouseItemInnerEntity],
                               ershouDataTotal: Int,
                               ershouHasMore: Bool = false,
                               ershouCallBack: @escaping () -> Void,
                               rentData: [FHRentSameNeighborhoodResponseDataItemsModel],
                               rentDataTotal: String,
                               rentHasMore: Bool = false,
                               rentCallBack: @escaping () -> Void,
                               disposeBag: DisposeBag,
                               tracerParams: TracerParams,
                               cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? FHSameHouseItemListCell {
        theCell.titleLabel.text = title
        theCell.navVC = navVC
        theCell.tracerParams = tracerParams
        theCell.ershouFooter?.openAllBtn.rx.tap
            .bind { void in
                ershouCallBack()
            }.disposed(by: disposeBag)
        //设置celltitle
        theCell.ershouBtn.rx.tap
            .bind { [weak theCell]  void in
                theCell?.titleLabel.text = "小区房源(\(ershouDataTotal))"
            }.disposed(by: disposeBag)

        theCell.rentFooter?.openAllBtn.rx.tap
            .bind { void in
                rentCallBack()
            }.disposed(by: disposeBag)
        //设置celltitle
        theCell.rentBtn.rx.tap
            .bind { [weak theCell] void in
                theCell?.titleLabel.text = "小区房源(\(rentDataTotal))"
            }.disposed(by: disposeBag)
        
        theCell.secondItemList = ershouData
        theCell.ershouHasMore = ershouHasMore
        var height = ershouData.count > 0 ? ershouData.count * 105 : 0
        height += ershouHasMore ? 68 : 0
        theCell.ershouTableView.reloadData()
        theCell.ershouTableView.snp.updateConstraints { (maker) in
            maker.height.equalTo(height)
        }
        theCell.ershouTableView.tableFooterView = theCell.ershouFooter
        theCell.ershouTableView.tableFooterView?.isHidden = !ershouHasMore

        theCell.rentItemList = rentData
        theCell.rentHasMore = rentHasMore
        var rentHeight = rentData.count > 0 ? rentData.count * 105 : 0
        rentHeight += rentHasMore ? 68 : 0
        theCell.rentTableView.snp.updateConstraints { (maker) in
            maker.height.equalTo(rentHeight)
        }
        theCell.rentTableView.reloadData()
        theCell.rentTableView.tableFooterView = theCell.rentFooter
        theCell.rentTableView.tableFooterView?.isHidden = !rentHasMore

        if ershouData.count > 0 { //有二手房源
            theCell.houseType = .secondHandHouse

            if rentData.count > 0 { //同时也有租房房源
                
                theCell.ershouBtn.isHidden = false
                theCell.rentBtn.isHidden = false
                theCell.rentBtn.snp.remakeConstraints { (maker) in
                    maker.right.equalTo(-20)
                    maker.centerY.equalTo(theCell.titleLabel)
                    maker.height.equalTo(26)
                }
                
                theCell.ershouBtn.snp.remakeConstraints { (maker) in
                    maker.right.equalTo(theCell.rentBtn.snp.left).offset(-20)
                    maker.centerY.equalTo(theCell.titleLabel)
                    maker.height.equalTo(26)
                }
                
            } else { //仅有二手房
                theCell.ershouBtn.isHidden = false
                theCell.rentBtn.isHidden = true
                theCell.ershouBtn.snp.remakeConstraints { (maker) in
                    maker.right.equalTo(-20)
                    maker.centerY.equalTo(theCell.titleLabel)
                    maker.height.equalTo(26)
                }

            }
        } else if rentData.count > 0 { //仅有租房

            theCell.houseType = .rentHouse
            theCell.ershouBtn.isHidden = true
            theCell.rentBtn.isHidden = false
            theCell.rentBtn.snp.remakeConstraints { (maker) in
                maker.right.equalTo(-20)
                maker.centerY.equalTo(theCell.titleLabel)
                maker.height.equalTo(26)
            }
        }

    }
}

fileprivate func fillSameSecondHouseItemCell(_ data: HouseItemInnerEntity,
                                           isFirstCell: Bool = false,
                                           isLastCell: Bool = false,
                                           cell: BaseUITableViewCell) {
    if let theCell = cell as? SingleImageInfoCell {
        theCell.majorTitle.text = data.displayTitle
        theCell.extendTitle.text = data.displaySubtitle
        theCell.isTail = isLastCell
        
        let text = NSMutableAttributedString()
        let attrTexts = data.tags?.enumerated().map({ (arg) -> NSAttributedString in
            let (offset, item) = arg
            let theItem = item
            return createTagAttrString(
                theItem.content,
                isFirst: offset == 0,
                textColor: hexStringToUIColor(hex: theItem.textColor ?? ""),
                backgroundColor: hexStringToUIColor(hex: theItem.backgroundColor ?? ""))
        })
        
        var height: CGFloat = 0
        attrTexts?.enumerated().forEach({ (e) in
            let (offset, tag) = e
            
            text.append(tag)
            
            let tagLayout = YYTextLayout(containerSize: CGSize(width: UIScreen.main.bounds.width - 170, height: CGFloat.greatestFiniteMagnitude), text: text)
            let lineHeight = tagLayout?.textBoundingSize.height ?? 0
            if lineHeight > height {
                if offset != 0 {
                    text.deleteCharacters(in: NSRange(location: text.length - tag.length, length: tag.length))
                }
                if offset == 0 {
                    height = lineHeight
                }
            }
        })
        
        theCell.areaLabel.attributedText = text
        theCell.areaLabel.snp.updateConstraints { (maker) in
            
            maker.left.equalToSuperview().offset(-3)
        }
        
        theCell.priceLabel.text = data.displayPrice
        theCell.roomSpaceLabel.text = data.displayPricePerSqm
        if let imageItem = data.houseImage?.first {
            theCell.majorImageView.bd_setImage(with: URL(string: imageItem.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
        }
        if let houseImageTag = data.houseImageTag,
            let backgroundColor = houseImageTag.backgroundColor,
            let textColor = houseImageTag.textColor {
            theCell.imageTopLeftLabel.textColor = hexStringToUIColor(hex: textColor)
            theCell.imageTopLeftLabel.text = houseImageTag.text
            theCell.imageTopLeftLabelBgView.backgroundColor = hexStringToUIColor(hex: backgroundColor)
            theCell.imageTopLeftLabelBgView.isHidden = false
        } else {
            theCell.imageTopLeftLabelBgView.isHidden = true
        }
        
        theCell.updateLayoutCompoents(isShowTags: text.string.count > 0)
    }
}


fileprivate func fillSameRentHouseItemCell(_ data: FHRentSameNeighborhoodResponseDataItemsModel,
                                           isFirstCell: Bool = false,
                                           isLastCell: Bool = false,
                                           cell: BaseUITableViewCell) {
    if let theCell = cell as? SingleImageInfoCell {
        theCell.majorTitle.text = data.title
        theCell.extendTitle.text = data.subtitle
        theCell.isTail = isLastCell
        
        let text = NSMutableAttributedString()
        let attrTexts = data.tags?.enumerated().map({ (arg) -> NSAttributedString in
            let (offset, item) = arg
            let theItem = item as? FHRentSameNeighborhoodResponseDataItemsTagsModel
            return createTagAttrString(
                theItem?.content ?? "",
                isFirst: offset == 0,
                textColor: hexStringToUIColor(hex: theItem?.textColor ?? ""),
                backgroundColor: hexStringToUIColor(hex: theItem?.backgroundColor ?? ""))
        })
        
        var height: CGFloat = 0
        attrTexts?.enumerated().forEach({ (e) in
            let (offset, tag) = e
            
            text.append(tag)
            
            let tagLayout = YYTextLayout(containerSize: CGSize(width: UIScreen.main.bounds.width - 170, height: CGFloat.greatestFiniteMagnitude), text: text)
            let lineHeight = tagLayout?.textBoundingSize.height ?? 0
            if lineHeight > height {
                if offset != 0 {
                    text.deleteCharacters(in: NSRange(location: text.length - tag.length, length: tag.length))
                }
                if offset == 0 {
                    height = lineHeight
                }
            }
        })
        
        theCell.areaLabel.attributedText = text
        theCell.areaLabel.snp.updateConstraints { (maker) in
            
            maker.left.equalToSuperview().offset(-3)
        }
        
        theCell.priceLabel.text = data.pricing
//        theCell.roomSpaceLabel.text = data.pric
        if let imageItem = data.houseImage?.first as? FHRentSameNeighborhoodResponseDataItemsHouseImageModel {
            theCell.majorImageView.bd_setImage(with: URL(string: imageItem.url ?? ""), placeholder: #imageLiteral(resourceName: "default_image"))
        }
        if let houseImageTag = data.houseImageTag,
            let backgroundColor = houseImageTag.backgroundColor,
            let textColor = houseImageTag.textColor {
            theCell.imageTopLeftLabel.textColor = hexStringToUIColor(hex: textColor)
            theCell.imageTopLeftLabel.text = houseImageTag.text
            theCell.imageTopLeftLabelBgView.backgroundColor = hexStringToUIColor(hex: backgroundColor)
            theCell.imageTopLeftLabelBgView.isHidden = false
        } else {
            theCell.imageTopLeftLabelBgView.isHidden = true
        }
        theCell.updateLayoutCompoents(isShowTags: text.string.count > 0)
    }
}
