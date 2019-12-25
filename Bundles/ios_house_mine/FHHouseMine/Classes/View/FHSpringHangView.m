//
//  FHSpringHangView.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/12/23.
//

#import "FHSpringHangView.h"
#import <Masonry.h>
#import "UIButton+TTAdditions.h"
#import <TTRoute.h>
#import <FHUtils.h>

#define kFHSpringViewCloseNotification @"kFHSpringViewCloseNotification"
#define kFHSpringViewCloseDate @"kFHSpringViewCloseDate"

@interface FHSpringHangView ()

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UIButton *closeBtn;

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
        make.top.mas_equalTo(self).offset(8);
        make.right.mas_equalTo(self).offset(-8);
        make.left.bottom.mas_equalTo(self);
    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(self.bgView);
        make.width.height.mas_equalTo(12);
    }];
}

- (void)show {
    NSString *midNightIntervalStr = [FHUtils contentForKey:kFHSpringViewCloseDate];
    if (midNightIntervalStr) {
        NSDate *date = [NSDate date];
        NSTimeInterval interval = [date timeIntervalSince1970] - [midNightIntervalStr doubleValue];
        //小于1天，不在显示
        if(interval < 24 * 60 * 60){
            return;
        }
    }
    
    self.hidden = NO;
}

- (void)close {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFHSpringViewCloseNotification object:nil];
    NSTimeInterval midNightInterval = [self getMidnightInterval];
    if(midNightInterval > 0){
        NSString *midNightIntervalStr = [NSString stringWithFormat:@"%0.0f",midNightInterval];
        [FHUtils setContent:midNightIntervalStr forKey:kFHSpringViewCloseDate];
    }
        
}

- (void)closeView:(NSNotification *)noti {
    self.hidden = YES;
}

- (void)goToSpring:(UITapGestureRecognizer *)sender {
    NSString *urlStr = @"sslocal://webview?url=https://m.haoduofangs.com/magic/page/ejs/5e02dc7854c8b002583c0773?appType=manyhouse";
    NSURL* url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
}

- (NSTimeInterval)getMidnightInterval {
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitYear | NSCalendarUnitMonth fromDate:[NSDate date]];
    [comp setHour:0];
    [comp setMinute:0];
    [comp setSecond:0];
    return [[[NSCalendar currentCalendar] dateFromComponents:comp] timeIntervalSince1970];
}

@end
