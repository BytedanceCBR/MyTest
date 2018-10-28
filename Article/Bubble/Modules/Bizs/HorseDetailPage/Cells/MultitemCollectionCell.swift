//
//  MultitemCollectionCell.swift
//  News
//
//  Created by leo on 2018/8/23.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

typealias CollectionViewCellRender = (UICollectionViewCell) -> Void

class MultitemCollectionCell: BaseUITableViewCell {

    var collectionViewCellRenders: [CollectionViewCellRender] = []

    var itemSelectors: [(DisposeBag) -> Void] = []

    var itemRecorders: [(TracerParams) -> Void] = []

    var hasShowOnScreen = false {
        didSet {
            traceShowElement()
        }
    }

    open override class var identifier: String {
        return "MultitemCollectionCell"
    }

    var itemReuseIdentifier: String = "floorPan"

    var tracerParams = TracerParams.momoid()

    let disposeBag = DisposeBag()

    lazy var collectionContainer: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        flowLayout.itemSize = CGSize(width: 156, height: 190)
        flowLayout.minimumLineSpacing = 8       
        flowLayout.scrollDirection = .horizontal
        let re = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        re.showsHorizontalScrollIndicator = false
        re.backgroundColor = UIColor.white
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionContainer)
        collectionContainer.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
            maker.height.equalTo(190)
        }
        collectionContainer.register(FloorPanItemCollectionCell.self, forCellWithReuseIdentifier: "floorPan")
        collectionContainer.register(NeighborhoodItemCollectionCell.self, forCellWithReuseIdentifier: "neighborhood")
        collectionContainer.delegate = self
        collectionContainer.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MultitemCollectionCell: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewCellRenders.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemReuseIdentifier, for: indexPath)
        if indexPath.row < collectionViewCellRenders.count {
            collectionViewCellRenders[indexPath.row](cell)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if itemRecorders.count > indexPath.row, hasShowOnScreen {
            itemRecorders[indexPath.row](tracerParams)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < itemSelectors.count {
            itemSelectors[indexPath.row](disposeBag)
        }
    }

    // 系统控件会提前将每种类型的cell提前渲染出一个，目前仅能通过延时激活来避免提前上报埋点
    func traceShowElement() {
        collectionContainer.indexPathsForVisibleItems.forEach { (indexPath) in
            if itemRecorders.count > indexPath.row, hasShowOnScreen {
                itemRecorders[indexPath.row](tracerParams)
            }
        }
    }
}


class MultitemCollectionNeighborhoodCell: BaseUITableViewCell {

    var collectionViewCellRenders: [CollectionViewCellRender] = []

    var itemSelectors: [(DisposeBag) -> Void] = []

    var itemRecorders: [(TracerParams) -> Void] = []

    var hasShowOnScreen = false {
        didSet {
            traceShowElement()
        }
    }

    open override class var identifier: String {
        return "MultitemCollectionNeighborhoodCell"
    }

    var itemReuseIdentifier: String = "floorPan"

    var tracerParams = TracerParams.momoid()

    let disposeBag = DisposeBag()

    lazy var collectionContainer: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        flowLayout.itemSize = CGSize(width: 156, height: 211)
        flowLayout.minimumLineSpacing = 8
        flowLayout.scrollDirection = .horizontal
        let re = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        re.showsHorizontalScrollIndicator = false
        re.backgroundColor = UIColor.white
        return re
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionContainer)
        collectionContainer.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
            maker.height.equalTo(211)
        }
        collectionContainer.register(FloorPanItemCollectionCell.self, forCellWithReuseIdentifier: "floorPan")
        collectionContainer.register(NeighborhoodItemCollectionCell.self, forCellWithReuseIdentifier: "neighborhood")
        collectionContainer.delegate = self
        collectionContainer.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MultitemCollectionNeighborhoodCell: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewCellRenders.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemReuseIdentifier, for: indexPath)
        if indexPath.row < collectionViewCellRenders.count {
            collectionViewCellRenders[indexPath.row](cell)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if itemRecorders.count > indexPath.row, hasShowOnScreen {
            itemRecorders[indexPath.row](tracerParams)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < itemSelectors.count {
            itemSelectors[indexPath.row](disposeBag)
        }
    }

    // 系统控件会提前将每种类型的cell提前渲染出一个，目前仅能通过延时激活来避免提前上报埋点
    func traceShowElement() {
        collectionContainer.indexPathsForVisibleItems.forEach { (indexPath) in
            if itemRecorders.count > indexPath.row, hasShowOnScreen {
                itemRecorders[indexPath.row](tracerParams)
            }
        }
    }
}



