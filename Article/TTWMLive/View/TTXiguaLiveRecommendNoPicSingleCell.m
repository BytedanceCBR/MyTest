//
//  TTXiguaLiveRecommendNoPicSingleCell.m
//  Article
//
//  Created by lipeilun on 2017/12/7.
//

#import "TTXiguaLiveRecommendNoPicSingleCell.h"
#import <TTAsyncCornerImageView.h>
#import <TTAsyncCornerImageView+VerifyIcon.h>
#import "TTArticleCellHelper.h"
#import <TTVerifyIconImageView.h>
#import <TTVerifyIconHelper.h>
#import <Lottie/Lottie.h>
#import "TTXiguaLiveLivingAnimationView.h"
#import "FRRouteHelper.h"
#import "TTXiguaLiveManager.h"

@interface TTXiguaLiveRecommendNoPicSingleCell()
@property (nonatomic, strong) TTAsyncCornerImageView *avatarImageView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *tipLabel;
@property (nonatomic, strong) TTVerifyIconImageView *veriImageView;
@property (nonatomic, strong) SSThemedLabel *subTitleLabel;
@property (nonatomic, strong) LOTAnimationView *avatarRoundView;
@property (nonatomic, strong) TTXiguaLiveLivingAnimationView *animationView;
@property (nonatomic, assign) BOOL showVerifyIcon;
@property (nonatomic, strong) TTXiguaLiveModel *model;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation TTXiguaLiveRecommendNoPicSingleCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.avatarImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.veriImageView];
        [self addSubview:self.tipLabel];
        [self addSubview:self.subTitleLabel];
        [self addSubview:self.avatarRoundView];
        [self addSubview:self.animationView];
        [self setTapGestureRecognizer:self.tapGestureRecognizer];
        
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    }
    return self;
}

- (void)refreshLayerUI {
    self.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:4];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    self.layer.shadowColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    self.layer.shadowRadius = 4;
    self.layer.shadowOpacity = 1;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)themeChanged:(NSNotification *)notification {
    [self.avatarRoundView removeFromSuperview];
    self.avatarRoundView = nil;
    [self insertSubview:self.avatarRoundView belowSubview:self.animationView];
    [self.avatarRoundView play];
    self.avatarRoundView.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:64], [TTDeviceUIUtils tt_newPadding:64]);
    self.avatarRoundView.center = self.avatarImageView.center;
    
    self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    self.layer.shadowColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    self.nameLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.tipLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarImageView.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:12], [TTDeviceUIUtils tt_newPadding:11], [TTDeviceUIUtils tt_newPadding:52], [TTDeviceUIUtils tt_newPadding:52]);
    
    
    self.avatarRoundView.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:62], [TTDeviceUIUtils tt_newPadding:62]);
    self.avatarRoundView.center = self.avatarImageView.center;
    
    self.animationView.centerX = self.avatarImageView.centerX;
    self.animationView.centerY = self.avatarImageView.bottom - [TTDeviceUIUtils tt_newPadding:3];

    //首行逻辑
    CGFloat labelLeft = self.avatarImageView.right + [TTDeviceUIUtils tt_newPadding:16];
    CGFloat maxLenth = self.width - labelLeft - [TTDeviceUIUtils tt_newPadding:12];
    NSDictionary *attributeDict = @{
                                    NSFontAttributeName : [UIFont tt_boldFontOfSize:[TTDeviceUIUtils tt_newFontSize:17]]
                                    };
    
    CGSize size = [[self.model liveUserInfoModel].name boundingRectWithSize:CGSizeMake(maxLenth - [TTDeviceUIUtils tt_newPadding:14] - [TTDeviceUIUtils tt_newPadding:4], [TTDeviceUIUtils tt_newPadding:24])
                                                                    options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                                 attributes:attributeDict
                                                                    context:nil].size;
    if (self.showVerifyIcon) {
        self.nameLabel.frame = CGRectMake(labelLeft, [TTDeviceUIUtils tt_newPadding:13], MIN(maxLenth - [TTDeviceUIUtils tt_newPadding:14] - 2 * [TTDeviceUIUtils tt_newPadding:3] - self.tipLabel.width, size.width), [TTDeviceUIUtils tt_newPadding:24]);

        self.veriImageView.frame = CGRectMake(self.nameLabel.right + [TTDeviceUIUtils tt_newPadding:3], 0, [TTDeviceUIUtils tt_newPadding:14], [TTDeviceUIUtils tt_newPadding:14]);
        self.veriImageView.centerY = self.nameLabel.centerY;
        
        self.tipLabel.left = self.veriImageView.right + [TTDeviceUIUtils tt_newPadding:3];
        self.tipLabel.centerY = self.nameLabel.centerY;
    } else {
        self.nameLabel.frame = CGRectMake(labelLeft, [TTDeviceUIUtils tt_newPadding:13], MIN(maxLenth - [TTDeviceUIUtils tt_newPadding:4] - self.tipLabel.width, size.width), [TTDeviceUIUtils tt_newPadding:24]);

        self.veriImageView.frame = CGRectZero;
        self.tipLabel.left = self.nameLabel.right + [TTDeviceUIUtils tt_newPadding:3];
        self.tipLabel.centerY = self.nameLabel.centerY;
    }
    
    
    self.subTitleLabel.frame = CGRectMake(self.avatarImageView.right + [TTDeviceUIUtils tt_newPadding:16], self.nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:3], maxLenth, [TTDeviceUIUtils tt_newPadding:20]);
}

