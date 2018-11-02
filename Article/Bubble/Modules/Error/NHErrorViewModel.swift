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
    case normal = 1
    case errorRetry = 2 //显示重试状态
    case errorNoData = 3 //查询数据为空，未找到数据，空数据状态
    case errorHaveDataNoNet = 4 //有数据无网络状态
    case errorRequest = 5 //请求错误（404，500，超时）
}

@objc class NHErrorViewModel: NSObject {
    weak var errorMask: EmptyMaskView!
    
    var isHaveData: Bool?
    
    var requestRetryText: String?    //重试文本
    
    var requestRetryImage: String?  //重试icon图片
    
    var requestNilDataText: String? //空数据文本
    
    var requestNilDataImage: String?//空数据icon图片
    
    var requestErrorText: String?   //请求错误文本
    
    var requestErrorImage: String?  //请求错误icon图片
    
    var toastErrorText : String?   //弹出toast文本
    
    var isViewDidLoad : Bool? //是否是第一次
    
    var isRequestError: Bool?
    
    var isUserInteractionEnabled : Bool? //是否可以点击重试

    let disposeBag = DisposeBag()

    let netState = BehaviorRelay<Bool>(value: true) //显示状态
    
    let errorState = BehaviorRelay<ErrorType>(value:.normal) //错误状态
    
    @objc convenience init(_ errorMask : EmptyMaskView ,
                     retryAction:(() -> Void)? = nil )
    {
        self.init(errorMask: errorMask, retryAction: retryAction)
    }
    
