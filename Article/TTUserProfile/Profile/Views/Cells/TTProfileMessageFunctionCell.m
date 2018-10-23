//
//  TTProfileMessageFunctionCell.m
//  Article
//
//  Created by 邱鑫玥 on 2017/4/22.
//
//

#import "TTProfileMessageFunctionCell.h"
#import "TTBusinessManager.h"
#import "NSString-Extension.h"
#import "TTSettingConstants.h"
#import "SSAvatarView+VerifyIcon.h"

#define kAccessoryLabelMinPaddingToBadgeView [TTDeviceUIUtils tt_padding:36.f]
#define kAccessoryLabelFontSize 14.f
#define kAccessoryLabelRightPadding 8
#define kCellImageViewSize 28.f
#define kRightImageViewSize 14.f
#define kRightImageViewRightPadding 17.f
#define kBadgeViewLeftPadding 5.f
#define kCellImageViewLeftPadding 30.f
#define kTitleLabelLeftPaddingForPad 110.f
#define kTitleLabelLeftPaddingForiPhone [TTDeviceUIUtils tt_padding:30.f/2]
#define kMidPadding [TTDeviceUIUtils tt_padding:36.f]
#define kAccessoryAvatarViewSize [TTDeviceUIUtils tt_padding:24]
#define kAccessoryAvatarRightPadding 7.f


@interface TTProfileMessageFunctionCell ()

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSString *tips;
@property (nonatomic, assign) BOOL isImportantMessage;

@end

@implementation TTProfileMessageFunctionCell

- (void)configWithEntry:(TTSettingMineTabEntry *)entry{
    [super configWithEntry:entry];
    _userName = entry.userName;
    _action = entry.action;
    _tips = entry.tips;
    _isImportantMessage = entry.isImportantMessage;
}

- (void)setupSubviews{
    self.titleLb.font = [UIFont systemFontOfSize:[self.class fontSizeOfTitle]];
    self.accessoryLb.font = [UIFont systemFontOfSize:[self.class fontSizeOfAccessory]];
    self.rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.badgeView.backgroundColorThemeKey = kColorBackground7;
    self.badgeView.badgeTextColorThemeKey = kColorText7;
    [self.badgeView setBadgeViewStyle:TTBadgeNumberViewStyleProfile];
    self.titleLb.textColorThemeKey = kColorText1;
    self.accessoryLb.textColorThemeKey = kColorText3;
    self.rightImageView.imageName = @"setting_rightarrow";
    self.rightImageView.userInteractionEnabled = YES;
    
    self.accessoryAvatarView.avatarImgPadding = 0.f;
    self.accessoryAvatarView.avatarStyle = SSAvatarViewStyleRound;
    self.accessoryAvatarView.userInteractionEnabled = YES;
    self.accessoryAvatarView.hidden = YES;
    self.backgroundColorThemeKey = kColorBackground4;
    if (![SSCommonLogic transitionAnimationEnable]) {
        self.backgroundSelectedColorThemeKey = @"BackgroundSelectedColor1";
    }
    self.separatorColorThemeKey = kColorLine1;
    self.separatorThemeInsetLeft = 0;
    self.needMargin = YES;
    self.separatorAtTOP = NO;
    self.separatorAtBottom = NO;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.titleLb sizeToFit];
    self.titleLb.centerY = self.height / 2.f;
    if ([TTDeviceHelper isPadDevice]){
        self.cellImageView.hidden = NO;
        self.cellImageView.size = CGSizeMake(kCellImageViewSize, kCellImageViewSize);
        self.cellImageView.left = kCellImageViewLeftPadding;
        self.cellImageView.centerY = self.height / 2.f;
        self.titleLb.left = kTitleLabelLeftPaddingForPad;
    }
    else{
        self.cellImageView.hidden = YES;
        self.titleLb.left = kTitleLabelLeftPaddingForiPhone;
    }
    
    [self.badgeView sizeToFit];
    self.badgeView.left = self.titleLb.right + kBadgeViewLeftPadding;
    self.badgeView.centerY = self.height / 2.f;
    
    self.rightImageView.size = CGSizeMake(kRightImageViewSize, kRightImageViewSize);
    self.rightImageView.centerY = self.height / 2.f;
    self.rightImageView.right = self.width - kRightImageViewRightPadding;
    
    if(!self.isImportantMessage){
        self.accessoryAvatarView.hidden = YES;
        CGFloat maxWidth = self.width - self.badgeView.right - kMidPadding - kRightImageViewSize - kRightImageViewRightPadding - kAccessoryLabelRightPadding;
        self.accessoryLb.text = self.tips;
        [self.accessoryLb sizeToFit];
        self.accessoryLb.width = MIN(self.accessoryLb.width, maxWidth);
        self.accessoryLb.right = self.rightImageView.left - kAccessoryLabelRightPadding;
        self.accessoryLb.centerY = self.height / 2.f;
    }
    else{
        self.accessoryAvatarView.hidden = NO;
        CGFloat maxWidth = self.width - self.badgeView.right - kMidPadding - kRightImageViewSize - kRightImageViewRightPadding - kAccessoryLabelRightPadding - kAccessoryAvatarViewSize - kAccessoryAvatarRightPadding;
        self.accessoryLb.text = [self accessoryTextWithNameText:self.userName actionText:self.action maxWidth:maxWidth];
        [self.accessoryLb sizeToFit];
        self.accessoryLb.width = MIN(self.accessoryLb.width, maxWidth);
        self.accessoryLb.right = self.rightImageView.left - kAccessoryLabelRightPadding;
        self.accessoryLb.centerY = self.height / 2.f;
        
        self.accessoryAvatarView.size = CGSizeMake(kAccessoryAvatarViewSize, kAccessoryAvatarViewSize);
        self.accessoryAvatarView.right = self.accessoryLb.left - kAccessoryAvatarRightPadding;
        self.accessoryAvatarView.centerY = self.height / 2.f;
        [self.accessoryAvatarView setupVerifyViewForLength:24 adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_size:standardSize];
        }];
    }
}

