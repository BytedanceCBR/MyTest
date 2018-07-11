//
// Created by linlin on 2018/7/11.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
class HouseCommentViewModel: NSObject, UITableViewDataSource {

    weak var tableView: UITableView?

    let datas: BehaviorRelay<[TableRowNode]> = BehaviorRelay(value: [])

    var pageableLoader: (() -> Void)?

    var onDataLoaded: (() -> Void)?

    private var cellFactory: UITableViewCellFactory

    private let disposeBag = DisposeBag()

    init(tableView: UITableView) {
        self.tableView = tableView
        self.cellFactory = getHouseDetailCellFactory()
        super.init()
        tableView.dataSource = self
        datas
                .subscribe(onNext: { [unowned self] datas in
                    self.onDataLoaded?()
                    self.tableView?.reloadData()
                })
                .disposed(by: disposeBag)
    }
    
    func request(courtId: Int64) {
        let loader = pageRequestNewHouseComment(houseId: courtId, count: 15)
        pageableLoader = { [unowned self] in
            loader()
                    .map { [unowned self] response -> [TableRowNode] in
                        if let data = response?.data {
                            return parseNewHouseCommentNode(data.list ?? [])()
                        } else {
                            return []
                        }
                    }
                .subscribe(onNext: self.datas.accept)
                    .disposed(by:self.disposeBag)
        }
        cleanData()
        pageableLoader?()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func cleanData() {
        self.datas.accept([])
    }
}
