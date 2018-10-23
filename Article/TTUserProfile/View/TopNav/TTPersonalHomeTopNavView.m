//
//  TTPersonalHomeTopNavView.m
//  Article
//
//  Created by 王迪 on 2017/3/13.
//
//

#import "TTPersonalHomeTopNavView.h"
#import "TTDeviceHelper.h"
#import "NSStringAdditions.h"
#import "TTFollowThemeButton.h"
#import "TTThemeManager.h"

@interface TTPersonalHomeTopNavView()

@property (nonatomic, weak) SSThemedButton *backBtn;
@property (nonatomic, weak) SSThemedButton *shareBtn;
@property (nonatomic, weak) SSThemedView *bottomLine;
@property (nonatomic, weak) SSThemedLabel *nameLabel;
@property (nonatomic, strong) UIColor *currentNavColor;
@property (nonatomic, assign) CGFloat currentNavAlpha;
@property (nonatomic, assign) CGFloat currentOtherAlpha;

@end

@implementation TTPersonalHomeTopNavView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        [self setupSubview];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themedChange) name:TTThemeManagerThemeModeChangedNotification object:nil];
        [self themedChange];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedButton *backBtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    backBtn.imageName = @"personal_home_back_white";
    backBtn.selectedImageName = @"personal_home_back_black";
    [backBtn addTarget:self action:@selector(didSelectedBack) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backBtn];
    self.backBtn = backBtn;
    
    SSThemedButton *shareBtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [shareBtn addTarget:self action:@selector(didSelectedShare) forControlEvents:UIControlEventTouchUpInside];
    shareBtn.imageName = @"personal_home_share_white";
    shareBtn.selectedImageName = @"personal_home_share_black";
    [self addSubview:shareBtn];
    self.shareBtn = shareBtn;
    
    TTFollowThemeButton *followBtn = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType101 followedType:TTFollowedType101 followedMutualType:TTFollowedMutualType101];;
    followBtn.alpha = 0;
    [followBtn addTarget:self action:@selector(didSelectedFollow:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:followBtn];
    self.followBtn = followBtn;
    
    SSThemedButton *privateMessageBtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    privateMessageBtn.titleColors = SSThemedColors(@"FFFFFF", @"CACACA");
    privateMessageBtn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
    [privateMessageBtn setTitle:@"发私信" forState:UIControlStateNormal];
    privateMessageBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    privateMessageBtn.width = [privateMessageBtn.currentTitle sizeWithFontCompatible:privateMessageBtn.titleLabel.font].width;
    privateMessageBtn.alpha = 0;
    privateMessageBtn.height = [TTDeviceUIUtils tt_newPadding:20];
//    [self addSubview:privateMessageBtn];
    self.privateMessageBtn = privateMessageBtn;
    
    SSThemedLabel *nameLabel = [[SSThemedLabel alloc] init];
    nameLabel.alpha = 0;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    nameLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:18]];
    nameLabel.textColorThemeKey = kColorText1;
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    SSThemedView *bottomLine = [[SSThemedView alloc] init];
    bottomLine.alpha = 0;
    bottomLine.backgroundColorThemeKey = kColorLine1;
    [self addSubview:bottomLine];
    self.bottomLine = bottomLine;
    
}

- (void)setInfoModel:(TTPersonalHomeUserInfoDataResponseModel *)infoModel
{
    _infoModel = infoModel;
    TTUnfollowedType originalUnfollowTyle = self.followBtn.unfollowedType;
    if ([self.infoModel.activity.redpack isKindOfClass:[FRRedpackStructModel class]]) {
        FRRedpackStructModel* redpacketModel = self.infoModel.activity.redpack;
        self.followBtn.unfollowedType = [TTFollowThemeButton redpacketButtonUnfollowTypeButtonStyle:redpacketModel.button_style.integerValue defaultType:TTUnfollowedType201];
    } else {
        self.followBtn.unfollowedType = TTUnfollowedType101;
    }
    if (originalUnfollowTyle != self.followBtn.unfollowedType) {
        [self.followBtn refreshUI];
    }
    
    [self setNeedsLayout];
}

- (void)updateBarTranslucentWithScale:(CGFloat)scale
{
    self.backgroundColor = [self.currentNavColor colorWithAlphaComponent:scale];
    self.currentNavAlpha = scale;
    if(scale >= 0.8) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        self.backBtn.selected = YES;
        self.shareBtn.selected = YES;
    } else {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        self.backBtn.selected = NO;
        self.shareBtn.selected = NO;
    }
    if(scale >= 1) {
        self.bottomLine.alpha = 1;
    } else {
        self.bottomLine.alpha = 0;
    }
}

