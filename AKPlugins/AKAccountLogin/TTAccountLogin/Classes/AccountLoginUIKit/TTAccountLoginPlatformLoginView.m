//
//  TTAccountLoginPlatformLoginView.m
//  TTAccountLogin
//
//  Created by huic on 16/3/1.
//
//

#import "TTAccountLoginPlatformLoginView.h"
#import <TTAlphaThemedButton.h>
#import <UIButton+TTAdditions.h>
#import <UIViewAdditions.h>
#import <TTThemeManager.h>
#import <Masonry.h>
#import <TTAccountSDK.h>
#import "TTAccountLoginConfLogic.h"



#define kTTAccountLoginTipTitleHeight          (14.f)
#define kTTAccountLoginTitleToButtonMargin     (26.f)
#define kTTAccountLoginPlatformButtonHeight    (54.f)
#define kTTAccountLoginPlatformMaskImageWidth  (32.f)
#define kTTAccountLoginPlatformHorizonMargin   (10.f)
#define kTTAccountLoginPlatformRightIconHeight (16.f)



@interface TTAccountLoginPlatformLoginView ()
@property (nonatomic, strong) SSThemedLabel       *tipLabel;
@property (nonatomic, strong) SSThemedScrollView  *containerView;
@property (nonatomic, strong) TTAlphaThemedButton *weixinButton;
@property (nonatomic, strong) TTAlphaThemedButton *douyinButton;
@property (nonatomic, strong) TTAlphaThemedButton *huoshanButton;
@property (nonatomic, strong) TTAlphaThemedButton *qqButton;
@property (nonatomic, strong) TTAlphaThemedButton *sinaButton;
@property (nonatomic, strong) TTAlphaThemedButton *tencentButton;
@property (nonatomic, strong) TTAlphaThemedButton *renrenButton;
@property (nonatomic, strong) TTAlphaThemedButton *tianyiButton; //天翼登录
@property (nonatomic, strong) TTAlphaThemedButton *phoneButton;
@property (nonatomic, strong) TTAlphaThemedButton *mailButton;
@property (nonatomic, strong) TTAlphaThemedButton *showMoreButton;
@property (nonatomic, strong) SSThemedImageView   *topMaskImageView;
@property (nonatomic, strong) SSThemedImageView   *bottomMaskImageView;
@property (nonatomic, strong) NSDictionary        *buttonDict;
@property (nonatomic, assign) BOOL                 showMore;

@property(nonatomic, strong) NSMutableArray *showArray;
@property(nonatomic, strong) NSMutableArray *hideArray;

@property (nonatomic, assign) TTAccountLoginPlatformType types;
@property (nonatomic, strong) NSArray<NSString *> *excludedPlatformNames; // 记录不显示的平台名称
@end

@implementation TTAccountLoginPlatformLoginView

- (instancetype)initWithFrame:(CGRect)frame
                platformTypes:(TTAccountLoginPlatformType)types
            excludedPlatforms:(NSArray<NSString *> *)platformsNames;
{
    if (self = [super initWithFrame:frame]) {
        // 计算控件高度
        self.height = kTTAccountLoginPlatformButtonHeight;
        self.types = types;
        self.excludedPlatformNames = platformsNames;
        
        NSArray<NSString *> *platforms = [self thirdLoginPlatforms];
        [self addSubview:self.containerView];
        for (NSString *identifier in platforms) {
            TTAlphaThemedButton *btn = [self enableButtonWithIdentifier:identifier];
            if (btn) {
                [self.containerView addSubview:btn];
            }
        }
        
        self.showArray = [NSMutableArray array];
        self.hideArray = [NSMutableArray array];
        
        for (TTAlphaThemedButton *btn in self.containerView.subviews) {
            if (btn.tag > 999) {
                if (_showArray.count < 4) {
                    [_showArray addObject:btn];
                } else {
                    [_hideArray addObject:btn];
                }
            }
        }
        
        if (_hideArray.count) { //如果没有隐藏的图标就不要展开了
            [self.containerView addSubview:self.showMoreButton];
        }
        
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.equalTo(self);
        }];
        
        [self addSubview:self.topMaskImageView];
        [self addSubview:self.bottomMaskImageView];
        [self.topMaskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(self);
            make.height.equalTo(@(kTTAccountLoginPlatformButtonHeight));
            make.width.equalTo(@(kTTAccountLoginPlatformMaskImageWidth));
        }];
        [self.bottomMaskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self);
            make.height.equalTo(@(kTTAccountLoginPlatformButtonHeight));
            make.width.equalTo(@(kTTAccountLoginPlatformMaskImageWidth));
        }];
        
        [self showMoreButtonClicked:nil];
    }
    return self;
}

