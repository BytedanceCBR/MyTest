//
//  TTLoginCell.m
//  Article
//
//  Created by 王霖 on 17/1/6.
//
//

#import "TTLoginCell.h"
#import "ExploreOrderedData.h"
#import "Login.h"
#import <SSThemed.h>
#import "TTArticleCellConst.h"
#import <TTDeviceHelper.h>
#import <TTAlphaThemedButton.h>
#import "TTUISettingHelper.h"
#import "TTArticleCellHelper.h"
#import "AccountManager.h"
#import "ExploreMixListDefine.h"
#import "SSCommon+UIApplication.h"
#import "TTUIResponderHelper.h"

#define kLoginHintText @"登录关注好友动态，互动精彩不停"
#define kLoginText @"立即登录"

@interface TTLoginCell ()


@end

@implementation TTLoginCell

+ (Class)cellViewClass {
    return [TTLoginCellView class];
}

- (void)willDisplay{
    [super willDisplay];
    ssTrackEventWithCustomKeys(@"weitoutiao", @"login_card_ show", nil, @"weitoutiao", nil);
}

@end

@interface TTLoginCellView ()

@property (nonatomic, strong, nullable) ExploreOrderedData * orderedData;
@property (nonatomic, strong, nullable) Login * login;

@property (nonatomic, strong) SSThemedView * bottomLine;


@end

@implementation TTLoginCellView

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createComponents];
    }
    return self;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if ([data isKindOfClass:[ExploreOrderedData class]] && nil != [(ExploreOrderedData *)data login]) {
        return 110.f;
    }
    return 0;
}

- (void)createComponents {
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    
    self.bottomLine = [[SSThemedView alloc] initWithFrame:CGRectMake(kPaddingLeft(), self.bottom - [TTDeviceHelper ssOnePixel], self.width - kPaddingLeft() - kPaddingRight(), [TTDeviceHelper ssOnePixel])];
    self.bottomLine.backgroundColorThemeKey = kColorLine1;
    self.bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.bottomLine];
    
    UIFont * loginHintTextFont = [UIFont tt_fontOfSize:22.f];
    SSThemedLabel * loginHintTextLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 24, self.width, ceil(loginHintTextFont.pointSize))];
    loginHintTextLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    loginHintTextLabel.textAlignment = NSTextAlignmentCenter;
    loginHintTextLabel.textColorThemeKey = kColorText1;
    loginHintTextLabel.text = NSLocalizedString(kLoginHintText, nil);
    [self addSubview:loginHintTextLabel];
    
    TTAlphaThemedButton * closeButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(self.width - 40.5f, -3.f, 44.f, 38.f)];
    closeButton.imageName = @"add_textpage";
    closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [closeButton addTarget:self action:@selector(closeLogin:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    TTAlphaThemedButton * loginButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake((self.width - 86.f)/2 , 58.f, 86.f, 32.f)];
    loginButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    loginButton.layer.cornerRadius = 4.f;
    loginButton.backgroundColorThemeKey = kColorBackground8;
    loginButton.titleColorThemeKey = kColorText12;
    loginButton.titleLabel.font = [UIFont tt_fontOfSize:14.f];
    [loginButton setTitle:kLoginText forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:loginButton];
}

- (id)cellData {
    return self.orderedData;
}

- (void)refreshUI {
    [super refreshUI];
    if ([(ExploreOrderedData *)self.orderedData nextCellHasTopPadding] || self.hideBottomLine) {
        self.bottomLine.hidden = YES;
    }else {
        self.bottomLine.hidden = NO;
    }
}

- (void)refreshWithData:(id)data {
    [super refreshWithData:data];
    if ([data isKindOfClass:[ExploreOrderedData class]] && nil != [(ExploreOrderedData *)data login]) {
        self.orderedData = data;
        self.login = [(ExploreOrderedData *)data login];
    }else {
        self.orderedData = nil;
        self.login = nil;
    }
}

#pragma mark - Notification

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
}

#pragma mark - Action

- (void)closeLogin:(id)sender {
    ssTrackEventWithCustomKeys(@"weitoutiao", @"login_card_cancel", nil, @"weitoutiao", nil);
    NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
    [userInfo setValue:self.orderedData forKey:kExploreMixListDeleteItemKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListItemDeleteNotification object:self userInfo:userInfo.copy];
}

- (void)login:(id)sender {
    ssTrackEventWithCustomKeys(@"weitoutiao", @"login_card_confirm", nil, @"weitoutiao", nil);
    WeakSelf;
    [AccountManager showLoginAlertWithType:TTAccountAlertTitleTypeSocial
                                    source:@"weitoutiao_tab_login_card"
                                 completed:^(TTAlertComplete type, NSString *phoneNum) {
                                     StrongSelf;
                                     if (type == TTAlertCompleteTip) {
                                         [AccountManager presentQuickLoginFromVC:[TTUIResponderHelper topViewControllerFor:self]
                                                                            type:TTLoginDialogTitleTypeDefault
                                                                          source:@"weitoutiao_tab_login_card"
                                                              completionnHandler:nil];
                                     }
    }];
}

@end
