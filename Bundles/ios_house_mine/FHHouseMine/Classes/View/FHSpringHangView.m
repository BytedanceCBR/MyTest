//
//  FHSpringHangView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/12/23.
//

#import "FHSpringHangView.h"
#import "Masonry.h"
#import "UIButton+TTAdditions.h"
#import "TTRoute.h"
#import "FHUtils.h"
#import <FHUserTracker.h>
#import <FHEnvContext.h>

#define kFHSpringViewCloseNotification @"kFHSpringViewCloseNotification"
#define kFHSpringViewCloseDate @"kFHSpringViewCloseDate"

@interface FHSpringHangView ()

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UIButton *closeBtn;
@property(nonatomic , copy) NSString *pageType;

@end

@implementation FHSpringHangView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self initConstaints];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeView:) name:kFHSpringViewCloseNotification object:nil];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"fh_spring_yunying"]];
    self.bgView.userInteractionEnabled = YES;
    [self addSubview:_bgView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToSpring:)];
    [self.bgView addGestureRecognizer:tap];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setImage:[UIImage imageNamed:@"fh_spring_yunying_close"] forState:UIControlStateNormal];
    [_closeBtn setImage:[UIImage imageNamed:@"fh_spring_yunying_close"] forState:UIControlStateHighlighted];
    _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-8, -8, -8, -8);
    [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];
}

- (void)initConstaints {
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(69);
        make.height.mas_equalTo(58);
        make.left.bottom.mas_equalTo(self);
    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(-15);
        make.right.mas_equalTo(self.bgView).offset(7);
        make.width.mas_equalTo(14);
        make.height.mas_equalTo(15);
    }];
}

- (void)show:(NSString *)pageType {
    NSString *midNightIntervalStr = [FHUtils contentForKey:kFHSpringViewCloseDate];
    if (midNightIntervalStr) {
        NSDate *date = [NSDate date];
        NSTimeInterval interval = [date timeIntervalSince1970] - [midNightIntervalStr doubleValue];
        //小于1天，不在显示
        if(interval < 24 * 60 * 60){
            return;
        }
    }
    //显示
    _pageType = pageType;
    if(![FHEnvContext sharedInstance].isShowingSpringHang){
        [self addPandentShowLog];
    }
    [FHEnvContext sharedInstance].isShowingSpringHang = YES;
    self.hidden = NO;
}

- (void)close {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHSpringViewCloseNotification object:nil];
    NSTimeInterval midNightInterval = [self getMidnightInterval];
    if(midNightInterval > 0){
        NSString *midNightIntervalStr = [NSString stringWithFormat:@"%0.0f",midNightInterval];
        [FHUtils setContent:midNightIntervalStr forKey:kFHSpringViewCloseDate];
    }
    //隐藏
    [FHEnvContext sharedInstance].isShowingSpringHang = NO;
    [self addPandentCloseLog];
}

- (void)closeView:(NSNotification *)noti {
    self.hidden = YES;
}

- (void)goToSpring:(UITapGestureRecognizer *)sender {
    NSString *urlStr = @"sslocal://webview?url=https://m.haoduofangs.com/magic/page/ejs/5e02dc7854c8b002583c0773?appType=manyhouse";
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
    [self addPandentClickLog];
}

- (NSTimeInterval)getMidnightInterval {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth fromDate:[NSDate date]];
    [comp setHour:0];
    [comp setMinute:0];
    [comp setSecond:0];
    return [[[NSCalendar currentCalendar] dateFromComponents:comp] timeIntervalSince1970];
}

#pragma mark - 埋点

- (void)addPandentShowLog {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"value"] = @"be_null";
    if(_pageType){
        tracerDict[@"page_type"] = _pageType;
    }
    TRACK_EVENT(@"pandent_show", tracerDict);
}

- (void)addPandentCloseLog {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"value"] = @"be_null";
    if(_pageType){
        tracerDict[@"page_type"] = _pageType;
    }
    TRACK_EVENT(@"pandent_close", tracerDict);
}

- (void)addPandentClickLog {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    tracerDict[@"value"] = @"be_null";
    if(_pageType){
        tracerDict[@"page_type"] = _pageType;
    }
    TRACK_EVENT(@"pandent_click", tracerDict);
}

@end
