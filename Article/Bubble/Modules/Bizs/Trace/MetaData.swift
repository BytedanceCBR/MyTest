//
// Created by leo on 2018/8/13.
//

import Foundation

enum TabName: String {
    case main
    case feed
    case message
    case mine
}

enum HouseCategory: String {
    case new_list
    case old_list
    case neighborhood_list
    case same_neighborhood_list
    case neighborhood_nearby_list
    case neighborhood_trade_list
    case house_model_list
}

enum EnterFrom: String {
    case maintab
    case new_detail
    case old_detail
    case neighborhood_detail
}

enum EnterType: String {
    case click
}

enum ElementFrom: String {
    case maintab_search
    case maintab_icon
    case maintab_operation
    case maintab_list_loadmore
    case same_neighborhood_loadmore
    case neighborhood_nearby_loadmore
    case house_model_loadmore
    case neighborhood_trade_loadmore
}

enum CardType: String {
    case left_pic
    case slide
}

enum MaintabEntrance: String {
    case search
    case icon
    case operation
    case list
    case list_loadmore
}