fileprivate class FloorPanItemCollectionCell: UICollectionViewCell {

    lazy var floorPanItemView: FloorPanItemView = {
        let re = FloorPanItemView()
        return re
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(floorPanItemView)
        floorPanItemView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(-16)
            maker.top.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate class NeighborhoodItemCollectionCell: UICollectionViewCell {
    lazy var neighborhoodItemView: NeighborhoodItemView = {
        let re = NeighborhoodItemView()
        return re
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(neighborhoodItemView)
        neighborhoodItemView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(-16)
            maker.top.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 二手房同小区房源
func parseSearchInNeighborhoodNodeCollection(
    _ data: SameNeighborhoodHouseResponse.Data?,
    traceExtension: TracerParams = TracerParams.momoid(),
    navVC: UINavigationController?,
    tracerParams: TracerParams) -> () -> TableSectionNode? {
    return {
        if let datas = data?.items.take(5), datas.count > 0 {
            
            let theDatas = datas.map({ (item) -> HouseItemInnerEntity in
                var newItem = item
                newItem.fhSearchId = data?.searchId
                return newItem
            })
            
            let params = TracerParams.momoid() <|>
                toTracerParams("same_neighborhood", key: "element_type") <|>
                traceExtension

            let openParams = params <|>
                toTracerParams("slide", key: "card_type") <|>
                toTracerParams("old_detail", key: "enter_from") <|>
                toTracerParams("same_neighborhood", key: "element_from") 

            let render = oneTimeRender(curry(fillSearchInNeighborhoodCollectionCell)(theDatas)(openParams)(navVC)(openParams))
            return TableSectionNode(
                items: [render],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params <|>
                    toTracerParams("old_detail", key: "page_type") <|>
                    toTracerParams("old", key: "house_type"))],
                label: "小区房源",
                type: .node(identifier: MultitemCollectionCell.identifier))
        } else {
            return nil
        }
    }
}

fileprivate func fillSearchInNeighborhoodCollectionCell(
        items: [HouseItemInnerEntity],
        params: TracerParams,
        navVC: UINavigationController?,
        itemTracerParams: TracerParams,
        cell: BaseUITableViewCell) {
    if let theCell = cell as? MultitemCollectionCell {
        theCell.itemReuseIdentifier = "floorPan"
        theCell.collectionViewCellRenders = items.take(5).map({ (entity) -> CollectionViewCellRender in
            curry(fillSearchInNeighborhoodItemCell)(entity)(itemTracerParams)
        })
        theCell.itemSelectors = items.take(5).enumerated().map { e -> (DisposeBag) -> Void in
            let (offset, item) = e
            return curry(searchInNeighborhoodItemCellSelector)(offset)(item)(itemTracerParams)(navVC)
        }

        theCell.itemRecorders = items.take(5).enumerated().map { e -> (TracerParams) -> Void in
            let (offset, item) = e
            let params = EnvContext.shared.homePageParams <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams(item.logPB ?? "be_null", key: "log_pb") <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    toTracerParams(item.id, key: "group_id") <|>
                    toTracerParams("slide", key: "card_type") <|>
                    toTracerParams("old", key: "house_type") <|>
                    toTracerParams("old_detail", key: "page_type") <|>
                    toTracerParams("same_neighborhood", key: "element_type")
            return onceRecord(key: "house_show", params: params.exclude("enter_from").exclude("element_from"))
        }
    }
}

fileprivate func fillSearchInNeighborhoodItemCell(
    item: HouseItemInnerEntity,
    itemTracerParams: TracerParams,
    cell: UICollectionViewCell) {
    if let theCell = cell as? FloorPanItemCollectionCell {
        if let urlStr = item.houseImage?.first?.url {
            theCell.floorPanItemView.icon.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default_image"))
        } else {
            theCell.floorPanItemView.icon.image = #imageLiteral(resourceName: "default_image")
        }
        let text = NSMutableAttributedString()
        let attributeText = NSMutableAttributedString(string: item.displayTitle ?? "")
        attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
        attributeText.yy_color = hexStringToUIColor(hex: kFHDarkIndigoColor)
        text.append(attributeText)

        theCell.floorPanItemView.descLabel.attributedText = text
        theCell.floorPanItemView.priceLabel.text = item.displayPrice
        theCell.floorPanItemView.spaceLabel.text = item.displayPricePerSqm
    }
}

// 二手房点击同小区房源
fileprivate func searchInNeighborhoodItemCellSelector(
    offset: Int,
    item: HouseItemInnerEntity,
    itemTracerParams: TracerParams,
    navVC: UINavigationController?,
    disposeBag: DisposeBag) {
    let theParams = itemTracerParams <|>
            toTracerParams("slide", key: "card_type") <|>
            itemTracerParams
    if let id = item.id, let houseId = Int64(id) {
        openErshouHouseDetailPage(
                houseId: houseId,
                logPB: item.logPB,
                disposeBag: disposeBag,
                tracerParams: theParams <|>
                        toTracerParams(item.logPB, key: "log_pb") <|>
                        toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                        toTracerParams(offset, key: "rank"),
                navVC: navVC)(TracerParams.momoid())
    }
}

// MARK 二手房/小区 周边小区
func parseRelatedNeighborhoodCollectionNode(
        _ datas: [NeighborhoodInnerItemEntity]?,
        traceExtension: TracerParams = TracerParams.momoid(),
        itemTracerParams: TracerParams,
        navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        if let datas = datas, datas.count > 0 {
            let enterParams = itemTracerParams <|>
                toTracerParams("neighborhood_nearby", key: "element_from") <|>
                toTracerParams("old_detail", key: "enter_from") <|>
                traceExtension
            let render = oneTimeRender(curry(fillRelatedNeighborhoodCell)(datas)(enterParams)(navVC))
            let params = itemTracerParams <|>
//                    toTracerParams("slide", key: "card_type") <|>
                    toTracerParams("neighborhood_nearby", key: "element_type") <|>
                    traceExtension
            return TableSectionNode(
                    items: [render],
                    selectors: nil,
                    tracer: [elementShowOnceRecord(params: params)],
                    label: "周边小区",
                    type: .node(identifier: "MultitemCollectionCell-neighborhood"))
        } else {
            return nil
        }
    }
}

fileprivate func fillRelatedNeighborhoodCell(
        datas: [NeighborhoodInnerItemEntity],
        itemTracerParams: TracerParams,
        navVC: UINavigationController?,
        cell: BaseUITableViewCell) {
    if let theCell = cell as? MultitemCollectionNeighborhoodCell {
        theCell.itemReuseIdentifier = "neighborhood"
        theCell.collectionViewCellRenders = datas.take(5).map { entity -> CollectionViewCellRender in
            curry(fillRelatedNeighborhoodItemCell)(entity)(itemTracerParams)
        }
        
        var traceParamsDict = itemTracerParams.paramsGetter([:])
        let itemTracerParamsResult = TracerParams.momoid() <|>
            toTracerParams(traceParamsDict["page_type"] ?? "be_null", key: "enter_from") //本页类型是下次进入小区详情页的enter_from
        
        theCell.itemSelectors = datas.take(5).enumerated().map { e -> (DisposeBag) -> Void in
            let (offset, item) = e
            return curry(relatedNeighborhoodItemSelector)(offset)(item)(itemTracerParamsResult)(navVC)
        }
        theCell.itemRecorders = datas.take(5).enumerated().map { e -> (TracerParams) -> Void in
            let (offset, item) = e
            let params = EnvContext.shared.homePageParams <|>
                    itemTracerParams <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams(item.logPB ?? "be_null", key: "log_pb") <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                    toTracerParams("slide", key: "card_type") <|>
                    toTracerParams("neighborhood_nearby", key: "element_type")
            return onceRecord(key: "house_show", params: params.exclude("enter_from").exclude("element_from"))
        }
    }
}

fileprivate func fillRelatedNeighborhoodItemCell(
        data: NeighborhoodInnerItemEntity,
        itemTracerParams: TracerParams,
        cell: UICollectionViewCell) {
    if let theCell = cell as? NeighborhoodItemCollectionCell {
        if let urlStr = data.images?.first?.url {
            theCell.neighborhoodItemView.icon.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default_image"))
        } else {
            theCell.neighborhoodItemView.icon.image = #imageLiteral(resourceName: "default_image")
        }
        theCell.neighborhoodItemView.descLabel.text = data.displayTitle
        theCell.neighborhoodItemView.priceLabel.text = data.displayPricePerSqm
        theCell.neighborhoodItemView.spaceLabel.text = data.displayBuiltYear
    }
}

fileprivate func relatedNeighborhoodItemSelector(
    offset: Int,
    data: NeighborhoodInnerItemEntity,
    itemTracerParams: TracerParams,
    navVC: UINavigationController?,
    disposeBag: DisposeBag) {
    
    
    
    if let id = data.id, let houseId = Int64(id) {
        openNeighborhoodDetailPage(
                neighborhoodId: houseId,
                logPB: data.logPB,
                disposeBag: disposeBag,
                tracerParams: itemTracerParams <|>
                        toTracerParams(data.logPB ?? "be_null", key: "log_pb") <|>
                        toTracerParams(data.fhSearchId ?? "be_null", key: "search_id") <|>
//                        toTracerParams("old_detail", key: "enter_from") <|>
                        toTracerParams(offset, key: "rank") <|>
                        toTracerParams("slide", key: "card_type") <|>
                        toTracerParams("neighborhood_nearby", key: "element_from"),
                navVC: navVC)(TracerParams.momoid())
    }
}

// MARK 新房 猜你喜欢
func parseRelateCourtCollectionNode(
        _ data: RelatedCourtResponse?,
        traceExtension: TracerParams = TracerParams.momoid(),
        navVC: UINavigationController?) -> () -> TableSectionNode? {
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
            let render = oneTimeRender(curry(fillSearchInNeighborhoodCell)(theDatas)(params)(navVC))

            return TableSectionNode(
                    items: [render],
                    selectors: nil,
                    tracer: [elementShowOnceRecord(params:params)],
                    label: "猜你喜欢",
                    type: .node(identifier: MultitemCollectionCell.identifier))
        } else {
            return nil
        }
    }
}

