//
//  File.swift
//  Article
//
//  Created by leo on 2018/10/10.
//

import RxSwift
import RxCocoa

class FollowUpViewModel {

    var disposeBag = DisposeBag()

    var loginDelegate: NIHLoginVCDelegate?

    func followIt(
        houseType: HouseType,
        followAction: FollowActionType,
        followId: String,
        disposeBag: DisposeBag,
        statusBehavior: BehaviorRelay<Bool>,
        isNeedRecord: Bool = true) -> () -> Void {
        return {
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
                        NotificationCenter.default.post(name: .followUpDidChange, object: nil)
                        statusBehavior.accept(true)
                    } else {
//                        self?.followStatus.accept(.success(false))
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
        statusBehavior: BehaviorRelay<Bool>,
        disposeBag: DisposeBag) -> () -> Void {
        return {
            requestCancelFollow(
                houseType: houseType,
                followId: followId,
                actionType: followAction)
                .subscribe(onNext: { response in
                    if response?.status ?? 1 == 0 {
                        EnvContext.shared.toast.dismissToast()
                        statusBehavior.accept(false)
                        EnvContext.shared.toast.showToast("取关成功")
                        NotificationCenter.default.post(name: .followUpDidChange, object: nil)
                    } else {
                        assertionFailure()
                    }
                }, onError: { error in
                    EnvContext.shared.toast.showToast("取消关注失败")
                })
                .disposed(by: disposeBag)
        }
    }

    fileprivate func displayLogin(onLoginSuccess: @escaping () -> Void) {
        let loginDelegate = NIHLoginVCDelegate {
            onLoginSuccess()
        }
        self.loginDelegate = loginDelegate
        let userInfo = TTRouteUserInfo(info: ["delegate": loginDelegate])
        TTRoute.shared().openURL(byPushViewController: URL(string: "fschema://flogin"), userInfo: userInfo)
    }

    func followThisItem(
        isFollowUpOrCancel: Bool,
        houseId: Int,
        statusBehavior: BehaviorRelay<Bool>) {
        if EnvContext.shared.client.accountConfig.userInfo.value == nil {
            displayLogin(onLoginSuccess: { [unowned self] in
                if isFollowUpOrCancel {
                    self.followIt(
                        houseType: .newHouse,
                        followAction: .newHouse,
                        followId: "\(houseId)",
                        disposeBag: self.disposeBag,
                        statusBehavior: statusBehavior,
                        isNeedRecord: false)()
                } else {
                    self.cancelFollowIt(
                        houseType: .newHouse,
                        followAction: .newHouse,
                        followId: "\(houseId)",
                        statusBehavior: statusBehavior,
                        disposeBag: self.disposeBag)()
                }
            })
        } else {
            if isFollowUpOrCancel {
                followIt(
                    houseType: .newHouse,
                    followAction: .newHouse,
                    followId: "\(houseId)",
                    disposeBag: disposeBag,
                    statusBehavior: statusBehavior,
                    isNeedRecord: false)()
            } else {
                cancelFollowIt(
                    houseType: .newHouse,
                    followAction: .newHouse,
                    followId: "\(houseId)",
                    statusBehavior: statusBehavior,
                    disposeBag: disposeBag)()
            }
        }

    }

}

