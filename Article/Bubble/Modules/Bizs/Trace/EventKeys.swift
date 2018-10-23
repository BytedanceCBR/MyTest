//
//  EventKeys.swift
//  News
//
//  Created by leo on 2018/8/13.
//

import Foundation
class EventKeys {

    static let event_type = "event_type"

    static let category_name = "category_name" //别表页类型

    static let enter_from = "enter_from" // 入口

    static let enter_type = "enter_type" // 点击，划动

    static let element_from = "element_from" // 进入组件

    static let card_type = "card_type" //

    static let filter = "filter" // (筛选条件，同house_filter中的filter：单层json

    static let search = "search" // (搜索条件，同house_search中的search：单层json)

    static let maintab_entrance = "maintab_entrance" // maintab_entrance：(首页入口类型，透传至后续埋点：首页搜索，首页icon，首页运营位，首页列表，首页列表查看更多)[search，icon，operation，list，list_loadmore]

    static let icon_type = "icon_type" // (首页icon进入时，icon类型，透传至后续埋点：二手房，新房，租房，小区)[old，new，rent，neighborhood]

    static let operation_name = "operation_name" // (首页运营位进入时，运营位名，透传至后续埋点)

    static let maintab_search = "maintab_search" // (首页搜索进入时的搜索条件，单层json，同house_search埋点的search，透传至后续埋点)

}
