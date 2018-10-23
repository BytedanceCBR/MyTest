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

extension Notification.Name {
    static let followUpDidChange = Notification.Name("follow_up_did_changed")
}


protocol DetailPageViewModel: class {

    var logPB: Any?  { get set }
    
    var searchId: String? { get set }

    var shareInfo: ShareInfo? { get set }
    
    var followStatus: BehaviorRelay<Result<Bool>> { get }

    var disposeBag: DisposeBag { get }

    var traceParams: TracerParams { get set }

    var followTraceParams: TracerParams { get set }

    var followPage: BehaviorRelay<String> { get set }

    var groupId: String { get }

//    var priceChangeFollowStatus: BehaviorRelay<Result<Bool>> { get }
//
//    var openCourtFollowStatus: BehaviorRelay<Result<Bool>> { get }

    var contactPhone: BehaviorRelay<String?> { get }

    var tableView: UITableView? { get set }

    var titleValue: BehaviorRelay<String?> { get }

    var onDataArrived: (() -> Void)? { get set }

    var onNetworkError: ((Error) -> Void)? { get set }

    var onEmptyData: (() -> Void)? { get set }

    func requestData(houseId: Int64, logPB: [String: Any]?, showLoading: Bool)

    func followThisItem(isNeedRecord: Bool)
    
    func bindFollowPage()

    func getShareItem() -> ShareItem

    var showMessageAlert: ((String) -> Void)? { get set }

    var dismissMessageAlert: (() -> Void)? { get set }
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
    
    func followIt(
        houseType: HouseType,
        followAction: FollowActionType,
        followId: String,
        disposeBag: DisposeBag,
        isNeedRecord: Bool = true) -> () -> Void {
        var loginDisposeBag = DisposeBag()
        return { [weak self] in
            
            if isNeedRecord {
                
                var tracerParams = EnvContext.shared.homePageParams
                tracerParams = tracerParams <|>
                    toTracerParams(followId, key: "group_id") <|>
                    toTracerParams(self?.searchId ?? "be_null", key: "search_id") <|>
                    toTracerParams(pageTypeString(houseType), key: "page_type") <|>
                    toTracerParams(self?.logPB ?? [:], key: "log_pb")
                
                if let followTraceParams = self?.followTraceParams {
                    // ugly code 为了埋点，0.2版本pageType只区分新房二手房小区和户型详情页
                    let paramsMap = followTraceParams.paramsGetter([:])
                    let enterFrom = paramsMap["enter_from"] as? String
                    if let theEnterFrom = enterFrom,theEnterFrom == "house_model_detail" {
                        
                        tracerParams = tracerParams <|>
                            toTracerParams(theEnterFrom, key: "page_type")
                    }
                }
                recordEvent(key: TraceEventName.click_follow, params: tracerParams)
                
            }
            if EnvContext.shared.client.reachability.connection == .none {
                EnvContext.shared.toast.showToast("网络异常")
                return
            }
            let userInfo = EnvContext.shared.client.accountConfig.userInfo

//            if userInfo.value == nil {
//                userInfo
//                    .skip(1)
//                    .filter { $0 != nil }
//                    .subscribe(onNext: { [weak self] _ in
//                        self?.followThisItem(isNeedRecord: false)
//                        loginDisposeBag = DisposeBag()
//                    })
//                    .disposed(by: loginDisposeBag)
//                
//                var userInfoParams = TTRouteUserInfo()
//                if var followTraceParams = self?.followTraceParams {
//                    
//                    followTraceParams = followTraceParams <|>
//                        toTracerParams("follow", key: "enter_type")
//                    let paramsMap = followTraceParams.paramsGetter([:])
//                    userInfoParams = TTRouteUserInfo(info: paramsMap)
//                    
//                }
//                
//                TTRoute.shared().openURL(byPushViewController: URL(string: "fschema://flogin"), userInfo: userInfoParams)
//                
//                return
//            }
            
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
            let userInfo = EnvContext.shared.client.accountConfig.userInfo

//            if userInfo.value == nil {
//                userInfo
//                    .skip(1)
//                    .filter { $0 != nil }
//                    .subscribe(onNext: { [weak self] _ in
//                        self?.followThisItem(isNeedRecord: false)
//                        loginDisposeBag = DisposeBag()
//                    })
//                    .disposed(by: loginDisposeBag)
//
//                TTRoute.shared().openURL(byPushViewController: URL(string: "fschema://flogin"), userInfo: TTRouteUserInfo())
//
//                return
//            }
            
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

    func bindBottomView(params: TracerParams) -> FollowUpBottomBarBinder {
        return { [unowned self] (bottomBar, followUpButton) in
            followUpButton.rx.tap
                .bind(onNext: { [weak self] in

                    self?.followThisItem(isNeedRecord: true)
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

            
            self.contactPhone.skip(1).subscribe(onNext: { [weak bottomBar] phone in
                if phone == "" || phone == nil
                {
                    bottomBar?.contactBtn.isUserInteractionEnabled = false
//                    bottomBar?.contactBtn.setTitle("暂无电话", for: .normal)
                    bottomBar?.contactBtn.isHidden = true
                    bottomBar?.snp.makeConstraints{ maker in
                        maker.bottom.equalTo(0)
                        maker.height.equalTo(0)
                    }
                }else
                {
                    bottomBar?.contactBtn.isUserInteractionEnabled = true
                    bottomBar?.contactBtn.setTitle("电话咨询", for: .normal)
                }
            }).disposed(by: self.disposeBag)
        
            
            bottomBar.contactBtn.rx.tap
                .withLatestFrom(self.contactPhone)
                .bind(onNext: {[weak self] (phone) in
                    let theParams = EnvContext.shared.homePageParams <|>
                        params <|>
                        toTracerParams(self?.searchId ?? "be_null", key: "search_id")
                    recordEvent(key: "click_call", params: theParams.exclude("search").exclude("filter"))
                    Utils.telecall(phoneNumber: phone)
                })
                .disposed(by: self.disposeBag)
        }
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
}

infix operator <-: SequencePrecedence

func <-(chain: DetailDataParser, parser: @escaping () -> TableSectionNode?) -> DetailDataParser {
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
    default:
        return "be_null"
    }
}
