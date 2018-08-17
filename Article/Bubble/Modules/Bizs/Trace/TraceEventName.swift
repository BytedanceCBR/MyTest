//
//  TraceEventName.swift
//  News
//
//  Created by 张静 on 2018/8/13.
//

import UIKit

class TraceEventName: NSObject {
    @objc
    static let click_minetab: String = "click_minetab" // 我的tab点击子页面

    static let enter_category = "enter_category" // 进入列表页

    static let stay_category = "stay_category" //停留时间

    static let category_refresh = "category_refresh" //刷新数据

    static let stay_tab = "stay_tab"

    @objc
    static let enter_tab = "enter_tab" // 进入tab

    static let go_detail = "go_detail" // 我的tab详情页

    static let delete_follow = "delete_follow" // 删除关注/取消关注

    static let element_show = "element_show"

    @objc
    static let login_page = "login_page" // 进入登录页

    static let click_verifycode = "click_verifycode" // 登录页点击获取验证码

    static let click_login = "click_login" // 进入登录页

    static let inform_show = "inform_show" // 变价通知、开盘通知弹窗

}
