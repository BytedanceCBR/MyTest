//
//  MessageListVC.swift
//  Bubble
//
//  Created by mawenlong on 2018/7/6.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class MessageListVC: BaseViewController, UITableViewDelegate, PageableVC, TTRouteInitializeProtocol, UIViewControllerErrorHandler {
    
    var hasMore = false
    
    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar(hiddenMaskBtn: false)
        re.rightBtn.isHidden = true
        re.removeGradientColor()
        re.title.text = "消息"
        return re
    }()

    lazy var tableView: UITableView = {
        let re = UITableView(frame: CGRect.zero, style: .grouped)
        re.separatorStyle = .none
        if #available(iOS 11.0, *) {
            re.contentInsetAdjustmentBehavior = .never
        }
        re.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        return re
    }()

    lazy var emptyMaskView: EmptyMaskView = {
        let re = EmptyMaskView()
        return re
    }()
    
    let disposeBag = DisposeBag()
    
    private var tableListViewModel: ChatDetailListTableViewModel?

    var messageId: String?
    
    private var minCursor: String?
    private var originSearchId: String?

    private let limit = "10"
    
    var pageableLoader: (() -> Void)?
    
    var dataLoader: ((Bool, Int) -> Void)?

    var traceParams = TracerParams.momoid()

//    var stayTimeParams: TracerParams?
    
    private var errorVM : NHErrorViewModel?

    private var hasRecordEnterCategory = false

    public required init(routeParamObj paramObj: TTRouteParamObj?) {
        super.init(nibName: nil, bundle: nil)
        if let paramObj = paramObj {
            
            let messageId = paramObj.queryParams["list_id"] as? String

            self.messageId = messageId
            self.navBar.title.text = paramObj.queryParams["title"] as? String

            var category_name = "be_null"
            var origin_from = "be_null"
            
            switch messageId {
                
            case "300":
                // "新房"
                category_name = "new_message_list"
                origin_from = "messagetab_new"
                
            case "301":
                // "二手房"
                category_name = "old_message_list"
                origin_from = "messagetab_old"
                
            case "302":
                // "租房"
                category_name = "rent_message_list"
                origin_from = "messagetab_rent"
            case "303":
                // "小区"
                category_name = "neighborhood_message_list"
                origin_from = "messagetab_neighborhood"
            case "307":
                // "房源推荐-二手房"
                category_name = "recommend_message_list"
                origin_from = "messagetab_recommend_old"
            case "309":
                // "房源推荐-租房"
                category_name = "recommend_message_list"
                origin_from = "messagetab_recommend_rent"
                
            default:
                break
                
            }
            
            let params = TracerParams.momoid() <|>
                toTracerParams("click", key: "enter_type") <|>
                toTracerParams(category_name, key: "category_name")
            
            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                toTracerParams(origin_from, key: "origin_from")
            self.traceParams = params <|>
                toTracerParams("be_null", key: "log_pb") <|>
                toTracerParams("messagetab", key: "enter_from") <|>
                toTracerParams("be_null", key: "search_id") <|>
                toTracerParams(category_name, key: "category_name")

        }

        self.navBar.backBtn.rx.tap
            .bind { [weak self] void in
                self?.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        self.ttTrackStayEnable = true
        self.view.backgroundColor = UIColor.white
        self.tableListViewModel = ChatDetailListTableViewModel(navVC: self.navigationController,tableView:tableView)
        self.tableListViewModel?.traceParams = traceParams

        view.addSubview(navBar)
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.left.right.top.equalToSuperview()
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            } else {
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(65)
            }
        }
        
        // Do any additional setup after loading the view.
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (maker) in
            maker.bottom.right.left.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
        }
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0

        tableView.dataSource = tableListViewModel
        tableView.delegate = tableListViewModel
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        tableView.backgroundColor = hexStringToUIColor(hex: "#f2f4f5")
        tableView.separatorStyle = .none

        tableView.register(ChatDetailListCell.self, forCellReuseIdentifier: ChatDetailListCell.identifier)
        self.setupLoadmoreIndicatorView(tableView: tableView, disposeBag: disposeBag)
        if let messageId = messageId {
            self.tableListViewModel?.messageId = messageId
            loadData(messageId: messageId)
        }
        
        view.addSubview(emptyMaskView)
        emptyMaskView.snp.makeConstraints { maker in
            maker.top.bottom.right.left.equalTo(tableView)
        }
        
        self.errorVM = NHErrorViewModel(errorMask:emptyMaskView,requestRetryText:"网络异常",requestNilDataText:"啊哦～你还没有收到消息～",requestNilDataImage:"empty_message",isUserClickEnable:false)
        self.errorVM?.onRequestViewDidLoad()
    }
    
    fileprivate func loadData(messageId: String) {
        if EnvContext.shared.client.reachability.connection == .none {
            // 无网络时直接返回空，不请求
            return
        }
        self.tt_startUpdate()
        self.dataLoader = self.onDataLoaded()
        
        let loader = pageRequestUserMessageList(listId: messageId,
                                                limit: "10",
                                                query: "")
        
        self.cleanData()
        
        pageableLoader = { [unowned self] in
            self.errorVM?.onRequest()
            loader()
                .subscribe(onNext: { [unowned self] (responsed) in
                    self.dismissLoadingAlert()
                    if let data = responsed?.data {
                        self.originSearchId = data.searchId
                        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                            toTracerParams(self.originSearchId ?? "be_null", key: "origin_search_id")

                        self.traceParams = EnvContext.shared.homePageParams <|>
                            self.traceParams <|>
                            toTracerParams(data.searchId ?? "be_null", key: "search_id")
                    }
                    if let responseData = responsed?.data?.items, responseData.count != 0 {

                        self.hasMore = responsed?.data?.hasMore ?? false
                        if let data = self.tableListViewModel?.datas.value{
                            self.tableListViewModel?.datas.accept(data + responseData)
                        }
                        self.tableView.reloadData()
                        self.errorVM?.onRequestNormalData()
                        self.dataLoader?(self.hasMore, responseData.count)
                        
                        if !self.hasMore
                        {
                            self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }

                        if !self.hasRecordEnterCategory {
                            
                            let traceParams = self.traceParams <|> toTracerParams("be_null", key: "element_from")
                            recordEvent(key: TraceEventName.enter_category, params: traceParams.exclude("log_pb"))
                            self.hasRecordEnterCategory = true
                        }

                    } else {
                        
                        if self.tableListViewModel?.datas.value.count == 0
                        {
                            self.showEmptyMaskView()
                        }else
                        {
                            self.hasMore = false
                            self.dataLoader?(false, 0)
                            self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        }
                    }
                    self.tt_endUpdataData()
                    }, onError: { [unowned self] (error) in
                        self.dismissLoadingAlert()
                        self.tableView.mj_footer.endRefreshing()
                        self.errorVM?.onRequestError(error: error)
                        self.showNetworkError()
                        self.tt_endUpdataData()
                })
                .disposed(by: self.disposeBag)
        }
        
        pageableLoader?()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.ttStatusBarStyle = UIStatusBarStyle.default.rawValue
        UIApplication.shared.setStatusBarHidden(false, with: .none)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)


    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.addStayCategoryLog()
        self.tt_resetStayTime()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func showEmptyMaskView() {
        self.errorVM?.onRequestNilData()
    }
    
    private func showNetworkError() {
        //TODO:
    }
    
    func loadMore() {
        
        traceParams = traceParams <|> toTracerParams("pre_load_more", key: "refresh_type")
            <|> toTracerParams("be_null", key: "element_from")


        recordEvent(key: TraceEventName.category_refresh, params: traceParams.exclude("log_pb"))

        self.pageableLoader?()
    }
    
    func cleanData() {
        self.tableListViewModel?.datas.accept([])
        tableView.reloadData()
    }

    func tt_hasValidateData() -> Bool {
        return self.tableListViewModel?.datas.value.count ?? 0 > 0
    }
    
    func addStayCategoryLog() {
        
        let trackTime = Int64(self.ttTrackStayTime * 1000)
        let stayTimeParams = self.traceParams <|> toTracerParams(trackTime, key: "stay_time")
            <|> toTracerParams("be_null", key: "element_from")
        recordEvent(key: TraceEventName.stay_category, params: stayTimeParams.exclude("log_pb"))
    }
    
}

