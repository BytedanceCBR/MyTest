//
//  AccountButton.m
//  ShareOne
//
//  Created by 剑锋 屠 on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AccountButton.h"
#import <QuartzCore/QuartzCore.h>
#import <UIImage+TTThemeExtension.h>
#import <TTUIResponderHelper.h>
#import <TTThemedAlertController.h>
#import <TTAccountBusiness.h>

@interface AccountButtonInternal : UIView
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong, readwrite) TTThirdPartyAccountInfoBase *accountInfo;
@property (nonatomic, assign) float customAlpha;
@end

@implementation AccountButtonInternal
@synthesize iconImage;
@synthesize accountInfo;
@synthesize customAlpha;

- (instancetype)initWithFrame:(CGRect)frame
                  accountInfo:(TTThirdPartyAccountInfoBase *)tAccount
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.accountInfo = tAccount;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect imageRect = rect;
    imageRect.size.width = iconImage.size.width;
    imageRect.size.height = iconImage.size.height;
    imageRect.origin.x = (self.frame.size.width - imageRect.size.width) / 2;
    imageRect.origin.y = rect.origin.y;
    
    if (accountInfo.accountStatus == TTThirdPartyAccountStatusNone) {
        float alpha = customAlpha;
        if(alpha == 0) alpha = 0.3;
        [iconImage drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:alpha];
    } else {
        [iconImage drawInRect:imageRect];
        
        UIImage *checkImage = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (accountInfo.accountStatus == TTThirdPartyAccountStatusChecked) {
            checkImage = [UIImage themedImageNamed:@"selecticon_repost.png"];
        } else {
            checkImage = [UIImage themedImageNamed:@"noselecticon_repost.png"];
        }
#pragma clang diagnostic pop
        
        CGRect checkRect = rect;
        checkRect.origin.x += CGRectGetMinX(imageRect) + imageRect.size.width / 2 + 8;
        checkRect.origin.y += imageRect.size.height / 2 + 3;
        checkRect.size.width = checkImage.size.width;
        checkRect.size.height = checkImage.size.height;
        [checkImage drawInRect:checkRect];
    }
}

@end



@interface AccountButton() {
@private
    BOOL _displayName;
    UIEdgeInsets _contentInsets;
}

@property (nonatomic, strong, readwrite) TTThirdPartyAccountInfoBase *accountInfo;
@property (nonatomic, strong) UIImage *normalBgImage;
@property (nonatomic, strong) UIImage *highlighBgImage;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) AccountButtonInternal *buttonInternal;
@end

@implementation AccountButton

@synthesize accountInfo;
@synthesize delegate;
@synthesize displayName;
@synthesize nameLabel;
@synthesize normalBgImage, highlighBgImage;
@synthesize bgImageView;
@synthesize buttonInternal;

- (void)dealloc
{
    [accountInfo removeObserver:self forKeyPath:@"accountStatus"];
    [accountInfo removeObserver:self forKeyPath:@"displayName"];
    [accountInfo removeObserver:self forKeyPath:@"contentInset"];
}

- (instancetype)initWithFrame:(CGRect)frame
                  accountInfo:(TTThirdPartyAccountInfoBase *)tAccount
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.accountInfo = tAccount;
        [accountInfo addObserver:self forKeyPath:@"accountStatus" options:NSKeyValueObservingOptionNew context:nil];
        [accountInfo addObserver:self forKeyPath:@"displayName" options:NSKeyValueObservingOptionNew context:nil];
        [accountInfo addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
        
        NSString *imageName = tAccount.iconImageName;
        self.clipsToBounds = NO;
        self.displayName = NO; //default to NO
        self.buttonInternal = [[AccountButtonInternal alloc] initWithFrame:CGRectMake(self.contentInsets.left,
                                                                                      self.contentInsets.top,
                                                                                      self.frame.size.width - self.contentInsets.left - self.contentInsets.right,
                                                                                      self.frame.size.height - self.contentInsets.top - self.contentInsets.bottom)
                                                               accountInfo:accountInfo];
        buttonInternal.iconImage = [UIImage themedImageNamed:imageName];
        [self addSubview:buttonInternal];
    }
    
    return self;
}