/**
 *  初始化控件，显示的icon在show数组，隐藏的icon在hide数组
 *
 *  @return ArticlePlatformLoginView
 */
- (instancetype)init
{
    return [self initWithFrame:[UIScreen mainScreen].bounds platformTypes:TTAccountLoginPlatformTypeAll excludedPlatforms:nil];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshIconsAutoSet:YES];
}

- (NSArray<NSValue *> *)refreshIconsAutoSet:(BOOL)autoSet
{
    CGFloat leftMargin = 0.0;
    CGFloat showWidth = 0.0;
    [self.containerView layoutIfNeeded];
    if (_showArray.count > 0) {
        showWidth = kTTAccountLoginPlatformHorizonMargin * (_showArray.count - 1) + kTTAccountLoginPlatformButtonHeight * _showArray.count;
        leftMargin = MAX(0.0, (self.containerView.width - showWidth) / 2);
    }
    
    NSMutableArray <NSValue *>*frameArray = @[].mutableCopy;
    for (int i = 0; i < _showArray.count; ++i) {
        TTAlphaThemedButton *btn = [_showArray objectAtIndex:i];
        CGRect currentRect = btn.frame;
        currentRect.size = CGSizeMake(kTTAccountLoginPlatformButtonHeight, kTTAccountLoginPlatformButtonHeight);
        CGPoint centerPoint = CGPointMake(btn.centerX, self.height - kTTAccountLoginPlatformButtonHeight / 2);
        currentRect.origin = CGPointMake(centerPoint.x - currentRect.size.width / 2, centerPoint.y - currentRect.size.height / 2);
        currentRect.origin.x = leftMargin + i * (kTTAccountLoginPlatformButtonHeight + kTTAccountLoginPlatformHorizonMargin);
        [frameArray addObject:[NSValue valueWithCGRect:currentRect]];
    }
    
    if (_hideArray.count) {
        _showMoreButton.size = CGSizeMake(kTTAccountLoginPlatformRightIconHeight, kTTAccountLoginPlatformRightIconHeight);
        _showMoreButton.centerY = self.height - kTTAccountLoginPlatformButtonHeight / 2;
        _showMoreButton.left = leftMargin + (showWidth > 0.0 ? showWidth : 0) + 15.f;//_tipLabel.right + 3;
    }
    
    //处理一下是否要设置offset
    if (leftMargin <= kTTAccountLoginPlatformMaskImageWidth) {
        self.containerView.contentInset = UIEdgeInsetsMake(0, kTTAccountLoginPlatformMaskImageWidth - leftMargin, 0, kTTAccountLoginPlatformMaskImageWidth);
        self.containerView.contentOffset = CGPointMake(-kTTAccountLoginPlatformMaskImageWidth + leftMargin, 0);
    }
    
    if (autoSet) {
        for (int i = 0; i < _showArray.count; ++i) {
            TTAlphaThemedButton *btn = [_showArray objectAtIndex:i];
            CGRect btnFrame = [[frameArray objectAtIndex:i] CGRectValue];
            btn.frame = btnFrame;
            btn.hidden = NO;
        }
    }
    
    leftMargin += showWidth + kTTAccountLoginPlatformHorizonMargin;
    for (int i = 0; i < _hideArray.count; ++i) {
        TTAlphaThemedButton *btn = [_hideArray objectAtIndex:i];
        btn.size = CGSizeMake(kTTAccountLoginPlatformButtonHeight, kTTAccountLoginPlatformButtonHeight);
        //竖直居中布局
        btn.centerY = self.height / 2;
        btn.left = leftMargin + i * (kTTAccountLoginPlatformButtonHeight + kTTAccountLoginPlatformHorizonMargin);
        btn.hidden = YES;
    }
    
    _containerView.contentSize = CGSizeMake(_showArray.count * (kTTAccountLoginPlatformButtonHeight + kTTAccountLoginPlatformHorizonMargin) - kTTAccountLoginPlatformHorizonMargin, _containerView.height);
    
    return  frameArray;
}