    /**
     初始化，根据需要选择是否自定义参数
     - Parameters:
     - requestRetryText:重试文本
     - requestRetryImage:重试icon图片
     - requestNilDataText:空数据文本
     - requestNilDataImage:空数据icon图片
     - requestErrorText:请求错误文本
     - requestErrorImage:请求错误icon图片
     - isUserClickEnable:是否可以点击重试
     - retryAction:点击回调
     **/
    init(errorMask: EmptyMaskView,
         requestRetryText:String? = "网络不给力",
         requestRetryImage:String? = "group-4",
         requestNilDataText:String? = "数据走丢了",
         requestNilDataImage:String? = "group-8",
         requestErrorText:String? = "网络不给力",
         requestErrorImage:String? = "group-4",
         toastErrorText:String? = "网络异常",
         isUserClickEnable:Bool? = false,
         retryAction:(() -> Void)? = nil)
    {
        self.isHaveData = false
        isViewDidLoad = true
        self.errorMask = errorMask
        self.errorMask.isHidden = true
        self.requestRetryText = requestRetryText
        self.requestRetryImage = requestRetryImage
        self.requestNilDataText = requestNilDataText
        self.requestNilDataImage = requestNilDataImage
        self.requestErrorText = requestErrorText
        self.requestErrorImage = requestErrorImage
        self.toastErrorText = toastErrorText
        self.isUserInteractionEnabled = isUserClickEnable
        
        super.init()
        
        if !(isUserClickEnable ?? false)
        {
            self.errorMask.retryBtn.isHidden = true
        }else
        {
            self.errorMask.retryBtn.isHidden = false
        }
        
        errorMask.tapGesture.rx.event
            .bind {[unowned self] (_) in
                //判断是否允许点击
                if let userClick = self.isUserInteractionEnabled{
                    if self.invalidNetwork() && userClick {
                        // 无网络时直接返回空，不请求
                        EnvContext.shared.toast.showToast("网络异常")
                        return
                    }
                    if self.errorState.value != .errorNoData && userClick
                    {
                        retryAction?()
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    //网络状态判断
    private func invalidNetwork() -> Bool
    {
        return EnvContext.shared.client.reachability.connection == .none
    }
    
   private func checkErrorState(){
        let state = (invalidNetwork(),isHaveData,isViewDidLoad)
        switch state{
        case (true,false,false)://无网络，无数据，不是第一次
            errorState.accept(.errorRetry)
            break
        case (true,false,true)://无网络，无数据，第一次
            errorState.accept(.errorRetry)
            break
        case (true,true,true)://无网络，有数据，第一次
            errorState.accept(.errorHaveDataNoNet)
            break
        case (true,true,false)://无网络，有数据，非第一次
            errorState.accept(.errorHaveDataNoNet)
            break
        case (false,true,true)://有网络，有数据，第一次
            errorState.accept(.normal)
            break
        case (false,false,false)://空数据 有网络，无数据，非第一次
            errorState.accept(.errorNoData)
            break
        case (false,false,true):
            errorState.accept(.normal)
            break
        default:
            errorState.accept(.normal)
        }
       changeState()
    }
    
    //默认初始状态
    private func resetState()
    {
        self.errorMask.isHidden = false
        self.netState.accept(true)
        self.errorMask.label.text = self.requestRetryText
        if let requestRetryImage = self.requestRetryImage{
            self.errorMask.icon.image = UIImage(named:requestRetryImage)
        }
        if errorState.value == .errorRetry && (self.isUserInteractionEnabled ?? false)
        {
            self.errorMask.retryBtn.isUserInteractionEnabled = true
            self.errorMask.retryBtn.isHidden = false
        }
    }
    
    private func changeState()
    {
        switch errorState.value{
        case .errorRetry:
            self.resetState()
        break
        case .errorNoData:
            self.isHaveData = false
            self.errorMask.label.text = self.requestNilDataText
            if let requestNilDataImageV = self.requestNilDataImage
            {
                self.errorMask.icon.image = UIImage(named:requestNilDataImageV)
            }
            
            self.errorMask.isHidden = false
            self.netState.accept(false)
            break
        case .errorHaveDataNoNet:
            self.errorMask.isHidden = true
            if let toastErrorTextV = self.toastErrorText{
                EnvContext.shared.toast.showToast(toastErrorTextV)
            }
            
            if (self.isUserInteractionEnabled ?? false)
            {
                if let requestRetryImage = self.requestRetryImage{
                    self.errorMask.icon.image = UIImage(named:requestRetryImage)
                }
                self.errorMask.retryBtn.isUserInteractionEnabled = true
                self.errorMask.retryBtn.isHidden = false
            }
            break
        case .errorRequest:
            self.errorMask.label.text = self.requestErrorText
            self.errorMask.retryBtn.isHidden = true
            self.netState.accept(true)
            self.errorMask.isHidden = false
            if let requestImageV = self.requestErrorImage{
                self.errorMask.icon.image = UIImage(named:requestImageV)
            }
            isRequestError = true
            break
        case .normal:
            self.errorMask.isHidden = true
            break
        default:
            
        break
        }
    }
    

    //VC页面加载调用，请求之前判断网络状态
    @objc func onRequestViewDidLoad()
    {
        checkErrorState()
        isViewDidLoad = false
    }
    //无网络状态
    @objc func onRequestInvalidNetWork()
    {
        if self.invalidNetwork()
        {
            self.resetState()
        }else
        {
            self.errorMask.isHidden = true
            self.netState.accept(false)
        }
    }
    //请求错误，包括404，500，timeout等
    @objc func onRequestError(error: Error?) {
        self.errorMask.label.text = self.requestErrorText
        self.errorMask.retryBtn.isHidden = true
        self.netState.accept(true)
        self.errorMask.isHidden = false
        if let requestImageV = self.requestErrorImage{
            self.errorMask.icon.image = UIImage(named:requestImageV)
        }
//        errorState.accept(.errorRequest)
        checkErrorState()
        isRequestError = true
    }
    
    //网络正常，无数据状态
    @objc func onRequestNilData() {
        self.isHaveData = false
        self.errorMask.label.text = self.requestNilDataText
        if let requestNilDataImage = self.requestNilDataImage{
            self.errorMask.icon.image = UIImage(named:requestNilDataImage)
        }
        self.errorMask.retryBtn.isHidden = true
        self.errorMask.isHidden = false
        self.netState.accept(false)
        errorState.accept(.errorNoData)
    }
    //请求刷新，下拉，分类重选等操作
    @objc func onRequestRefreshData(){
        checkErrorState()
    }
    //数据正常
    @objc func onRequestNormalData() {
        self.isHaveData = true
        self.errorMask.isHidden = true
        self.netState.accept(false)
    }
    
}

extension NSError {
    
    func errorMessageByErrorCode() -> String {
        
        switch self.code {
        case -106:
            return "网络异常"
        default:
            return self.localizedDescription
        }
        
        
    }
    
}