fileprivate func fillSearchInNeighborhoodCell(
        items: [CourtItemInnerEntity],
        params: TracerParams,
        navVC: UINavigationController?,
        cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultitemCollectionCell {
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
    }
}

fileprivate func fillSearchInNeighborhoodItemCell(
        item: CourtItemInnerEntity,
        params: TracerParams,
        navVC: UINavigationController?,
        itemTracerParams: TracerParams,
        cell: UICollectionViewCell) {
    if let theCell = cell as? FloorPanItemCollectionCell {
        if let urlStr = item.courtImage?.first?.url {
            theCell.floorPanItemView.icon.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default_image"))
        } else {
            theCell.floorPanItemView.icon.image = #imageLiteral(resourceName: "default_image")
        }
        let text = NSMutableAttributedString()
        let attributeText = NSMutableAttributedString(string: item.displayTitle ?? "")
        attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
        attributeText.yy_color = hexStringToUIColor(hex: kFHDarkIndigoColor)
        text.append(attributeText)

        if let status = item.tags?.first {
            let tag = createTagAttributeText(
                    content: status.content,
                    textColor: hexStringToUIColor(hex: status.textColor),
                    backgroundColor: hexStringToUIColor(hex: status.backgroundColor),
                    insets: UIEdgeInsets(top: -3, left: -5, bottom: 0, right: -5))
            tag.yy_baselineOffset = 2
            text.append(tag)
        }

        theCell.floorPanItemView.descLabel.attributedText = text
        theCell.floorPanItemView.priceLabel.text = item.displayPricePerSqm
    }
}