#pragma mark - Actions

/**
 *  点击展开更多icon
 *  将hide数组中隐藏的icon通过动画形式展现
 *  @param sender 事件发送者
 */
- (void)showMoreButtonClicked:(id)sender
{
    [_showArray addObjectsFromArray:self.hideArray];
    [_hideArray removeAllObjects];
    _showMoreButton.hidden = YES;
    
    if (_showArray.firstObject) {
        [self refreshIconsAutoSet:YES];
    }
}

/**
 *  使用邮箱登录
 *  这边需要做一下下面icon显示的变化及其动画
 */
- (void)mailButtonClick:(UIButton *)sender
{
    [_showArray removeObject:sender];
    if (![_hideArray containsObject:sender]) {
        [_hideArray addObject:sender];
    }
    
    NSArray <NSValue *>* frameArray = [self refreshIconsAutoSet:NO];
    [UIView animateWithDuration:0.3 animations:^{
        for (int i = 0; i < _showArray.count; ++i) {
            TTAlphaThemedButton *btn = [_showArray objectAtIndex:i];
            CGRect btnFrame = [[frameArray objectAtIndex:i] CGRectValue];
            btn.frame = btnFrame;
            btn.hidden = NO;
        }
    }];
}

- (void)chanTypeToPhoneLogin
{
    if (![_showArray containsObject:_mailButton]) {
        [_showArray addObject:_mailButton];
    }
    [_hideArray removeObject:_mailButton];
    _mailButton.alpha = 0.f;
    NSArray <NSValue *>* frameArray = [self refreshIconsAutoSet:NO];
    [UIView animateWithDuration:0.3 animations:^{
        for (int i = 0; i < _showArray.count; ++i) {
            TTAlphaThemedButton *btn = [_showArray objectAtIndex:i];
            CGRect btnFrame = [[frameArray objectAtIndex:i] CGRectValue];
            btn.frame = btnFrame;
            btn.hidden = NO;
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _mailButton.alpha = 1.f;
        }];
    }];
}

- (void)phoneButtonClick:(UIButton *)sender
{
    [_showArray removeObject:sender];
    if (![_hideArray containsObject:sender]) {
        [_hideArray addObject:sender];
    }
    if (![_showArray containsObject:_mailButton]) {
        [_showArray addObject:_mailButton];
    }
    [_hideArray removeObject:_mailButton];
    _mailButton.alpha = 0.f;
    NSArray <NSValue *>* frameArray = [self refreshIconsAutoSet:NO];
    [UIView animateWithDuration:0.5 animations:^{
        for (int i = 0; i < _showArray.count; ++i) {
            TTAlphaThemedButton *btn = [_showArray objectAtIndex:i];
            CGRect btnFrame = [[frameArray objectAtIndex:i] CGRectValue];
            btn.frame = btnFrame;
            btn.hidden = NO;
        }
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            _mailButton.alpha = 1.f;
        }];
    });
}

