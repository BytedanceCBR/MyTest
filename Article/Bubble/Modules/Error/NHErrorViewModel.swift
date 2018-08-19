//
//  NHErrorViewModel.swift
//  NewsInHouse
//
//  Created by 谢飞 on 2018/8/19.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa
import Reachability

enum ErrorType: Int {
    case noneDataRetry = 1
    case haveDataError = 2
    case requestNoData = 3
}

class NHErrorViewModel: NSObject {
    weak var errorMask: EmptyMaskView!
    
    var noneDataRetryText = "网络不给力，点击屏幕重试"
    
//    var isHaveData = false
    
    let disposeBag = DisposeBag()

    init(errorMask: EmptyMaskView)
    {
        self.errorMask = errorMask;
    }
    
    init(errorMask: EmptyMaskView,noneDataRetryText:NSString)
    {
        self.noneDataRetryText = noneDataRetryText as String
        self.errorMask = errorMask;
    }
    
    init(errorMask: EmptyMaskView,
         noneDataRetryText:NSString = "",
         requestNoDataText:NSString = "",
         requestNoDataImage:NSString = "")
    {
        self.errorMask = errorMask;
    }
    
    func checkNetWorkForType(error:ErrorType!) {
        if EnvContext.shared.client.reachability.connection == .none {
            switch error {
            case .noneDataRetry:
                self.errorMask.label.text = self.noneDataRetryText
            case .haveDataError:
                self.errorMask.label.text = "没有找到相关的信息，换个条件试试吧~"
            case .requestNoData:
                self.errorMask.label.text = "数据走丢了"
            default:
                break
            }
//        Reachability.rx.isReachable
//            .bind { [unowned self] reachable in
//                if !reachable {
//                    self.errorMask?.label.text = "xxxxxx"
//                } else {
//
//                }
//            }
//            .disposed(by: disposeBag)
        }
    }
    
    private func invalidNetwork() -> Bool
    {
        return EnvContext.shared.client.reachability.connection == .none
    }
    
    func onRequestInvalidNetWork()
    {
        if self.invalidNetwork()
        {
            
        }
    }
    
    func onRequestError(error: Error?) {
        
    }
    
    func onRequestNilData() {
        
    }
    
    func onRequestRefreshData(){
        
    }
    
    func onRequestNormalData() {
        
    }
    
}
