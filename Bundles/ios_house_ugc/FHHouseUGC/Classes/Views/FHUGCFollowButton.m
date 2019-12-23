//
//  FHUGCFollowButton.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/14.
//

#import "FHUGCFollowButton.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"
#import "FHUGCConfig.h"
#import "ToastManager.h"
#import "TTBaseMacro.h"
#import "TTUIResponderHelper.h"
#import "FHUserTracker.h"
#import "TTReachability.h"

@interface FHUGCFollowButton ()

@property (nonatomic, assign) FHUGCFollowButtonStyle style; // 默认是有边框
@property (nonatomic, strong) NSString *loadingImageName;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) UIImageView *loadingAnimateView;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong)     NSMutableDictionary       *tracerParams;

@end

@implementation FHUGCFollowButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initNotification];
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(FHUGCFollowButtonStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        _style = style;
        [self initNotification];
        [self setupUI];
    }
    return self;
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStateChanged:) name:kFHUGCFollowNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFollowed:(BOOL)followed {
    _followed = followed;
    UIColor *borderColor = nil;
    self.backgroundColor = [UIColor whiteColor];
    if (followed) {
        self.titleStr = @"已关注";
        self.loadingImageName = @"fh_ugc_loading_gray";
        borderColor = self.followedTextColor ?:[UIColor themeGray4];
        if(self.followedBackgroundColor) {
            self.backgroundColor = self.followedBackgroundColor;
        }
    } else {
        self.titleStr = @"关注";
        self.loadingImageName = @"fh_ugc_loading_red";
        borderColor = self.unFollowedTextColor?:[UIColor themeRed1];
        if(self.unFollowedBackgroundColor) {
            self.backgroundColor = self.unFollowedBackgroundColor;
        }
    }
    
    if(self.style == FHUGCFollowButtonStyleBorder){
        self.layer.borderColor = [borderColor CGColor];
    }
    
    [self setTitleColor:borderColor forState:UIControlStateNormal];
    [self setTitle:self.titleStr forState:UIControlStateNormal];
    self.loadingAnimateView.image = [UIImage imageNamed:self.loadingImageName];
}

- (void)setupUI {
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 4;
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel.font = [UIFont themeFontRegular:12];
    [self setTitle:@"关注" forState:UIControlStateNormal];
    [self setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    
    if(self.style == FHUGCFollowButtonStyleBorder){
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [[UIColor themeRed1] CGColor];
    }
    
    self.loadingImageName = @"fh_ugc_loading_red";
    self.loadingAnimateView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.loadingImageName]];\
    _loadingAnimateView.hidden = YES;
    [self addSubview:_loadingAnimateView];
    
    [self addTarget:self action:@selector(clicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self initConstraints];
}

- (void)initConstraints {
    [self.loadingAnimateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.height.mas_equalTo(16);
    }];
}

- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)startLoading {
    self.isLoading = YES;
    [self setTitle:@"" forState:UIControlStateNormal];
    
    CABasicAnimation *rotationAnimation = [[CABasicAnimation alloc] init];
    rotationAnimation.keyPath = @"transform.rotation.z";
    rotationAnimation.toValue = @(M_PI * 2.0);
    rotationAnimation.duration = 0.4;
    rotationAnimation.repeatCount = MAXFLOAT;
    
    _loadingAnimateView.hidden = NO;
    [_loadingAnimateView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopLoading {
    if(self.isLoading){
        self.isLoading = NO;
        [self setTitle:self.titleStr forState:UIControlStateNormal];
        _loadingAnimateView.hidden = YES;
        [_loadingAnimateView.layer removeAllAnimations];
    }
}

- (void)clicked {
    if(self.followed){
        [self showDeleteAlert];
    }else{
        [self doFollow];
    }
}

- (void)doFollow {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    if(isEmptyString(self.groupId)){
        return;
    }
    if (self.isLoading) {
        return;
    }
    [self startLoading];
    if (self.followed) {
        // 取消关注埋点 在点击的时候报吧 ~~~
    } else {
        // 关注埋点
        [self followTracer];
    }
    [self requestData];
}

- (void)requestData {
    __weak typeof(self) wself = self;
    NSString *enter_from = self.tracerDic[@"page_type"] ?: @"be_null";
    [[FHUGCConfig sharedInstance] followUGCBy:self.groupId isFollow:!self.followed enterFrom:enter_from enterType:@"click" completion:^(BOOL isSuccess) {
        [wself stopLoading];
        if(isSuccess) {
            wself.followed = !wself.followed;
        }
        
        if(wself.followedSuccess){
            wself.followedSuccess(isSuccess,wself.followed);
        }
    }];
}

- (void)followStateChanged:(NSNotification *)notification {
    if(isEmptyString(self.groupId)){
        return;
    }
    
    BOOL followed = [notification.userInfo[@"followStatus"] boolValue];
    NSString *groupId = notification.userInfo[@"social_group_id"];
    
    if([groupId isEqualToString:self.groupId]){
        self.followed = followed;
    }
}

- (void)showDeleteAlert {
    [self unFollowTracer];
    [self cancelJoinPopupShow];
    __weak typeof(self) wself = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认要取消关注吗？"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"再看看"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             // 点击取消按钮，调用此block
                                                             [wself cancelJoinPopupClickByConfirm:NO];
                                                         }];
    [alert addAction:cancelAction];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确认"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              // 点击按钮，调用此block
                                                              [wself doFollow];
                                                              [wself cancelJoinPopupClickByConfirm:YES];
                                                          }];
    [alert addAction:defaultAction];
    [[TTUIResponderHelper visibleTopViewController] presentViewController:alert animated:YES completion:nil];
}

