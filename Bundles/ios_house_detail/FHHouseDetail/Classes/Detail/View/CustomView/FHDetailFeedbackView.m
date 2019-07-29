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
#import "FHDetailHouseOutlineInfoCell.h"
#import "FHURLSettings.h"
#import "ToastManager.h"
#import "FHHouseDetailAPI.h"
#import "TTReachability.h"
#import "FHUserTracker.h"
#import "TTDeviceHelper.h"
#import <FHHouseBase/UIImage+FIconFont.h>

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
@property(nonatomic, strong) UIView *bottomView;

@property(nonatomic, copy) NSString *imprId;
@property(nonatomic, copy) NSString *searchId;

@end

@implementation FHDetailFeedbackView

- (void)show:(UIView *)parentView {
    [parentView addSubview:self];
    [self initVars];
    [self traceRealtorEvaluatePopupShow];
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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
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
    UIImage *img = ICON_FONT_IMG(24, @"\U0000e673", nil);
    [_closeBtn setImage:img forState:UIControlStateNormal];
    _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:_closeBtn];
    
    self.normalBtn = [self buttonWithText:@"一般" imageName:@"\U0000e66b" selectedImageName:@"\U0000e66b" tag:2]; //detail_feedback_normal
    [self.containerView addSubview:_normalBtn];
    
    self.unLikeBtn = [self buttonWithText:@"不专业" imageName:@"\U0000e6ae" selectedImageName:@"\U0000e6ae" tag:1]; //detail_feedback_unlike
    [self.containerView addSubview:_unLikeBtn];
    
    self.likeBtn = [self buttonWithText:@"专业" imageName:@"\U0000e6af" selectedImageName:@"\U0000e6af" tag:3];//detail_feedback_like
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
    
    self.bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor themeGray7];
    [self.containerView addSubview:_bottomView];
}

- (void)initConstaints {
    CGFloat bottom = 0;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    if([TTDeviceHelper isIPhoneXSeries]){
        bottom -= 25;
        if(bottom < 0){
            bottom = 0;
        }
    }
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(300 + bottom);
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
        make.left.right.mas_equalTo(self.containerView);
        make.bottom.mas_equalTo(self.containerView).offset(-bottom);
        make.height.mas_equalTo(50);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self.containerView);
        make.height.mas_equalTo(bottom);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (UIButton *)buttonWithText:(NSString *)text imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName tag:(NSInteger)tag {
    UIButton *btn = [[UIButton alloc] init];
    btn.imageView.contentMode = UIViewContentModeCenter;
    UIImage *img = ICON_FONT_IMG(40, imageName, [UIColor themeGray6]);
    [btn setImage:img forState:UIControlStateNormal];
    img = ICON_FONT_IMG(40, selectedImageName, [UIColor themeRed]);
    [btn setImage:img forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor themeGray3] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor themeRed] forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont themeFontRegular:16];
    btn.tag = tag;
    [btn setTitle:text forState:UIControlStateNormal];

    [btn sizeToFit];
    
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -btn.imageView.frame.size.width, -btn.imageView.frame.size.height - 10, 0.0)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-btn.titleLabel.frame.size.height - 10, 0.0,0.0, -btn.titleLabel.frame.size.width)];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)initVars {
    id data = self.viewModel.detailData;
    if([data isKindOfClass:[FHDetailOldModel class]]){
        FHDetailOldModel *model = (FHDetailOldModel *)data;

        if(model.data.logPb[@"impr_id"]){
            self.imprId = model.data.logPb[@"impr_id"];
        }
        
        if(model.data.logPb[@"search_id"]){
            self.searchId = model.data.logPb[@"search_id"];
        }
    }
}

- (void)btnClick:(id)sender {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    [self hide];
    [self traceRealtorEvaluatePopupClick:[NSString stringWithFormat:@"%i",tag]];
    
    [FHHouseDetailAPI requestPhoneFeedback:self.viewModel.houseId houseType:self.viewModel.houseType realtorId:self.realtorId imprId:self.imprId searchId:self.searchId score:tag completion:^(bool succss, NSError * _Nonnull error) {
        if(succss){
            [[ToastManager manager] showToast:@"提交成功，感谢您的评价"];
        }else{
            [[ToastManager manager] showToast:@"提交失败"];
        }
    }];
}

- (void)goToReport {
    [self traceClickFeedback];
    
    NSDictionary *jsonDic = nil;
    NSString *reportUrl = nil;
    id data = self.viewModel.detailData;
    if([data isKindOfClass:[FHDetailOldModel class]]){
        FHDetailOldModel *model = (FHDetailOldModel *)data;
        jsonDic = [model.data toDictionary];
    }
    
    NSMutableArray *items = self.viewModel.items;
    for (id item in items) {
        if([item isKindOfClass:[FHDetailHouseOutlineInfoModel class]]){
            FHDetailHouseOutlineInfoModel *infoModel = (FHDetailHouseOutlineInfoModel *)item;
            reportUrl = infoModel.houseOverreview.reportUrl;
            break;
        }
    }

    if (reportUrl && reportUrl.length > 0 && jsonDic) {
        NSString *openUrl = @"sslocal://webview";
        NSDictionary *pageData = @{@"data":jsonDic};
        NSDictionary *commonParams = [[FHEnvContext sharedInstance] getRequestCommonParams];
        if (commonParams == nil) {
            commonParams = @{};
        }
        NSDictionary *commonParamsData = @{@"data":commonParams};
        NSDictionary *jsParams = @{@"requestPageData":pageData,
                                   @"getNetCommonParams":commonParamsData
                                   };
        NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",host,reportUrl];
        NSDictionary *info = @{@"url":urlStr,@"fhJSParams":jsParams,@"title":@"房源问题反馈"};
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openUrl] userInfo:userInfo];
    }
}

- (void)close {
    [self hide];
    [self traceRealtorEvaluatePopupClick:@"cancel"];
}

#pragma mark - 埋点相关

- (void)traceRealtorEvaluatePopupShow {
    NSMutableDictionary *tracerDic = [self.viewModel.detailTracerDic mutableCopy];
    tracerDic[@"realtor_id"] = self.realtorId ? self.realtorId : @"be_null";
    TRACK_EVENT(@"realtor_evaluate_popup_show", tracerDic);
}

- (void)traceRealtorEvaluatePopupClick:(NSString *)position {
    NSMutableDictionary *tracerDic = [self.viewModel.detailTracerDic mutableCopy];
    tracerDic[@"realtor_id"] = self.realtorId ? self.realtorId : @"be_null";
    tracerDic[@"click_position"] = position ? position : @"be_null";
    TRACK_EVENT(@"realtor_evaluate_popup_click", tracerDic);
}

- (void)traceClickFeedback {
    NSMutableDictionary *tracerDic = [self.viewModel.detailTracerDic mutableCopy];
    tracerDic[@"enter_from"] = @"realtor_evaluate_popup";
    TRACK_EVENT(@"click_feedback", tracerDic);
}

@end
