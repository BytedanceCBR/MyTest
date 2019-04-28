//
//  TTXiguaLiveRecommendNoPicCell.m
//  Article
//
//  Created by lipeilun on 2017/12/6.
//

#import "TTXiguaLiveRecommendNoPicCell.h"
#import <TTAsyncCornerImageView.h>
#import <TTAsyncCornerImageView+VerifyIcon.h>
#import "TTArticleCellHelper.h"
#import <TTVerifyIconImageView.h>
#import <TTVerifyIconHelper.h>
#import <Lottie/Lottie.h>
#import "TTXiguaLiveLivingAnimationView.h"
#import "FRRouteHelper.h"

@interface TTXiguaLiveRecommendNoPicCell()
@property (nonatomic, strong) TTAsyncCornerImageView *avatarImageView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) TTVerifyIconImageView *veriImageView;
@property (nonatomic, strong) SSThemedLabel *subTitleLabel;
@property (nonatomic, strong) SSThemedLabel *contentLabel;
@property (nonatomic, strong) LOTAnimationView *avatarRoundView;
@property (nonatomic, strong) TTXiguaLiveLivingAnimationView *animationView;
@property (nonatomic, assign) BOOL showVerifyIcon;
@property (nonatomic, strong) TTXiguaLiveModel *model;
@end

@implementation TTXiguaLiveRecommendNoPicCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.avatarImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.veriImageView];
        [self addSubview:self.subTitleLabel];
        [self addSubview:self.contentLabel];
        [self addSubview:self.avatarRoundView];
        [self addSubview:self.animationView];
        
        self.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:4];
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
        self.layer.shadowColor = [UIColor tt_themedColorForKey:kColorLine1].CGColor;
        self.layer.shadowRadius = 4;
        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;

        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    }
    return self;
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
    self.contentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarImageView.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:16], [TTDeviceUIUtils tt_newPadding:12], [TTDeviceUIUtils tt_newPadding:52], [TTDeviceUIUtils tt_newPadding:52]);
    
    
    self.avatarRoundView.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:64], [TTDeviceUIUtils tt_newPadding:64]);
    self.avatarRoundView.center = self.avatarImageView.center;

    self.animationView.centerX = self.avatarImageView.centerX;
    self.animationView.centerY = self.avatarImageView.bottom - 2;

    CGFloat labelLeft = self.avatarImageView.right + [TTDeviceUIUtils tt_newPadding:16];
    if (self.showVerifyIcon) {
        CGFloat maxLenth = self.width - labelLeft - [TTDeviceUIUtils tt_newPadding:12];
        NSDictionary *attributeDict = @{
                                        NSFontAttributeName : [UIFont tt_boldFontOfSize:[TTDeviceUIUtils tt_newFontSize:19]]
                                        };
        
        CGSize size = [[self.model liveUserInfoModel].name boundingRectWithSize:CGSizeMake(maxLenth - [TTDeviceUIUtils tt_newPadding:14] - [TTDeviceUIUtils tt_newPadding:4], [TTDeviceUIUtils tt_newPadding:26])
                                                                        options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                                     attributes:attributeDict
                                                                        context:nil].size;
        self.nameLabel.frame = CGRectMake(labelLeft, [TTDeviceUIUtils tt_newPadding:16], MIN(maxLenth - [TTDeviceUIUtils tt_newPadding:14] - [TTDeviceUIUtils tt_newPadding:4], size.width), [TTDeviceUIUtils tt_newPadding:26]);
        self.veriImageView.frame = CGRectMake(self.nameLabel.right + [TTDeviceUIUtils tt_newPadding:4], 0, [TTDeviceUIUtils tt_newPadding:14], [TTDeviceUIUtils tt_newPadding:14]);
        self.veriImageView.centerY = self.nameLabel.centerY;
    } else {
        self.veriImageView.frame = CGRectZero;
        self.nameLabel.frame = CGRectMake(labelLeft, [TTDeviceUIUtils tt_newPadding:16], self.width - [TTDeviceUIUtils tt_newPadding:12] - labelLeft, [TTDeviceUIUtils tt_newPadding:26]);
    }
    self.subTitleLabel.frame = CGRectMake(self.avatarImageView.right + [TTDeviceUIUtils tt_newPadding:16], self.nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:3], self.width - [TTDeviceUIUtils tt_newPadding:12] - self.subTitleLabel.left, [TTDeviceUIUtils tt_newPadding:16]);
    self.contentLabel.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:12], self.avatarImageView.bottom + [TTDeviceUIUtils tt_newPadding:14], self.width - 2 * [TTDeviceUIUtils tt_newPadding:12], [TTDeviceUIUtils tt_newPadding:17]);
}

- (void)configWithModel:(TTXiguaLiveModel *)model {
    self.model = model;
    self.nameLabel.text = [model liveUserInfoModel].name;
    self.subTitleLabel.text = [NSString stringWithFormat:@"%ld人观看", [model liveLiveInfoModel].watchingCount];
    self.contentLabel.text = model.title;
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
        _nameLabel.font = [UIFont tt_boldFontOfSize:[TTDeviceUIUtils tt_newFontSize:19]];
        _nameLabel.numberOfLines = 1;
    }
    return _nameLabel;
}

- (SSThemedLabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _subTitleLabel.textColorThemeKey = kColorText3;
        _subTitleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:11]];
        _subTitleLabel.numberOfLines = 1;
    }
    return _subTitleLabel;
}

- (SSThemedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        _contentLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:13]];
        _contentLabel.numberOfLines = 1;
    }
    return _contentLabel;
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

- (TTXiguaLiveLivingAnimationView *)animationView {
    if (!_animationView) {
        _animationView = [[TTXiguaLiveLivingAnimationView alloc] initWithStyle:TTXiguaLiveLivingAnimationViewStyleSmallNoLine];
        [_animationView beginAnimation];
    }
    return _animationView;
}

@end
