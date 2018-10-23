//
//  FHCellProtocol.swift
//  listViewContainer
//
//  Created by 张静 on 2018/9/11.
//  Copyright © 2018年 FHouse. All rights reserved.
//

import Foundation

let FHDefaultCellID = "FHDefaultCellID"

@objc protocol FHCellProtocol: class {
    
    /*
     *     如果未设置则返回default
     */
    var fhCellID: String { get set }
    /**
     如果未设置则返回default
     */
    var fhCellHeight: CGFloat { get set }
    /**
     如果未设置则返回default
     */
    var fhSectionHeaderHeight: CGFloat { get set }

    var fhIndexPath: IndexPath? { get set }

    var fhHeaderSection: Int { get set }

}

class FHCellModel: NSObject, FHCellProtocol {
    
    var fhCellID: String = FHDefaultCellID
    
    var fhCellHeight: CGFloat = 0
    
    var fhSectionHeaderHeight: CGFloat = 0
    
    var fhIndexPath: IndexPath?
    
    var fhHeaderSection: Int = 0
    

    override init() {
        
        super.init()
    }
    
    
}



extension FHCellProtocol {
    
    
    
}
