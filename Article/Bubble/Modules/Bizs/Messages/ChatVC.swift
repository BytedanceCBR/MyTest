//
//  ChatVC.swift
//  Bubble
//
//  Created by linlin on 2018/7/5.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Reachability

class ChatVC: BaseViewController, UIViewControllerErrorHandler {

    lazy var navBar: SimpleNavBar = {
        let re = SimpleNavBar(hiddenMaskBtn: false)
        re.backBtn.isHidden = true
        re.rightBtn.isHidden = true
        re.title.text = "消息"
        re.removeGradientColor()
        return re
    }()

    var timerDisposable: Disposable?
    
    var isFirstEnter: Bool = true

    lazy var tableView: UITableView = {
        let re = UITableView()
        if #available(iOS 11.0, *) {
            re.contentInsetAdjustmentBehavior = .never
        }
        re.rowHeight = UITableViewAutomaticDimension
        re.separatorStyle = .none
        return re
    }()

    let disposeBag = DisposeBag()

    lazy var emptyMaskView: EmptyMaskView = {
        let re = EmptyMaskView()
        re.isHidden = true
        return re
    }()
    
    private var errorVM : NHErrorViewModel?

    private var tableViewModel: ChatListTableViewModel?

    private var stayTabParams = TracerParams.momoid()
    private var theThresholdTracer: ((String, TracerParams) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = false

        self.view.addSubview(navBar)
        self.tableViewModel = ChatListTableViewModel(navVC: self.navigationController)
        navBar.snp.makeConstraints { maker in
            if #available(iOS 11, *) {
                maker.left.right.top.equalToSuperview()
                maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            } else {
                maker.left.right.top.equalToSuperview()
                maker.height.equalTo(65)
            }
        }

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.equalTo(navBar.snp.bottom)
            if #available(iOS 11, *) {
                var bottomOffset = (49 + view.tt_safeAreaInsets.bottom)
                if let tabBarItem = TTTabBarManager.shared().tabItem(withIdentifier: kFHouseMessageTabKey) {
                    bottomOffset = tabBarItem.frame.height
                }
                maker.bottom.equalToSuperview().offset(-bottomOffset)
            } else {
                maker.bottom.equalToSuperview().offset(-49)
            }
        }
        tableView.dataSource = tableViewModel
        tableView.delegate = tableViewModel
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.identifier)
        

        
        view.addSubview(emptyMaskView)
        emptyMaskView.icon.image = UIImage(named: "group-4")
        emptyMaskView.snp.makeConstraints { maker in
            maker.top.bottom.right.left.equalTo(tableView)
        }
        
        self.errorVM = NHErrorViewModel(
            errorMask: emptyMaskView,
            requestRetryText: "网络异常",
            requestNilDataText: "啊哦～您还没收到相关消息",
            requestNilDataImage: "empty_message",
            requestErrorText: "网络异常",
            isUserClickEnable: false)
    }
    
    func updateTableView()
    {
        UIView.performWithoutAnimation {
            [weak self] in
            self?.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstEnter
        {
            EnvContext.shared.toast.dismissToast()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        self.navigationController?.navigationBar.isHidden = true

        // Do any additional setup after loading the view.


//        emptyMaskView.tapGesture.rx.event
//            .bind { [unowned self] (_) in
//                if EnvContext.shared.client.reachability.connection == .none {
//                    // 无网络时直接返回空，不请求
//                    EnvContext.shared.toast.showToast("网络异常")
//                    return
//                }
//                self.requestData()
//            }
//            .disposed(by: disposeBag)
        
        var withTips: String?
        if let messageBarItem = TTTabBarManager.shared().tabItems.first(where: { $0.identifier == kFHouseMessageTabKey}) {
            if let badgeView = messageBarItem.ttBadgeView {
                withTips = badgeView.badgeNumber != 0 ? "1" : "0"
            }
            
        }
        
        self.theThresholdTracer = thresholdTracer()
        self.stayTabParams = TracerParams.momoid() <|>
                toTracerParams("message", key: "tab_name") <|>
                toTracerParams("click_tab", key: "enter_type") <|>
                toTracerParams(withTips ?? "0", key: "with_tips") <|>
                traceStayTime()
    }

    func requestData() {
        if isFirstEnter {
            self.tt_startUpdate()
        }
        errorVM?.onRequest()
        requestUserUnread(query:"")
            .subscribe(onNext: { [weak self] (responsed) in
                
                guard let `self` = self else { return }
                self.isFirstEnter = false
                if let responseData = responsed?.data?.unread {
                    self.tableViewModel?.datas = responseData
                    self.updateTableView()
                    if let responseData = responsed?.data?.unread {
                        var unreadCount:Int = 0
                        responseData.forEach {
                            if let unread = $0.unread
                            {
                                unreadCount += unread
                            }
                        }
                        if let badgeView = self.messageTab()?.ttBadgeView {
                            if unreadCount > 0 {
                                badgeView.badgeNumber = unreadCount
                            } else {
                                badgeView.badgeNumber = TTBadgeNumberHidden
                            }
                        }
                    }
                    if responseData.count == 0 {
                        self.showEmptyInfo()
                    } else {
                        self.emptyMaskView.isHidden = true
                        self.errorVM?.onRequestNormalData()
                    }
                } else {
                    self.showResponseError()
                }
                self.tt_endUpdataData()
            }, onError: { [unowned self] (error) in
                self.showNetworkError()
                self.errorVM?.onRequestError(error: error)
                self.tt_endUpdataData()
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if EnvContext.shared.client.reachability.connection == .none {
            self.errorVM?.onRequestViewDidLoad()
        } else {
            requestData()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.emptyMaskView.isHidden = true

        self.theThresholdTracer?(TraceEventName.stay_tab, self.stayTabParams)
    }

    fileprivate func showEmptyInfo() {
        self.emptyMaskView.isHidden = false
        emptyMaskView.icon.image = UIImage(named:"empty_message")
        self.emptyMaskView.label.text = "啊哦～你还没有收到消息～"
        view.bringSubview(toFront: emptyMaskView)
        self.clearBadgeNumber()
    }
    
    fileprivate func showResponseError() {
        
        self.emptyMaskView.label.text = "数据走丢了"
        self.emptyMaskView.icon.image = UIImage(named: "group-9")
        self.emptyMaskView.isHidden = false
    }

    fileprivate func showNetworkError() {
        self.emptyMaskView.isHidden = false
        self.emptyMaskView.label.text = "网络异常"
        self.clearBadgeNumber()
    }
    
    fileprivate func clearBadgeNumber()
    {
        if let badgeView = self.messageTab()?.ttBadgeView {
            badgeView.badgeNumber = TTBadgeNumberHidden
        }
    }

    func tt_hasValidateData() -> Bool {
        return self.tableViewModel?.datas.count ?? 0 > 0
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @objc
    fileprivate func messageTab() -> TTTabBarItem? {
        return TTTabBarManager.shared().tabItems.first(where: { $0.identifier == kFHouseMessageTabKey })
    }

}



class ChatListTableViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    //let imageIconMap: [String: UIImage] = ["300": UIImage(named: "icon-msg-xinfang")!,
    //                                       "301": UIImage(named: "icon-msg-ershoufang")!,
    //                                       "302": UIImage(named: "icon-msg-zufang")!,
    //                                       "303": UIImage(named: "icon-msg-xiaoqu")!]

    
//    let listIdMap: [String: String] = ["301": "二手房",
//                                           "300": "新房",
//                                           "302": "租房",
//                                           "303": "小区"]
//    let categoryNames = ["301":"old_message_list",
//                         "300":"new_message_list",
//                         "302":"be_null",
//                         "303":"neighborhood_message_list"]
//    let categoryNames = ["old_message_list",
//                         "new_message_list",
//                         "be_null",
//                         "neighborhood_message_list"]
    var datas: [UserUnreadInnerMsg] = []
    
    private let disposeBag = DisposeBag()
    
    weak var navVC: UINavigationController?
    
    init(navVC: UINavigationController?) {
        self.navVC = navVC
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier)
        if let theCell = cell as? ChatCell {
            let item = datas[indexPath.row]
            if let text = item.content {
                theCell.secondaryLabel.text = text
            }
            if let text2 = item.dateStr {
                theCell.rightLabel.text = text2
            }
            if let unreadCount = item.unread, unreadCount > 0 {
                theCell.unreadRedDotView.badgeNumber = unreadCount
            } else {
                theCell.unreadRedDotView.badgeNumber = TTBadgeNumberHidden
            }

            theCell.iconImageView.bd_setImage(with: URL(string: item.icon ?? ""), placeholder: UIImage(named: "default_image"))
            theCell.label.text = item.title

        }
        return cell ?? ChatCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var data = datas[indexPath.row]
        if let msgCount = data.unread, msgCount > 0 {
            // Tab消息个数减少
            if let msgTab = TTTabBarManager.shared().tabItems.first(where: { $0.identifier == kFHouseMessageTabKey}), let badgeView = msgTab.ttBadgeView {
                var tabMsgCount = badgeView.badgeNumber
                tabMsgCount -= msgCount
                tabMsgCount = tabMsgCount >= 0 ? tabMsgCount : 0
                badgeView.badgeNumber = tabMsgCount
            }
            // Cell消息个数清零
            data.unread = 0
            if let theCell = tableView.cellForRow(at: indexPath) as? ChatCell {
                theCell.unreadRedDotView.badgeNumber = TTBadgeNumberHidden
            }
        }

        if let url = data.openUrl,
            let encodeUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            TTRoute.shared().openURL(byPushViewController: URL(string: encodeUrl))
        }
        
        
        
//        if let id = data.id,
//            id == "308",
//            let url = data.openUrl,
//            let encodeUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
//                toTracerParams("be_null", key: "origin_from") <|>
//                toTracerParams("be_null", key: "origin_search_id")
//            TTRoute.shared().openURL(byPushViewController: URL(string: encodeUrl))
//            return
//        }
//
//        let vc = MessageListVC()
//
//
//        vc.messageId = datas[indexPath.row].id
//
//        var category_name = "be_null"
//        var origin_from = "be_null"
//
//        switch vc.messageId {
//
//        case "300":
//            // "新房"
//            category_name = "new_message_list"
//            origin_from = "messagetab_new"
//
//        case "301":
//            // "二手房"
//            category_name = "old_message_list"
//            origin_from = "messagetab_old"
//
//        case "302":
//            // "租房"
//            category_name = "rent_message_list"
//            origin_from = "messagetab_rent"
//        case "303":
//            // "小区"
//            category_name = "neighborhood_message_list"
//            origin_from = "messagetab_neighborhood"
//        case "307":
//            // "小区"
//            category_name = "recommend_message_list"
//            origin_from = "messagetab_recommend"
//
//        default:
//            break
//
//        }
//
//        let params = TracerParams.momoid() <|>
//            toTracerParams("click", key: "enter_type") <|>
//            beNull(key: "log_pb") <|>
//            toTracerParams(category_name, key: "category_name")
//        vc.traceParams = params
//
//        EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
//            toTracerParams(origin_from, key: "origin_from")
//        vc.traceParams = vc.traceParams <|>
//            toTracerParams("be_null", key: "log_pb") <|>
//            toTracerParams("messagetab", key: "enter_from") <|>
//            toTracerParams("be_null", key: "search_id") <|>
//            toTracerParams(category_name, key: "category_name")
//
//
//        //        vc.navBar.title.text = listIdMap[vc.messageId ?? "301"]
//        vc.navBar.title.text = datas[indexPath.row].title
//
//        vc.navBar.backBtn.rx.tap
//            .subscribe(onNext: { [unowned self] void in
//                self.navVC?.popViewController(animated: true)
//            })
//            .disposed(by: disposeBag)
//        self.navVC?.pushViewController(vc, animated: true)
        
        
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}