fileprivate func searchInNeighborhoodItemCellSelector(
        offset: Int,
        item: CourtItemInnerEntity,
        itemTracerParams: TracerParams,
        navVC: UINavigationController?,
        disposeBag: DisposeBag) {
    let theParams = itemTracerParams <|>
            toTracerParams("slide", key: "card_type") <|>
            itemTracerParams <|>
            toTracerParams(item.logPB, key: "log_pb") <|>
            toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
            toTracerParams("related", key: "element_from") <|>
            toTracerParams("new_detail", key: "enter_from")
    if let id = item.id, let houseId = Int64(id) {
        openNewHouseDetailPage(
                houseId: houseId,
                logPB: item.logPB as? [String: Any],
                disposeBag: disposeBag,
                tracerParams: (theParams  <|>
                        toTracerParams(offset, key: "rank")).exclude("element_type"),
                navVC: navVC)(TracerParams.momoid())
    }
}

// 新房楼盘户型
func parseNewHouseFloorPanCollectionNode(
        _ newHouseData: NewHouseData,
        logPb: Any? = "be_null",
        traceExtension: TracerParams = TracerParams.momoid(),
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        bottomBarBinder: @escaping FollowUpBottomBarBinder) -> () -> TableSectionNode? {
    return {
        if newHouseData.floorPan?.list?.count ?? 0 > 0 {
            let cellRender = oneTimeRender(curry(fillGuessLikeFloorPanCell)(newHouseData.floorPan?.list ?? [])(newHouseData.logPB)(newHouseData.contact?.phone?.count ?? 0 < 1)(logPb)(navVC)(followPage)(bottomBarBinder))
            let params = TracerParams.momoid() <|>
                toTracerParams("house_model", key: "element_type") <|>
                toTracerParams("new_detail", key: "enter_from") <|>
                toTracerParams(newHouseData.logPB, key: "log_pb") <|>
                toTracerParams(newHouseData.id, key: "group_id") <|>
                traceExtension
            return TableSectionNode(
                items: [cellRender],
                selectors: nil,
                tracer: [elementShowOnceRecord(params: params)],
                label: "楼盘户型",
                type: .node(identifier: "MultitemCollectionCell-floorPan"))
        } else {
            return nil
        }
    }
}

