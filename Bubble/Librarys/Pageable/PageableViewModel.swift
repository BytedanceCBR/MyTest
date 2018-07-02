//
//  PageableViewModel.swift
//  Calendar
//
//  Created by linlin on 2017/11/20.
//  Copyright © 2017年 Bytedance.Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public typealias PageViewProviderGenerator = () -> PageViewProvider

open class PageableViewModel: NSObject {

    let bufferSize: Int = 1000

    var pageViews: [UIView] = []
    let pageViewProviders: [PageViewProvider]
    var onDateChanged: ((Int) -> Void)?
    public let pageView: UIScrollView

    var currentPage: Int = 0 {
        didSet {
            if !isMute {
                onDateChanged?(currentPage)
            }
        }
    }
    var cacheViewCount = 3

    var isMute = false

    fileprivate var pageFrameObv: NSKeyValueObservation?

    let disposeBag = DisposeBag()

    private var initContentYOffset: CGFloat = -1

    var onPanelViewInited: ((UIView) -> Void)?

    private var hasCallInitFunc = false

    public init(
        cacheViewCount: Int = 3,
        initPageIndex: Int = 0,
        pageViewProviderGenerator: PageViewProviderGenerator) {

        let pageableScrollVIew = UIScrollView()
        pageableScrollVIew.alwaysBounceHorizontal = false
        self.pageView = pageableScrollVIew
        self.cacheViewCount = cacheViewCount
        self.currentPage = initPageIndex
        self.pageViewProviders = PageableViewModel.initPageProviders(
            pageViewProviderGenerator: pageViewProviderGenerator,
            cacheViewCount: cacheViewCount)
        super.init()
        pageFrameObv = pageableScrollVIew.observe(\.bounds, options: [.new, .old]) { [weak self] (view, value) in
            if let old = value.oldValue, let new = value.newValue {
                if !old.size.equalTo(new.size) {
                    self?.onPageLayout()
                }
            }
        }
        loadPage(provider: providerSelector(0))

        DispatchQueue.main.async {
            (1..<self.pageViewProviders.count).forEach({ (index) in
                self.loadPage(provider: self.providerSelector(index))
            })
            //初始化页面逻辑，需要在所有的页面都构造后调用
            self.setPageViewFrame(
                currentPage: self.currentPage,
                pageViewCache: self.pageViews,
                cacheViewCount: self.cacheViewCount)
            self.activateCurrentPage(currentPage: self.currentPage)
            self.reloadPageView(
                currentPage: self.currentPage,
                cacheViewCount: self.cacheViewCount)
            if let defaultView = self.pageViews.first {
                self.pageView.bringSubview(toFront: defaultView)
            }
        }

        self.pageView.isPagingEnabled = true
        self.adjectPageLayoutWhenScrollEnded(pageView: pageView)

    }

    private func loadPage(provider: PageViewProvider) {
        let view = provider.pageView(
            pageableView: self.pageView,
            pageableViewModel: self)
        pageView.addSubview(view)
        pageViews.append(view)
    }

    fileprivate class func initPageProviders(
        pageViewProviderGenerator: PageViewProviderGenerator,
        cacheViewCount: Int) -> [PageViewProvider] {
        return (0...cacheViewCount)
            .map { (_) -> PageViewProvider in
                pageViewProviderGenerator()
            }
    }

    func activateCurrentPage(currentPage: Int) {
        pageViewProviders.forEach { (provider) in
            provider.deActivate()
        }
        providerSelector(currentPage).activate()
    }

