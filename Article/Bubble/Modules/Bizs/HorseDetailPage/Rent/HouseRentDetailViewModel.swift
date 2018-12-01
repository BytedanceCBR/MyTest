//
//  HouseRentDetailViewModel.swift
//  Article
//
//  Created by leo on 2018/11/19.
//

import Foundation
import RxSwift
import RxCocoa
class HouseRentDetailViewMode: NSObject, UITableViewDataSource, UITableViewDelegate, TableViewTracer {
    var datas: [TableSectionNode] = []

    var disposeBag = DisposeBag()

    var cellFactory: UITableViewCellFactory

    let detailData = BehaviorRelay<FHRentDetailResponseModel?>(value: nil)

    private var relateErshouHouseData = BehaviorRelay<FHHouseRentRelatedResponseModel?>(value: nil)

    private var houseInSameNeighborhood = BehaviorRelay<FHRentSameNeighborhoodResponseModel?>(value: nil)

    var navVC: UINavigationController?

    weak var tableView: UITableView?

    var houseRentTracer: HouseRentTracer

    private var elementShowIndexPathCache: [IndexPath] = []
    private var sectionShowCache: [Int] = []

    private let houseId: Int64

    private var shareInfo: FHRentDetailResponseDataShareInfoModel?
    
    var contactPhone = BehaviorRelay<FHHouseDetailContact?>(value: nil)

    let follwUpStatus: BehaviorRelay<Result<Bool>> = BehaviorRelay(value: .success(false))

    private var groupId: String = ""

    init(houseId: Int64, houseRentTracer: HouseRentTracer) {
        cellFactory = getHouseDetailCellFactory()
        self.houseId = houseId
        self.houseRentTracer = houseRentTracer
        super.init()
        Observable
            .combineLatest(detailData, houseInSameNeighborhood, relateErshouHouseData)
            .filter { $0.0 != nil }
            .subscribe(onNext: { [weak self] (_) in
                if let result = self?.processData()([]) {

                    self?.datas = result
                    self?.tableView?.reloadData()
                    DispatchQueue.main.async {
                        if let tableView = self?.tableView, let datas = self?.datas {
                            self?.traceDisplayCell(tableView: tableView, datas: datas)
                            self?.bindTableScrollingTrace()
                        }
                    }

                }
            }).disposed(by: disposeBag)
    }

    func bindTableScrollingTrace() {
        self.tableView?.rx.didScroll
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .bind { [weak self, weak tableView] void in
                self?.traceDisplayCell(tableView: tableView, datas: self?.datas ?? [])
            }.disposed(by: disposeBag)
    }

    func traceDisplayCell(tableView: UITableView?, datas: [TableSectionNode]) {
        let indexPaths = tableView?.indexPathsForVisibleRows
        let params = EnvContext.shared.homePageParams
        indexPaths?.forEach({ (indexPath) in
            if !elementShowIndexPathCache.contains(indexPath) {
                self.callTracer(
                    tracer: datas[indexPath.section].tracer,
                    atIndexPath: indexPath,
                    traceParams: params)
                elementShowIndexPathCache.append(indexPath)
            }

            if !sectionShowCache.contains(indexPath.section),
                let tracer = datas[indexPath.section].sectionTracer {
                tracer(params)
                sectionShowCache.append(indexPath.section)
            }

            if let theCell = tableView?.cellForRow(at: indexPath) as? MultitemCollectionCell {
                theCell.hasShowOnScreen = true
            } else if let theCell = tableView?.cellForRow(at: indexPath) as? MultitemCollectionNeighborhoodCell {
                theCell.hasShowOnScreen = true
            }

        })


    }

    func registerCell(tableView: UITableView) {
        cellFactory.register(tableView: tableView)
    }

    fileprivate func processData() -> ([TableSectionNode]) -> [TableSectionNode] {
//        self.houseRentTracer?.logPb
        self.houseRentTracer.recordGoDetail()


        let infos:[ErshouHouseBaseInfo] = getRentPropertyList(data: detailData.value?.data)

        let dataParser = DetailDataParser.monoid()
            <- parseRentHouseCycleImageNode(detailData.value?.data?.houseImage as? [FHRentDetailResponseDataHouseImageModel],
                                            tracer:self.houseRentTracer,
                                            disposeBag: disposeBag)
            <- parseRentNameCellNode(model: detailData.value?.data)
            <- parseRentCoreInfoCellNode(model: detailData.value?.data,
                                         tracer: houseRentTracer)
            <- parseRentPropertyListCellNode(infos)
            //房屋配置
            <- parseRentHouseFacility()
            //房屋概况
            <- parseRentHouseSummarySection()
            // 小区测评
            <- parseRentNeighborhoodInfo()
            // 同小区房源
            <- parseRentSearchInNeighborhoodNodeCollection()
            // 周边房源
            <- parseRentErshouHouseListItemNode()
            <- parseRentDisclaimerCellNode(model: detailData.value?.data)
        return dataParser.parser
    }

