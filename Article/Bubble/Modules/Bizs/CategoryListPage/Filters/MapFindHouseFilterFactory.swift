//
//  MapFindHouseFilterFactory.swift
//  NewsLite
//
//  Created by leo on 2018/10/25.
//

import Foundation

class MapFindHouseFilterFactory: NSObject {
    func createFilterPanel() -> HouseFilterViewModel {
        return HouseFilterViewModel()
    }
}

protocol HouseFilterViewModelDelegate: NSObjectProtocol {
    func onConditionChanged(condition: String)
}

class HouseFilterViewModel: NSObject {

    weak var delegate: HouseFilterViewModelDelegate?

    // 搜索过滤器展现面版
    lazy var filterPanelView: UIView = {
        let re = UIView()
        re.backgroundColor = UIColor.blue
        return re
    }()


    /// 用户设置条件的面版
    lazy var filterConditionPanel: UIView = {
        let re = UIView()
        re.backgroundColor = UIColor.blue
        return re
    }()

}