    func adjectPageLayoutWhenScrollEnded(pageView: UIScrollView) {
        pageView.rx.didScroll
            .throttle(0.4, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] () in
                self.currentPage = self.currentPageByOffsetSize(contentOffset: pageView.contentOffset)
                self.setPageViewFrame(
                    currentPage: self.currentPage,
                    pageViewCache: self.pageViews,
                    cacheViewCount: self.cacheViewCount)
                    self.activateCurrentPage(currentPage: self.currentPage)
                    self.reloadPageView(
                        currentPage: self.currentPage,
                        cacheViewCount: self.cacheViewCount)

            })
            .disposed(by: disposeBag)
    }

    func onPageLayout() {
        let pageWidth = pageView.frame.size.width
        let contentWidth = pageWidth * (CGFloat(bufferSize) * 2 + 1)
        let offsetPosition = CGFloat(currentPage) * pageWidth + (CGFloat(bufferSize) * pageWidth)
        pageView.contentSize = CGSize(width: contentWidth, height: pageView.frame.size.height)
        pageView.contentOffset = CGPoint(x: offsetPosition, y: 0)
        if !hasCallInitFunc && onPanelViewInited != nil {
            pageViews.forEach { (view) in
                onPanelViewInited?(view)
            }
        }
        setPageViewFrame(
            currentPage: currentPage,
            pageViewCache: pageViews,
            cacheViewCount: cacheViewCount)
    }

    func setPageViewFrame(
        currentPage: Int,
        pageViewCache: [UIView],
        cacheViewCount: Int) {
        _ = rangeOfWholePageViewsIndex(
            currentPage: currentPage,
            halfOfBgViewCount: halfOfBgViewCount(cacheViewCount: cacheViewCount))
            .map { ($0, pageViewSelector(
                selectedPageIndex: $0,
                pageViewCache: pageViewCache,
                cacheViewCount: cacheViewCount))
            }
            .map(setPageViewFrame)
    }

    func reloadPageView(
        currentPage: Int,
        cacheViewCount: Int) {

        rangeOfWholePageViewsIndex(
            currentPage: currentPage,
            halfOfBgViewCount: halfOfBgViewCount(cacheViewCount: cacheViewCount))
            .forEach { (offset) in
                let provider = providerSelector(offset)
                if offset == currentPage {
                    provider.reloadData(by: offset, forceUpdate: false)
                } else {
                    DispatchQueue.main.async {
                        provider.reloadData(by: offset, forceUpdate: false)
                    }
                }
            }
    }

    func setPageViewFrame(pageEntry: (Int, UIView?)) -> (Int, UIView?) {
        let (pageIndex, view) = pageEntry
        view?.frame = pageFrameOfIndex(
            pageIndex: pageIndex,
            pageWidth: pageView.frame.width,
            pageHeight: pageView.frame.height)
        return pageEntry
    }

    func isOffsetAtCurrentPage() -> Bool {
        let frame = pageFrameOfIndex(pageIndex: 0, pageWidth: pageView.frame.size.width, pageHeight: pageView.frame.height)
        return pageView.contentOffset.x == frame.minX
    }

    func halfOfBgViewCount(cacheViewCount: Int) -> Int {
        return (cacheViewCount - 1) / 2
    }

    func rangeOfWholePageViewsIndex(currentPage: Int, halfOfBgViewCount: Int) -> [Int] {
        var result = [currentPage]
        for i in (1...halfOfBgViewCount) {
            result.append(currentPage + i)
            result.append(currentPage - i)
        }
        return result
    }

    func pageViewProviderSelector(
        selectedPageIndex: Int,
        pageViewCache: [UIView],
        cacheViewCount: Int) -> PageViewProvider {

        let selectedIndex = (selectedPageIndex + bufferSize) % cacheViewCount
        if selectedIndex > cacheViewCount - 1 {
            assertionFailure("选择视图错误")
        }
        return pageViewProviders[selectedIndex + 1]
    }

    var providerSelector: (Int) -> PageViewProvider {
        return { [unowned self] in
            self.pageViewProviderSelector(
                selectedPageIndex: $0,
                pageViewCache: self.pageViews,
                cacheViewCount: self.cacheViewCount)
        }
    }

    func pageViewSelector(
        selectedPageIndex: Int,
        pageViewCache: [UIView],
        cacheViewCount: Int) -> UIView? {
        let selectedIndex = catulatePageOffsetByIndex(index: selectedPageIndex)
        if pageViewCache.count <= selectedIndex + 1 {
            return nil
        } else {
            return pageViewCache[selectedIndex + 1]
        }
    }

    private func catulatePageOffsetByIndex(index: Int) -> Int {
        if index == 0 {
            return 0
        } else {
            let selectedIndex = (index + bufferSize) % cacheViewCount
            if selectedIndex > cacheViewCount - 1 {
                assertionFailure("选择视图错误")
            }
            return selectedIndex
        }
    }

    func pageIndexBy(offset: Int) -> Int {
        if offset == 0 {
            return 0
        } else {
            let selectedIndex = (offset + bufferSize) % cacheViewCount
            if selectedIndex > cacheViewCount {
                assertionFailure("选择视图错误")
            }
            return selectedIndex + 1
        }
    }

    func pageFrameOfIndex(
        pageIndex: Int,
        pageWidth: CGFloat,
        pageHeight: CGFloat) -> CGRect {
        return CGRect(
            x: pageWidth * CGFloat(pageIndex) + CGFloat(bufferSize) * pageWidth,
            y: 0,
            width: pageWidth,
            height: pageHeight)
    }

    func currentPageByOffsetSize(contentOffset: CGPoint) -> Int {
        if pageView.frame.size.width != 0 {
            let index = (contentOffset.x + pageView.frame.size.width / 2) / pageView.frame.size.width
            return Int(index) - bufferSize
        } else {
            return 0
        }
    }

    func changeToPerviousPage() {
        let frame = pageFrameOfIndex(pageIndex: self.currentPage - 1, pageWidth: pageView.frame.size.width, pageHeight: pageView.frame.height)
        pageView.scrollRectToVisible(frame, animated: true)
        self.currentPage -= 1
    }

    func changeToNextPage() {
        let frame = pageFrameOfIndex(pageIndex: self.currentPage + 1, pageWidth: pageView.frame.size.width, pageHeight: pageView.frame.height)
        pageView.scrollRectToVisible(frame, animated: true)
        self.currentPage += 1
    }

    func changeToFirstPage(animated: Bool = true) {
        let frame = pageFrameOfIndex(pageIndex: 0, pageWidth: pageView.frame.size.width, pageHeight: pageView.frame.height)
        pageView.scrollRectToVisible(frame, animated: animated)
        self.currentPage = 0
    }

    func changeToPageAtIndex(index: Int, animated: Bool = false, onComplete: (() -> Void)? = nil) {
        isMute = true
        let frame = pageFrameOfIndex(pageIndex: index, pageWidth: pageView.frame.size.width, pageHeight: pageView.frame.height)
        UIView.animate(withDuration: 0.1, animations: {
            self.pageView.scrollRectToVisible(frame, animated: false)
            self.currentPage = index
        }) { ( _ ) in
            self.currentPage = self.currentPageByOffsetSize(contentOffset: self.pageView.contentOffset)
            self.setPageViewFrame(
                currentPage: self.currentPage,
                pageViewCache: self.pageViews,
                cacheViewCount: self.cacheViewCount)
            //                DispatchQueue.main.async {
            self.activateCurrentPage(currentPage: self.currentPage)
            self.reloadPageView(
                currentPage: self.currentPage,
                cacheViewCount: self.cacheViewCount)
            onComplete?()
            self.isMute = false
        }
    }

    func reloadData(currentPageOnly: Bool) {
        if currentPageOnly == false {
            pageViewProviders.forEach({ (provider) in
                provider.reloadData()
            })
        } else {
            pageViewProviders
                .first(where: { (provider) -> Bool in
                    provider.isActivite
                })?
                .reloadData()
        }
    }

    private func reset() {

    }

    deinit {
        if pageView.superview != nil {
            pageView.subviews.forEach { $0.removeFromSuperview() }
            pageView.removeFromSuperview()
        }
    }
}

public protocol PageViewProvider: class {

    var isActivite: Bool { get }

    var index: Int { get set }

    var pageableViewModel: PageableViewModel? { get set }

    func pageView(
        pageableView: UIScrollView,
        pageableViewModel: PageableViewModel) -> UIView

    func reloadData(by index: Int, forceUpdate: Bool)

    func reloadData()

    /// 当前page在屏幕中时被调用
    func activate()

    func deActivate()
}