- (void)updateOtherTranslucentWithScale:(CGFloat)scale
{
    self.currentOtherAlpha = scale;
    self.nameLabel.alpha = scale;
    self.followBtn.alpha = scale;
    self.privateMessageBtn.alpha = !self.followBtn.alpha;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat topInset = 20;
    if (@available(iOS 11.0, *)) {
        topInset = self.safeAreaInsets.top;
    }
    self.backBtn.left = 5;
    self.backBtn.width = 34;
    self.backBtn.height = 34;
    self.backBtn.top = (44 - self.backBtn.height) * 0.5 + topInset;
    
    self.shareBtn.width = 34;
    self.shareBtn.height = 34;
    self.shareBtn.left = self.width - self.shareBtn.width - [TTDeviceUIUtils tt_newPadding:10];
    self.shareBtn.top =  (44 - self.shareBtn.height) * 0.5 + topInset;
    
    self.followBtn.top =  (44 - self.followBtn.height) * 0.5 + topInset;
    self.followBtn.right = self.shareBtn.left - [TTDeviceUIUtils tt_newPadding:7];
    
    self.privateMessageBtn.centerY = self.shareBtn.centerY - 2;
    self.privateMessageBtn.right = self.shareBtn.left - [TTDeviceUIUtils tt_newPadding:14];
    
    self.bottomLine.width = self.width;
    self.bottomLine.left = 0;
    self.bottomLine.height = [TTDeviceHelper ssOnePixel];
    self.bottomLine.top = self.height - self.bottomLine.height;
    
    self.nameLabel.text = self.infoModel.name;
    self.nameLabel.top = (44 - self.nameLabel.height) * 0.5 + topInset;
    self.nameLabel.height = [TTDeviceUIUtils tt_newPadding:25];
    if([self.infoModel.user_id isEqualToString:self.infoModel.current_user_id] || self.infoModel.is_blocking.integerValue == 1) {
        self.followBtn.hidden = YES;
        self.privateMessageBtn.hidden = YES;
        self.nameLabel.left = self.backBtn.right + [TTDeviceUIUtils tt_newPadding:15];
        self.nameLabel.width = self.shareBtn.left - self.backBtn.right - [TTDeviceUIUtils tt_newPadding:15];
    } else {
        self.nameLabel.left = self.width - self.followBtn.left + [TTDeviceUIUtils tt_newPadding:15];
        self.nameLabel.width = self.width - 2 * self.nameLabel.left;
        self.followBtn.hidden = NO;
        self.privateMessageBtn.hidden = NO;

        if(self.infoModel.is_followed.integerValue == 1 && self.infoModel.is_following.integerValue == 1) {
            self.followBtn.followed = YES;
            self.followBtn.beFollowed = YES;
            self.followBtn.borderColorThemeKey = kColorLine1;
        } else if(self.infoModel.is_following.integerValue == 1) {
            self.followBtn.followed = YES;
            self.followBtn.beFollowed = NO;
        } else {
            self.followBtn.followed = NO;
            self.followBtn.beFollowed = NO;
        }
    }
    
}

- (void)didSelectedFollow:(TTFollowThemeButton *)btn
{
    if(btn.isLoading) return;
    if([self.delegate respondsToSelector:@selector(navigationViewdidSelectedFollow:)]) {
        [self.delegate navigationViewdidSelectedFollow:!btn.followed];
    }
}

- (void)didSelectedBack
{
    if([self.delegate respondsToSelector:@selector(navigationviewDidSelectedBack)]) {
        [self.delegate navigationviewDidSelectedBack];
    }
}

- (void)didSelectedShare
{
    if([self.delegate respondsToSelector:@selector(navigationViewDidSelectedShare)]) {
        [self.delegate navigationViewDidSelectedShare];
    }
}

#pragma mark 通知回调
- (void)themedChange
{
    self.followBtn.alpha = self.currentOtherAlpha;
    self.nameLabel.alpha = self.currentOtherAlpha;
    self.privateMessageBtn.alpha = !self.followBtn.alpha;
    if([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.currentNavColor = [[UIColor whiteColor] colorWithAlphaComponent:self.currentNavAlpha];
    } else {
        self.currentNavColor = [[UIColor colorWithHexString:@"#252525"]  colorWithAlphaComponent:self.currentNavAlpha];
    }
    self.backgroundColor = self.currentNavColor;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
