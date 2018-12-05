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

    func followIt(
        houseType: HouseType,
        followAction: FollowActionType,
        followId: String,
        disposeBag: DisposeBag,
        statusBehavior: BehaviorRelay<Result<Bool>>,
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
                        statusBehavior.accept(.success(true))
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
        statusBehavior: BehaviorRelay<Result<Bool>>,
        disposeBag: DisposeBag) -> () -> Void {
        return {
            requestCancelFollow(
                houseType: houseType,
                followId: followId,
                actionType: followAction)
                .subscribe(onNext: { response in
                    if response?.status ?? 1 == 0 {
                        EnvContext.shared.toast.dismissToast()
                        statusBehavior.accept(.success(false))
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

    func followThisItem(
        isFollowUpOrCancel: Bool,
        houseId: Int64,
        houseType: HouseType = .secondHandHouse,
        followAction: FollowActionType = .ershouHouse,
        statusBehavior: BehaviorRelay<Result<Bool>>) {
        if isFollowUpOrCancel {
            followIt(
                houseType: houseType,
                followAction: followAction,
                followId: "\(houseId)",
                disposeBag: disposeBag,
                statusBehavior: statusBehavior,
                isNeedRecord: false)()
        } else {
            cancelFollowIt(
                houseType: houseType,
                followAction: followAction,
                followId: "\(houseId)",
                statusBehavior: statusBehavior,
                disposeBag: disposeBag)()
        }
    }

    func followThisItem(
        isFollowUpOrCancel: Bool,
        houseId: Int64,
        houseType: HouseType = .secondHandHouse,
        followAction: FollowActionType = .ershouHouse,
        statusBehavior: BehaviorRelay<Bool>) {
            if isFollowUpOrCancel {
                followIt(
                    houseType: houseType,
                    followAction: followAction,
                    followId: "\(houseId)",
                    disposeBag: disposeBag,
                    statusBehavior: statusBehavior,
                    isNeedRecord: false)()
            } else {
                cancelFollowIt(
                    houseType: houseType,
                    followAction: followAction,
                    followId: "\(houseId)",
                    statusBehavior: statusBehavior,
                    disposeBag: disposeBag)()
            }
    }



    
    // MARK: 静默关注房源
    func followHouseItem(
        houseType: HouseType,
        followAction: FollowActionType,
        followId: String,
        disposeBag: DisposeBag,
        statusBehavior: BehaviorRelay<Bool>? = nil,
        followStateBehavior: BehaviorRelay<Result<Bool>>? = nil,
        isNeedRecord: Bool = true,
        showTip: Bool = false) -> () -> Void {
        
        return {
            
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
                            
                            // add by zjing for test
                            toastCount = 0
                            
                            if toastCount < 3 {
                                
                                var style = fhCommonToastStyle()
                                style.isCustomPosition = true
                                style.customX = UIScreen.main.bounds.size.width - 20
                                style.backgroundColor = hexStringToUIColor(hex: kFHDarkIndigoColor, alpha: 0.6)
                                style.verticalOffset = 40 + (CommonUIStyle.Screen.isIphoneX ? 20 : 0)
                                style.titleFont = CommonUIStyle.Font.pingFangRegular(10)
                                style.cornerRadius = 12
                                style.verticalPadding = 8
                                style.horizontalPadding = 10
                                fhShowToast("已加入关注列表", position: .top)
                                toastCount += 1
                                UserDefaults.standard.set(toastCount, forKey: kFHToastCountKey)
                                UserDefaults.standard.synchronize()
                            }
                        }else if response?.data?.followStatus ?? 0 == 1 {
                            let toastCount =  UserDefaults.standard.integer(forKey: kFHToastCountKey)
                            if toastCount < 3 && showTip {
                                EnvContext.shared.toast.showToast("提交成功")
                            }
                        }
                        NotificationCenter.default.post(name: .followUpDidChange, object: nil)
                        statusBehavior?.accept(true)
                        followStateBehavior?.accept(.success(true))
                    }
                }, onError: { error in
                    EnvContext.shared.toast.showToast("网络异常")
                })
                .disposed(by: disposeBag)
        }
    }

}

