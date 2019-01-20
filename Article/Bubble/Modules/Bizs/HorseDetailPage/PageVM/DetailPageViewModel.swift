//
//  DetailPageViewModel.swift
//  Bubble
//
//  Created by linlin on 2018/7/3.
//  Copyright © 2018年 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

let kFHToastCountKey = "kFHToastCountKey"

extension Notification.Name {
    static let followUpDidChange = Notification.Name("follow_up_did_changed")
}


protocol DetailPageViewModel: class {

    var source: String? { get set } // 页面来源

    var logPB: Any?  { get set }
    
    var searchId: String? { get set }

    var shareInfo: ShareInfo? { get set }
    
    var followStatus: BehaviorRelay<Result<Bool>> { get }

    var disposeBag: DisposeBag { get }

    var traceParams: TracerParams { get set }

    var followTraceParams: TracerParams { get set }

    var followPage: BehaviorRelay<String> { get set }

    var groupId: String { get }
    var tracerModel: HouseRentTracer? { get set }

    var contactPhone: BehaviorRelay<FHHouseDetailContact?> { get }
    var houseType: HouseType { get set }
    var houseId: Int64 { get set }

    var tableView: UITableView? { get set }

    var titleValue: BehaviorRelay<String?> { get }

    var onDataArrived: (() -> Void)? { get set }

    var onNetworkError: ((Error) -> Void)? { get set }

    var onEmptyData: (() -> Void)? { get set }

    func requestData(houseId: Int64, logPB: [String: Any]?, showLoading: Bool)

    func followThisItem(isNeedRecord: Bool, traceParam: TracerParams)
    
    func bindFollowPage()

    func getShareItem() -> ShareItem

    var showMessageAlert: ((String) -> Void)? { get set }

    var dismissMessageAlert: (() -> Void)? { get set }
    
    var goDetailTraceParam: TracerParams? { get set }

    func isDataAvailable() -> Bool
    

}

extension DetailPageViewModel {
    