// MARK: 猜你喜欢
fileprivate func fillGuessLikeFloorPanCell(
        _ data: [FloorPan.Item],
        logPB: Any?,
        isHiddenBottomBtn: Bool? = true,
        logPBVC: Any?,
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        bottomBarBinder: @escaping FollowUpBottomBarBinder,
        cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultitemCollectionCell {
        theCell.collectionViewCellRenders = data.take(5).map { item -> CollectionViewCellRender in
            curry(floorGuessLikePanItemCell)(item)(isHiddenBottomBtn)(navVC)(followPage)(bottomBarBinder)
        }
        theCell.itemSelectors = data.take(5).enumerated().map { e -> (DisposeBag) -> Void in
            let (offset, item) = e
            return curry(floorPanItemSelector)(item)(logPBVC)(isHiddenBottomBtn)(offset)(navVC)(followPage)(bottomBarBinder)
        }
        theCell.itemRecorders = data.take(5).enumerated().map { e -> (TracerParams) -> Void in
            let (offset, item) = e
            let params = EnvContext.shared.homePageParams <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams(item.id, key: "group_id") <|>
                    toTracerParams("slide", key: "card_type") <|>
                    toTracerParams("new_detail", key: "enter_from") <|>
                    toTracerParams("house_model", key: "element_from") <|>
                    toTracerParams("house_model", key: "house_type") <|>
                    toTracerParams("new_detail", key: "page_type") <|>
                    toTracerParams("house_model", key: "element_type") <|>
                    toTracerParams(logPB, key: "log_pb")

            return onceRecord(key: TraceEventName.house_show, params: params.exclude("enter_from").exclude("element_from"))
        }
    }
}

