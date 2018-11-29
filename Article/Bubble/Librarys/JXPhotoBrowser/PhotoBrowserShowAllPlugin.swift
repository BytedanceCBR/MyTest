//
//  PhotoBrowserShowAllPlugin.swift
//  PhotoBrowser
//
//  Created by 张静 on 2018/8/5.
//  Copyright © 2018年 JiongXing. All rights reserved.
//

import UIKit
import JXPhotoBrowser

class PhotoBrowserShowAllPlugin: PhotoBrowserPlugin {
    
    /// 可指定中心点Y坐标，距离底部值。
    /// 若不指定，默认为20
    open var centerBottomY: CGFloat?
    
    /// 总页码
    open var totalPages = 0
    
    /// 当前页码
    open var currentPage = 0
    
    var didTouchBackButton: (() -> Void)?
    var didTouchShowAllButton: (() -> Void)?

    
    
    open lazy var overlayView: OverlayView = {
        let view = OverlayView()
        view.didTouchBackButton = { [unowned self] in
            self.didTouchBackButton?()
        }
        view.didTouchShowAllButton = { [unowned self] in
            self.didTouchShowAllButton?()
        }
        return view
    }()
    
    class OverlayView: UIView {
        /// 所在 cell 索引
        var index = 0
        
        var didTouchBackButton: (() -> Void)?
        var didTouchShowAllButton: (() -> Void)?


        lazy var backBtn: UIButton = {
            let btn = UIButton(type: .custom)
            btn.setImage(UIImage(named: "icon-return-white"), for: .normal)
            btn.setImage(#imageLiteral(resourceName: "icon-return-white"), for: .highlighted)

            return btn
        }()
        
        /// 按钮
        lazy var showBtn: UIButton = {
            let btn = UIButton(type: .custom)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            btn.setTitleColor(.white, for: .normal)
            btn.setTitle("全部图片", for: .normal)
            return btn
        }()

        lazy var imageNameLabel: UILabel = {
            let re = UILabel()
            re.font = UIFont.systemFont(ofSize: 17)
            re.textColor = .white
            re.isHidden = true
            return re
        }()
        
        init() {
            super.init(frame: .zero)
            addSubview(backBtn)
            addSubview(showBtn)
            addSubview(imageNameLabel)
            backBtn.addTarget(self, action: #selector(onBackButton), for: .touchUpInside)
            showBtn.addTarget(self, action: #selector(onShowAllButton), for: .touchUpInside)

        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            backBtn.sizeToFit()
            backBtn.frame = CGRect(x: 10, y: 0, width: backBtn.bounds.width, height: self.bounds.height)

            let x = self.bounds.width - 20 - showBtn.bounds.width

            showBtn.sizeToFit()
            showBtn.frame = CGRect(x: x, y: 0, width: showBtn.bounds.width, height: self.bounds.height)

            imageNameLabel.frame = CGRect(x: showBtn.frame.maxX + 10,
                                          y: 0,
                                          width: backBtn.frame.minX - 10,
                                          height: self.bounds.height)
        }
        
        @objc private func onBackButton() {
            didTouchBackButton?()
        }
        
        @objc private func onShowAllButton() {
            didTouchShowAllButton?()
        }
        
    }
    

    
    open func photoBrowser(_ photoBrowser: PhotoBrowser, didChangedPageIndex index: Int) {
        currentPage = index
        layout()
    }
    
    open func photoBrowser(_ photoBrowser: PhotoBrowser, numberOfPhotos count: Int) {
        totalPages = count
        layout()
    }
    
    open func photoBrowser(_ photoBrowser: PhotoBrowser, viewDidAppear view: UIView, animated: Bool) {
        // 页面出来后，再显示页码指示器
        // 多于一张图才显示
        if totalPages > 1 {
            view.addSubview(overlayView)
        }
    }
    
    open func photoBrowser(_ photoBrowser: PhotoBrowser, viewDidLayoutSubviews view: UIView) {
        layout()
        overlayView.isHidden = totalPages <= 1
    }
    
    private func layout() {

        overlayView.sizeToFit()
        guard let superView = overlayView.superview else { return }
        
        overlayView.frame = CGRect(x: 0, y: 0, width: superView.bounds.width, height: 64)
        overlayView.center = CGPoint(x: superView.bounds.midX,
                                     y: bottomOffsetY)
    }
    
    private var bottomOffsetY: CGFloat {
        if let bottomY = centerBottomY {
            return bottomY
        }
        guard let superView = overlayView.superview else {
            return 0
        }
        var offsetY: CGFloat = 0
        if #available(iOS 11.0, *) {
            offsetY = superView.safeAreaInsets.top
        }
        return offsetY + 20
    }
}