- (void)setTracerDic:(NSDictionary *)tracerDic {
    _tracerDic = [tracerDic copy];
    if (tracerDic) {
        self.tracerParams = [NSMutableDictionary new];
        //
        self.tracerParams[@"page_type"] = self.tracerDic[@"page_type"] ?: @"be_null";
        self.tracerParams[@"enter_from"] = self.tracerDic[@"enter_from"] ?: @"be_null";
        self.tracerParams[@"enter_type"] = self.tracerDic[@"enter_type"] ?: @"be_null";
        self.tracerParams[@"rank"] = self.tracerDic[@"rank"] ?: @"be_null";
        self.tracerParams[@"log_pb"] = self.tracerDic[@"log_pb"] ?: @"be_null";
        
        if(tracerDic[@"card_type"]){
            self.tracerParams[@"card_type"] = tracerDic[@"card_type"];
        }
        
        if(tracerDic[@"element_type"]){
            self.tracerParams[@"element_type"] = tracerDic[@"element_type"];
        }
        
        if(tracerDic[@"element_from"]){
            self.tracerParams[@"element_from"] = tracerDic[@"element_from"];
        }
        
        if(tracerDic[@"house_type"]){
            self.tracerParams[@"house_type"] = tracerDic[@"house_type"];
        }
        
        if(tracerDic[@"show_type"]){
            self.tracerParams[@"show_type"] = tracerDic[@"show_type"];
        }
        
        if(tracerDic[@"calssify_label"]){
            self.tracerParams[@"calssify_label"] = tracerDic[@"calssify_label"];
        }
    }
}

- (void)cancelJoinPopupClickByConfirm:(BOOL)isConfirm {
    NSMutableDictionary *tracerDict = self.tracerParams.mutableCopy;
    NSString *page_type = self.tracerDic[@"page_type"];
    NSString *enter_from = self.tracerDic[@"enter_from"];
    tracerDict[@"page_type"] = @"join_community_grouppopup";
    tracerDict[@"enter_from"] = page_type ?: @"be_null";
    tracerDict[@"origin_from"] = enter_from ?: @"be_null";
    [tracerDict removeObjectForKey:@"enter_type"];
    [tracerDict removeObjectForKey:@"rank"];
    if (isConfirm) {
        tracerDict[@"click_position"] = @"confirm";
    } else {
        tracerDict[@"click_position"] = @"cancel";
    }
    
    [FHUserTracker writeEvent:@"cancel_join_popup_click" params:tracerDict];
}

- (void)cancelJoinPopupShow {
    NSMutableDictionary *tracerDict = self.tracerParams.mutableCopy;
    NSString *page_type = self.tracerDic[@"page_type"];
    tracerDict[@"page_type"] = @"join_community_grouppopup";
    tracerDict[@"enter_from"] = page_type ?: @"be_null";
    [tracerDict removeObjectForKey:@"enter_type"];
    [tracerDict removeObjectForKey:@"rank"];
    
    [FHUserTracker writeEvent:@"cancel_join_popup_show" params:tracerDict];
}

// 关注埋点
- (void)followTracer {
    NSMutableDictionary *tracerDict = self.tracerParams.mutableCopy;
    tracerDict[@"click_position"] = @"join_like";
    [FHUserTracker writeEvent:@"click_join" params:tracerDict];
}

// 取消关注埋点
- (void)unFollowTracer {
    NSMutableDictionary *tracerDict = self.tracerParams.mutableCopy;
    tracerDict[@"click_position"] = @"cancel_like";
    [FHUserTracker writeEvent:@"click_unjoin" params:tracerDict];
}

@end