fileprivate func floorGuessLikePanItemCell(
        _ data: FloorPan.Item,
        isHiddenBottomBtn: Bool? = true,
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        bottomBarBinder: @escaping FollowUpBottomBarBinder,
        cell: UICollectionViewCell) {
    if let theCell = cell as? FloorPanItemCollectionCell {
        if let urlStr = data.images?.first?.url {
            theCell.floorPanItemView.icon.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default_image"))
        }
        let text = NSMutableAttributedString()
        let attributeText = NSMutableAttributedString(string: data.title ?? "")
        attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
        attributeText.yy_color = hexStringToUIColor(hex: kFHDarkIndigoColor)
        text.append(attributeText)

        if let status = data.saleStatus {
            let tag = createTagAttributeText(
                    content: status.content,
                    textColor: hexStringToUIColor(hex: status.textColor),
                    backgroundColor: hexStringToUIColor(hex: status.backgroundColor),
                    insets: UIEdgeInsets(top: -3, left: -5, bottom: 0, right: -5))
            tag.yy_baselineOffset = 2
            text.append(tag)
        }

        theCell.floorPanItemView.descLabel.attributedText = text
        theCell.floorPanItemView.priceLabel.text = data.pricingPerSqm
        if let squaremeter = data.squaremeter {

            theCell.floorPanItemView.spaceLabel.text = "建面 \(squaremeter)"
        }
    }
}

fileprivate func floorPanItemSelector(
        _ data: FloorPan.Item,
        logPbVC: Any?,
        isHiddenBottomBtn: Bool? = true,
        offset: Int,
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        bottomBarBinder: @escaping FollowUpBottomBarBinder,
        dispostBag: DisposeBag) {
    if let id = data.id, let floorPanId = Int64(id) {

        followPage.accept("house_model_detail")
        let params = TracerParams.momoid() <|>
            toTracerParams(offset, key: "rank") <|>
            toTracerParams("house_model", key: "element_from") <|>
            toTracerParams("slide", key: "card_type") <|>
            toTracerParams("new_detail", key: "enter_from")

        openFloorPanCategoryDetailPage(
                floorPanId: floorPanId,
                isHiddenBottomBtn: isHiddenBottomBtn ?? true,
                logPbVC: logPbVC,
                disposeBag: dispostBag,
                navVC: navVC,
                followPage: followPage,
                bottomBarBinder: bottomBarBinder,
                params: params)()
    }
}

// MARK 小区详情页 小区房源
func parseSearchInNeighborhoodCollectionNode(
        _ data: SameNeighborhoodHouseResponse.Data?,
        traceExtension: TracerParams = TracerParams.momoid(),
        followStatus: BehaviorRelay<Result<Bool>>,
        navVC: UINavigationController?) -> () -> TableSectionNode? {
    return {
        if let datas = data?.items.take(5), datas.count > 0 {
            let params = TracerParams.momoid() <|>
                    toTracerParams("same_neighborhood", key: "element_type") <|>
                    traceExtension

            let theDatas = datas.map({ (item) -> HouseItemInnerEntity in
                var newItem = item
                newItem.fhSearchId = data?.searchId
                return newItem
            })
            
            let openParams = params <|>
            toTracerParams("slide", key: "card_type") <|>
            toTracerParams("neighborhood_detail", key: "enter_from") <|>
            toTracerParams("same_neighborhood", key: "element_from")

            let render = oneTimeRender(curry(fillSearchInNeighborhoodCell)(theDatas)(followStatus)(openParams)(navVC))
            return TableSectionNode(
                    items: [render],
                    selectors: nil,
                    tracer: [elementShowOnceRecord(params: params)],
                    label: "小区房源",
                    type: .node(identifier: MultitemCollectionCell.identifier))
        } else {
            return nil
        }
    }
}