/**
 *  点击第三方登录icon
 *  根据tag值映射成为相应的keyName，通过delegate传递到VC
 *  @param sender 事件发送者
 */
- (void)platformButtonClicked:(UIButton *)sender
{
    NSString *keyName = nil;
    if (sender.tag == 1001) {
        keyName = TT_LOGIN_PLATFORM_SINAWEIBO;
    } else if (sender.tag == 1000) {
        keyName = TT_LOGIN_PLATFORM_QZONE;
    } else if (sender.tag == 1002) {
        keyName = TT_LOGIN_PLATFORM_WECHAT;
    } else if (sender.tag == 1003) {
        keyName = TT_LOGIN_PLATFORM_QQWEIBO;
    } else if (sender.tag == 1004) {
        keyName = TT_LOGIN_PLATFORM_RENREN;
    } else if (sender.tag == 1005) {
        keyName = TT_LOGIN_PLATFORM_TIANYI;
    } else if (sender.tag == 1011) {
        keyName = TT_LOGIN_PLATFORM_EMAIL;
    } else if (sender.tag == 1010) {
        keyName = TT_LOGIN_PLATFORM_PHONE;
    } else if (sender.tag == 1006) {
        keyName = TT_LOGIN_PLATFORM_HUOSHAN;
    } else if (sender.tag == 1007) {
        keyName = TT_LOGIN_PLATFORM_DOUYIN;
    }
    
    if (_delegate) {
        [_delegate loginPlatform:keyName];
    }
}

#pragma mark - Helper

- (BOOL)installedWeixin
{
    return [TTAccountAuthWeChat isAppAvailable];
}

//- (BOOL)installedDouyin
//{
//    return [TTAccountAuthDouYin isAppAvailable];
//}
//
//- (BOOL)installedHuoshan
//{
//    return [TTAccountAuthHuoShan isAppAvailable];
//}
//
//- (BOOL)installedQQ
//{
//    return [TTAccountAuthTencent isAppAvailable];
//}
//
//- (BOOL)installedWeibo
//{
//    return [TTAccountAuthWeibo isAppAvailable];
//}

/**
 *  初始化第三方登录Button
 *
 *  @param tag
 *  @param imageName Button图片
 *
 *  @return 自带Highlighted的TTAlphaThemedButton
 */
