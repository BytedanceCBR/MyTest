//
//  TTProfileBaseFunctionCell.m
//  Article
//
//  Created by lizhuoli on 2017/3/28.
//
//

#import "TTProfileBaseFunctionCell.h"
#import "TTBusinessManager.h"
#import "TTSettingConstants.h"
#import "SSAvatarView+VerifyIcon.h"

@interface TTProfileBaseFunctionCell ()

@property (nonatomic, strong) MASConstraint *titleLeftMargin;

@end

@implementation TTProfileBaseFunctionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLb = [SSThemedLabel new];
        self.cellImageView = [SSThemedImageView new];
        self.accessoryLb = [SSThemedLabel new];
        self.badgeView = [TTBadgeNumberView new];
        self.rightImageView = [SSThemedImageView new];
        self.accessoryAvatarView = [SSAvatarView new];
        
        [self addSubview:self.titleLb];
        [self addSubview:self.cellImageView];
        [self addSubview:self.accessoryLb];
        [self addSubview:self.badgeView];
        [self addSubview:self.rightImageView];
        [self addSubview:self.accessoryAvatarView];
        
        [self setupSubviews];
    }
    
    return self;
}

- (void)setupSubviews
{
    [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.titleLb.mas_right).with.offset(5);
    }];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        self.titleLeftMargin = make.left.equalTo(self).with.offset([TTDeviceUIUtils tt_padding:30.f/2]);
        make.centerY.equalTo(self);
    }];
    [self.titleLb setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisVertical];
    [self.accessoryLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightImageView.mas_left).with.offset(-8);
        make.centerY.equalTo(self);
        make.width.lessThanOrEqualTo(@([TTDeviceUIUtils tt_padding:kTTSettingContentMaxWidth]));
    }];
    [self.accessoryLb setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisVertical];
    [self.accessoryLb setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).with.offset(-17);
        make.width.mas_equalTo(14);
        make.height.mas_equalTo(14);
    }];
    [self.rightImageView setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisVertical];
    [self.rightImageView setContentHuggingPriority:251 forAxis:UILayoutConstraintAxisHorizontal];
    [self.cellImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).with.offset(30);
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(28);
    }];
    [self.accessoryAvatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([TTDeviceUIUtils tt_padding:24]);
        make.width.mas_equalTo([TTDeviceUIUtils tt_padding:24]);
        make.centerY.equalTo(self);
        make.right.equalTo(self.accessoryLb.mas_left).with.offset(-7);
    }];
    
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
    
    [self setupExtraConfig];
}

- (void)setupExtraConfig
{
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

- (void)configWithModel:(id)model
{
    // empty implementation
}

- (void)configWithEntry:(TTSettingMineTabEntry *)entry
{
    if (!entry) {
        return;
    }
    
    self.accessoryAvatarView.hidden = YES;
    self.titleLb.text = entry.text;
    [self.titleLb sizeToFit];
    if (!isEmptyString(entry.accessoryTextColor)) {
        self.accessoryLb.textColor = [UIColor colorWithHexString:entry.accessoryTextColor];
    }
    self.accessoryLb.text = entry.accessoryText;
    [self.accessoryLb sizeToFit];
    
    [self setHintStyle:entry.hintStyle number:entry.hintCount];
    
    if ([TTDeviceHelper isPadDevice]) {
        [self setCellImageName:entry.iconName];
    }
    
    NSString *avatarUrlString = entry.avatarUrlString;
    if (!isEmptyString(avatarUrlString)) {
        self.accessoryAvatarView.hidden = NO;
        [self.accessoryAvatarView showAvatarByURL:avatarUrlString];
        [self.accessoryAvatarView showOrHideVerifyViewWithVerifyInfo:entry.userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];

    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.accessoryAvatarView setupVerifyViewForLength:24 adaptationSizeBlock:^CGSize(CGSize standardSize) {
        return [TTVerifyIconHelper tt_size:standardSize];
    }];
}

- (void)setHintStyle:(TTSettingHintStyle)hintStyle number:(long long)number
{
    switch (hintStyle) {
        case TTSettingHintStyleNone:
            self.badgeView.hidden = YES;
            self.badgeView.badgeNumber = TTBadgeNumberHidden;
            break;
        case TTSettingHintStyleRedPoint:
            self.badgeView.hidden = NO;
            self.badgeView.badgeNumber = TTBadgeNumberPoint;
            break;
        case TTSettingHintStyleNewFlag:
            self.badgeView.hidden = NO;
            self.badgeView.badgeValue = @"NEW";
            break;
        case TTSettingHintStyleNumber:
            self.badgeView.hidden = NO;
            self.badgeView.badgeNumber = number;
            break;
        default:
            self.badgeView.hidden = YES;
            self.badgeView.badgeNumber = TTBadgeNumberHidden;
            break;
    }
}

- (void)setCellImageName:(NSString*)imageName
{
    self.cellImageView.hidden = NO;
    self.cellImageView.imageName = imageName;
    self.titleLeftMargin.offset = 110;
}

+ (CGFloat)fontSizeOfTitle
{
    return [TTDeviceUIUtils tt_fontSize:kTTSettingTitleFontSize];
}

+ (CGFloat)fontSizeOfAccessory
{
    return [TTDeviceUIUtils tt_fontSize:kTTSettingContentFontSize];
}

@end