// MARK: TTUIViewControllerTrackProtocol
extension MessageListVC {
    
    override func trackStartedByAppWillEnterForground() {
        
        self.tt_resetStayTime()
        self.ttTrackStartTime = Date().timeIntervalSince1970
    }
    override func trackEndedByAppWillEnterBackground() {
        
        self.addStayCategoryLog()
        self.tt_resetStayTime()
    }
}

fileprivate  class ChatDetailListTableViewModel: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    let disposeBag = DisposeBag()
    
    let datas: BehaviorRelay<[UserListMsgItem]> = BehaviorRelay(value: [])

    weak var navVC: UINavigationController?
    
    var tableView: UITableView?

    var traceParams = TracerParams.momoid()

    var recordedIndexPath = Set<IndexPath>()

    var messageId: String?
    
    init(navVC: UINavigationController?,tableView: UITableView?) {
        self.navVC = navVC
        self.tableView = tableView
        super.init()
        
        datas
            .skip(1)
            .subscribe({ [unowned self] datas in
                self.tableView?.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = datas.value[section].items {
            return data.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatDetailListCell.identifier, for: indexPath)
        if let theCell = cell as? ChatDetailListCell {

            if let items = datas.value[indexPath.section].items {
                let data = items[indexPath.row]
                theCell.majorTitle.text = data.title
                theCell.extendTitle.text = data.description
                theCell.isTail = indexPath.row == items.count - 1

                let text = NSMutableAttributedString()
                let attrTexts = data.tags?.enumerated().map({ (offset, item) -> NSAttributedString in
                    createTagAttrString(
                        item.content,
                        isFirst: offset == 0,
                        textColor: hexStringToUIColor(hex: item.textColor),
                        backgroundColor: hexStringToUIColor(hex: item.backgroundColor))
                })
                
                attrTexts?.forEach({ (attrText) in
                    text.append(attrText)
                })
                
                theCell.areaLabel.attributedText = text
                theCell.areaLabel.snp.updateConstraints { (maker) in
                    
                    maker.left.equalToSuperview().offset(-3)
                }
                if data.houseType == HouseType.newHouse.rawValue {
                    
                    theCell.priceLabel.text = data.pricePerSqm
                    
                }else {
                    theCell.priceLabel.text = data.price
                    theCell.roomSpaceLabel.text = data.pricePerSqm
                }

                if data.houseType == HouseType.newHouse.rawValue {

                    theCell.priceLabel.text = data.pricePerSqm

                }else {
                    theCell.priceLabel.text = data.price
                    theCell.roomSpaceLabel.text = data.pricePerSqm
                }
                theCell.isTail = (indexPath.row == items.count - 1) ? true : false

                theCell.majorImageView.bd_setImage(with: URL(string: data.images?.first?.url ?? ""), placeholder:UIImage(named: "default_image"))
                
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
                
                if data.status == 1 { // 已下架
                    theCell.priceLabel.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
                } else {
                    theCell.priceLabel.textColor = hexStringToUIColor(hex: "#f85959")
                }
                
                theCell.updateLayoutCompoents(isShowTags: text.string.count > 0)
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UserMsgSectionView()
        view.tipsLabel.text = datas.value[section].title
        view.dateLabel.text = datas.value[section].dateStr
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if datas.value.count > section {
            let item = datas.value[section]
            if item.moreLabel?.isEmpty ?? true == false {
                return 40
            }
        }
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if datas.value.count > section {
            let item = datas.value[section]
            if item.moreLabel?.isEmpty ?? true == false {
                let view = UserMsgFooterOpenAllView(){
     
                    recordEvent(key: "click_recommend_loadmore", params: TracerParams.momoid())

                    var tracerParams = TracerParams.momoid()
                    tracerParams = tracerParams <|>
                        toTracerParams("messagetab", key: "element_from") <|>
                        toTracerParams("messagetab", key: "enter_from") <|>
                        toTracerParams("click", key: "enter_type")

                    var paramsMap = tracerParams.paramsGetter([:])
                    paramsMap["origin_from"] = selectTraceParam(EnvContext.shared.homePageParams, key: "origin_from") ?? "be_null"
                    paramsMap["origin_search_id"] = selectTraceParam(EnvContext.shared.homePageParams, key: "origin_search_id") ?? "be_null"
                    let userInfo = TTRouteUserInfo(info: ["tracer": paramsMap])
                    if let moreDetail = item.moreDetal
                    {
                        TTRoute.shared().openURL(byPushViewController: URL(string: moreDetail), userInfo: userInfo)
                    }
                }
                view.title.text = item.moreLabel
                return view
            }
        }
        return UIView()
    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        if let houseId = datas.value[indexPath.section].items?[indexPath.row].id {
            if let houseTypeId = datas.value[indexPath.section].items?[indexPath.row].houseType {

                let houseType: HouseType = HouseType(rawValue: houseTypeId) ?? .newHouse
                let logPb = datas.value[indexPath.section].items?[indexPath.row].logPb
                var tracerDict: [String: Any] = [:]
                tracerDict["card_type"] = "left_pic"
                let listType = selectTraceParam(self.traceParams, key: "category_name")
                tracerDict["enter_from"] = listType ?? "old_message_list"
                tracerDict["element_from"] = "be_null"
                tracerDict["search_id"] = datas.value[indexPath.section].items?[indexPath.row].searchId ?? "be_null"
                tracerDict["log_pb"] = logPb ?? "be_null"
                tracerDict["rank"] = rankByIndexPath(indexPath)
                tracerDict["origin_from"] = selectTraceParam(EnvContext.shared.homePageParams, key: "origin_from")
                tracerDict["origin_search_id"] = selectTraceParam(EnvContext.shared.homePageParams, key: "origin_search_id")
                let userInfo = TTRouteUserInfo(info: ["tracer": tracerDict])
                
                switch houseType {
                    case .newHouse:
                        TTRoute.shared()?.openURL(byPushViewController: URL(string: "fschema://new_house_detail?court_id=\(houseId)"), userInfo: userInfo)

                    case .secondHandHouse:
                        TTRoute.shared()?.openURL(byPushViewController: URL(string: "fschema://old_house_detail?house_id=\(houseId)"), userInfo: userInfo)

                    case .rentHouse:
                        TTRoute.shared()?.openURL(byPushViewController: URL(string: "fschema://rent_detail?house_id=\(houseId)"), userInfo: userInfo)
                default:
                    TTRoute.shared()?.openURL(byPushViewController: URL(string: "fschema://neighborhood_detail?neighborhood_id=\(houseId)"), userInfo: userInfo)
                }

//                switch houseType {
//                case .newHouse:
//                    openNewHouseDetailPage(
//                        houseId: Int64(houseId) ?? 0,
//                        logPB: logPb as? [String: Any],
//                        disposeBag: disposeBag,
//                        tracerParams: params <|> toTracerParams("new_message_list", key: "enter_from"),
//                        navVC: navVC)(TracerParams.momoid() <|>
//                            beNull(key: "element_from") <|>
//                            toTracerParams(rankByIndexPath(indexPath), key: "rank"))
//                case .secondHandHouse:
//
//                    let listType = selectTraceParam(self.traceParams, key: "category_name")
//                    var elementParams = TracerParams.momoid()
//                                        <|> toTracerParams(rankByIndexPath(indexPath), key: "rank")
//                                        <|> beNull(key: "element_from")
//
//                    if let categoryName = listType as? String, categoryName == "recommend_message_list"  {
//
//                        params = params <|> toTracerParams("recommend_message_list", key: "enter_from")
//                        elementParams = elementParams <|> toTracerParams("be_null", key: "element_from")
//
//                    }else {
//                        params = params <|> toTracerParams(listType ?? "old_message_list", key: "enter_from")
//                    }
//                    openErshouHouseDetailPage(
//                        houseId: Int64(houseId) ?? 0,
//                        logPB: logPb as? [String: Any],
//                        disposeBag: disposeBag,
//                        tracerParams: params,
//                        navVC: navVC)(elementParams)
//
//                case .rentHouse:
//
//                    var tracerDict:[String:Any] = [:]
//                    tracerDict["card_type"] = "left_pic"
//
//                    let listType = selectTraceParam(self.traceParams, key: "category_name")
//                    if let categoryName = listType as? String, categoryName == "recommend_message_list"  {
//                        tracerDict["enter_from"] = "recommend_message_list"
//                    }else {
//                        tracerDict["enter_from"] = listType ?? "rent_message_list"
//                    }
//                    tracerDict["element_from"] = "be_null"
//                    tracerDict["log_pb"] = selectTraceParam(params, key: "log_pb") ?? "be_null"
//                    tracerDict["rank"] = rankByIndexPath(indexPath)
//                    tracerDict["origin_from"] = selectTraceParam(EnvContext.shared.homePageParams, key: "origin_from")
//                    tracerDict["origin_search_id"] = selectTraceParam(EnvContext.shared.homePageParams, key: "origin_search_id")
//
//                    let userInfo = TTRouteUserInfo(info: ["tracer": tracerDict])
//                    TTRoute.shared()?.openURL(byPushViewController: URL(string: "fschema://rent_detail?house_id=\(houseId)"), userInfo: userInfo)
//
//                default:
//                    openErshouHouseDetailPage(
//                        houseId: Int64(houseId) ?? 0,
//                        logPB: logPb as? [String: Any],
//                        disposeBag: disposeBag,
//                        tracerParams: params <|> toTracerParams("neighborhood_message_list", key: "enter_from"),
//                        navVC: navVC)(TracerParams.momoid() <|>
//                            beNull(key: "element_from") <|>
//                            toTracerParams(rankByIndexPath(indexPath), key: "rank"))
//                }
            } else {
                assertionFailure()
            }
        }
    }

    fileprivate func houseTypeStringByHouseType(_ houseType: Int) -> String {
        let ht = HouseType(rawValue: houseType) ?? .secondHandHouse
        switch ht {
        case .newHouse:
            return "new"
        case .secondHandHouse:
            return "old"
        case .rentHouse:
            return "rent"
        default:
            return "old"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < datas.value.count {
            
            if let count = datas.value[indexPath.section].items?.count, count == indexPath.row + 1 {
                return 125
            }
        }
        return 105
    }

    fileprivate func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let paths = tableView.indexPathsForVisibleRows {
            paths.forEach { path in
                if !recordedIndexPath.contains(path) {
                    if let item = datas.value[path.section].items?[path.row] {
                        let listType = selectTraceParam(self.traceParams, key: "category_name") as? String
                        let elementType = "be_null"
                        let params = EnvContext.shared.homePageParams <|>
                                traceParams <|>
                                toTracerParams(item.logPb ?? "be_null", key: "log_pb") <|>
                                toTracerParams(item.searchId ?? "be_null", key: "search_id") <|>
                                toTracerParams(item.imprId ?? "be_null", key: "impr_id") <|>
                                toTracerParams(item.id ?? "be_null", key: "group_id") <|>
                                toTracerParams(rankByIndexPath(path), key: "rank") <|>
                                toTracerParams(elementType, key: "element_type") <|>
                                toTracerParams(houseTypeStringByHouseType(item.houseType ?? 2), key: "house_type") <|>
                                toTracerParams("left_pic", key: "card_type") <|>
                                imprIdTraceParam(item.logPb) <|>
                                groupIdTraceParam(item.logPb) <|>
                                searchIdTraceParam(item.logPb) <|>
                                toTracerParams(listType ?? "", key: "page_type")

                        recordEvent(key: TraceEventName.house_show, params: params
                            .exclude("enter_from")
                            .exclude("category_name")
                            .exclude("enter_type"))
                    }
                    recordedIndexPath.insert(path)
                }
            }
        }
    }

    fileprivate func rankByIndexPath(_ indexPath: IndexPath) -> Int {
        var count: Int = 0
        var index = 0
        while index < indexPath.section {
            count = count + (datas.value[index].items?.count ?? 0)
            index = index + 1
        }

        count = count + indexPath.row
        return count
    }
}
