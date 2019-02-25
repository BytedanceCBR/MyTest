//
//  MessageEventManager.swift
//  News
//
//  Created by leo on 2018/8/22.
//

import Foundation
import SnapKit
import RxCocoa
import RxSwift
import Reachability

public let kCategroyDefaulHouse = "f_house_news" //定义全局使用频道默认

class MessageEventManager: NSObject {

    var timerDisposable: Disposable?

    var timerCategroyDisposable: Disposable?

    private let disposeBag = DisposeBag()
    
    let messageData = BehaviorRelay<[UserUnreadInnerMsg]>(value: [])

    func setup() {
        EnvContext.shared.client.accountConfig.userInfo
            .subscribe(onNext: { user in

            })
            .disposed(by: disposeBag)
    }

    func startSyncMessage() {
        timerDisposable = Observable<Int>.interval(1800, scheduler: MainScheduler.instance)
                .bind(onNext: { [unowned self] (_) in
                    self.requestMessageData()
        })
        self.requestMessageData()
    }
    
    @objc func startSyncCategoryBadge() {
        
    }

    func stopSyncMessage() {
        if let badgeView = self.messageTab()?.ttBadgeView {
            badgeView.badgeNumber = TTBadgeNumberHidden
        }
        timerDisposable?.dispose()
        timerDisposable = nil
    }
    
    @objc func stopSyncCategoryBadge() {
//        TTCategoryBadgeNumberManager.shared().updateNotifyBadgeNumber(ofCategoryID: kCategroyDefaulHouse, withShow: false)
//        timerCategroyDisposable?.dispose()
//        timerCategroyDisposable = nil
    }
    
    func requestRefreshTip() {
        requestCategroyRefreshTip(query:"")
            .subscribe(onNext: {  (responsed) in
                if let responseData = responsed?.data?.count,responseData > 0 {
                    if let stringCategoryId = TTArticleCategoryManager.currentSelectedCategoryID()          {
                        if stringCategoryId != kCategroyDefaulHouse
                        {
                            TTCategoryBadgeNumberManager.shared().updateNotifyBadgeNumber(ofCategoryID: kCategroyDefaulHouse, withShow: true)
                        }
                    }
                }
                }, onError: {  (error) in
                    
            })
            .disposed(by: disposeBag)
    }
    
    func requestMessageData() {
        requestUserUnread(query:"")
                .subscribe(onNext: { [unowned self] (responsed) in
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
                }, onError: { (error) in

                })
                .disposed(by: disposeBag)
    }
    
    @objc
    fileprivate func messageTab() -> TTTabBarItem? {
        return TTTabBarManager.shared().tabItems.first(where: { $0.identifier == kFHouseMessageTabKey })
    }

    deinit {
        if let timerDisposable = timerDisposable {
            timerDisposable.dispose()
        }
        if let timerCategroyDisposable = timerCategroyDisposable {
            timerCategroyDisposable.dispose()
        }
    }
    
}
