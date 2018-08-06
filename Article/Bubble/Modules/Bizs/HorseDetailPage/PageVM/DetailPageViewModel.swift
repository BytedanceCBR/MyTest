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

//    var priceChangeFollowStatus: BehaviorRelay<Result<Bool>> { get }
//
//    var openCourtFollowStatus: BehaviorRelay<Result<Bool>> { get }

    var contactPhone: BehaviorRelay<String?> { get }

    var tableView: UITableView? { get set }

    var titleValue: BehaviorRelay<String?> { get }

    func requestData(houseId: Int64)

    func followThisItem()

}

extension DetailPageViewModel {

    func followIt(
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
                TTAccountManager.presentQuickLogin(fromVC: EnvContext.shared.rootNavController, type: TTAccountLoginDialogTitleType.default, source: "", completion: { (state) in

                })
                return
            }
            requestFollow(
                houseType: houseType,
                followId: followId,
                actionType: followAction)
                .subscribe(onNext: { response in
                    if response?.data?.followStatus ?? 1 == 0 {
                        self.followStatus.accept(.success(true))
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
                TTAccountManager.presentQuickLogin(fromVC: EnvContext.shared.rootNavController, type: TTAccountLoginDialogTitleType.default, source: "", completion: { (state) in

                })
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

