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
@property(nonatomic , strong) UIView *filterBarView;
@property(nonatomic , strong) UIView *filterTagsView;
@property(nonatomic , strong) UIView *bottomLine;
@property(nonatomic , strong) ArticleListNotifyBarView *notifyBarView;
@property(nonatomic , strong) UIView       *theBottomView;

@end

@implementation FHMainListTopView

-(instancetype)initWithBannerView:(UIView *)bannerView filterView:(UIView *)filterView filterTagsView:(UIView *)filterTagsView 
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.bannerView = bannerView;
        self.filterBarView = filterView;
        self.filterTagsView = filterTagsView;
        
        CGFloat width = SCREEN_WIDTH;
        
        CGFloat top = 0;
        bannerView.top = top;
        top = bannerView.bottom;
        filterView.top = bannerView.bottom;
        top = filterView.bottom;
        // 目前只有二手房大类页有tags标签，而且要做实验-setting控制
        if (filterTagsView) {
            filterTagsView.top = filterView.bottom;
            top = filterTagsView.bottom;
        }
        self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectMake(0, top, width, NOTIFY_HEIGHT)];
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, filterView.bottom - ONE_PIXEL, filterView.width - 2*HOR_MARGIN, ONE_PIXEL)];
        _bottomLine.backgroundColor = [UIColor themeGray6];
        [self addSubview:_notifyBarView];
        if (bannerView) {
            [self addSubview:bannerView];
            self.theBottomView = bannerView;
        }
        if (filterView) {
            [self addSubview:filterView];
            self.theBottomView = filterView;
        }
        if (filterTagsView) {
            [self addSubview:filterTagsView];
            self.theBottomView = filterTagsView;
        }
        [self addSubview:_bottomLine];
        
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
    return self.filterBarView.top - [FHFakeInputNavbar perferredHeight];
}

-(CGFloat)filterBottom
{
    return self.theBottomView.bottom;
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
    
    CGRect bottomFrame = _bottomLine.frame;
    bottomFrame.origin.y = _filterBarView.bottom - ONE_PIXEL;
    _bottomLine.frame = bottomFrame;
    
    CGRect frame = self.frame;
    frame.size.height = self.theBottomView.bottom;
    self.frame = frame;
    return frame;
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.bottomLine.frame = CGRectMake(HOR_MARGIN, self.filterBarView.bottom - ONE_PIXEL, self.width - 2*HOR_MARGIN, ONE_PIXEL);
    }else{
        self.bottomLine.frame = CGRectMake(0, self.filterBarView.bottom - ONE_PIXEL, self.width , ONE_PIXEL);
    }
}

@end
