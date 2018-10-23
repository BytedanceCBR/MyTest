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
    
    @objc
    static let stay_tab = "stay_tab"

    @objc
    static let enter_tab = "enter_tab" // 进入tab

    @objc
    static let go_detail = "go_detail" // 我的tab详情页

    static let delete_follow = "delete_follow" // 删除关注/取消关注

    static let element_show = "element_show"

    @objc
    static let login_page = "login_page" // 进入登录页

    static let click_verifycode = "click_verifycode" // 登录页点击获取验证码

    static let click_login = "click_login" // 登录页点击登录

    static let inform_show = "inform_show" // 变价通知、开盘通知弹窗

    static let click_confirm = "click_confirm" // (登录状态)变价通知、开盘通知弹窗点击确认

    static let click_follow = "click_follow" // 点击关注
    
    static let picture_show = "picture_show" // 图片展示

    static let picture_save = "picture_save" // 图片保存

    static let picture_gallery = "picture_gallery" // 进入图集

    static let click_switch_maintablist = "click_switch_maintablist" // 首页找房频道切换二手房、新房列表

    static let house_show = "house_show"

    static let picture_gallery_stay = "picture_gallery_stay" // 图集停留时长

    static let picture_large_stay = "picture_large_stay" // 大图页停留时长

    static let click_house_info = "click_house_info" // 点击(更多)楼盘信息

    static let click_house_history = "click_house_history" // 点击楼盘动态

    static let click_house_comment = "click_house_comment" // 点击用户点评

}
