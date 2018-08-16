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
            .skip(1)
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
        return {

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
            requestCancelFollow(
                    houseType: houseType,
                    followId: followId,
                    actionType: followAction)
                    .subscribe(onNext: { response in
                        if response?.data?.followStatus ?? 1 == 0 {
                            EnvContext.shared.toast.dismissToast()
                            self.followStatus.accept(.success(false))
                            EnvContext.shared.toast.showToast("取关成功")
                        }
                    }, onError: { error in

                    })
                    .disposed(by: disposeBag)
        }
    }

    func bindBottomView() -> FollowUpBottomBarBinder {
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
                    .bind(onNext: Utils.telecall)
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

struct TableSectionNode {
    let items: [TableCellRender]
    var selectors: [TableCellSelectedProcess]? = nil
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