    fileprivate func getRentPropertyList(data: FHRentDetailResponseDataModel?) -> [ErshouHouseBaseInfo] {
        if let baseInfos = data?.baseInfo as? [FHRentDetailResponseDataBaseInfoModel] {
            return baseInfos.map({ (item) -> ErshouHouseBaseInfo in
                ErshouHouseBaseInfo(attr: item.attr, value: item.value, isSingle: item.isSingle)
            })
        } else {
            return []
        }
    }


    /// 房屋概况组件
    ///
    /// - Returns:
    func parseRentHouseSummarySection() -> () -> [TableSectionNode]? {
        let action: () -> Void = { [weak self] in
            if let url = self?.detailData.value?.data?.reportUrl {
                self?.jumpToReportPage(url: url)
            } else {
                self?.jumpToReportPage(url: "http://i.haoduofangs.com/f100/client/feedback")
            }

        }
        let header = combineParser(left: parseFlineNode(),
                                   right: parseRentSummaryHeaderCellNode("房屋概况", reportAction: action))
        return parseNodeWrapper(preNode: header,
                                wrapedNode: parseRentSummaryCellNode(model: detailData.value,
                                                                     tracer: houseRentTracer))
    }

    /// 房屋配置
    ///
    /// - Returns:
    func parseRentHouseFacility() -> () -> [TableSectionNode]? {
        let header = combineParser(left: parseFlineNode(), right: parseHeaderNode("房屋配置", adjustBottomSpace: 0))
        return parseNodeWrapper(preNode: header,
                                wrapedNode: parseRentFacilityCellNode(model: detailData.value,
                                                                      tracer: houseRentTracer))
    }

    /// 小区测评
    ///
    /// - Returns:
    func parseRentNeighborhoodInfo() -> () -> [TableSectionNode]? {
        let title = detailData.value?.data?.neighborhoodInfo?.name
        let process: TableCellSelectedProcess = { [weak self] (params) in
            if let neighborhoodId = self?.detailData.value?.data?.neighborhoodInfo?.id {
                self?.jumpToNeighborhoodDetailPage(neighborhoodId: neighborhoodId)
            }
        }
        let header = combineParser(left: parseFlineNode(),
                                   right: parseHeaderNode("小区 \(title ?? "")", showLoadMore: true, adjustBottomSpace: 0, process: process))
        return parseNodeWrapper(preNode: header,
                                wrapedNode: parseRentNeighborhoodInfoNode(model: detailData.value,
                                                                          tracer: houseRentTracer))
    }

    /// 同小区房源
    ///
    /// - Returns:
    func parseRentSearchInNeighborhoodNodeCollection() -> () -> [TableSectionNode]? {
        let params = TracerParams.momoid()
        return parseNodeWrapper(preNode: parseHeaderNode("同小区房源"),
                                wrapedNode: parseRentSearchInNeighborhoodNode(houseInSameNeighborhood.value?.data,
                                                                              tracer: houseRentTracer,
                                                                              traceExtension: params,
                                                                              navVC: navVC,
                                                                              tracerParams: params))
    }

    /// 相关租房
    ///
    /// - Returns:
    func parseRentErshouHouseListItemNode() -> () -> [TableSectionNode]? {
//        let relatedErshouItems = relateErshouHouseData.value?.data?.items?.map({ (item) -> HouseItemInnerEntity in
////            var newItem = item
//            return item
//        })
        let relatedErshouItems = relateErshouHouseData.value?.data?.items as? [FHHouseRentRelatedResponseDataItemsModel]
        let params = TracerParams.momoid()
        let header = combineParser(left: parseFlineNode(), right: parseHeaderNode("周边房源", adjustBottomSpace: 0))

        let tail = parseOpenAllNode(true) { [weak self] in
            if let houseId = self?.houseId {
                var theUrl = "fschema://house_list_in_neighborhood?house_id=\(houseId)"
                if let neighborhoodId = self?.detailData.value?.data?.neighborhoodInfo?.id {
                    theUrl = theUrl + "neighborhood_id=\(neighborhoodId)"
                }
                let url = URL(string: theUrl)
                let bottomBarBinder: FollowUpBottomBarBinder = { [weak self] (HouseDetailPageBottomBarView, UIButton, TracerParams) in

                    
                    
                    
                }
                let info = ["bottomBarBinder": bottomBarBinder]
                let userInfo = TTRouteUserInfo(info: info)
                TTRoute.shared()?.openURL(byViewController: url, userInfo: userInfo)
            }
        }

        let result = parseRentReleatedHouseListItemNode(
            relatedErshouItems,
            traceExtension: params,
            disposeBag: disposeBag,
            tracerParams: params,
            navVC: self.navVC)
        return parseNodeWrapper(preNode: header,
                                wrapedNode: result,
                                tailNode: tail)
    }

