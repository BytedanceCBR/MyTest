//
// Created by linlin on 2018/7/11.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
protocol PageableVC: class {
    var footIndicatorView: LoadingIndicatorView? { get set }

    func setupLoadmoreIndicatorView(tableView: UITableView, disposeBag: DisposeBag)

    func loadMore()

}

extension PageableVC {

    func setupLoadmoreIndicatorView(tableView: UITableView, disposeBag: DisposeBag) {
        tableView.tableFooterView = footIndicatorView
        tableView.rx.didScroll
                .throttle(0.3, latest: false, scheduler: MainScheduler.instance)
                .subscribe(onNext: { [unowned self, unowned tableView] void in
                    if tableView.contentOffset.y > 0 &&
                               tableView.contentSize.height - tableView.frame.height - tableView.contentOffset.y <= 0 &&
                        self.footIndicatorView?.isAnimating ?? false == false {
                        self.footIndicatorView?.startAnimating()
                        self.loadMore()
                    }
                })
                .disposed(by: disposeBag)
    }
}
