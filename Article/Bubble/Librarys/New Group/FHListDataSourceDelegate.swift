//
//  FHListDataSourceDelegate.swift
//  listViewContainer
//
//  Created by 张静 on 2018/9/11.
//  Copyright © 2018年 FHouse. All rights reserved.
//

import UIKit

class FHListDataSourceDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var fhSections: [[FHCellModel]] = []
    var fhHeaderSections: [AnyObject] = []
    var datas: [TableSectionNode] = []

    weak var fhTableView: UITableView?

    var showCells: [IndexPath] = []

    init(tableView: UITableView, datasV: [TableSectionNode]? = []) {
        super.init()

        self.fhTableView = tableView
        if #available(iOS 11.0, *) {
            tableView.estimatedRowHeight = 0
            tableView.estimatedSectionHeaderHeight = 0
            tableView.estimatedSectionFooterHeight = 0
            
        }
        
        self.fhSections = []
        self.fhHeaderSections = []
        self.datas = datasV ?? []
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return fhSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section >= fhSections.count {
            return 0
        }
        
        return fhSections[section].count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if !tableView.fd_indexPathHeightCache.existsHeight(at: indexPath) {
            var cellModel : FHCellModel?

            tableView.fd_heightForCell(withIdentifier: identifierByIndexPath(indexPath), cacheBy: indexPath) { [unowned self] (cell) in

                if indexPath.section < self.fhSections.count {
                    let aSection = self.fhSections[indexPath.section]
                    if indexPath.row < aSection.count {
                       cellModel = aSection[indexPath.row]
                    }
                }
                
                if let cell = cell as? UITableViewCell {
                    self.fillCellData(cell: cell, indexPath: indexPath, model: cellModel)
                } else {
                    assertionFailure()
                }

            }

        }
        return tableView.fd_indexPathHeightCache.height(for: indexPath)
    }
    
    func keyByIndexPath(_ indexPath: IndexPath) -> String {
        return "\(indexPath.section)-\(indexPath.row)"
    }
    
    func identifierByIndexPath(_ indexPath: IndexPath) -> String {
        if indexPath.section >= fhSections.count {
            return FHDefaultCellID
        }
        
        let aSection = fhSections[indexPath.section]
        if indexPath.row >= aSection.count {
            return FHDefaultCellID
        }
        let cellModel = aSection[indexPath.row]
        return cellModel.fhCellID
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section >= fhSections.count {
            let cell = UITableViewCell(style: .default, reuseIdentifier: FHDefaultCellID)
            return cell
        }
        
        let aSection = fhSections[indexPath.section]
        if indexPath.row >= aSection.count {
            let cell = UITableViewCell(style: .default, reuseIdentifier: FHDefaultCellID)
            return cell
        }
        let cellModel = aSection[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: cellModel.fhCellID)
        if cell == nil {
            
            cell = UITableViewCell(style: .default, reuseIdentifier: cellModel.fhCellID)
//            print("cellID:\(cellModel.fhCellID)对应的Cell未注册，将返回默认cell")
            
        }
        cellModel.fhIndexPath = indexPath
        cell?.selectionStyle = .none
//        cell?.fillData(cellModel)
        if let cell = cell {
            self.fillCellData(cell: cell, indexPath: indexPath, model: cellModel)
        }

        
        return cell ?? UITableViewCell(style: .default, reuseIdentifier: FHDefaultCellID)
        
    }
    
    func fillCellData(cell: UITableViewCell, indexPath: IndexPath, model: Any?) {
        if let model = model as? FHCellModel {
            cell.fillData(model)
        }
    }
    
    //    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    //        print("scrollViewDidEndDecelerating")
    //        if let visibleCells = fhTableView?.visibleCells {
    //
    //            visibleCells.forEach { (cell) in
    //
    //                if let indexPath = fhTableView?.indexPath(for: cell),!showCells.contains(indexPath) {
    //                    print("visibleCell-\(indexPath)")
    //                    showCells.append(indexPath)
    //                }
    //
    //            }
    //        }
    //    }
    
    //    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    //
    //        print("scrollViewDidEndDragging")
    //        if let visibleCells = fhTableView?.visibleCells {
    //
    //            visibleCells.forEach { (cell) in
    //
    //                if let indexPath = fhTableView?.indexPath(for: cell),!showCells.contains(indexPath) {
    //                    print("visibleCell-\(indexPath)")
    //                    showCells.append(indexPath)
    //                }
    //
    //            }
    //        }
    //    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude

    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    

}


