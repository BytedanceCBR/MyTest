//
//  FHLoginTipView.m
//  FHHouseBase
//
//  Created by liuyu on 2020/6/2.
//

#import "FHLoginTipView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "FHEnvContext.h"
#import "UIDevice+BTDAdditions.h"
#import "TTAccountLoginManager.h"
#import "TTAccountManager.h"
@interface FHLoginTipView ()
@property (weak, nonatomic)UILabel *contentLab;
@property (weak, nonatomic)UIButton *loginBtn;

@end
@implementation FHLoginTipView

+ (instancetype)showLoginTipViewInView:(UIView *)bacView navbarHeight:(CGFloat)navbarHeight withTracerDic:(NSDictionary *)tracerDic {
    if ([FHEnvContext canShowLoginTip] && ![TTAccount sharedAccount].isLogin) {
        FHLoginTipView *loginTipView = [[FHLoginTipView alloc]initWithFrame:CGRectMake(0, MAIN_SCREENH_HEIGHT - navbarHeight - ([UIDevice btd_isIPhoneXSeries] ? 83 : 49)-50, MAIN_SCREEN_WIDTH, 50)];
        loginTipView.traceDict = tracerDic;
        loginTipView.navbarHeight = navbarHeight;
        [bacView addSubview:loginTipView];
        loginTipView.showTimer =   [NSTimer scheduledTimerWithTimeInterval:10 target:loginTipView selector:@selector(loginTipViewDsappear) userInfo:nil repeats:NO];
        return loginTipView;
    }else {
        return nil;
    }
}

- (void)loginTipViewDsappear {
//    [UIView animateWithDuration:0.25 animations:^{
//        self.frame = CGRectMake(0, MAIN_SCREENH_HEIGHT -self.navbarHeight, [UIScreen mainScreen].bounds.size.width, 50);
//        self.alpha = 0;
//    } completion:^(BOOL finished) {
        [self removeFromSuperview];
//    }];
    if (_showTimer) {
        [_showTimer invalidate];
        _showTimer = nil;
    }
}

- (void)setType:(FHLoginTipViewtType)type {
    _type = type;
    if (type == FHLoginTipViewtTypeMain) {
        _contentLab.text = @"立即登录，关注房源不丢失";
    }else {
        _contentLab.text = @"立即登录，推荐内容更精准";
    }
}

- (void)pauseTimer {
    if (_showTimer) {
        [_showTimer invalidate];
        _showTimer = nil;
    }
}

- (void)startTimer {
    if (!_showTimer) {
       _showTimer =   [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(loginTipViewDsappear) userInfo:nil repeats:NO];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.backgroundColor = [[UIColor themeGray1]colorWithAlphaComponent:.8];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.centerY.equalTo(self);
    }];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(52, 24));
    }];
}

- (UILabel *)contentLab {
    if (!_contentLab) {
        UILabel *contentLab = [[UILabel alloc]init];
        contentLab.font = [UIFont themeFontRegular:14];
        contentLab.textColor = [UIColor whiteColor];
        contentLab.text = @"立即登录，关注房源不丢失";
        [self addSubview:contentLab];
        _contentLab = contentLab;
    }
    return _contentLab;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        UIButton *loginBtn = [[UIButton alloc]init];
        [loginBtn setBackgroundColor:[UIColor themeOrange1]];
        [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        loginBtn.titleLabel.font = [UIFont themeFontRegular:12];
        [loginBtn addTarget:self action:@selector(gotoLogin) forControlEvents:UIControlEventTouchDown];
        [loginBtn setTitleColor:[UIColor themeWhite] forState:UIControlStateNormal];
        loginBtn.layer.cornerRadius = 12;
        [self addSubview:loginBtn];
        _loginBtn = loginBtn;
    }
    return _loginBtn;
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *enterFrom = self.type == FHLoginTipViewtTypeMain? @"maintab":@"neighborhood_tab";
    [params setObject:enterFrom forKey:@"enter_from"];
    [params setObject:@"login_tips" forKey:@"enter_type"];
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    [TTAccountLoginManager presentAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        [self removeFromSuperview];
    }];
}

@end