- (NSString *)accessoryTextWithNameText:(NSString *)name actionText:(NSString *)action maxWidth:(CGFloat)maxWidth
{
    if (isEmptyString(name) || isEmptyString(action)) {
        NSString *accessory = [NSString stringWithFormat:@"%@%@", name, action];
        return accessory;
    }
    
    UIFont *font = [UIFont systemFontOfSize:[[self class] fontSizeOfAccessory]];
    CGFloat actionWidth = [action tt_sizeWithMaxWidth:FLT_MAX font:font].width;
    CGFloat nameWidth = [name tt_sizeWithMaxWidth:FLT_MAX font:font].width;
    
    // 先判断两段文本拼接是否超出大小
    if (nameWidth + actionWidth <= maxWidth) {
        NSString *accessory = [NSString stringWithFormat:@"%@%@", name, action];
        return accessory;
    }
    
    // 再判断删除name最后一个字符，将action第一个字符添加省略号后，是否超出大小
    NSMutableString *nameProcessed = [name mutableCopy];
    NSString *actionProcessed = [NSString stringWithFormat:@"%@%@", @"…", action];
    actionWidth = [actionProcessed tt_sizeWithMaxWidth:FLT_MAX font:font].width;
    
    // 循环删除name的最后一个字符，直到大小小于最大宽度限制
    while (nameProcessed.length > 0 && nameWidth + actionWidth > maxWidth) {
        [nameProcessed deleteCharactersInRange:NSMakeRange(nameProcessed.length - 1, 1)];
        nameWidth = [nameProcessed tt_sizeWithMaxWidth:FLT_MAX font:font].width;
    }
    
    NSString *accessory = [NSString stringWithFormat:@"%@%@", nameProcessed, actionProcessed];
    
    return accessory;
}

+ (CGFloat)fontSizeOfTitle
{
    return [TTDeviceUIUtils tt_fontSize:kTTSettingTitleFontSize];
}

+ (CGFloat)fontSizeOfAccessory
{
    return [TTDeviceUIUtils tt_fontSize:kAccessoryLabelFontSize];
}

@end
