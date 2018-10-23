//
//  HomeViewTableViewDataSource.swift
//  Bubble
//
//  Created by linlin on 2018/6/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class HomeViewTableViewDataSource: NSObject, UITableViewDataSource {

    var datas: [HouseRecommendSection] = []

    func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "item")
        cell?.selectionStyle = .none
        if let theCell = cell as? SingleImageInfoCell {
            if let item = datas[indexPath.section].items?[indexPath.row] {
                let count = datas[indexPath.section].items?.count ?? 0
                fillHouseItemToCell(theCell,isLastCell: indexPath.row == count - 1, item: item)
            }
        }
        return cell ?? UITableViewCell()
    }

    func onDataArrived(datas: [HouseRecommendSection]) {
        self.datas = datas
    }
}
