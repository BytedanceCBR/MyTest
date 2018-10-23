//
//  UITableView+FHExts.swift
//  listViewContainer
//
//  Created by 张静 on 2018/9/11.
//  Copyright © 2018年 FHouse. All rights reserved.
//

import Foundation

extension UITableViewCell {
    
    class func cellName() -> String {
        
        return NSStringFromClass(self)
    }
    
    class func registXibTo(_ tableView: UITableView) {
        
        let nib = UINib.init(nibName: cellName(), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellName())
    }
    
    class func registClassTo(_ tableView: UITableView) -> Void {
        
        tableView.register(self, forCellReuseIdentifier: cellName())
    }
    
    @objc func fillData(_ cellModel: FHCellModel) {
        
        
    }
    
}