    func getShareItem() -> ShareItem {
        var shareimage: UIImage? = nil
        if let shareImageUrl = shareInfo?.coverImage {
            shareimage = BDImageCache.shared().imageFromDiskCache(forKey: shareImageUrl)
        }
        
        if let shareInfo = shareInfo {
            return ShareItem(
                title: shareInfo.title,
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
    
    func bindFollowPage() {
    
        self.followPage
            .subscribe(onNext: { [unowned self] followPage in
                self.followTraceParams = self.followTraceParams <|>
                    toTracerParams(followPage, key: "enter_from")
            })
            .disposed(by: disposeBag)
        
        
    }
    
    func processError() -> (Error?) -> Void {
        return {  error in
            if EnvContext.shared.client.reachability.connection != .none {
                EnvContext.shared.toast.dismissToast()
                EnvContext.shared.toast.showToast("请求失败")
            } else {
                EnvContext.shared.toast.dismissToast()
                EnvContext.shared.toast.showToast("网络异常")
            }
        }
    }
    
    func sendPhoneNumberRequest(houseId: Int64, phone: String, from: String = "detail", success: @escaping () -> Void)
    {
        requestSendPhoneNumber(houseId: houseId, phone: phone, from: from).subscribe(
            onNext: { [unowned self] (response) in
                if let status = response?.status, status == 0 {
                    var toastCount =  UserDefaults.standard.integer(forKey: kFHToastCountKey)
                    if toastCount >= 3 {
                        
                        EnvContext.shared.toast.showToast("提交成功，经纪人将尽快与您联系")
                    }
                    success()
                }
                else {
                    if let message = response?.message
                    {
                        EnvContext.shared.toast.showToast("提交失败," + message)
                    }
                }
            },
            onError: self.processError())
            .disposed(by: self.disposeBag)
    }
    
    func followIt(
        houseType: HouseType,
        followAction: FollowActionType,
        followId: String,
        disposeBag: DisposeBag,
        isNeedRecord: Bool = true) -> () -> Void {
        var loginDisposeBag = DisposeBag()
        return { [weak self] in

            if EnvContext.shared.client.reachability.connection == .none {
                EnvContext.shared.toast.showToast("网络异常")
                return
            }
            
            requestFollow(
                houseType: houseType,
                followId: followId,
                actionType: followAction)
                .subscribe(onNext: { response in
                    if response?.status ?? 1 == 0 {
                        if response?.data?.followStatus ?? 0 == 0 {
                            EnvContext.shared.toast.showToast("关注成功")
                        } else {
                            EnvContext.shared.toast.showToast("已经关注")
                        }
                        self?.followStatus.accept(.success(true))
                    } else {
                        self?.followStatus.accept(.success(false))
//                        assertionFailure()
                    }
                }, onError: { error in
                    EnvContext.shared.toast.showToast("关注失败")
                })
                .disposed(by: disposeBag)
        }
    }

    

    func cancelFollowIt(
            houseType: HouseType,
            followAction: FollowActionType,
            followId: String,
            disposeBag: DisposeBag) -> () -> Void {
            var loginDisposeBag = DisposeBag()
        return { [weak self] in

            if EnvContext.shared.client.reachability.connection == .none {
                EnvContext.shared.toast.showToast("取消关注失败")
                return
            }
            
            var tracerParams = TracerParams.momoid()
            if let followTraceParams = self?.followTraceParams {
                
                let paramsMap = followTraceParams.paramsGetter([:])
                tracerParams = tracerParams <|>
                    toTracerParams(paramsMap["enter_from"] ?? "be_null", key: "page_type")
            }
            tracerParams = tracerParams <|>
                toTracerParams(followId, key: "group_id") <|>
                toTracerParams(self?.logPB ?? [:], key: "log_pb")
            recordEvent(key: TraceEventName.delete_follow, params: tracerParams)
            
            requestCancelFollow(
                    houseType: houseType,
                    followId: followId,
                    actionType: followAction)
                    .subscribe(onNext: { response in
                        if response?.status ?? 1 == 0 {
                            EnvContext.shared.toast.dismissToast()
                            self?.followStatus.accept(.success(false))
                            EnvContext.shared.toast.showToast("取关成功")
                            NotificationCenter.default.post(name: .followUpDidChange, object: nil)
                        } else {
                            self?.followStatus.accept(.success(true))
                            assertionFailure()
                        }
                    }, onError: { error in
                        EnvContext.shared.toast.showToast("取消关注失败")
                    })
                    .disposed(by: disposeBag)
        }
    }
    
    // MARK: 静默关注房源
    func followHouseItem(
        houseType: HouseType,
        followAction: FollowActionType,
        followId: String,
        disposeBag: DisposeBag,
        isNeedRecord: Bool = true,
        showTip: Bool = false) -> () -> Void {

        return { [weak self] in

            if EnvContext.shared.client.reachability.connection == .none {
                EnvContext.shared.toast.showToast("网络异常")
                return
            }
            
            requestFollow(
                houseType: houseType,
                followId: followId,
                actionType: followAction)
                .subscribe(onNext: { response in
                    if response?.status ?? 1 == 0 {
                        if response?.data?.followStatus ?? 0 == 0 {

                            var toastCount =  UserDefaults.standard.integer(forKey: kFHToastCountKey)
                            if toastCount < 3 {

                                var style = fhCommonToastStyle()
                                style.isCustomPosition = true
                                style.customX = UIScreen.main.bounds.size.width - 20
                                style.backgroundColor = hexStringToUIColor(hex: kFHDarkIndigoColor, alpha: 0.6)
                                style.messageFont = CommonUIStyle.Font.pingFangRegular(10)
                                style.verticalOffset = 65 + (CommonUIStyle.Screen.isIphoneX ? 20 : 0)
                                style.cornerRadius = 12
                                style.verticalPadding = 5
                                style.horizontalPadding = 6
                                fhShowToast("已加入关注列表", position: .top, style: style)
                                toastCount += 1
                                UserDefaults.standard.set(toastCount, forKey: kFHToastCountKey)
                                UserDefaults.standard.synchronize()
                            }
                            NotificationCenter.default.post(name: .followUpDidChange,
                                                            object: nil,
                                                            userInfo: ["status": 1, "followup_id": followId])
                        }else if response?.data?.followStatus ?? 0 == 1 {
                            let toastCount =  UserDefaults.standard.integer(forKey: kFHToastCountKey)
                            if toastCount < 3 && showTip {
                                
                                EnvContext.shared.toast.showToast("提交成功，经纪人将尽快与您联系")
                            }
                        }
                        self?.followStatus.accept(.success(true))
                    }
                }, onError: { error in

                })
                .disposed(by: disposeBag)
        }
    }
    
    func recordFollowEvent(_ traceParam: TracerParams) {
        
        recordEvent(key: TraceEventName.click_follow, params: traceParam)
        
    }

    func bindBottomView(params: TracerParams) -> FollowUpBottomBarBinder {
        return { [unowned self] (bottomBar, followUpButton, traceParam) in
            followUpButton.rx.tap
                .bind(onNext: { [weak self] in

                    let paramsDict = traceParam.paramsGetter([:])
                    if paramsDict.count > 0 {
                        
                        self?.followThisItem(isNeedRecord: true, traceParam: traceParam)
                    }else {
                        
                        var tracerParams = EnvContext.shared.homePageParams

                        if let params = self?.goDetailTraceParam {
                            tracerParams = tracerParams <|> params
                                .exclude("house_type")
                                .exclude("element_type")
                                .exclude("maintab_search")
                                .exclude("search")
                                .exclude("filter")
                        }
                        tracerParams = tracerParams <|>
                            toTracerParams(self?.houseId ?? "be_null", key: "group_id") <|>
                            toTracerParams(self?.searchId ?? "be_null", key: "search_id") <|>
                            toTracerParams(pageTypeString(self?.houseType ?? .newHouse), key: "page_type")
                     
                        if let followTraceParams = self?.followTraceParams {
                            // ugly code 为了埋点，0.2版本pageType只区分新房二手房小区和户型详情页
                            let paramsMap = followTraceParams.paramsGetter([:])
                            let enterFrom = paramsMap["enter_from"] as? String
                            if let theEnterFrom = enterFrom,theEnterFrom == "house_model_detail" {
                                
                                tracerParams = tracerParams <|>
                                    toTracerParams(theEnterFrom, key: "page_type")
                            }
                        }

                        self?.followThisItem(isNeedRecord: true, traceParam: tracerParams)
                    }
                })
                    .disposed(by: self.disposeBag)
            self.followStatus
                    .filter { (result) -> Bool in
                        if case .success(_) = result {
                            return true
                        } else {
                            return false
                        }
                    }
                    .map { (result) -> Bool in
                        if case let .success(status) = result {
                            return status
                        } else {
                            return false
                        }
                    }
                    .bind(to: followUpButton.rx.isSelected)
                    .disposed(by: self.disposeBag)

            
            self.contactPhone.skip(1).subscribe(onNext: { [weak bottomBar] contactPhone in
                
                var titleStr:String = "电话咨询"
                if let phone = contactPhone?.phone, phone.count > 0 {
                    
                    titleStr = "电话咨询"
                } else {
                    titleStr = "询底价"
                }
                
                bottomBar?.contactBtn.setTitle(titleStr, for: .normal)
                bottomBar?.contactBtn.setTitle(titleStr, for: .highlighted)
                
            }).disposed(by: self.disposeBag)
        
            let topVC:UIViewController? = TTUIResponderHelper.topViewController(for: bottomBar)
            var topView:UIView? = UIApplication.shared.keyWindow?.rootViewController?.view
            if (topVC != nil) {
                topView = topVC?.view
            }
            
            bottomBar.contactBtn.rx.tap
                .withLatestFrom(self.contactPhone)
                .bind(onNext: {[weak self] (contactPhone) in
                    
                    if let phone = contactPhone?.phone, phone.count > 0 {
                        
                        if let houseId = self?.houseId, let houseType = self?.houseType {

                            var clickCallParams: TracerParams? = nil

                            if var traceParams = self?.traceParams, let houseType = self?.houseType, houseType != .neighborhood {

                                if let paramsMap = self?.followTraceParams.paramsGetter([:]), let enter_from = paramsMap["enter_from"] as? String, enter_from == "house_model_detail" {
                                    traceParams = traceParams <|> toTracerParams("house_model_detail", key: "page_type")
                                } else {
                                    traceParams = traceParams <|>
                                        toTracerParams(enterFromByHouseType(houseType: houseType), key: "page_type")
                                }

                                traceParams = traceParams <|> EnvContext.shared.homePageParams
                                    .exclude("house_type")
                                    .exclude("element_type")
                                    .exclude("maintab_search")
                                    .exclude("search")
                                    .exclude("filter")
                                traceParams = traceParams <|>
                                    toTracerParams(self?.searchId ?? "be_null", key: "search_id")
                                if let houseId = self?.houseId {
                                    traceParams = traceParams <|> toTracerParams("\(houseId)", key: "group_id")
                                }else {
                                    traceParams = traceParams <|> toTracerParams("be_null", key: "group_id")
                                }
                                clickCallParams = traceParams
                            }
                            var theImprId: String?
                            if let logPB = self?.logPB as? [String: Any],let imprId = logPB["impr_id"] as? String {
                                theImprId = imprId
                            }
                            self?.callRealtorPhone(contactPhone: contactPhone,
                                                   bottomBar: bottomBar,
                                                   houseId: houseId,
                                                   houseType: houseType,
                                                   searchId: self?.searchId ?? "",
                                                   imprId: theImprId ?? "",
                                                   traceParams: clickCallParams,
                                                   disposeBag: self?.disposeBag ?? DisposeBag())
                            self?.followHouseItem(houseType: houseType,
                                                  followAction: (FollowActionType(rawValue: houseType.rawValue) ?? .newHouse),
                                                  followId: "\(houseId)",
                                disposeBag: self?.disposeBag ?? DisposeBag(),
                                isNeedRecord: false)()
                        }
                        

                    }else {
                        if let pageType = traceParam.paramsGetter([:])["page_type"] as? String, pageType == "house_model_detail"
                        {
                            self?.showSendPhoneAlert(title: "询底价", subTitle: "提交后将安排专业经纪人与您联系", confirmBtnTitle: "获取底价",traceParam: traceParam,isHouseModelDetail: true, topView: topView)
                        }else
                        {
                            self?.showSendPhoneAlert(title: "询底价", subTitle: "提交后将安排专业经纪人与您联系", confirmBtnTitle: "获取底价", topView: topView)
                        }
                    }
                })
                .disposed(by: self.disposeBag)
        }
    }
    // UIApplication.shared.keyWindow?.rootViewController?.view
    func showSendPhoneAlert(title: String, subTitle: String, confirmBtnTitle: String , traceParam: TracerParams = TracerParams.momoid(), isHouseModelDetail: Bool = false, topView:UIView?) {
        let alert = NIHNoticeAlertView(alertType: .alertTypeSendPhone,title: title, subTitle: subTitle, confirmBtnTitle: confirmBtnTitle)
        alert.sendPhoneView.confirmBtn.rx.tap
            .bind { [unowned self] void in
                if let phoneNum = alert.sendPhoneView.currentInputPhoneNumber, phoneNum.count == 11, phoneNum.prefix(1) == "1", isPureInt(string: phoneNum)
                {
                    self.sendPhoneNumberRequest(houseId: self.houseId, phone: phoneNum, from: gethouseTypeSendPhoneFromStr(houseType: self.houseType)){
                        [unowned self]  in
                        EnvContext.shared.client.sendPhoneNumberCache?.setObject(phoneNum as NSString, forKey: "phonenumber")
                        alert.dismiss()
                        let tracerParamsInform = EnvContext.shared.homePageParams <|> (self.goDetailTraceParam ?? TracerParams.momoid())
                        var informShowParams = isHouseModelDetail ? traceParam : tracerParamsInform
                            .exclude("house_type")
                            .exclude("element_type")
                            .exclude("search_id")
                            .exclude("group_id")

                        if let logPb = self.logPB {
                            informShowParams = informShowParams <|>
                                toTracerParams(logPb, key: "log_pb")
                        }
                        recordEvent(key: TraceEventName.inform_show,
                                    params: informShowParams)
                        
                        self.sendClickConfimTrace(traceConfirm: isHouseModelDetail ? traceParam : tracerParamsInform.exclude("house_type").exclude("element_type"))
                        
                        self.followHouseItem(houseType: self.houseType,
                                             followAction: (FollowActionType(rawValue: self.houseType.rawValue) ?? .newHouse),
                                             followId: "\(self.houseId)",
                            disposeBag: self.disposeBag,
                            isNeedRecord: false,
                            showTip: true)()
                    }
                }else
                {
                    alert.sendPhoneView.showErrorText()
                }

                
            }
            .disposed(by: disposeBag)
        
        if let tempView = topView
        {
            let tracerParamsInform = EnvContext.shared.homePageParams <|> (goDetailTraceParam ?? TracerParams.momoid())
            recordEvent(key: TraceEventName.inform_show,
                        params: isHouseModelDetail ? traceParam : tracerParamsInform.exclude("house_type").exclude("element_type").exclude("search_id").exclude("group_id"))
            
            alert.showFrom(tempView)
        }
    }
    
    func sendClickConfimTrace(traceConfirm: TracerParams)
    {
            recordEvent(key: TraceEventName.click_confirm,
                    params: traceConfirm.exclude("house_type").exclude("element_type"))
        
    }
    
    // MARK: 电话转接以及拨打相关操作
    func callRealtorPhone(contactPhone: FHHouseDetailContact?,
                          bottomBar: HouseDetailPageBottomBarView?,
                          houseId: Int64,
                          houseType: HouseType,
                          searchId: String,
                          imprId: String,
                          traceParams: TracerParams?,
                          disposeBag: DisposeBag) {

        guard let phone = contactPhone?.phone, phone.count > 0 else {
            return
        }
        
        bottomBar?.contactBtn.startLoading()
        requestVirtualNumber(realtorId: contactPhone?.realtorId ?? "0", houseId: houseId, houseType: houseType, searchId: searchId, imprId: imprId)
            .subscribe(onNext: { [weak bottomBar, weak self] (response) in
                
                bottomBar?.contactBtn.stopLoading()
                if let contactPhone = response?.data, let virtualNumber = contactPhone.virtualNumber {
                    self?.traceCall(rank: "0", contact: self?.contactPhone.value, isVirtualNumber: true, traceParams: traceParams)
                    Utils.telecall(phoneNumber: virtualNumber)
                }else {
                    self?.traceCall(rank: "0", contact: self?.contactPhone.value, isVirtualNumber: false, traceParams: traceParams)
                    Utils.telecall(phoneNumber: phone)
                }
                
            }, onError: { [weak bottomBar, weak self]  (error) in
                bottomBar?.contactBtn.stopLoading()
                self?.traceCall(rank: "0", contact: self?.contactPhone.value, isVirtualNumber: false, traceParams: traceParams)
                Utils.telecall(phoneNumber: phone)
            })
            .disposed(by: disposeBag)
        
    }


    func traceCall(rank: String,
                   contact: FHHouseDetailContact?,
                   isVirtualNumber: Bool,
                   traceParams: TracerParams?) {
        guard let traceParams = traceParams else {
            return
        }
        let params = traceParams <|>
            toTracerParams(rank, key: "realtor_rank") <|>
            toTracerParams(1, key: "has_auth") <|>
            toTracerParams(contact?.realtorId ?? "be_null", key: "realtor_id") <|>
            toTracerParams("detail_button", key: "realtor_position") <|>
            toTracerParams(0, key: "is_dial") <|>
            toTracerParams(isVirtualNumber ? 1 : 0, key: "has_associate")


        // 谢飞不打，我就不打has_auth
        recordEvent(key: "click_call", params: params)
    }

}

typealias TableCellRender = (BaseUITableViewCell) -> Void

typealias NewHouseDetailDataParser = ([TableSectionNode]) -> [TableSectionNode]

typealias TableViewSectionViewGen = (Int) -> UIView?

typealias TableCellSelectedProcess = (TracerParams) -> Void

struct TableViewSectionHeaderGenerator {
    let generator: TableViewSectionViewGen

    static func momoid() -> TableViewSectionHeaderGenerator {
        return TableViewSectionHeaderGenerator { _ in
            return nil
        }
    }
}

extension TableViewSectionHeaderGenerator {
    func or(g: @escaping TableViewSectionViewGen) -> TableViewSectionHeaderGenerator {
        return TableViewSectionHeaderGenerator {
            if let view = self.generator($0) {
                return view
            } else {
                return g($0)
            }
        }
    }
}


enum TableCellType {
    case dataItem(identifier: String, rowId: String)
    case node(identifier: String)
}

typealias ElementRecord = (TracerParams) -> Void

func operationShowonceRecord(params: TracerParams) -> ElementRecord {
    var isExecuted = false
    return { (theParams) in
        if isExecuted {
            return
        }
        let recordParams = theParams <|> params
        recordEvent(key: "operation_show", params: recordParams)
        isExecuted = true
    }
}

func elementShowOnceRecord(params: TracerParams) -> ElementRecord {
    var isExecuted = false
    return { (theParams) in
        if isExecuted {
            return
        }
        isExecuted = true
        let recordParams = theParams <|> params
        recordEvent(key: "element_show", params: recordParams)
    }
}

func onceRecord(key: String, params: TracerParams) -> ElementRecord {
    var isExecured = false
    return { (theParams) in
        if isExecured {
            return
        }
        isExecured = true
        let recordParams = theParams <|> params
        recordEvent(key: key, params: recordParams)
    }
}

func elementShowRecord(params: TracerParams) -> ElementRecord {
    return { (theParams) in
        let recordParams = theParams <|> params
        recordEvent(key: "element_show", params: recordParams)
    }
}

struct TableSectionNode {
    let items: [TableCellRender]
    var selectors: [TableCellSelectedProcess]? = nil
    var tracer: [ElementRecord]? = nil
    var sectionTracer: ElementRecord? = nil
    let label: String
    let type: TableCellType
}

enum TableRowEditResult {
    case success(String)
    case error(Error)
}

struct TableRowNode {
    let itemRender: TableCellRender
    var selector: TableCellSelectedProcess? = nil
    var tracer: ElementRecord? = nil
    let type: TableCellType
    var editor: ((UITableViewCellEditingStyle) -> Observable<TableRowEditResult>)?
}

struct DetailDataParser {
    let parser: NewHouseDetailDataParser

    static func monoid() -> DetailDataParser {
        return DetailDataParser {
            $0
        }
    }
}

func oneTimeRender(_ parser: @escaping TableCellRender) -> TableCellRender {
    var executed = false
    return { (cell) in
        if !executed {
            parser(cell)
            executed = true
        }
    }
}

extension DetailDataParser {
    func join(_ parser: @escaping () -> TableSectionNode?) -> DetailDataParser {
        return DetailDataParser { inputs in
            if let result = parser() {
                return self.parser(inputs) + [result]
            } else {
                return self.parser(inputs)
            }
        }
    }

    func join(_ parser: @escaping () -> [TableSectionNode]?) -> DetailDataParser {
        return DetailDataParser { inputs in
            if let result = parser() {
                return self.parser(inputs) + result
            } else {
                return self.parser(inputs)
            }
        }
    }
}

infix operator <-: SequencePrecedence

func <-(chain: DetailDataParser, parser: @escaping () -> TableSectionNode?) -> DetailDataParser {
    return chain.join(parser)
}

func <-(chain: DetailDataParser, parser: @escaping () -> [TableSectionNode]?) -> DetailDataParser {
    return chain.join(parser)
}

func pageTypeString(_ houseType: HouseType) -> String {
    switch houseType {
    case .newHouse:
        return "new_detail"
    case .neighborhood:
        return "neighborhood_detail"
    case .secondHandHouse:
        return "old_detail"
    case .rentHouse:
        return "rent_detail"
    default:
        return "be_null"
    }
}

func enterFromByHouseType(houseType: HouseType) -> String {
    switch houseType {
    case .newHouse:
        return "new_detail"
    case .secondHandHouse:
        return "old_detail"
    case .neighborhood:
        return "neighborhood_detail"
    case .rentHouse:
        return "rent_detail"
    default:
        return "be_null"
    }
}

func gethouseTypeSendPhoneFromStr(houseType: HouseType) -> String {
    switch houseType {
    case .newHouse:
        return "app_court"
    case .secondHandHouse:
        return "app_oldhouse"
    case .neighborhood:
        return "app_neighbourhood"
    case .rentHouse:
        return "app_rent"
    default:
        return "be_null"
    }
}

func combineParser(left: @escaping () -> TableSectionNode?, right: @escaping () -> TableSectionNode?) -> () -> [TableSectionNode]? {
    return {
        var result = [TableSectionNode]()
        if let node = left() {
            result.append(node)
        }

        if let node = right() {
            result.append(node)
        }
        return result
    }
}

func parseNodeWrapper(preNode: @escaping () -> [TableSectionNode]?,
                      wrapedNode: @escaping () -> TableSectionNode?) -> () -> [TableSectionNode]? {
    return {
        if let wrapped = wrapedNode() {
            var result = [TableSectionNode]()
            if let node = preNode() {
                result.append(contentsOf: node)
            }
            result.append(wrapped)
            return result
        } else {
            return []
        }
    }
}

func parseNodeWrapper(preNode: @escaping () -> [TableSectionNode]?,
                      wrapedNode: @escaping () -> TableSectionNode?,
                      tailNode: @escaping () -> [TableSectionNode]?) -> () -> [TableSectionNode]? {
    return {
        if let wrapped = wrapedNode() {
            var result = [TableSectionNode]()
            if let node = preNode() {
                result.append(contentsOf: node)
            }
            result.append(wrapped)

            if let node = tailNode() {
                result.append(contentsOf: node)
            }
            return result
        } else {
            return []
        }
    }
}

func parseNodeWrapper(preNode: @escaping () -> [TableSectionNode]?,
                      wrapedNode: @escaping () -> TableSectionNode?,
                      tailNode: @escaping () -> TableSectionNode?) -> () -> [TableSectionNode]? {
    return {
        if let wrapped = wrapedNode() {
            var result = [TableSectionNode]()
            if let node = preNode() {
                result.append(contentsOf: node)
            }
            result.append(wrapped)

            if let node = tailNode() {
                result.append(node)
            }
            return result
        } else {
            return []
        }
    }
}



func parseNodeWrapper(preNode: @escaping () -> TableSectionNode?,
                      wrapedNode: @escaping () -> TableSectionNode?) -> () -> [TableSectionNode]? {
    return {
        if let wrapped = wrapedNode() {
            var result = [TableSectionNode]()
            if let node = preNode() {
                result.append(node)
            }
            result.append(wrapped)
            return result
        } else {
            return []
        }
    }
}

func getStringFromLogPb(key: String, logPb: Any?) -> String {
    if let logPB = logPb as? [String: Any],
        let result = logPB[key] as? String {
        return result
    }
    return "be_null"
}

var getSearchIdFromLogPb = curry(getStringFromLogPb)("search_id")
var getGroupIdFromLogPb = curry(getStringFromLogPb)("group_id")
var getImprIdFromLogPb = curry(getStringFromLogPb)("impr_id")

var searchIdTraceParam:(Any?) -> TracerPremeter = { toTracerParams(getSearchIdFromLogPb($0), key: "search_id") }
var groupIdTraceParam:(Any?) -> TracerPremeter = { toTracerParams(getGroupIdFromLogPb($0), key: "group_id") }
var imprIdTraceParam:(Any?) -> TracerPremeter = { toTracerParams(getImprIdFromLogPb($0), key: "impr_id") }