fileprivate func fillSearchInNeighborhoodCell(
        items: [HouseItemInnerEntity],
        followStatus: BehaviorRelay<Result<Bool>>,
        params: TracerParams,
        navVC: UINavigationController?,
        cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultitemCollectionCell {
        theCell.itemReuseIdentifier = "floorPan"
        theCell.collectionViewCellRenders = items.take(5).map { entity -> CollectionViewCellRender in
            curry(fillSearchInNeighborhoodItemCell)(entity)(params)(navVC)
        }
        theCell.itemSelectors = items.take(5).enumerated().map { e -> (DisposeBag) -> Void  in
            let (offset, item) = e
            return curry(searchInNeighborhoodSelector)(offset)(item)(followStatus)(params)(navVC)
        }
        theCell.itemRecorders = items.take(5).enumerated().map { e -> (TracerParams) -> Void in
            let (offset, item) = e
            let params = EnvContext.shared.homePageParams <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams(item.logPB, key: "log_pb") <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    toTracerParams(item.id, key: "group_id") <|>
                    toTracerParams("slide", key: "card_type") <|>
                    toTracerParams("old", key: "house_type") <|>
                    toTracerParams("neighborhood_detail", key: "page_type") <|>
                    toTracerParams("same_neighborhood", key: "element_type")
            return onceRecord(key: "house_show", params: params.exclude("enter_from").exclude("element_from"))
        }
    }
}