- (UIEdgeInsets)contentInsets
{
    return _contentInsets;
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)) {
        _contentInsets = contentInsets;
        buttonInternal.frame = CGRectMake(_contentInsets.left,
                                          _contentInsets.top,
                                          self.frame.size.width - _contentInsets.left - _contentInsets.right,
                                          self.frame.size.height - _contentInsets.top - _contentInsets.bottom);
        CGRect nameRect = nameLabel.frame;
        nameRect.origin.x += contentInsets.left;
        nameRect.origin.y += contentInsets.top;
        nameLabel.frame = nameRect;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (highlighBgImage) {
        [bgImageView setImage:highlighBgImage];
        [bgImageView sizeToFit];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([touch tapCount] == 1) {
        [self clicked];
    }
    
    if (normalBgImage) {
        [bgImageView setImage:normalBgImage];
        [bgImageView sizeToFit];
    }
}

- (void)clicked
{
    if (delegate && [delegate respondsToSelector:@selector(accountButtonClicked:accountDisplayName:accountName:)]) {
        [delegate accountButtonClicked:self accountDisplayName:self.accountInfo.displayName accountName:self.accountInfo.keyName];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    switch (accountInfo.accountStatus) {
        case TTThirdPartyAccountStatusNone: {
            [TTAccountLoginManager requestLoginPlatformByName:self.accountInfo.keyName completion:^(BOOL success, NSError * _Nonnull error) {
                
            }];
        }
            break;
        case TTThirdPartyAccountStatusBounded: {
            if ([self.accountInfo.keyName  isEqual: @"sina_weibo"]) {
                NSDate *weiboExpiredLastTime = [[NSUserDefaults standardUserDefaults] valueForKey:@"weiboExpiredLastTime"];
                double alertAfterTime = [[[NSUserDefaults standardUserDefaults] valueForKey:@"weiboExpiredShowInterval"] doubleValue];
                NSDate *nowDate = [NSDate date];
                if ([TTPlatformExpiration sharedInstance].alertWeiboExpired && (!weiboExpiredLastTime ||(weiboExpiredLastTime && [nowDate timeIntervalSinceDate:weiboExpiredLastTime] >= alertAfterTime))) {
                    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"weiboExpiredLastTime"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSString *title = NSLocalizedString(@"新浪微博授权过期，如需分享到新浪微博，请重新授权", @"新浪微博授权过期，如需分享到新浪微博，请重新授权");
                    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:title message:@"" preferredType:TTThemedAlertControllerTypeAlert];
                    [alert addActionWithTitle:NSLocalizedString(@"取消", @"取消") actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
                    [alert addActionWithTitle:NSLocalizedString(@"去授权", @"去授权") actionType:TTThemedAlertActionTypeNormal actionBlock:^{
                        [TTAccountLoginManager requestLoginPlatformByName:PLATFORM_SINA_WEIBO completion:^(BOOL success, NSError * _Nonnull error) {
                            
                        }];
                        
                        [TTPlatformExpiration sharedInstance].alertWeiboExpired = NO;
                    }];
                    [alert showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
                }
            }
            
            [self.accountInfo setAccountStatus:TTThirdPartyAccountStatusChecked];
            [[TTPlatformAccountManager sharedManager] setAccountPlatform:self.accountInfo.keyName checked:YES];
        }
            break;
        case TTThirdPartyAccountStatusChecked: {
            [self.accountInfo setAccountStatus:TTThirdPartyAccountStatusBounded];
            [[TTPlatformAccountManager sharedManager] setAccountPlatform:self.accountInfo.keyName checked:NO];
        }
            break;
        default:
            break;
    }
#pragma clang diagnostic pop
}

- (void)setCustomAlpha:(float)alpha
{
    buttonInternal.customAlpha = alpha;
    [buttonInternal setNeedsDisplay];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"accountStatus"]) {
        [buttonInternal setNeedsDisplay];
    } else if([keyPath isEqualToString:@"displayName"] && nameLabel) {
        nameLabel.text = [change objectForKey:NSKeyValueChangeNewKey];
    }
}

- (BOOL)displayName
{
    return _displayName;
}

- (void)setDisplayName:(BOOL)tDisplayName
{
    if(_displayName != tDisplayName) {
        _displayName = tDisplayName;
    }
    
    if (_displayName) {
        if (!nameLabel) {
            self.nameLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                      buttonInternal.iconImage.size.height + 5,
                                                      self.frame.size.width,
                                                      15)];
            nameLabel.font = [UIFont systemFontOfSize:14];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.text = accountInfo.displayName;
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            nameLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:nameLabel];
        }
    }
}

@end
