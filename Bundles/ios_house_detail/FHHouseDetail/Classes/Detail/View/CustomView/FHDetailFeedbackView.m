//
//  FHDetailFeedbackView.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/7/16.
//

#import "FHDetailFeedbackView.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "UIViewAdditions.h"
#import "YYLabel.h"
#import "NSAttributedString+YYText.h"
#import "TTAccountManager.h"
#import "FHEnvContext.h"
#import "FHDetailOldModel.h"
#import "FHDetailRentModel.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface FHDetailFeedbackView ()

@property(nonatomic, strong) UIView *emptyView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIButton *closeBtn;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subTitleLabel;

@property(nonatomic, strong) UIButton *unLikeBtn;
@property(nonatomic, strong) UIButton *normalBtn;
@property(nonatomic, strong) UIButton *likeBtn;

@property(nonatomic, strong) YYLabel *reportLabel;

@end

@implementation FHDetailFeedbackView

- (void)show:(UIView *)parentView {
    [parentView addSubview:self];
}

- (void)hide {
    [self removeFromSuperview];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        [self initViews];
        [self initConstaints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    
    self.emptyView = [[UIView alloc] init];
    _emptyView.backgroundColor = [UIColor clearColor];
    _emptyView.userInteractionEnabled = YES;
    [self addSubview:_emptyView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
    [_emptyView addGestureRecognizer:tapGesture];
    
    self.containerView = [[UIView alloc] init];
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.userInteractionEnabled = YES;
    [self addSubview:_containerView];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontSemibold:20] textColor:[UIColor themeGray1]];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"您沟通的经纪人是否认真专业";
    [self.containerView addSubview:_titleLabel];
    
    self.subTitleLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    _subTitleLabel.textAlignment = NSTextAlignmentCenter;
    _subTitleLabel.text = @"幸福里邀请您对本次通话进行评价";
    [self.containerView addSubview:_subTitleLabel];
    
    self.closeBtn = [[UIButton alloc] init];
    [_closeBtn setImage:[UIImage imageNamed:@"detail_alert_closed"] forState:UIControlStateNormal];
    _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:_closeBtn];
    
    self.normalBtn = [self buttonWithText:@"一般" imageName:@"detail_feedback_normal" tag:1];
    [self.containerView addSubview:_normalBtn];
    
    self.unLikeBtn = [self buttonWithText:@"不专业" imageName:@"detail_feedback_unlike" tag:2];
    [self.containerView addSubview:_unLikeBtn];
    
    self.likeBtn = [self buttonWithText:@"专业" imageName:@"detail_feedback_like" tag:3];
    [self.containerView addSubview:_likeBtn];
    
    self.reportLabel = [[YYLabel alloc] init];
    _reportLabel.backgroundColor = [UIColor themeGray7];
    _reportLabel.textColor = [UIColor themeGray3];
    _reportLabel.font = [UIFont themeFontRegular:14];
    [self.containerView addSubview:_reportLabel];
    
    __weak typeof(self) wself = self;
    NSDictionary *commonTextStyle = @{
                                      NSFontAttributeName : [UIFont themeFontRegular:14],
                                      NSForegroundColorAttributeName : [UIColor themeGray3],
                                      };
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:@"如房源存在问题，请通过举报反馈"];
    [attrText addAttributes:commonTextStyle range:NSMakeRange(0, attrText.length)];
    
    [attrText yy_setTextHighlightRange:NSMakeRange(11, 4) color:[UIColor themeRed] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        [wself goToReport];
    }];
    
    _reportLabel.attributedText = attrText;
    _reportLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)initConstaints {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(300);
    }];
    
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.containerView.mas_top);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(44);
        make.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(28);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6);
        make.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(20);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containerView).offset(10);
        make.right.mas_equalTo(self.containerView).offset(-10);
        make.width.height.mas_equalTo(24);
    }];
    
    [self.normalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(26);
        make.centerX.mas_equalTo(self.containerView);
        make.width.height.mas_equalTo(100);
    }];
    
    [self.unLikeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.normalBtn);
        make.right.mas_equalTo(self.normalBtn.mas_left);
        make.width.height.mas_equalTo(100);
    }];
    
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.normalBtn);
        make.left.mas_equalTo(self.normalBtn.mas_right);
        make.width.height.mas_equalTo(100);
    }];
    
    [self.reportLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(50);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (UIButton *)buttonWithText:(NSString *)text imageName:(NSString *)imageName tag:(NSInteger)tag {
    UIButton *btn = [[UIButton alloc] init];
    btn.imageView.contentMode = UIViewContentModeCenter;
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont themeFontRegular:16];
    btn.tag = tag;
    [btn setTitle:text forState:UIControlStateNormal];

    [btn sizeToFit];
    
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width, -btn.imageView.frame.size.height - 10, 0.0)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-btn.titleLabel.frame.size.height - 10, 0.0,0.0, -btn.titleLabel.frame.size.width)];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)click {
    if(self.clickBlock){
        self.clickBlock();
    }
}

- (void)btnClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    //调用接口
}

- (void)goToReport {
//    if ([TTAccountManager isLogin]) {
//        [self gotoReportVC];
//    } else {
//        [self gotoLogin];
//    }
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setObject:@"rent_feedback" forKey:@"enter_from"];
//    [params setObject:@"feedback" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(NO) forKey:@"need_pop_vc"];
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                [wSelf gotoReportVC];
            }
            // 移除登录页面
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wSelf delayRemoveLoginVC];
            });
        }
    }];
}

- (void)delayRemoveLoginVC {
//    if(self.navVC){
        NSInteger count = self.navigationController.viewControllers.count;
        if (self.navigationController && count >= 2) {
            NSMutableArray *vcs = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
            if (vcs.count == count) {
                [vcs removeObjectAtIndex:count - 2];
                [self.navigationController setViewControllers:vcs];
            }
        }
//    }
}

- (void)gotoReportVC {
    NSDictionary *jsonDic = nil;
    id data = self.viewModel.detailData;
    if([data isKindOfClass:[FHDetailOldDataModel class]]){
        FHDetailOldDataModel *model = (FHDetailOldDataModel *)data;
        jsonDic = [model toDictionary];
    }else if([data isKindOfClass:[FHRentDetailResponseModel class]]){
        FHRentDetailResponseModel *model = (FHRentDetailResponseModel *)data;
        jsonDic = [model toDictionary];
    }
    
//    NSMutableArray *items = self.viewModel.items;
    
//    FHRentDetailResponseModel *rentData = (FHRentDetailResponseModel *)self.viewModel.baseViewModel.detailData;
//    NSDictionary *jsonDic = [self.viewModel.detailData toDictionary];
//    if (model && model.houseOverreview.reportUrl.length > 0 && jsonDic) {
//
//        NSString *openUrl = @"sslocal://webview";
//        NSDictionary *pageData = @{@"data":jsonDic};
//        NSDictionary *commonParams = [[FHEnvContext sharedInstance] getRequestCommonParams];
//        if (commonParams == nil) {
//            commonParams = @{};
//        }
//        NSDictionary *commonParamsData = @{@"data":commonParams};
//        NSDictionary *jsParams = @{@"requestPageData":pageData,
//                                   @"getNetCommonParams":commonParamsData
//                                   };
//        NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
//        NSString *urlStr = [NSString stringWithFormat:@"%@%@",host,model.houseOverreview.reportUrl];
//        NSDictionary *info = @{@"url":urlStr,@"fhJSParams":jsParams,@"title":@"房源问题反馈"};
//        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
//        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openUrl] userInfo:userInfo];
//    }
}

- (void)close {
    [self hide];
}

@end