- (TTAlphaThemedButton *)getAccountButton:(NSString *)tag
                                imageName:(NSString *)imageName
{
    TTAlphaThemedButton *button = [[TTAlphaThemedButton alloc] init];
    button.tag = [tag intValue];
    button.imageName = imageName;
    [button addTarget:self
               action:@selector(platformButtonClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (NSArray<NSString *> *)thirdLoginPlatforms
{
    // 首先获取服务端下发的渠道
    NSArray<NSString *> *loginPlatforms = [TTAccountLoginConfLogic loginPlatformEntryList];
    if ([loginPlatforms count] <= 0) {
        // 下发为空，以默认为准
        loginPlatforms = @[TT_LOGIN_PLATFORM_WECHAT,
                           TT_LOGIN_PLATFORM_HUOSHAN,
                           TT_LOGIN_PLATFORM_DOUYIN,
                           TT_LOGIN_PLATFORM_QZONE,
                           // TT_LOGIN_PLATFORM_SINAWEIBO,  /** 微博默认下掉 */
                           TT_LOGIN_PLATFORM_TIANYI,
                           TT_LOGIN_PLATFORM_EMAIL,
                           // TT_LOGIN_PLATFORM_QQWEIBO,    /** 不再支持 */
                           // TT_LOGIN_PLATFORM_RENREN      /** 不再支持 */
                           ];
    }
    
    NSMutableArray<NSString *> *sortedPlatforms = [NSMutableArray array];
    if ([loginPlatforms count] > 0) {
        if ([self installedWeixin] &&
            ([loginPlatforms containsObject:TT_LOGIN_PLATFORM_WECHAT])) {
            [sortedPlatforms addObject: TT_LOGIN_PLATFORM_WECHAT];
        }
        
//        if ([self installedHuoshan] &&
//            ([loginPlatforms containsObject:TT_LOGIN_PLATFORM_HUOSHAN])) {
//            [sortedPlatforms addObject: TT_LOGIN_PLATFORM_HUOSHAN];
//        }
//
//        if ([self installedDouyin] &&
//            ([loginPlatforms containsObject:TT_LOGIN_PLATFORM_DOUYIN])) {
//            [sortedPlatforms addObject: TT_LOGIN_PLATFORM_DOUYIN];
//        }
        
        if ([loginPlatforms containsObject:TT_LOGIN_PLATFORM_QZONE]) {
            [sortedPlatforms addObject: TT_LOGIN_PLATFORM_QZONE];
        }
        
        if ([loginPlatforms containsObject:TT_LOGIN_PLATFORM_SINAWEIBO]) {
            [sortedPlatforms addObject: TT_LOGIN_PLATFORM_SINAWEIBO];
        }
        
        if ([loginPlatforms containsObject:TT_LOGIN_PLATFORM_TIANYI]) {
            [sortedPlatforms addObject: TT_LOGIN_PLATFORM_TIANYI];
        }
        
        if ([loginPlatforms containsObject:TT_LOGIN_PLATFORM_EMAIL]) {
            [sortedPlatforms addObject:TT_LOGIN_PLATFORM_EMAIL];
        }
        
        if ([loginPlatforms containsObject:TT_LOGIN_PLATFORM_QQWEIBO]) {
            [sortedPlatforms addObject: TT_LOGIN_PLATFORM_QQWEIBO];
        }
        
        if ([loginPlatforms containsObject:TT_LOGIN_PLATFORM_RENREN]) {
            [sortedPlatforms addObject: TT_LOGIN_PLATFORM_RENREN];
        }
    }
    return sortedPlatforms;
}

- (TTAlphaThemedButton *)enableButtonWithIdentifier:(NSString *)identifier
{
    if (!_buttonDict) {
        _buttonDict = @{
                        TT_LOGIN_PLATFORM_PHONE     : self.phoneButton,  // 1010
                        TT_LOGIN_PLATFORM_WECHAT    : self.weixinButton, // 1002
                        TT_LOGIN_PLATFORM_DOUYIN    : self.douyinButton, // 1007
                        TT_LOGIN_PLATFORM_HUOSHAN   : self.huoshanButton,// 1006
                        TT_LOGIN_PLATFORM_RENREN    : self.renrenButton, // 1004
                        TT_LOGIN_PLATFORM_QZONE     : self.qqButton,     // 1000
                        TT_LOGIN_PLATFORM_QQWEIBO   : self.tencentButton,// 1003
                        TT_LOGIN_PLATFORM_SINAWEIBO : self.sinaButton,   // 1001
                        TT_LOGIN_PLATFORM_EMAIL     : self.mailButton,   // 1011
                        TT_LOGIN_PLATFORM_TIANYI    : self.tianyiButton, // 1005
                        };
    }
    if (![self loginTypeIsEnableWithIdentifier:identifier]) {
        return nil;
    }
    
    TTAlphaThemedButton *btn = [_buttonDict objectForKey:identifier];
    return btn;
}

// 判断平台是否展示
- (BOOL)isShowingForPlatform:(NSString *)platformName
{
    if (!platformName) return NO;
    
    __block BOOL bShowing = NO;
    
    void (^isPlatformShowingBlock)(NSInteger) = ^(NSInteger tag) {
        [self.showArray enumerateObjectsUsingBlock:^(TTAlphaThemedButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tag == tag) {
                bShowing = YES;
                *stop = YES;
            }
        }];
    };
    
    if ([platformName isEqualToString:TT_LOGIN_PLATFORM_EMAIL]) {
        isPlatformShowingBlock(1011);
    }
    else if ([platformName isEqualToString:TT_LOGIN_PLATFORM_PHONE]) {
        isPlatformShowingBlock(1010);
    }
    else if (([platformName isEqualToString:TT_LOGIN_PLATFORM_WECHAT])) {
        isPlatformShowingBlock(1002);
    }
    else if ([platformName isEqualToString:TT_LOGIN_PLATFORM_WECHAT_SNS]) {
        isPlatformShowingBlock(1002);
    }
    else if ([platformName isEqualToString:TT_LOGIN_PLATFORM_QZONE]) {
        isPlatformShowingBlock(1000);
    }
    else if ([platformName isEqualToString:TT_LOGIN_PLATFORM_QQWEIBO]) {
        isPlatformShowingBlock(1003);
    }
    else if ([platformName isEqualToString:TT_LOGIN_PLATFORM_SINAWEIBO]) {
        isPlatformShowingBlock(1001);
    }
    else if ([platformName isEqualToString:TT_LOGIN_PLATFORM_TIANYI]) {
        isPlatformShowingBlock(1005);
    }
    else if ([platformName isEqualToString:TT_LOGIN_PLATFORM_HUOSHAN]) {
        isPlatformShowingBlock(1006);
    }
    else if ([platformName isEqualToString:TT_LOGIN_PLATFORM_DOUYIN]) {
        isPlatformShowingBlock(1007);
    }
    return bShowing;
}

- (BOOL)loginTypeIsEnableWithIdentifier:(NSString *)identifier
{
    if (identifier && [self.excludedPlatformNames containsObject:identifier]) {
        return NO;
    }
    
    if ([identifier isEqualToString:TT_LOGIN_PLATFORM_EMAIL]) {
        return _types & TTAccountLoginPlatformTypeEmail;
    }
    if ([identifier isEqualToString:TT_LOGIN_PLATFORM_PHONE]) {
        return _types & TTAccountLoginPlatformTypePhone;
    }
    if ([self installedWeixin] &&
        ([identifier isEqualToString:TT_LOGIN_PLATFORM_WECHAT])) {
        return _types & TTAccountLoginPlatformTypeWeChat;
    }
    if ([identifier isEqualToString:TT_LOGIN_PLATFORM_WECHAT_SNS]) {
        return _types & TTAccountLoginPlatformTypeWeChatSNS;
    }
    if ([identifier isEqualToString:TT_LOGIN_PLATFORM_QZONE]) {
        return _types & TTAccountLoginPlatformTypeQZone;
    }
    if ([identifier isEqualToString:TT_LOGIN_PLATFORM_QQWEIBO]) {
        return _types & TTAccountLoginPlatformTypeQQWeibo;
    }
    if ([identifier isEqualToString:TT_LOGIN_PLATFORM_SINAWEIBO]) {
        return _types & TTAccountLoginPlatformTypeSinaWeibo;
    }
    if ([identifier isEqualToString:TT_LOGIN_PLATFORM_RENREN]) {
        return _types & TTAccountLoginPlatformTypeRenRen;
    }
    if ([identifier isEqualToString:TT_LOGIN_PLATFORM_TIANYI]) {
        return _types & TTAccountLoginPlatformTypeTianYi;
    }
    if ([identifier isEqualToString:TT_LOGIN_PLATFORM_HUOSHAN]) {
        return _types & TTAccountLoginPlatformTypeHuoshan;
    }
    if ([identifier isEqualToString:TT_LOGIN_PLATFORM_DOUYIN]) {
        return _types & TTAccountLoginPlatformTypeDouyin;
    }
    
    return NO;
}

#pragma mark - Getter/Setter

- (SSThemedLabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.numberOfLines = 1;
        _tipLabel.textColorThemeKey = kColorText1;
        _tipLabel.font = [UIFont systemFontOfSize:kTTAccountLoginTipTitleHeight];
        _tipLabel.text = @"更多登录方式";
        [_tipLabel sizeToFit];
    }
    return _tipLabel;
}

- (TTAlphaThemedButton *)mailButton
{
    if (!_mailButton) {
        _mailButton = [self getAccountButton:@"1011"
                                   imageName:@"mailbox_sdk_login"];
    }
    return _mailButton;
}

- (TTAlphaThemedButton *)phoneButton
{
    if (!_phoneButton) {
        _phoneButton = [self getAccountButton:@"1010"
                                    imageName:@"cellphoneicon_login_profile"];
        [_phoneButton addTarget:self
                         action:@selector(phoneButtonClick:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _phoneButton;
}

- (TTAlphaThemedButton *)qqButton
{
    if (!_qqButton) {
        _qqButton = [self getAccountButton:@"1000"
                                 imageName:@"qq_sdk_login"];
    }
    return _qqButton;
}

- (TTAlphaThemedButton *)sinaButton
{
    if (!_sinaButton) {
        _sinaButton = [self getAccountButton:@"1001"
                                   imageName:@"sina_sdk_login"];
    }
    return _sinaButton;
}

- (TTAlphaThemedButton *)weixinButton
{
    if (!_weixinButton) {
        _weixinButton = [self getAccountButton:@"1002"
                                     imageName:@"weixin_sdk_login"];
    }
    return _weixinButton;
}

- (TTAlphaThemedButton *)tencentButton
{
    if (!_tencentButton) {
        _tencentButton = [self getAccountButton:@"1003"
                                      imageName:@"weibo_sdk_login"];
    }
    return _tencentButton;
}

- (TTAlphaThemedButton *)renrenButton
{
    if (!_renrenButton) {
        _renrenButton = [self getAccountButton:@"1004"
                                     imageName:@"renren_sdk_login"];
    }
    return _renrenButton;
}

- (TTAlphaThemedButton *)tianyiButton
{
    if (!_tianyiButton) {
        _tianyiButton = [self getAccountButton:@"1005"
                                     imageName:@"tianyi_sdk_login"];
    }
    return _tianyiButton;
}

- (TTAlphaThemedButton *)huoshanButton
{
    if (!_huoshanButton) {
        _huoshanButton = [self getAccountButton:@"1006"
                                      imageName:@"huoshan_sdk_login"];
    }
    return _huoshanButton;
}

- (TTAlphaThemedButton *)douyinButton
{
    if (!_douyinButton) {
        _douyinButton = [self getAccountButton:@"1007"
                                     imageName:@"douyin_sdk_login"];
    }
    return _douyinButton;
}

- (TTAlphaThemedButton *)showMoreButton
{
    if (!_showMoreButton) {
        _showMoreButton = [[TTAlphaThemedButton alloc] init];
        //增大点击范围
        _showMoreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -3 - CGRectGetWidth(_tipLabel.frame), -5, -10);
        _showMoreButton.imageName = @"rightbackicon_sdk_login";
        [_showMoreButton addTarget:self
                            action:@selector(showMoreButtonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    return _showMoreButton;
}

- (SSThemedScrollView *)containerView
{
    if (!_containerView) {
        _containerView = [SSThemedScrollView new];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.showsVerticalScrollIndicator = NO;
        _containerView.showsHorizontalScrollIndicator = NO;
        _containerView.scrollEnabled = YES;
    }
    return _containerView;
}

- (SSThemedImageView *)topMaskImageView
{
    if (!_topMaskImageView) {
        _topMaskImageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _topMaskImageView.imageName = @"left_cover";
    }
    return _topMaskImageView;
}

- (SSThemedImageView *)bottomMaskImageView
{
    if (!_bottomMaskImageView) {
        _bottomMaskImageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _bottomMaskImageView.imageName = @"right_cover";
    }
    return _bottomMaskImageView;
}

@end

