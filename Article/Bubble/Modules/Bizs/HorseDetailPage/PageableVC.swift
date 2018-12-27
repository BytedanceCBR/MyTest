//
// Created by linlin on 2018/7/11.
// Copyright (c) 2018 linlin. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
protocol PageableVC: class {
    
    var hasMore: Bool { get set }

    var tableView: UITableView { get }

    func loadMore()

}

extension PageableVC {

    func setupLoadmoreIndicatorView(tableView: UITableView, disposeBag: DisposeBag) {
        let footer: FHRefreshCustomFooter = FHRefreshCustomFooter { [weak self] in
            self?.loadMore()
        }
        
        tableView.mj_footer = footer
        footer.isHidden = true
    }

    func onDataLoaded() -> (Bool, Int) -> Void {
        return { [weak self] (hasMore, count) in
            self?.hasMore = hasMore
            self?.tableView.mj_footer.isHidden = false
            EnvContext.shared.toast.dismissToast()
            if hasMore == false {
                self?.tableView.mj_footer.endRefreshingWithNoMoreData()
            }else {
                self?.tableView.mj_footer.endRefreshing()
            }
        }
    }
}
