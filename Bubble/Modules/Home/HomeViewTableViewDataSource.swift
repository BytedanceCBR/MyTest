//
//  HomeViewTableViewDataSource.swift
//  Bubble
//
//  Created by linlin on 2018/6/12.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit

class HomeViewTableViewDataSource: NSObject, UITableViewDataSource {

    var datas: [HouseItemEntity] = []

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

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

    func onDataArrived(datas: [HouseItemEntity]) {
        self.datas = datas
    }
}
