//
//  CategoryListDataSource.swift
//  Bubble
//
//  Created by linlin on 2018/6/25.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class CategoryListDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    var datas: [HouseItemInnerEntity] = []

//    func numberOfSections(in tableView: UITableView) -> Int {
//        return datas.count
//    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item")
        cell?.selectionStyle = .none
        if let theCell = cell as? SingleImageInfoCell {
            fillHouseItemToCell(theCell, item: datas[indexPath.row])
        }
        return cell ?? UITableViewCell()
    }

    func onDataArrived(datas: [HouseItemInnerEntity]) {
        self.datas = datas
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
