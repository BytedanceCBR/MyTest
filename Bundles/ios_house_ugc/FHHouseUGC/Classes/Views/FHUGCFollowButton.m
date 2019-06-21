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
#import "FHUGCFollowManager.h"
#import "ToastManager.h"
#import "TTBaseMacro.h"
#import "TTUIResponderHelper.h"

@interface FHUGCFollowButton ()

@property (nonatomic, assign) FHUGCFollowButtonStyle style; // 默认是有边框
@property (nonatomic, strong) NSString *loadingImageName;
@property (nonatomic, strong) NSString *titleStr;
@property (nonatomic, strong) UIImageView *loadingAnimateView;
@property (nonatomic, assign) BOOL isLoading;

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
    
    if (followed) {
        self.titleStr = @"已关注";
        self.loadingImageName = @"fh_ugc_loading_gray";
        borderColor = [UIColor themeGray4];
    } else {
        self.titleStr = @"关注";
        self.loadingImageName = @"fh_ugc_loading_red";
        borderColor = [UIColor themeRed1];
    }
    
    if(self.style == FHUGCFollowButtonStyleBorder){
        self.layer.borderColor = [borderColor CGColor];
    }
    
    [self setTitleColor:borderColor forState:UIControlStateNormal];
    [self setTitle:self.titleStr forState:UIControlStateNormal];
    self.loadingAnimateView.image = [UIImage imageNamed:self.loadingImageName];
}

//- (void)setStyle:(FHUGCFollowButtonStyle)style {
//    _style = style;
//
//    if(self.style == FHUGCFollowButtonStyleBorder){
//        self.layer.borderWidth = 0.5f;
//        if(self.followed){
//            self.layer.borderColor = [[UIColor themeGray4] CGColor];
//        }else{
//            self.layer.borderColor = [[UIColor themeRed1] CGColor];
//        }
//    }else{
//        self.layer.borderWidth = 0.0f;
//    }
//}

- (void)setupUI {
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 4;
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel.font = [UIFont themeFontRegular:12];
    [self setTitle:@"关注" forState:UIControlStateNormal];
    [self setTitleColor:[UIColor themeRed1] forState:UIControlStateNormal];
    
    if(self.style == FHUGCFollowButtonStyleBorder){
        self.layer.borderWidth = 0.5f;
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
    self.enabled = NO;
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
        self.enabled = YES;
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
    [self startLoading];
    //增加延迟，为了动画效果
    CGFloat delayTime = 1.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestData];
    });
}

- (void)requestData {
    if(isEmptyString(self.groupId)){
        return;
    }

    __weak typeof(self) wself = self;
    [[FHUGCFollowManager sharedInstance] followUGCBy:self.groupId isFollow:!self.followed completion:^(BOOL isSuccess) {
        [wself stopLoading];
        if(isSuccess){
            wself.followed = !self.followed;
        }else{
            if (wself.followed) {
                [[ToastManager manager] showToast:@"取消关注失败"];
            } else {
                [[ToastManager manager] showToast:@"关注失败"];
            }
        }
        
        if(self.followedSuccess){
            self.followedSuccess(isSuccess,wself.followed);
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
    __weak typeof(self) wself = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认要退出吗"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             // 点击取消按钮，调用此block
                                                         }];
    [alert addAction:cancelAction];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              // 点击按钮，调用此block
                                                              [wself doFollow];
                                                          }];
    [alert addAction:defaultAction];
    [[TTUIResponderHelper visibleTopViewController] presentViewController:alert animated:YES completion:nil];
}


@end
