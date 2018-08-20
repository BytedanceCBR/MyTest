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

protocol DetailPageViewModel: class {

    var logPB: Any?  { get set }
    
    var followStatus: BehaviorRelay<Result<Bool>> { get }

    var disposeBag: DisposeBag { get }

    var traceParams: TracerParams { get set }

    var followTraceParams: TracerParams { get set }

    var followPage: BehaviorRelay<String> { get set }

//    var priceChangeFollowStatus: BehaviorRelay<Result<Bool>> { get }
//
//    var openCourtFollowStatus: BehaviorRelay<Result<Bool>> { get }

    var contactPhone: BehaviorRelay<String?> { get }

    var tableView: UITableView? { get set }

    var titleValue: BehaviorRelay<String?> { get }

    func requestData(houseId: Int64)

    func followThisItem()
    
    func bindFollowPage()

}

extension DetailPageViewModel {
    
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
        disposeBag: DisposeBag) -> () -> Void {
        var loginDisposeBag = DisposeBag()
        return { [weak self] in
            let userInfo = EnvContext.shared.client.accountConfig.userInfo

            if userInfo.value == nil {
                userInfo
                    .skip(1)
                    .filter { $0 != nil }
                    .subscribe(onNext: { [weak self] _ in
                        self?.followThisItem()
                        loginDisposeBag = DisposeBag()
                    })
                    .disposed(by: loginDisposeBag)
                
                var userInfo = TTRouteUserInfo()
                if var followTraceParams = self?.followTraceParams {
                    
                    followTraceParams = followTraceParams <|>
                        toTracerParams("follow", key: "enter_type")
                    let paramsMap = followTraceParams.paramsGetter([:])
                    userInfo = TTRouteUserInfo(info: paramsMap)
                    
                }
                
                TTRoute.shared().openURL(byPushViewController: URL(string: "fschema://flogin"), userInfo: userInfo)
                
                return
            }
            
            var tracerParams = EnvContext.shared.homePageParams
            if let followTraceParams = self?.followTraceParams {
                
                let paramsMap = followTraceParams.paramsGetter([:])
                tracerParams = tracerParams <|>
                    toTracerParams(paramsMap["enter_from"] ?? "be_null", key: "page_type")
            }
            tracerParams = tracerParams <|>
                toTracerParams(followId, key: "group_id") <|>
                toTracerParams(self?.logPB ?? [:], key: "log_pb")
            recordEvent(key: TraceEventName.click_follow, params: tracerParams)
            
            requestFollow(
                houseType: houseType,
                followId: followId,
                actionType: followAction)
                .subscribe(onNext: { response in
                    if response?.data?.followStatus ?? 1 == 0 {
                        self?.followStatus.accept(.success(true))
                        EnvContext.shared.toast.showToast("关注成功")
                    }
                }, onError: { error in
                    
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

            let userInfo = EnvContext.shared.client.accountConfig.userInfo

            if userInfo.value == nil {
                userInfo
                    .skip(1)
                    .filter { $0 != nil }
                    .subscribe(onNext: { [weak self] _ in
                        self?.followThisItem()
                        loginDisposeBag = DisposeBag()
                    })
                    .disposed(by: loginDisposeBag)

                TTRoute.shared().openURL(byPushViewController: URL(string: "fschema://flogin"), userInfo: TTRouteUserInfo())
                
                return
            }
            
            var tracerParams = EnvContext.shared.homePageParams
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
                        if response?.data?.followStatus ?? 1 == 0 {
                            EnvContext.shared.toast.dismissToast()
                            self?.followStatus.accept(.success(false))
                            EnvContext.shared.toast.showToast("取关成功")
                        }
                    }, onError: { error in

                    })
                    .disposed(by: disposeBag)
        }
    }

    func bindBottomView(params: TracerParams) -> FollowUpBottomBarBinder {
        return { [unowned self] (bottomBar) in
            bottomBar.favouriteBtn.rx.tap
                    .bind(onNext: self.followThisItem)
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
                    .bind(to: bottomBar.favouriteBtn.rx.isSelected)
                    .disposed(by: self.disposeBag)

            bottomBar.contactBtn.rx.tap
                .withLatestFrom(self.contactPhone)
                .bind(onNext: { (phone) in
                    let theParams = EnvContext.shared.homePageParams <|>
                        params <|>
                        toTracerParams("call_bottom", key: "element_type")
                    recordEvent(key: "click_call", params: theParams)
                    Utils.telecall(phoneNumber: phone)
                })
                .disposed(by: self.disposeBag)
        }
    }

}

typealias TableCellRender = (BaseUITableViewCell) -> Void

typealias NewHouseDetailDataParser = ([TableSectionNode]) -> [TableSectionNode]

typealias TableViewSectionViewGen = (Int) -> UIView?

typealias TableCellSelectedProcess = () -> Void

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

