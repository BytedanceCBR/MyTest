//
//  FHMainListTopView.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/8.
//

#import "FHMainListTopView.h"
#import <TTPlatformUIModel/ArticleListNotifyBarView.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <FHHouseBase/FHCommonDefines.h>
#import <FHCommonUI/UIColor+Theme.h>

#define NOTIFY_HEIGHT 32

@interface FHMainListTopView ()

@property(nonatomic , strong) UIView *bannerView;
@property(nonatomic , strong) UIView *filterBarView;
@property(nonatomic , strong) UIView *bottomLine;
@property (nonatomic , strong) ArticleListNotifyBarView *notifyBarView;

@end

@implementation FHMainListTopView

-(instancetype)initWithBannerView:(UIView *)bannerView filterView:(UIView *)filterView
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.bannerView = bannerView;
        self.filterBarView = filterView;
        
        CGFloat top = 0;
        bannerView.top = top;
        top = bannerView.bottom;
        filterView.top = bannerView.bottom;
        top = filterView.bottom;
        self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectMake(0, top, [UIScreen mainScreen].bounds.size.width, NOTIFY_HEIGHT)];
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, top - ONE_PIXEL, filterView.width - 2*HOR_MARGIN, ONE_PIXEL)];
        _bottomLine.backgroundColor = [UIColor themeGray6];
        [self addSubview:_notifyBarView];
        [self addSubview:bannerView];
        [self addSubview:filterView];
        [self addSubview:_bottomLine];
        
        _notifyBarView.hidden = YES;
        self.frame = CGRectMake(0, 0, bannerView.width, filterView.bottom);
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
    return self.filterBarView.top;
}

-(CGFloat)filterBottom
{
    return self.filterBarView.bottom;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    NSLog(@"[SCROLL] topview set frame : %@",NSStringFromCGRect(frame));
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.bottomLine.frame = CGRectMake(HOR_MARGIN, self.filterBarView.bottom - ONE_PIXEL, self.width - 2*HOR_MARGIN, ONE_PIXEL);
    }else{
        self.bottomLine.frame = CGRectMake(0, self.filterBarView.bottom - ONE_PIXEL, self.width , ONE_PIXEL);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
