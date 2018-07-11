//
// Created by linlin on 2018/7/11.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class HouseCommentViewModel: NSObject, UITableViewDataSource {

    weak var tableView: UITableView?

    let datas: BehaviorRelay<CourtComentResponse?> = BehaviorRelay(value: nil)

    init(tableView: UITableView) {
        self.tableView = tableView
        tableView.dataSource = self
        data
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    }
}