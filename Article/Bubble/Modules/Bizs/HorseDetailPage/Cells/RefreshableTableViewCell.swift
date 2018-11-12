//
//  RefreshableTableViewCell.swift
//  Article
//
//  Created by 张元科 on 2018/11/12.
//

import Foundation

typealias CellRefreshCallback = () -> Void

protocol RefreshableTableViewCell {
    
    var refreshCallback: CellRefreshCallback? { get set }
    
    func refreshCell()
    
}

extension RefreshableTableViewCell {
    func refreshCell() {
        refreshCallback?()
    }
}
