//
//  FHMainListTopView.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/8.
//

#import "FHMainListTopView.h"
#import <TTUIWidget/ArticleListNotifyBarView.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/FHFakeInputNavbar.h>

#define NOTIFY_HEIGHT 32

@interface FHMainListTopView ()

@property(nonatomic , strong) UIView *bannerView;
@property(nonatomic , strong) UIView *filterView;
@property(nonatomic , strong) UIView *filterBgView;
@property(nonatomic , strong) UIView *filterBarView;
@property(nonatomic , strong) UIView *filterTagsView;
@property(nonatomic , strong) ArticleListNotifyBarView *notifyBarView;
@property(nonatomic , strong) UIView       *theBottomView;
@property(nonatomic , strong) CAShapeLayer *maskLayer;
@end

@implementation FHMainListTopView

- (UIView *)filterBgView
{
    if (!_filterBgView) {
        _filterBgView = [[UIView alloc]init];
    }
    return _filterBgView;
}

-(instancetype)initWithBannerView:(UIView *)bannerView filterView:(UIView *)filterView filterTagsView:(UIView *)filterTagsView 
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.bannerView = bannerView;
        self.filterTagsView = filterTagsView;
        
        CGFloat width = SCREEN_WIDTH;
        
        CGFloat top = 0;
        bannerView.top = top;
        top = bannerView.bottom;
        if (filterView) {
            _filterView = filterView;
            self.filterBgView.width = filterView.width;
            self.filterBgView.height = filterView.height;
            self.filterBgView.top = bannerView.bottom;
            top = self.filterBgView.bottom;
            self.filterBarView = self.filterBgView;
        }
//        filterView.top = bannerView.bottom;
//        top = filterView.bottom;
        // 目前只有二手房大类页有tags标签，而且要做实验-setting控制
        if (filterTagsView) {
            filterTagsView.top = self.filterBgView.bottom;
            top = filterTagsView.bottom;
        }
        self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectMake(0, top, width, NOTIFY_HEIGHT)];
        [self addSubview:_notifyBarView];
        if (bannerView) {
            [self addSubview:bannerView];
            self.theBottomView = bannerView;
        }
        if (filterView) {
            [self addSubview:self.filterBgView];
            [self.filterBgView addSubview:filterView];
            _filterView.layer.masksToBounds = YES;
            self.filterBgView.backgroundColor = [UIColor themeGray7];
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, width, 15) byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.backgroundColor = [UIColor themeGray7].CGColor;
            maskLayer.frame = CGRectMake(0, 0, width, 15);
            maskLayer.path = maskPath.CGPath;
            maskLayer.fillColor = [UIColor whiteColor].CGColor;
            self.maskLayer = maskLayer;
            [filterView.layer addSublayer:maskLayer];
            self.theBottomView = self.filterBgView;
        }
        if (filterTagsView) {
            [self addSubview:filterTagsView];
            self.theBottomView = filterTagsView;
        }
        _notifyBarView.hidden = YES;
        self.frame = CGRectMake(0, 0, width, self.theBottomView.bottom);
    }
    return self;
}

-(CGFloat)showNotify:(NSString *)message willCompletion:(void (^)(void))willCompletion
{
    self.height = self.notifyBarView.bottom;
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:^(ArticleListNotifyBarView *barView) {
        
    }];
    if (willCompletion) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            willCompletion();
        });
    }
    return self.notifyBarView.bottom;
}

-(CGFloat)filterTop
{
    if (self.filterBarView.top - [FHFakeInputNavbar perferredHeight] > 0) {
        return self.filterBarView.top - [FHFakeInputNavbar perferredHeight];
    }
    return self.filterBarView.top - [FHFakeInputNavbar perferredHeight];
}

-(CGFloat)filterBottom
{
    return self.theBottomView.bottom;
}

- (void)showFilterCorner:(BOOL)isShow
{
    self.maskLayer.hidden = !isShow;
}

-(CGFloat)notifyHeight
{
    return NOTIFY_HEIGHT;
}

-(CGRect)relayout
{
    CGFloat top = 0;
    _bannerView.top = top;
    top = _bannerView.bottom;
    _filterBarView.top = _bannerView.bottom;
    top = _filterBarView.bottom;
    self.theBottomView = _filterBarView;
    if (self.filterTagsView) {
        self.filterTagsView.top = self.filterBarView.bottom;
        top = self.filterTagsView.bottom;
        self.theBottomView = self.filterTagsView;
    }

    CGRect notifyBarFrame = _notifyBarView.frame;
    notifyBarFrame.origin.y = top;
    _notifyBarView.frame = notifyBarFrame;
    CGRect frame = self.frame;
    frame.size.height = self.theBottomView.bottom;
    self.frame = frame;
    return frame;
}


@end