- (void)configWithModel:(TTXiguaLiveModel *)model {
    self.model = model;
    self.nameLabel.text = [model liveUserInfoModel].name;
    self.subTitleLabel.text = model.title;
    self.showVerifyIcon = [TTVerifyIconHelper isVerifiedOfVerifyInfo:[model liveUserInfoModel].userAuthInfo];
    [self.avatarImageView tt_setImageWithURLString:[model liveUserInfoModel].avatarUrl];
    [self.veriImageView updateWithVerifyInfo:[model liveUserInfoModel].userAuthInfo];
}

- (void)tryBeginAnimation {
    [self.avatarRoundView play];
    [self.animationView beginAnimation];
}

- (void)tryStopAnimation {
    [self.avatarRoundView stop];
    [self.animationView stopAnimation];
}

- (void)avatarClick:(id)sender {
    [FRRouteHelper openProfileForUserID:[self.model liveUserInfoModel].userId.longLongValue];
}

- (void)onClickCell {
    UIViewController *audienceVC = [[TTXiguaLiveManager sharedManager] audienceRoomWithUserID:[self.model liveUserInfoModel].userId extraInfo:self.extraDict];
    [self.navigationController pushViewController:audienceVC animated:YES];
}

#pragma mark - GET

- (TTAsyncCornerImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:52], [TTDeviceUIUtils tt_newPadding:52]) allowCorner:YES];
        _avatarImageView.borderWidth = 0.0f;
        _avatarImageView.coverColor = [UIColor colorWithWhite:0 alpha:0.05];
        _avatarImageView.cornerRadius = [TTDeviceUIUtils tt_newPadding:52];
        _avatarImageView.placeholderName = @"default_avatar";
        [_avatarImageView addTouchTarget:self action:@selector(avatarClick:)];
    }
    return _avatarImageView;
}

- (SSThemedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _nameLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        _nameLabel.font = [UIFont tt_boldFontOfSize:[TTDeviceUIUtils tt_newFontSize:17]];
        _nameLabel.numberOfLines = 1;
    }
    return _nameLabel;
}

- (SSThemedLabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _tipLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        _tipLabel.font = [UIFont tt_boldFontOfSize:[TTDeviceUIUtils tt_newFontSize:17]];
        _tipLabel.numberOfLines = 1;
        _tipLabel.text = @"正在直播";
        NSDictionary *attributeDict = @{
                                        NSFontAttributeName : [UIFont tt_boldFontOfSize:[TTDeviceUIUtils tt_newFontSize:17]]
                                        };
        
        CGSize size = [@"正在直播" boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, [TTDeviceUIUtils tt_newPadding:24])
                                            options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                         attributes:attributeDict
                                            context:nil].size;
        _tipLabel.size = size;
    }
    return _tipLabel;
}

- (SSThemedLabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.textColorThemeKey = kColorText3;
        _subTitleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        _subTitleLabel.numberOfLines = 1;
    }
    return _subTitleLabel;
}

- (TTVerifyIconImageView *)veriImageView {
    if (!_veriImageView) {
        _veriImageView = [[TTVerifyIconImageView alloc] initWithFrame:CGRectZero];
    }
    return _veriImageView;
}

- (LOTAnimationView *)avatarRoundView {
    if (!_avatarRoundView) {
        NSString *animationFileStr;
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            animationFileStr = [[NSBundle mainBundle] pathForResource:@"xg_header_round" ofType:@"json" inDirectory:@"XiguaLiveResource.bundle"];
        } else {
            animationFileStr = [[NSBundle mainBundle] pathForResource:@"xg_header_round_night" ofType:@"json" inDirectory:@"XiguaLiveResource.bundle"];
        }
        _avatarRoundView = [LOTAnimationView animationWithFilePath:animationFileStr];
        _avatarRoundView.loopAnimation = YES;
        _avatarRoundView.backgroundColor = [UIColor clearColor];
        [_avatarRoundView play];
    }
    return _avatarRoundView;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickCell)];
    }
    return _tapGestureRecognizer;
}

- (TTXiguaLiveLivingAnimationView *)animationView {
    if (!_animationView) {
        _animationView = [[TTXiguaLiveLivingAnimationView alloc] initWithStyle:TTXiguaLiveLivingAnimationViewStyleSmallNoLine];
        [_animationView beginAnimation];
    }
    return _animationView;
}
@end