fileprivate func fillSearchInNeighborhoodItemCell(
        item: HouseItemInnerEntity,
        params: TracerParams,
        navVC: UINavigationController?,
        cell: UICollectionViewCell) -> Void {
    if let theCell = cell as? FloorPanItemCollectionCell {
        if let urlStr = item.houseImage?.first?.url {
            theCell.floorPanItemView.icon.bd_setImage(with: URL(string: urlStr), placeholder: #imageLiteral(resourceName: "default_image"))
        } else {
            theCell.floorPanItemView.icon.image = #imageLiteral(resourceName: "default_image")
        }
        let text = NSMutableAttributedString()
        let attributeText = NSMutableAttributedString(string: item.displayTitle ?? "")
        attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
        attributeText.yy_color = hexStringToUIColor(hex: kFHDarkIndigoColor)
        text.append(attributeText)

        theCell.floorPanItemView.descLabel.attributedText = text
        theCell.floorPanItemView.priceLabel.text = item.displayPrice
        theCell.floorPanItemView.spaceLabel.text = item.displayPricePerSqm
    }

}

fileprivate func searchInNeighborhoodSelector(
        offset: Int,
        item: HouseItemInnerEntity,
        followStatus: BehaviorRelay<Result<Bool>>, // 解决同小区房源详情进入小区详情，followup状态不同步
        params: TracerParams,
        navVC: UINavigationController?,
        disposeBag: DisposeBag) {
    let theParams = params <|>
            toTracerParams("slide", key: "card_type") <|>
            params
    if let id = item.id, let houseId = Int64(id) {
        openErshouHouseDetailPage(
                houseId: houseId,
                followStatus: followStatus,
                disposeBag: disposeBag,
                tracerParams: theParams <|>
                        toTracerParams(item.logPB, key: "log_pb") <|>
                        toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                        toTracerParams(offset, key: "rank"),
                navVC: navVC)(TracerParams.momoid())
    }
}

// 房型列表页 相关房型
func parseFloorPanCollectionNode(
        _ items: [FloorPlanInfoData.Recommend],
        isHiddenBottomBar: Bool = true,
        logPb: Any? = "be_null",
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        bottomBarBinder: @escaping FollowUpBottomBarBinder) -> () -> TableSectionNode? {
    return {
        if items.count > 0 {
            let params = TracerParams.momoid() <|>
                    toTracerParams("house_model", key: "element_type")

            let cellRender = oneTimeRender(curry(fillFloorPanCell)(items)(isHiddenBottomBar)(logPb)(navVC)(followPage)(bottomBarBinder))
            return TableSectionNode(
                    items: [cellRender],
                    selectors: nil,
                    tracer: [elementShowOnceRecord(params: params)],
                    label: "楼盘户型",
                    type: .node(identifier: "MultitemCollectionCell-floorPan"))
        } else {
            return nil
        }
    }
}

fileprivate func fillFloorPanCell(
        _ data: [FloorPlanInfoData.Recommend],
        isHiddenBottomBar: Bool = true,
        logPBVC: Any?,
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        bottomBarBinder: @escaping FollowUpBottomBarBinder,
        cell: BaseUITableViewCell) -> Void {
    if let theCell = cell as? MultitemCollectionCell {
        theCell.collectionViewCellRenders = data.take(5).map { item -> CollectionViewCellRender in
            curry(floorPanItemCell)(item)(navVC)(followPage)(bottomBarBinder)
        }
        theCell.itemSelectors = data.take(5).enumerated().map { e -> (DisposeBag) -> Void in
            let (offset, item) = e
            return curry(floorPanItemSelector)(item)(isHiddenBottomBar)(logPBVC)(offset)(navVC)(followPage)(bottomBarBinder)
        }
        theCell.itemRecorders = data.take(5).enumerated().map { e -> (TracerParams) -> Void in
            let (offset, item) = e
            let params = EnvContext.shared.homePageParams <|>
                    toTracerParams(offset, key: "rank") <|>
                    toTracerParams(item.logPB, key: "log_pb") <|>
                    toTracerParams(item.fhSearchId ?? "be_null", key: "search_id") <|>
                    toTracerParams(item.id, key: "group_id") <|>
                    toTracerParams("slide", key: "card_type") <|>
                    toTracerParams("new", key: "house_type") <|>
                    toTracerParams("house_model_detail", key: "page_type") <|>
                    toTracerParams("related", key: "element_type")
            return onceRecord(key: "house_show", params: params.exclude("enter_from").exclude("element_from"))
        }
    }
}

fileprivate func floorPanItemCell(
        _ data: FloorPlanInfoData.Recommend,
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        bottomBarBinder: @escaping FollowUpBottomBarBinder,
        cell: UICollectionViewCell) {
    if let theCell = cell as? FloorPanItemCollectionCell {
        if let urlStr = data.images?.first?.url {
            theCell.floorPanItemView.icon.bd_setImage(with: URL(string: data.images?.first?.url ?? ""), placeholder: UIImage(named: "default_image"))
        } else {
            theCell.floorPanItemView.icon.image = UIImage(named: "default_image")
        }
        let text = NSMutableAttributedString()
        let attributeText = NSMutableAttributedString(string: data.title ?? "")
        attributeText.yy_font = CommonUIStyle.Font.pingFangRegular(16)
        attributeText.yy_color = hexStringToUIColor(hex: kFHDarkIndigoColor)
        text.append(attributeText)

//    if let status = item.saleStatus, let content = status.content {
//        let tag = createTagAttributeText(
//                content: content,
//                textColor: hexStringToUIColor(hex: "#33bf85"),
//                backgroundColor: hexStringToUIColor(hex: "#33bf85", alpha: 0.08),
//                insets: UIEdgeInsets(top: -3, left: -5, bottom: 0, right: -5))
//        tag.yy_baselineOffset = 2
//        text.append(tag)
//    }

        theCell.floorPanItemView.descLabel.attributedText = text
        theCell.floorPanItemView.priceLabel.text = data.pricingPerSqm
        theCell.floorPanItemView.spaceLabel.text = data.squaremeter
    }
}

fileprivate func floorPanItemSelector(
        _ data: FloorPlanInfoData.Recommend,
        isHiddenBottomBtn: Bool = true,
        logPbVC: Any?,
        offset: Int,
        navVC: UINavigationController?,
        followPage: BehaviorRelay<String>,
        bottomBarBinder: @escaping FollowUpBottomBarBinder,
        dispostBag: DisposeBag) {
    if let id = data.id, let floorPanId = Int64(id) {

        followPage.accept("house_model_detail")
        let params = TracerParams.momoid() <|>
                toTracerParams(offset, key: "rank") <|>
                toTracerParams("related", key: "element_from") <|>
                toTracerParams("house_model_detail", key: "enter_from")

        openFloorPanCategoryDetailPage(
                floorPanId: floorPanId,
                isHiddenBottomBtn: isHiddenBottomBtn,
                logPbVC: logPbVC,
                disposeBag: dispostBag,
                navVC: navVC,
                followPage: followPage,
                bottomBarBinder: bottomBarBinder,
                params: params)()
    }
}