//
//  TFRegistView.m
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-26.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import "TFRegistView.h"
#import "SSTitleBarView.h"
#import "SSButton.h"
#import "UIColorAdditions.h"
#import "TFFetchInfoManager.h"
#import "SSActivityIndicatorView.h"
#import "NetworkUtilities.h"
#import "TFManager.h"

@interface TFRegistView()
@property(nonatomic, retain)SSTitleBarView * titleBar;
@property(nonatomic, retain)UIView * contactView;
@property(nonatomic, retain)UIView * identityView;
@property(nonatomic, retain)UITextField * contactField;
@property(nonatomic, retain)UITextField * identityField;
@property(nonatomic, retain)UIButton * registButton;

@end

@implementation TFRegistView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.registButton = nil;
    self.contactView = nil;
    self.identityView = nil;
    self.titleBar = nil;
    self.contactField = nil;
    self.identityField = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithHexString:@"eeeeee"];
        
        //build title
        
        self.titleBar = [[[SSTitleBarView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [SSTitleBarView titleBarHeight])] autorelease];
        UIImage *bgImage = [[UIImage resourceImageNamed:@"titlebarbg.png"] stretchableImageWithLeftCapWidth:0.5 topCapHeight:22];
        [_titleBar setBackgroundImage:bgImage];
        [self addSubview:_titleBar];
        [_titleBar setTitleText:@"注册"];
        
//        SSButton * refreshButton = [SSButton buttonWithSSButtonType:SSButtonTypeRefresh];
//        [refreshButton addTarget:self action:@selector(refreshButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//        _titleBar.rightView = refreshButton;
//        
        //build view
        
        self.identityView = [[[UIView alloc] initWithFrame:[self frameForIdentityView]] autorelease];
        [self addSubview:_identityView];
        
        UIImageView * identityBgView = [[[UIImageView alloc] initWithImage:[self backgroundImge]] autorelease];
        identityBgView.backgroundColor = [UIColor clearColor];
        identityBgView.frame = _identityView.bounds;
        [_identityView addSubview:identityBgView];
        
        self.identityField = [[[UITextField alloc] initWithFrame:[self frameForIdentityField]] autorelease];
        _identityField.backgroundColor = [UIColor clearColor];
        _identityField.font = [UIFont systemFontOfSize:15.f];
        _identityField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _identityField.placeholder = @"用户名";
        [_identityView addSubview:_identityField];
        
        self.contactView = [[[UIView alloc] initWithFrame:[self frameForContactView]] autorelease];
        [self addSubview:_contactView];
        
        UIImageView * contactBgView = [[[UIImageView alloc] initWithImage:[self backgroundImge]] autorelease];
        contactBgView.backgroundColor = [UIColor clearColor];
        contactBgView.frame = _identityView.bounds;
        [_contactView addSubview:contactBgView];
        
        self.contactField = [[[UITextField alloc] initWithFrame:[self frameForContactField]] autorelease];
        _contactField.backgroundColor = [UIColor clearColor];
        _contactField.font = [UIFont systemFontOfSize:15.f];
        _contactField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _contactField.placeholder = @"电子邮件";
        [_contactView addSubview:_contactField];
        
        self.registButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _registButton.frame = [self frameForRegistButton];
        [_registButton addTarget:self action:@selector(registButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _registButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
        [_registButton setTitle:@"注册/登录" forState:UIControlStateNormal];
        
        [self addSubview:_registButton];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchInfoFail:) name:kFetchInfoFailedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchInfoDone:) name:kFetchInfoDoneNotification object:nil];

        [self clearAccount];
        
        [self reloadThemeUI];
        
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification
{
    _registButton.backgroundColor = [UIColor colorWithHexString:SSUIString(@"ssTitleImageViewBackgroundColor", @"77157d")];
    
}

#pragma mark -- observer

- (void)fetchInfoDone:(NSNotification *)notification
{
    [self showMessage:@"登录成功"];
    [self back];
}

- (void)fetchInfoFail:(NSNotification *)notification
{
    NSString * errorType = [[notification userInfo] objectForKey:kErrorType];
    if ([errorType isEqualToString:vWaitVerifyType]) {
        [self showMessage:@"注册成功，请等待审核账户"];
        [self back];
    }
    else if([errorType isEqualToString:vEmailUnmatch]) {
        [self showMessage:@"Email与设备不匹配, 请重试"];
        [self clearAccount];
    }
    else if ([errorType isEqualToString:kNoNetConnectError]){
        [self showMessage:@"没有网络连接"];
    }
    else if ([errorType isEqualToString:kServerError]){
        [self showMessage:@"服务繁忙，请稍后重试"];
    }
    else {
        [self showMessage:@"请重新输入"];
        [self clearAccount];
    }
}

#pragma mark -- private

- (void)clearAccount
{
    [TFManager saveIsUserAvailable:NO];
    [TFManager saveTestFlightAccountEmail:nil];
    [TFManager saveTestFlightAccountIdentifier:nil];
}

- (void)back
{
    [[SSCommon topViewControllerFor:self] dismissModalViewControllerAnimated:YES];
}

#pragma mark -- life cycle

- (void)willAppear
{
    [super willAppear];
}

#pragma mark -- resource

- (UIImage *)backgroundImge
{
    return [[UIImage resourceImageNamed:SSUIString(@"feedbackPostViewContentBg", @"inputbox_repost.png")] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}


#pragma mark -- frame

- (CGRect)frameForIdentityField
{
   return CGRectMake(10, 0, [self frameForIdentityView].size.width - 20, [self frameForIdentityView].size.height);
    
}

- (CGRect)frameForIdentityView
{
    CGRect rect = CGRectMake(15, 80, self.frame.size.width - 30, 40);
    return rect;
}

- (CGRect)frameForContactField
{
    return [self frameForIdentityField];
}

- (CGRect)frameForContactView
{
    CGRect rect = [self frameForIdentityView];
    rect.origin.y = CGRectGetMaxY([self frameForIdentityView]) - 1;//1为图片边框
    return rect;
}

- (CGRect)frameForRegistButton
{
    CGRect rect = CGRectMake(0, CGRectGetMaxY([self frameForContactView]) + 30, 100, 44);
    rect.origin.x = self.frame.size.width - rect.size.width - [self frameForIdentityView].origin.x;
    return rect;
}

#pragma mark -- button target

//- (void)refreshButtonClicked
//{
//    NSLog(@"refreshButtonClicked");
//}

- (void)registButtonClicked
{
    
    if (isEmptyString(_identityField.text)) {
        [self showMessage:@"请输入用户名"];
        return;
    }
    
    if (isEmptyString(_contactField.text)) {
        [self showMessage:@"请输入电子邮件"];
        return;
    }
    
    if (!SSNetworkConnected()) {
        [self showMessage:@"没有网络连接"];
    }
    
    [self showMessage:@"注册中， 请稍后"];
    [[TFFetchInfoManager shareManager] startFetchInfos:_contactField.text identity:_identityField.text isRegister:YES];
}

- (void)showMessage:(NSString *)msg
{
    if (isEmptyString(msg)) {
        return;
    }
    [SSActivityIndicatorView sharedView].yOffset = -60;
    [[SSActivityIndicatorView sharedView] showMessage:msg];
}


@end
