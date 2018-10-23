//
//  SlidePageView.swift
//  Bubble
//
//  Created by linlin on 2018/6/13.
//  Copyright © 2018年 linlin. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SlidePageView: MarqueeGroupView {


    init() {
        super.init(frame: CGRect.zero)

        self.isPagingEnabled = true
        self.bounces = false
        self.showsHorizontalScrollIndicator = false

    }

    override func loadData() {
        super.loadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func qubeSize() -> CGSize {
        return self.bounds.size
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

fileprivate class CarouselControl {

    private var totalPage: Int
    private var currentPage: Int
    private var frequency: Int
    private var timer: Timer?
    private var index: Int

    var changePageTo: ((Int) -> Void)?

    init(
            totalPage: Int,
            currentPage: Int = 0,
            frequency: Int = 3) {
        self.totalPage = totalPage
        self.currentPage = currentPage
        self.frequency = frequency
        self.index = currentPage
        assert(currentPage < totalPage)
    }

    func start() {
        if timer == nil {
            let theTimer = Timer.scheduledTimer(
                    timeInterval: TimeInterval(frequency),
                    target: self,
                    selector: #selector(fire),
                    userInfo: nil,
                    repeats: true)
            RunLoop.main.add(theTimer, forMode: .commonModes)
            timer = theTimer
            theTimer.fireDate = Date() + 1
        }
    }

    func resetCurrentPage(index: Int) {
        currentPage = index
        self.index = currentPage
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    @objc
    public func fire() {
        index += 1
        let nextPage = index % totalPage
        changePageTo?(nextPage)
        currentPage = nextPage
    }

}

class SlidePageViewPanel: UIView {

    lazy var pageControl: UIPageControl = {
        UIPageControl()
    }()

    lazy var slidePageView: SlidePageView = {
        SlidePageView()
    }()

    fileprivate var carouselControl: CarouselControl?

    let disposeBag = DisposeBag()

    init() {
        super.init(frame: CGRect.zero)
        addSubview(slidePageView)
        slidePageView.snp.makeConstraints { maker in
            maker.top.bottom.left.right.equalToSuperview()
        }
        addSubview(pageControl)
        pageControl.snp.makeConstraints { maker in
            maker.bottom.centerX.equalToSuperview()
            maker.width.equalTo(200)
            maker.height.equalTo(20)
        }
        slidePageView.rx.didEndDecelerating
                .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
                .subscribe(onNext: self.onPageDidScrollByUser())
                .disposed(by: disposeBag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startCarousel() {
        if carouselControl == nil {
            let theCarouselControl = CarouselControl(totalPage: self.slidePageView.count())
            theCarouselControl.start()
            carouselControl = theCarouselControl
            theCarouselControl.changePageTo = { [weak self] (index) in
                self?.changeSlidePage(index)
            }
        }
        pageControl.numberOfPages = slidePageView.count()
    }

    func changeSlidePage(_ index: Int) {
        let size = slidePageView.bounds.size
        let toArea = CGRect(x: CGFloat(index) * size.width, y: 0, width: size.width, height: size.height)
        slidePageView.scrollRectToVisible(toArea, animated: true)
        pageControl.currentPage = index
    }

    func onPageDidScrollByUser() -> () -> Void {
        return { [unowned self] in
            let contentOffset = self.slidePageView.contentOffset
            let pageSize = self.slidePageView.bounds.size
            let index = Int(contentOffset.x / pageSize.width)
            self.pageControl.currentPage = index
            self.carouselControl?.resetCurrentPage(index: index)
        }
    }

    deinit {
        carouselControl?.stop()
    }

}
