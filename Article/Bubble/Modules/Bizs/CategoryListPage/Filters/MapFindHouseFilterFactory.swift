//
//  MapFindHouseFilterFactory.swift
//  NewsLite
//
//  Created by leo on 2018/10/25.
//

import Foundation

@objc class MapFindHouseFilterFactory: NSObject {
    @objc func createFilterPanelViewModel() -> HouseFilterViewModel {
        return HouseFilterViewModel()
    }
}

@objc protocol HouseFilterViewModelDelegate: NSObjectProtocol {
    func onConditionChanged(condition: String)
}

@objc class HouseFilterViewModel: NSObject {

    @objc weak var delegate: HouseFilterViewModelDelegate?

    // 搜索过滤器展现面版
    @objc lazy var filterPanelView: UIView = {
        let re = UIView()
        re.backgroundColor = UIColor.blue
        return re
    }()


    /// 用户设置条件的面版
    @objc lazy var filterConditionPanel: UIControl = {
        let re = UIControl()
        re.backgroundColor = UIColor.blue
        re.isHidden = true
        return re
    }()

}