    /// 跳转到小区详情页
    ///
    /// - Parameter neighborhoodId: 小区id
    fileprivate func jumpToNeighborhoodDetailPage(neighborhoodId: String) {
        let jumpUrl = "fschema://neighborhood_detail?neighborhood_id=\(neighborhoodId)"
        if let url = jumpUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            TTRoute.shared()?.openURL(byPushViewController: URL(string: url))
        }
    }

    /// 跳转到投诉页面
    ///
    /// - Parameter url: reportUrl
    fileprivate func jumpToReportPage(url: String) {
        if let jumpUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let detailModel = self.detailData.value?.data?.toDictionary() as? [String: Any],
            let commonParams = TTNetworkManager.shareInstance()?.commonParamsblock() {
            let openUrl = "fschema://webview_oc"
            let pageData: [String: Any] = ["data": detailModel]
            let commonParamsData: [String: Any] = ["data": commonParams]

            let jsParams = ["requestPageData": pageData,
                            "getNetCommonParams": commonParamsData]
            let info: [String: Any] = ["url": jumpUrl, "jsParams": jsParams]
            let userInfo = TTRouteUserInfo(info: info)
            TTRoute.shared()?.openURL(byViewController: URL(string: openUrl), userInfo: userInfo)

        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datas.count > section {
            return datas[section].items.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch datas[indexPath.section].type {
        case let .node(identifier):
            let cell = cellFactory.dequeueReusableCell(
                identifer: identifier,
                tableView: tableView,
                indexPath: indexPath)
            datas[indexPath.section].items[indexPath.row](cell)
            return cell
        default:
            return CycleImageCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if datas[indexPath.section].selectors?.isEmpty ?? true == false {
            datas[indexPath.section].selectors?[indexPath.row](TracerParams.momoid())
        }
    }

    func requestDetailData() {
        let task = FHRentDetailAPI.requestRentDetail("\(self.houseId)") { [weak self] (model, error) in
            if model != nil {
                self?.detailData.accept(model)
                if let contactDict = self?.detailData.value?.data?.contact?.toDictionary() as? [String: Any]
                {
                    let contactMapple = FHHouseDetailContact(JSON: contactDict)
                    self?.contactPhone.accept(contactMapple)
                }
               
                if let status = model?.data?.userStatus {
                    self?.follwUpStatus.accept(.success(status.houseSubStatus == 1 ? true: false))
                }
                self?.shareInfo = model?.data?.shareInfo
            }
            self?.requestReletedData()
        }
    }
    
    
    func recordFollowEvent(_ traceParam: TracerParams) {
        recordEvent(key: TraceEventName.click_follow, params: traceParam)
    }

    func requestReletedData() {

        let task = HouseRentAPI.requestHouseRentRelated("\(self.houseId)") { [weak self] (model, error) in
            self?.relateErshouHouseData.accept(model)
        }

        let task1 = HouseRentAPI.requestHouseRentSameNeighborhood("\(self.houseId)", withNeighborhoodId: self.detailData.value?.data?.neighborhoodInfo?.id ?? "") { [weak self] (model, error) in
            self?.houseInSameNeighborhood.accept(model)
        }
    }

    func getShareItem() -> ShareItem {
        var shareimage: UIImage? = nil
        if let shareImageUrl = shareInfo?.coverImage {
            shareimage = BDImageCache.shared().imageFromDiskCache(forKey: shareImageUrl)
        }

        if let shareInfo = shareInfo {
            return ShareItem(
                title: shareInfo.title ?? "",
                desc: shareInfo.desc ?? "",
                webPageUrl: shareInfo.shareUrl ?? "",
                thumbImage: shareimage ?? #imageLiteral(resourceName: "default_image"),
                shareType: TTShareType.webPage,
                groupId: groupId)
        } else {
            return ShareItem(
                title: "",
                desc: "",
                webPageUrl: "",
                thumbImage: #imageLiteral(resourceName: "icon-bus"),
                shareType: TTShareType.webPage,
                groupId: "")
        }
    }

}

