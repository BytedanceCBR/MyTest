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
    
    var isHaveData: Bool!
    
    var reuestRetryText: String!    //重试文本
    
    var reuestRetryImage: String!   //重试icon图片
    
    var requestNilDataText: String! //空数据文本
    
    var requestNilDataImage: String!//空数据icon图片
    
    var requestErrorText: String!   //请求错误文本
    
    var requestErrorImage: String!  //请求错误icon图片
    
    var toastErrorText : String!    //弹出toast文本

    let disposeBag = DisposeBag()
    
    
    /**
     初始化，根据需要选择是否自定义参数
     - Parameters:
     - reuestRetryText:重试文本
     - reuestRetryImage:重试icon图片
     - requestNilDataText:空数据文本
     - requestNilDataImage:空数据icon图片
     - requestErrorText:请求错误文本
     - requestErrorImage:请求错误icon图片
     **/
    init(errorMask: EmptyMaskView,
         reuestRetryText:String = "网络不给力，点击屏幕重试",
         reuestRetryImage:String = "group-9",
         requestNilDataText:String = "数据走丢了",
         requestNilDataImage:String = "empty_message",
         requestErrorText:String = "网络错误",
         requestErrorImage:String = "empty_message",
         toastErrorText:String = "网络异常")
    {
        self.isHaveData = false
        self.errorMask = errorMask
        self.reuestRetryText = reuestRetryText
        self.reuestRetryImage = reuestRetryImage
        self.requestNilDataText = requestNilDataText
        self.requestNilDataImage = requestNilDataImage
        self.requestErrorText = requestErrorText
        self.requestErrorImage = requestErrorImage
        self.toastErrorText = toastErrorText
    }
    //网络状态判断
    private func invalidNetwork() -> Bool
    {
        return EnvContext.shared.client.reachability.connection == .none
    }
    //默认初始状态
    private func resetState()
    {
        self.errorMask.isHidden = false
        self.errorMask.label.text = self.reuestRetryText
        self.errorMask.icon.image = UIImage(named:self.reuestRetryImage)
    }
    //VC页面加载调用，请求之前判断网络状态
    func onRequestViewDidLoad()
    {
        if invalidNetwork() {
            self.resetState()
        }
    }
    //无网络状态
    func onRequestInvalidNetWork()
    {
        if self.invalidNetwork()
        {
            self.resetState()
        }else
        {
            self.errorMask.isHidden = true
        }
    }
    //请求错误，包括404，500，timeout等
    func onRequestError(error: Error?) {
        self.errorMask.label.text = self.requestErrorText
        if self.invalidNetwork()
        {
            self.errorMask.isHidden = false
            self.errorMask.label.text = self.requestErrorText
            self.errorMask.icon.image = UIImage(named:self.requestErrorImage)
        }
    }
    
    //网络正常，无数据状态
    func onRequestNilData() {
        self.isHaveData = false
        self.errorMask.label.text = self.requestNilDataText
        self.errorMask.icon.image = UIImage(named:self.requestNilDataImage)
    }
    //请求刷新，下拉，分类重选等操作
    func onRequestRefreshData(){
        if(self.isHaveData)
        {
            self.errorMask.isHidden = true
            EnvContext.shared.toast.showToast(self.toastErrorText)
        }else
        {
           self.resetState()
        }
    }
    //数据正常
    func onRequestNormalData() {
        self.isHaveData = true
        self.errorMask.isHidden = true
    }
    
}
