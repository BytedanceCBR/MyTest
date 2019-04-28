//
//  TTCertificationPreviewView.m
//  Article
//
//  Created by wangdi on 2017/5/21.
//
//

#import "TTCertificationPreviewView.h"
#import "ExploreAvatarView.h"
#import "TTAsyncCornerImageView.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "UIImageView+WebCache.h"
#import <TTAccountBusiness.h>

@interface TTCertificationPreviewView ()

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTAsyncCornerImageView *iconView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *occupationalLabel;
@end

@implementation TTCertificationPreviewView

- (instancetype)init {
    if(self = [super init]) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.text = @"认证预览";
    titleLabel.textColorThemeKey = kColorText1;
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:16]];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    TTAsyncCornerImageView *iconView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:50], [TTDeviceUIUtils tt_newPadding:50]) allowCorner:YES];
    iconView.cornerRadius = [TTDeviceUIUtils tt_newPadding:50] * 0.5;
    iconView.placeholderName = @"default_avatar";
    iconView.borderWidth = 0;
    iconView.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05f];
    [iconView tt_setImageWithURLString:[TTAccountManager avatarURLString]];
    [iconView setupVerifyViewForLength:50 adaptationSizeBlock:^CGSize(CGSize standardSize) {
        return [TTVerifyIconHelper tt_newSize:standardSize];
    }];
    [self addSubview:iconView];
    self.iconView = iconView;
    
    SSThemedLabel *nameLabel = [[SSThemedLabel alloc] init];
    nameLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newPadding:18]];
    nameLabel.textColorThemeKey = kColorText1;
    nameLabel.text = [TTAccountManager userName];
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    SSThemedLabel *occupationalLabel = [[SSThemedLabel alloc] init];
    occupationalLabel.numberOfLines = 0;
    occupationalLabel.textColorThemeKey = kColorText3;
    occupationalLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:16]];
    [self addSubview:occupationalLabel];
    self.occupationalLabel = occupationalLabel;
}

- (void)setPreViewText:(NSString *)text
{
    self.occupationalLabel.text = text;
    [self setNeedsLayout];
    
}

- (void)setAuthType:(NSString *)authType
{
    NSMutableDictionary *authDict = [NSMutableDictionary dictionary];
    [authDict setValue:authType forKey:@"auth_type"];
    [authDict setValue:@" " forKey:@"auth_info"];
    NSData *authData = [NSJSONSerialization dataWithJSONObject:authDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *authJson = [[NSString alloc] initWithData:authData encoding:NSUTF8StringEncoding];
    [self.iconView showOrHideVerifyViewWithVerifyInfo:authJson decoratorInfo:nil sureQueryWithID:YES userID:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.left = [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.height = [TTDeviceUIUtils tt_newPadding:22.5];
    self.titleLabel.width = self.width - 2 * self.titleLabel.left;
    self.titleLabel.top = [TTDeviceUIUtils tt_newPadding:15];

    self.iconView.left = [TTDeviceUIUtils tt_newPadding:15];
    self.iconView.top = self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:15];
    
    self.nameLabel.left = self.iconView.right + [TTDeviceUIUtils tt_newPadding:12];
    self.nameLabel.top = self.iconView.top;
    self.nameLabel.width = self.width - self.nameLabel.left - [TTDeviceUIUtils tt_newPadding:15];
    self.nameLabel.height = [TTDeviceUIUtils tt_newPadding:25];
    
    self.occupationalLabel.left = self.nameLabel.left;
    self.occupationalLabel.top = self.nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:2];
    self.occupationalLabel.size = CGSizeMake(self.nameLabel.width, [TTDeviceUIUtils tt_newPadding:22]);
}

@end
