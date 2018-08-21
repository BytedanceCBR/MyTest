//
//  TTPersonalHomeErrorView.m
//  Article
//
//  Created by wangdi on 2017/4/12.
//
//

#import "TTPersonalHomeErrorView.h"
#import "TTCancelFollowButton.h"
#import "FriendDataManager.h"
#import "TTIndicatorView.h"
#import <SSNavigationBar.h>

@interface TTPersonalHomeNavView ()

@property (nonatomic, weak) SSThemedButton *backBtn;
@property (nonatomic, weak) SSThemedView *bottomLine;

@end

@implementation TTPersonalHomeNavView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
        SSThemedButton *backBtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        backBtn.imageName = @"personal_home_back_black";
        [self addSubview:backBtn];
        self.backBtn = backBtn;
        
        SSThemedView *bottomLine = [[SSThemedView alloc] init];
        bottomLine.backgroundColorThemeKey = kColorLine1;
        [self addSubview:bottomLine];
        self.bottomLine = bottomLine;
    }
    return self;
}

- (void)back
{
    if(self.backBlock) {
        self.backBlock();
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat topInset = 20;
    if (@available(iOS 11.0, *)) {
        topInset = self.safeAreaInsets.top;
    }
    
    self.backBtn.left = [TTDeviceUIUtils tt_newPadding:10];
    self.backBtn.width = self.backBtn.currentImage.size.width;
    self.backBtn.height = self.backBtn.currentImage.size.height;
    self.backBtn.top = (44 - self.backBtn.height) * 0.5 + topInset;
    
    self.bottomLine.width = self.width;
    self.bottomLine.left = 0;
    self.bottomLine.height = [TTDeviceHelper ssOnePixel];
    self.bottomLine.top = self.height - self.bottomLine.height;
}

@end

@interface TTPersonalHomeErrorView()

@property (nonatomic, strong) TTPersonalHomeNavView *navView;
@property (nonatomic, strong) SSThemedImageView *errorIcon;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTCancelFollowButton *followCancelButton;

@end

@implementation TTPersonalHomeErrorView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [self addGestureRecognizer:tap];
        [self setupSubview];
        self.errorType = ErrorTypeNone;
    }
    return self;
}

- (void)setupSubview
{
    TTPersonalHomeNavView *navView = [[TTPersonalHomeNavView alloc] init];
    __weak typeof(self) weakSelf = self;
    navView.backBlock = ^{
        [weakSelf back];
    };
    navView.backgroundColorThemeKey = kColorBackground4;
    [self addSubview:navView];
    self.navView = navView;
    
    SSThemedImageView *errorIcon = [[SSThemedImageView alloc] init];
    [self addSubview:errorIcon];
    self.errorIcon = errorIcon;
    
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:14]];
    titleLabel.textColorThemeKey = kColorText3;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
}

- (TTCancelFollowButton *)followCancelButton{
    
    if (!_followCancelButton) {
        _followCancelButton = [[TTCancelFollowButton alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_lineHeight:72], 28)];
        _followCancelButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        [_followCancelButton addTarget:self action:@selector(clickFollowButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_followCancelButton];
    }
    
    return _followCancelButton;
    
}

- (void)back
{
    if(self.backBlock) {
        self.backBlock();
    }
}

- (void)setErrorType:(ErrorType)errorType
{
    _errorType = errorType;
    if(errorType == ErrorTypeNone) {
        self.errorIcon.hidden = YES;
        self.titleLabel.hidden = YES;
    } else {
        self.errorIcon.hidden = NO;
        self.titleLabel.hidden = NO;
        if(errorType == ErrorTypeClosureError) {
            
            if (!isEmptyString(self.errorString)) {
                self.titleLabel.text = self.errorString;
            }
            else {
                self.titleLabel.text = @"抱歉，访问的用户已经被封禁";
    
            }
            self.errorIcon.imageName = @"personal_home_error";
        }
        else if (errorType == ErrorTypeClosureFollowError){
            
            if (!isEmptyString(self.errorString)) {
                self.titleLabel.text = self.errorString;
            }
            else {
                self.titleLabel.text = @"抱歉，访问的用户已经被封禁";
                
            }
            self.errorIcon.imageName = @"personal_home_error";
            
            self.followCancelButton.followState = TTFolloweStateFollow;
        }
        
        else if (errorType == ErrorTypeDataError){
            
            if (!isEmptyString(self.errorString)) {
                self.titleLabel.text = self.errorString;
            }
            else {
                self.titleLabel.text = @"信息读取失败，请稍后重试";
            }
            self.errorIcon.imageName = @"personal_network_error";
        }
        
        else if(errorType == ErrorTypeNetWorkError) {
            self.titleLabel.text = @"网络不给力，点击屏幕重试";
            self.errorIcon.imageName = @"personal_network_error";
        }
    }
    [self setNeedsLayout];
}

- (void)tapClick
{
    if(self.errorType == ErrorTypeNetWorkError) {
        if(self.retryConnectionNetworkBlock) {
            self.retryConnectionNetworkBlock();
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.navView.frame = CGRectMake(0, 0, self.width, [SSNavigationBar navigationBarHeight]);
    
    self.errorIcon.width = self.errorIcon.image.size.width;
    self.errorIcon.height = self.errorIcon.image.size.height;
    self.errorIcon.centerX = self.width * 0.5;
    
    if(self.errorType == ErrorTypeNetWorkError || self.errorType == ErrorTypeDataError) {
        self.errorIcon.top = self.navView.bottom + [TTDeviceUIUtils tt_newPadding:87];
    } else if(self.errorType == ErrorTypeClosureError || self.errorType == ErrorTypeClosureFollowError) {
        self.errorIcon.width = 59;
        self.errorIcon.height = 41;
        self.errorIcon.centerX = self.width * 0.5;
        self.errorIcon.top = self.navView.bottom + [TTDeviceUIUtils tt_newPadding:87];
    }
    self.titleLabel.left = [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.top = self.errorIcon.bottom + [TTDeviceUIUtils tt_newPadding:12];
    self.titleLabel.width = self.width - 2 * self.titleLabel.left;
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(self.titleLabel.width, MAXFLOAT)];
    self.titleLabel.height = titleLabelSize.height;
    if (self.errorType == ErrorTypeClosureFollowError) {
        self.followCancelButton.top = self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:12];
        self.followCancelButton.centerX = self.centerX;
    }
}

- (void)clickFollowButton:(id)sender{
    
    if (self.errorType != ErrorTypeClosureFollowError) {
        return;
    }
    
    if (self.followCancelButton.followState == TTFolloweStateFollow) {
        self.followCancelButton.enabled = YES;
        
        if (!isEmptyString(self.userId)) {
            
            [self.followCancelButton startLoading];
            WeakSelf;
            
            TTFollowNewSource source = TTFollowNewSourceProfile;
            [[TTFollowManager sharedManager] startFollowAction:FriendActionTypeUnfollow userID:self.userId platform:nil name:nil from:nil reason:nil newReason:nil newSource:@(source) completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                StrongSelf;
                
                [self.followCancelButton stopLoading];
                if (error) {
                    
                    NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                    if (isEmptyString(hint)) {
                        hint = NSLocalizedString(@"取消关注失败" ,nil);
                    }
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage"] autoDismiss:YES dismissHandler:nil];
                    
                    self.followCancelButton.followState = TTFolloweStateFollow;
                    
                } else {
                    
                    self.followCancelButton.followState = TTFolloweStateCancel;
                    
                }
                
            }];
        }
        
    }
    
    else {
        self.followCancelButton.enabled = NO;
    }
    
}

@end
