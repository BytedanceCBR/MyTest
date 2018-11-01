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

class MessageListVC: BaseViewController, UITableViewDelegate, PageableVC, TTRouteInitializeProtocol {
    
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

    var stayTimeParams: TracerParams?
    
    private var errorVM : NHErrorViewModel?

    private var hasRecordEnterCategory = false

    public required init(routeParamObj paramObj: TTRouteParamObj?) {
        super.init(nibName: nil, bundle: nil)
        if let paramObj = paramObj {
            self.messageId = paramObj.queryParams["list_id"] as? String
            self.navBar.title.text = paramObj.queryParams["title"] as? String
        }
        self.navBar.backBtn.rx.tap
            .bind { [weak self] void in
                EnvContext.shared.toast.dismissToast()
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
        tableView.backgroundColor = hexStringToUIColor(hex: "#f4f5f6")
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

        self.dataLoader = self.onDataLoaded()
        
//        EnvContext.shared.toast.showLoadingToast("正在加载")
        showLoadingAlert(message: "正在加载")
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

                        if !self.hasRecordEnterCategory {
                            self.stayTimeParams = self.traceParams <|> traceStayTime()
                            recordEvent(key: TraceEventName.enter_category, params: self.traceParams)
                            self.hasRecordEnterCategory = true
                        }

                    } else {
                        self.showEmptyMaskView()
                    }
                    
                    }, onError: { [unowned self] (error) in
                        self.dismissLoadingAlert()
                        self.tableView.mj_footer.endRefreshing()
                        self.errorVM?.onRequestError(error: error)
                        self.showNetworkError()
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
        if let stayTimeParams = stayTimeParams {
            recordEvent(key: TraceEventName.stay_category, params: stayTimeParams)
        }
        stayTimeParams = nil
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
        
        traceParams = traceParams <|>
            toTracerParams("pre_load_more", key: "refresh_type")

        recordEvent(key: TraceEventName.category_refresh, params: traceParams)

        self.pageableLoader?()
    }
    
    func cleanData() {
        self.tableListViewModel?.datas.accept([])
        tableView.reloadData()
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

                if data.status == 1 { // 已下架
                    theCell.priceLabel.textColor = hexStringToUIColor(hex: kFHCoolGrey2Color)
                } else {
                    theCell.priceLabel.textColor = hexStringToUIColor(hex: "#f85959")
                }

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
        return 122
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if datas.value.count > section {
            let item = datas.value[section]
            if item.moreLabel?.isEmpty ?? true == false {
                return 50
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if datas.value.count > section {
            let item = datas.value[section]
            if item.moreLabel?.isEmpty ?? true == false {
                let view = UserMsgFooterOpenAllView(){
                    //to do
//                    let userInfo = TTRouteUserInfo(info: ["tracer": parmasMap,
//                                                          "houseSearch": houseSearchParams])
                    
                    recordEvent(key: "click_recommend_loadmore", params: TracerParams.momoid())
                    

                    EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
                        toTracerParams("messagetab_recommend", key: "origin_from")
                    
                    var tracerParams = TracerParams.momoid()
                    tracerParams = tracerParams <|>
                        toTracerParams("messagetab", key: "enter_from") <|>
                        toTracerParams("messagetab_recommend", key: "element_from") <|>
                        toTracerParams("click", key: "enter_type")
                    
                    let paramsMap = tracerParams.paramsGetter([:])
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
        return nil
    }



    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let houseId = datas.value[indexPath.section].items?[indexPath.row].id {
            if let houseTypeId = datas.value[indexPath.section].items?[indexPath.row].houseType {
                let logPb = datas.value[indexPath.section].items?[indexPath.row].logPb
                var params = EnvContext.shared.homePageParams <|>
                    toTracerParams(logPb ?? "be_null", key: "log_pb") <|>
                    toTracerParams("left_pic", key: "card_type") <|>
                    toTracerParams(rankByIndexPath(indexPath), key: "rank")
                let houseType: HouseType = HouseType(rawValue: houseTypeId) ?? .newHouse

                switch houseType {
                case .newHouse:
                    openNewHouseDetailPage(
                        houseId: Int64(houseId) ?? 0,
                        logPB: logPb as? [String: Any],
                        disposeBag: disposeBag,
                        tracerParams: params <|> toTracerParams("new_message_list", key: "enter_from"),
                        navVC: navVC)(TracerParams.momoid() <|>
                            beNull(key: "element_from") <|>
                            toTracerParams(rankByIndexPath(indexPath), key: "rank"))
                case .secondHandHouse:
                    
                    let listType = selectTraceParam(self.traceParams, key: "category_name")
                    var elementParams = TracerParams.momoid()
                                        <|> toTracerParams(rankByIndexPath(indexPath), key: "rank")
                                        <|> beNull(key: "element_from")

                    if let categoryName = listType as? String, categoryName == "recommend_message_list"  {
                        
                        params = params <|> toTracerParams("messagetab", key: "enter_from")
                        elementParams = elementParams <|> toTracerParams("messagetab_recommend", key: "element_from")

                    }else {
                        params = params <|> toTracerParams(listType ?? "old_message_list", key: "enter_from")
                    }
                    openErshouHouseDetailPage(
                        houseId: Int64(houseId) ?? 0,
                        logPB: logPb as? [String: Any],
                        disposeBag: disposeBag,
                        tracerParams: params,
                        navVC: navVC)(elementParams)
                default:
                    openErshouHouseDetailPage(
                        houseId: Int64(houseId) ?? 0,
                        logPB: logPb as? [String: Any],
                        disposeBag: disposeBag,
                        tracerParams: params <|> toTracerParams("neighborhood_message_list", key: "enter_from"),
                        navVC: navVC)(TracerParams.momoid() <|>
                            beNull(key: "element_from") <|>
                            toTracerParams(rankByIndexPath(indexPath), key: "rank"))
                }
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

                        let params = EnvContext.shared.homePageParams <|>
                                traceParams <|>
                                toTracerParams(item.logPb ?? "be_null", key: "log_pb") <|>
                                toTracerParams(rankByIndexPath(path), key: "rank") <|>
                                toTracerParams("be_null", key: "element_type") <|>
                                toTracerParams(houseTypeStringByHouseType(item.houseType ?? 2), key: "house_type") <|>
                                toTracerParams("left_pic", key: "card_type") <|>
                                toTracerParams(listType ?? "", key: "page_type")

                        recordEvent(key: TraceEventName.house_show, params: params
                            .exclude("search_id")
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
