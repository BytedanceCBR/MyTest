//
//  TTLiveFakeNavigationBar.m
//  TTLive
//
//  Created by matrixzk on 7/18/16.
//
//

#import "TTLiveFakeNavigationBar.h"

#import "SSThemed.h"
#import "TTAlphaThemedButton.h"

#import <Masonry.h>
#import "NSStringAdditions.h"

#import "UIButton+WebCache.h"

#import "TTLiveTopBannerInfoModel.h"
#import "TTLiveStreamDataModel.h"
#import <TTNetworkManager.h>
#import "TTIndicatorView.h"

#import "TTRoute.h"
#import "TTActivityShareManager.h"
#import "SSActivityView.h"
#import "TTModuleBridge.h"
#import "TTLiveMainViewController.h"
#import "NSStringAdditions.h"
#import "TTFollowNotifyServer.h"
#import "NSStringAdditions.h"
#import "TTLiveHeaderView.h"
#import "TTImageView.h"
#import "TTIconFontChatroomDefine.h"
#import <TTTracker/TTTrackerProxy.h>
#import "TTUIResponderHelper.h"
#import "TTFollowThemeButton.h"
#import "UIImage+Masking.h"
#import "UIButton+SDAdapter.h"

extern NSString * const TTFollowSuccessForPushGuideNotification;

@interface TTLiveFakeNavigationBar () <SSActivityViewDelegate>

@property (nonatomic, strong) TTAlphaThemedButton  *backButton;
//@property (nonatomic, strong) TTAlphaThemedButton  *followedButton;
@property (nonatomic, strong) TTFollowThemeButton  *followedButton;

@property (nonatomic, strong) TTAlphaThemedButton  *shareBtn;

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedView *bottomLine;

// 赛事相关

@property (nonatomic, strong)UIView *labelView;
//Normal
/** 直播状态&参与人数 */
@property (nonatomic, strong) UIView *messageView;
@property (nonatomic, strong) SSThemedLabel *participatedLabel;

//Silder
/** 未开始显示时间 */
@property (nonatomic, strong) SSThemedLabel *startDateLabel;
@property (nonatomic, strong) SSThemedLabel *startTimeLabel;
/** 比分 */
@property (nonatomic, strong) SSThemedLabel *scoreLabel;
/** 副标题 */
@property (nonatomic, strong) SSThemedLabel *matchSubtitle;
@property (nonatomic, strong) UIButton *leftTeamLogoButton;
@property (nonatomic, strong) UIButton *rightTeamLogoButton;

// 视频相关
@property (nonatomic, strong) UIButton *statusView;
@property (nonatomic, strong) UILabel *returnLbl;

@property (nonatomic, strong) SSActivityView *phoneShareView;
@property (nonatomic, strong) TTActivityShareManager *activityActionManager;

@property (nonatomic, assign) TTLiveFakeNavigationBarType barType;
@property (nonatomic, assign) BOOL isFollowed;
@property (nonatomic, strong) TTLiveTopBannerInfoModel *dataModel;
@property (nonatomic, assign) TTLiveStatus currentLiveStatus;

@property (nonatomic, weak) TTLiveMainViewController *chatroom;

@end

static CGFloat kOffsetCenterY = 10;
static CGFloat realNavBarHeight = 44;
@implementation TTLiveFakeNavigationBar

- (void)dealloc {
    [_dataModel removeObserver:self forKeyPath:@"followed"];
}

- (instancetype)initWithFrame:(CGRect)frame chatroom:(TTLiveMainViewController *)chatroom {
    self = [super initWithFrame:frame];
    if (self) {
        
        _chatroom = chatroom;
        
        self.backgroundColorThemeKey = kColorBackground4;
        
        // 返回button
        _backButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
        _backButton.imageName = @"lefterbackicon_titlebar";
        [_backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(32);
            make.height.mas_equalTo(44);
            make.bottom.equalTo(self);
            make.left.equalTo(self.mas_left).offset(8);
        }];
        
        // 底部分割线
        _bottomLine = [[SSThemedView alloc] init];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_bottomLine];
        [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.bottom.equalTo(self.mas_bottom).offset(-[TTDeviceHelper ssOnePixel]);
            make.width.equalTo(self);
            make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
        }];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (TTLiveTypeVideo == self.dataModel.background_type.integerValue) {
        [self refreshTitleView];
    }
}

- (void)setupBarWithModel:(TTLiveTopBannerInfoModel *)model type:(TTLiveFakeNavigationBarType)type
{
    if (!model) {
        return;
    }
    
    _dataModel = model;
    _barType = type;
    _currentLiveStatus = _dataModel.status.integerValue;
    
    [self refreshRightButton];
    
    // KVO
    [_dataModel addObserver:self forKeyPath:@"followed" options:NSKeyValueObservingOptionNew context:(void *)self];
    
    switch (type) {
            
        case TTLiveFakeNavigationBarTypeNormal:
            [self setupSubviews4BarTypeNormal];
            _shareBtn.imageName = @"new_share_tabbar1";
            [self refreshMessageViewWitParticipated:model.participated.stringValue participatedSuffix:model.participated_suffix];
            break;
            
        case TTLiveFakeNavigationBarTypeSlide:
            [self setupSubviews4BarTypeSlide];
            _shareBtn.imageName = @"new_share_tabbar";
            _matchSubtitle.text = model.subtitle;
            [self updateScoreAndSubtitleConst:!isEmptyString(model.subtitle)];
            break;
            
        default:
            break;
    }
}

- (void)refreshMessageViewWitParticipated:(NSString *)participated participatedSuffix:(NSString *)suffix {
    if (isEmptyString(participated)) {
        participated = @"0人参与";
    }else{
        _participatedLabel.text = [NSString stringWithFormat:@"%@%@",participated,suffix];
        [_participatedLabel sizeToFit];
        [_participatedLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(ceil(_participatedLabel.width));
            make.height.mas_equalTo(ceil(_participatedLabel.height));
        }];
    }
}

- (void)setupSubviews4BarTypeNormal
{
    [_bottomLine removeFromSuperview];
    
    switch (_dataModel.background_type.integerValue) {
            
        case TTLiveTypeSimple:
        case TTLiveTypeStar:
        {
            self.backgroundColorThemeKey = nil;
            _backButton.imageName = @"white_lefterbackicon_titlebar";
            
            [self addTitleLabelWithText:self.dataModel.title colorKey:kColorText12 needShadow:NO];
        }
            break;
        case TTLiveTypeMatch:
        {
            self.backgroundColorThemeKey = nil;
            _backButton.imageName = @"white_lefterbackicon_titlebar";
            
            NSString *title = self.dataModel.background.match.title;
            [self addTitleLabelWithText:title colorKey:kColorText12 needShadow:NO];
            [self addMessageView];
        }
            break;
            
        case TTLiveTypeVideo:
        {
            self.backgroundColorThemeKey = nil;
            
            UIImageView *bgImgView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"up_textshade_video"]];
            bgImgView.frame = self.bounds;
            [self insertSubview:bgImgView atIndex:0];
            
            _backButton.imageName = @"leftbackbutton_titlebar_photo_preview";
            _backButton.highlightedImageName = @"leftbackbutton_titlebar_photo_preview_press";
            
            [self addTitleLabelWithText:self.dataModel.title colorKey:kColorText12 needShadow:NO];
        }
            break;
            
        default:
            break;
    }
}

- (void)setupSubviews4BarTypeSlide
{
    self.backgroundColorThemeKey = kColorBackground4;
    _backButton.imageName = @"lefterbackicon_titlebar";
    
    switch (_dataModel.background_type.integerValue) {
            
        case TTLiveTypeSimple:
        case TTLiveTypeStar:
            [self addTitleLabelWithText:self.dataModel.title colorKey:kColorText1 needShadow:NO];
            break;
            
        case TTLiveTypeMatch:
            [self setupSubviews4Match];
            break;
            
        case TTLiveTypeVideo:
        {
            self.backgroundColorThemeKey = nil;
            _backButton.imageName = @"leftbackbutton_titlebar_photo_preview";
            _backButton.highlightedImageName = @"leftbackbutton_titlebar_photo_preview_press";
            
            [_bottomLine removeFromSuperview];
            
            [self setupSubviews4Video];
        }
            
        default:
            break;
    }
}

- (void)refreshBarWithModel:(TTLiveStreamDataModel *)model
{
    if (TTLiveFakeNavigationBarTypeSlide != _barType) {
        switch (_dataModel.background_type.integerValue) {
            case TTLiveTypeMatch:
            {
                if (_currentLiveStatus != model.status.integerValue) {
                    _currentLiveStatus = model.status.integerValue;
                }
                [self refreshMessageViewWitParticipated:model.participated.stringValue participatedSuffix:_dataModel.participated_suffix];
            }
                break;
        }
        return;
    }
    
    switch (_dataModel.background_type.integerValue) {
        case TTLiveTypeMatch:
        {
            if (_currentLiveStatus != model.status.integerValue) {
                _currentLiveStatus = model.status.integerValue;
                [self refreshMatchTitleViewWithStatus:_currentLiveStatus];
            }
            [self refreshMatchScoreWithModel:model];
            _matchSubtitle.text = model.subtitle;
            [self updateScoreAndSubtitleConst:!isEmptyString(model.subtitle)];
        }
            break;
            
        case TTLiveTypeVideo:
            if (_currentLiveStatus != model.status.integerValue) {
                _currentLiveStatus = model.status.integerValue;
                [self refreshVideoStatusViewWithStatus:_currentLiveStatus statusDescription:model.status_display];
            }
            break;
        default:
            break;
    }
}

- (void)refreshFollowedButtonStatus:(BOOL)isFollowed
{
    self.isFollowed = isFollowed;
    _followedButton.followed = isFollowed;
}

- (void)refreshRightButton
{
    if (_shareBtn == nil) {
        _shareBtn = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _shareBtn.imageName = @"new_share_tabbar";
        _shareBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
        _shareBtn.enableHighlightAnim = YES;
        _shareBtn.enableNightMask = NO;
        [_shareBtn addTarget:self action:@selector(makeShare:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shareBtn];
        
    }
    if (_followedButton == nil) {
        TTFollowedType followType = TTFollowedType103;
        TTUnfollowedType unfollowType = TTUnfollowedType103;
        TTFollowedMutualType mutualType = TTFollowedMutualType103;
        if (_barType == TTLiveFakeNavigationBarTypeSlide && TTLiveTypeVideo != _dataModel.background_type.integerValue) {
            followType = TTFollowedType101;
            unfollowType = TTUnfollowedType101;
            mutualType = TTFollowedMutualType101;
        }
      
        _followedButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:unfollowType
                                                                 followedType:followType
                                                           followedMutualType:mutualType];
        [_followedButton addTarget:self action:@selector(followedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_followedButton];
        
    }
    
    if ([self.chatroom roleOfCurrentUserIsLeader]) {
        _followedButton.hidden = YES;
        _shareBtn.hidden = NO;
    } else {
        [self refreshFollowedButtonStatus:_dataModel.followed.boolValue];
        _followedButton.hidden = NO;
        _shareBtn.hidden = NO;
    }
    CGFloat topPadding = self.height - realNavBarHeight;
    if ([TTDeviceHelper isIPhoneXDevice]){
        kOffsetCenterY = topPadding / 2;
    }
    [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(28);
        make.height.mas_equalTo(28);
        make.centerY.equalTo(self.mas_centerY).offset(topPadding / 2);
        make.right.equalTo(self.mas_right).offset(TTLivePadding(-15));
    }];
    [_followedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(58);
        make.height.mas_equalTo(28);
        make.centerY.equalTo(self.mas_centerY).offset(topPadding / 2);;
        if (_shareBtn.hidden){
            make.right.equalTo(self.mas_right).offset(TTLivePadding(15));
        }else{
            make.right.equalTo(_shareBtn.mas_left).offset(TTLivePadding(-15));
        }
    }];
}

- (void)addUnfoldedButton
{
    UIButton *unfoldedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    WeakSelf;
    [unfoldedButton addTarget:self withActionBlock:^{
        StrongSelf;
        [self.chatroom unfoldedHeaderView];
        // event track
        [self.chatroom eventTrackWithEvent:@"live" label:@"video_header_launch"];
    } forControlEvent:UIControlEventTouchUpInside];
    [self addSubview:unfoldedButton];
    [self bringSubviewToFront:unfoldedButton];
    [unfoldedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat padding = 12;
        make.centerY.equalTo(self.mas_centerY).offset(kOffsetCenterY);
        make.right.equalTo(_followedButton.mas_left).offset(-padding);
        make.left.equalTo(_backButton.mas_right).offset(padding);
        make.height.equalTo(@(CGRectGetHeight(self.frame) - 20));
    }];
}

- (void)addTitleLabelWithText:(NSString *)text colorKey:(NSString *)colorKey needShadow:(BOOL)needShadow
{
    if (_titleLabel) {
        [_titleLabel removeFromSuperview];
        _titleLabel = nil;
    }
    
    _titleLabel = [SSThemedLabel new];
    _titleLabel.textColorThemeKey = colorKey;
    _titleLabel.font = [UIFont systemFontOfSize:17];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    if (needShadow) {
        _titleLabel.layer.shadowColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.85].CGColor;
        _titleLabel.layer.shadowRadius = 2.5;
        _titleLabel.layer.shadowOpacity = 0.85;
        _titleLabel.layer.shadowOffset = CGSizeZero;
    }
    [self addSubview:_titleLabel];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat padding = 12;
        make.centerY.equalTo(self.backButton);
        make.left.greaterThanOrEqualTo(self.backButton.mas_right).offset(padding);
        make.right.lessThanOrEqualTo(self.followedButton.mas_left).offset(-padding);
        make.centerX.equalTo(self).priority(MASLayoutPriorityDefaultLow);
    }];
    _titleLabel.text = text;
}

- (void)addMessageView {
    if (self.barType == TTLiveFakeNavigationBarTypeNormal) {
        [_shareBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
        }];
        [_followedButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
        }];
        [_backButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
        }];
    }
    
    _titleLabel.font = [UIFont systemFontOfSize:16];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        CGFloat padding = 12;
        make.top.equalTo(self).offset(5);
        make.height.mas_equalTo(22);
        make.left.greaterThanOrEqualTo(self.backButton.mas_right).offset(padding);
        make.right.lessThanOrEqualTo(self.followedButton.mas_left).offset(-padding);
        make.centerX.equalTo(self).priority(MASLayoutPriorityDefaultLow);
    }];
    
    _participatedLabel = [[SSThemedLabel alloc] init];
    _participatedLabel.font = [UIFont systemFontOfSize:12];
    _participatedLabel.textColorThemeKey = kColorText12;
    _participatedLabel.text = @"0";
    [_participatedLabel sizeToFit];
    [self addSubview:_participatedLabel];
    [_participatedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_titleLabel);
        make.top.equalTo(_titleLabel.mas_bottom);
        make.height.mas_equalTo(14);
    }];
    
}

- (void)refreshTitleViewHidden:(BOOL)hidden{
    _rightTeamLogoButton.hidden = hidden;
    _leftTeamLogoButton.hidden = hidden;
    _scoreLabel.hidden = hidden;
    _matchSubtitle.hidden = hidden;
    _startTimeLabel.hidden = hidden;
    _startDateLabel.hidden = hidden;
    _messageView.hidden = hidden;
    _titleLabel.hidden = hidden;
    _participatedLabel.hidden = hidden;
}

- (void)refreshActionButtonHidden:(BOOL)hidden{
    _backButton.hidden = hidden;
    _followedButton.hidden = hidden;
    _shareBtn.hidden = hidden;
}

#pragma mark - Video

- (void)setupSubviews4Video
{
    UIView *backBlurView;
    if ([TTDeviceHelper OSVersionNumber]>=9.0) {
        backBlurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]]; // UIBlurEffectStyleLight
    } else {
        backBlurView = [[UIToolbar alloc] init];
        [(UIToolbar *)backBlurView setBarStyle:UIBarStyleDefault];
    }
    backBlurView.frame = self.bounds;
    backBlurView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self insertSubview:backBlurView atIndex:0];
    
    _statusView = [self customStatusView];
    [self addSubview:_statusView];
    
    _returnLbl = [UILabel new];
    _returnLbl.font = [UIFont systemFontOfSize:17];
    _returnLbl.textColor = [UIColor tt_themedColorForKey:kColorText8];
    _returnLbl.text = @"回到直播";
    [self addSubview:_returnLbl];
    
    [self refreshVideoStatusViewWithStatus:_currentLiveStatus statusDescription:_dataModel.status_display];
    
    [self addUnfoldedButton];
}

- (void)refreshVideoStatusViewWithStatus:(TTLiveStatus)status statusDescription:(NSString *)description
{
    if (_statusView) {
        [_statusView removeFromSuperview];
    }
    
    if (isEmptyString(description) &&
        !(TTLiveStatusOver == status && _dataModel.background.video.playbackEnable)) {
        return;
    }
    
    switch (status) {
            
        case TTLiveStatusPre:
        {
            _statusView = [self customStatusView];
            [self addSubview:_statusView];
            
            [_statusView setImage:[UIImage themedImageNamed:@"chatroom_icon_video1"] forState:UIControlStateNormal];
            _statusView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground16];
            _statusView.layer.borderColor = [[UIColor colorWithHexString:@"#FFFFFF"] colorWithAlphaComponent:0.1].CGColor;
            [_statusView setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
            [self.statusView setTitle:description forState:UIControlStateNormal];
        }
            break;
            
        case TTLiveStatusPlaying:
            
            _statusView = [self customStatusView];
            [self addSubview:_statusView];
            
            [_statusView setImage:[UIImage themedImageNamed:@"chatroom_icon_live"] forState:UIControlStateNormal];
            _statusView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground7];
            _statusView.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground7].CGColor;
            [_statusView setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
            [_statusView setTitle:description forState:UIControlStateNormal];
            
            break;
            
        case TTLiveStatusOver:
            
            if (_dataModel.background.video.playbackEnable) {
                _statusView = [UIButton buttonWithType:UIButtonTypeCustom];
                [_statusView setImage:[UIImage themedImageNamed:@"chatroom_icon_voice_play"] forState:UIControlStateNormal];
                _statusView.userInteractionEnabled = NO;
                [self addSubview:_statusView];
            } else {
                _statusView = [self customStatusView];
                [self addSubview:_statusView];
                
                [_statusView setImage:[UIImage themedImageNamed:@"chatroom_icon_end"] forState:UIControlStateNormal];
                NSString *colorHex = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? @"E8E8E8" : @"999999";
                _statusView.backgroundColor = [UIColor colorWithHexString:colorHex];
                _statusView.layer.borderColor = [UIColor colorWithHexString:colorHex].CGColor;
                [_statusView setTitleColor:[UIColor tt_themedColorForKey:kColorText3] forState:UIControlStateNormal];
                [_statusView setTitle:description forState:UIControlStateNormal];
            }
            
            break;
            
        default:
            break;
    }
    
    [self refreshTitleView];
}

- (void)refreshTitleView
{
    [_statusView sizeToFit];
    [_returnLbl sizeToFit];
    
    CGSize stateViewSize = _statusView.frame.size;
    CGSize returnLblSize = _returnLbl.frame.size;
    
    CGFloat padding = 5;
    CGFloat totalWidth = stateViewSize.width + padding + returnLblSize.width;
    
    _statusView.frame = CGRectMake(CGRectGetMaxX(_backButton.frame) + (CGRectGetMinX(_followedButton.frame) - CGRectGetMaxX(_backButton.frame) - totalWidth)/2, 0, stateViewSize.width, stateViewSize.height);
    _returnLbl.frame = CGRectMake(CGRectGetMaxX(_statusView.frame) + padding, 0, returnLblSize.width, returnLblSize.height);
    
    _statusView.center = CGPointMake(_statusView.center.x, _backButton.center.y);
    _returnLbl.center = CGPointMake(_returnLbl.center.x, _backButton.center.y);
}

- (UIButton *)customStatusView
{
    UIButton *customView = [UIButton buttonWithType:UIButtonTypeCustom];
    customView.layer.cornerRadius = 5;
    customView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    customView.titleLabel.font = [UIFont systemFontOfSize:12];
    customView.contentEdgeInsets = UIEdgeInsetsMake(3, 5, 3, 8);
    customView.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
    customView.userInteractionEnabled = NO;
    
    return customView;
}

- (void)hideTitleView:(BOOL)hidden
{
//    self.titleLabel.hidden = hidden;
//    if (![self.chatroom roleOfCurrentUserIsLeader]) {
//        self.followedButton.hidden = hidden;
//    }
    
    // 这里的 hide 要支持动画，所以是设置 alpha
    CGFloat alpha = hidden ? 0 : 1;
    self.titleLabel.alpha = alpha;
    if (![self.chatroom roleOfCurrentUserIsLeader]) {
        self.followedButton.alpha = alpha;
    }
}

#pragma mark - Match

- (void)setupSubviews4Match
{
    CGFloat topPadding = self.height - realNavBarHeight;
    self.labelView = [[UIView alloc] init];
    _labelView.backgroundColor = [UIColor clearColor];
    [self addSubview:_labelView];
    [_labelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.height.mas_equalTo(realNavBarHeight);
    }];
    
    // 开始日期
    self.startDateLabel = [[SSThemedLabel alloc] init];
    self.startDateLabel.textColorThemeKey = kColorText1;
    self.startDateLabel.font = [UIFont systemFontOfSize:16];
    [_labelView addSubview:self.startDateLabel];
    [self.startDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(5 + topPadding);
        make.height.mas_equalTo(22);
        make.centerX.equalTo(self).priority(MASLayoutPriorityDefaultLow);
    }];
    
    // 开始时间
    self.startTimeLabel = [[SSThemedLabel alloc] init];
    self.startTimeLabel.textColorThemeKey = kColorText1;
    self.startTimeLabel.font = [UIFont systemFontOfSize:12];
    [_labelView addSubview:self.startTimeLabel];
    [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_startDateLabel);
        make.top.equalTo(_startDateLabel.mas_bottom);
        make.height.mas_equalTo(14);
    }];
    
    // 比分
    self.scoreLabel = [[SSThemedLabel alloc] init];
    self.scoreLabel.textColorThemeKey = kColorText1;
    self.scoreLabel.font = [UIFont boldSystemFontOfSize:14];
    if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]){
        self.scoreLabel.font = [UIFont boldSystemFontOfSize:13];
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"888: 888"];
    [self.scoreLabel sizeToFit];
    [_labelView addSubview:self.scoreLabel];
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_centerY).offset(kOffsetCenterY + 2);
        make.centerX.equalTo(self.mas_centerX);
        make.height.mas_greaterThanOrEqualTo(self.scoreLabel.height);
        make.width.mas_greaterThanOrEqualTo(self.scoreLabel.width);
    }];
    
    // 副标题
    _matchSubtitle = [[SSThemedLabel alloc] init];
    _matchSubtitle.textColorThemeKey = kColorText1;
    _matchSubtitle.font = [UIFont systemFontOfSize:12];
    [_labelView addSubview:_matchSubtitle];
    [_matchSubtitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_scoreLabel.mas_bottom).offset(2);
        make.centerX.equalTo(self);
    }];
    
    [_labelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.greaterThanOrEqualTo(_scoreLabel);
        make.width.greaterThanOrEqualTo(_matchSubtitle);
    }];
    
    CGFloat kSideOfLogo = 20;
    CGFloat kPaddingOfLogoToCenter = 6;
    if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]){
        kSideOfLogo = 16;
        kPaddingOfLogoToCenter = 3;
    }
    // Left Team
    self.leftTeamLogoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftTeamLogoButton.adjustsImageWhenHighlighted = NO;
    self.leftTeamLogoButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    WeakSelf;
    [self.leftTeamLogoButton addTarget:self withActionBlock:^{
        StrongSelf;
        NSString *openURLStr = self.dataModel.background.match.team1_url;
        if (!isEmptyString(openURLStr)) {
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openURLStr]];
            // evnet track
            [self eventTrackWithLabel:@"cell_match_head"];
        }
    } forControlEvent:UIControlEventTouchUpInside];
    [self.leftTeamLogoButton sda_setBackgroundImageWithURL:[NSURL URLWithString:[self.dataModel.background.match.team1_icon tt_stringValueForKey:@"url"]]
                                                 forState:UIControlStateNormal
                                         placeholderImage:[UIImage imageNamed:@"chatroom_background_image"]
                                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight){
                                                        [self.leftTeamLogoButton setBackgroundImage:[image tt_nightImage] forState:UIControlStateNormal];
                                                    }
                                                }];
    [self addSubview:self.leftTeamLogoButton];
    [self.leftTeamLogoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kSideOfLogo, kSideOfLogo));
        make.centerY.equalTo(self).offset(topPadding / 2);
        make.right.equalTo(_labelView.mas_left).offset(-kPaddingOfLogoToCenter);
    }];
    
    // Right Team
    self.rightTeamLogoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightTeamLogoButton.adjustsImageWhenHighlighted = NO;
    self.rightTeamLogoButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [self.rightTeamLogoButton addTarget:self withActionBlock:^{
        StrongSelf;
        NSString *openURLStr = self.dataModel.background.match.team2_url;
        if (!isEmptyString(openURLStr)) {
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openURLStr]];
            // evnet track
            [self eventTrackWithLabel:@"cell_match_head"];
        }
    } forControlEvent:UIControlEventTouchUpInside];
    [self.rightTeamLogoButton sda_setBackgroundImageWithURL:[NSURL URLWithString:[self.dataModel.background.match.team2_icon tt_stringValueForKey:@"url"]]
                                                  forState:UIControlStateNormal
                                          placeholderImage:[UIImage imageNamed:@"chatroom_background_image"]
                                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                     if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight){
                                                         [self.rightTeamLogoButton setBackgroundImage:[image tt_nightImage] forState:UIControlStateNormal];
                                                     }
                                                 }];
    [self addSubview:self.rightTeamLogoButton];
    [self.rightTeamLogoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kSideOfLogo, kSideOfLogo));
        make.centerY.equalTo(self.leftTeamLogoButton);
        make.left.equalTo(_labelView.mas_right).offset(kPaddingOfLogoToCenter);
    }];
    
    self.startTimeLabel.hidden = self.startDateLabel.hidden = self.scoreLabel.hidden = YES;
    
    // 比赛时间赋值
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.dataModel.start_time.doubleValue];
    self.startDateLabel.text = [TTBusinessManager stringChineseMMDDFormWithDate:startDate];
    self.startTimeLabel.text = [TTBusinessManager stringHHMMFormWithDate:startDate];
    
    // 比分赋值
    self.scoreLabel.text = [NSString stringWithFormat:@"%@ : %@", self.dataModel.background.match.team1_score, self.dataModel.background.match.team2_score];
    [self.scoreLabel sizeToFit];
    
    [self refreshMatchTitleViewWithStatus:self.dataModel.status.integerValue];
}

- (void)refreshMatchTitleViewWithStatus:(TTLiveStatus)liveStatus
{
    switch (liveStatus) {
        case TTLiveStatusPre:
            if (_startDateLabel.hidden){
                [_labelView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.greaterThanOrEqualTo(_startDateLabel);
                    make.width.greaterThanOrEqualTo(_startTimeLabel);
                }];
            }
            self.scoreLabel.hidden = YES;
            self.startDateLabel.hidden = self.startTimeLabel.hidden = NO;
            break;
            
        case TTLiveStatusPlaying:
        case TTLiveStatusOver:
            self.scoreLabel.hidden = NO;
            self.startDateLabel.hidden = self.startTimeLabel.hidden = YES;
            break;
            
        default:
            break;
    }
}

- (void)refreshMatchScoreWithModel:(TTLiveStreamDataModel *)model
{
    self.scoreLabel.text = [NSString stringWithFormat:@"%@ : %@", model.score1, model.score2];
    [self.scoreLabel sizeToFit];
}


#pragma mark - Action

- (CGFloat)followButtonCenterxToRight{
    if ([_chatroom roleOfCurrentUserIsLeader]){
        return 30;
    }else{
        return 84;
    }
}

- (void)backButtonPressed:(UIButton *)sender
{
    TTLiveOverallInfoModel *live = self.chatroom.overallModel;
    if (!isEmptyString(live.adId)) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:live.logExtra forKey:@"log_extra"];
        [dict setValue:live.liveId forKey:@"ext_value"];
        [dict setValue:@([[TTTrackerProxy sharedProxy] connectionType]) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        [dict setValue:live.liveStateNum forKey:@"live_status"];
        wrapperTrackEventWithCustomKeys(@"embeded_ad", @"detail_to_feed", live.adId, nil, dict);
    }
    [[TTUIResponderHelper topNavigationControllerFor:self] popViewControllerAnimated:YES];
}

- (void)followedButtonPressed:(UIButton *)sender
{
    if (![_dataModel.followed boolValue]) {
//        if ([TTFirstConcernManager firstTimeGuideEnabled]) {
//            TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//            WeakSelf;
//            [manager showFirstConcernAlertViewWithDismissBlock:^{
//                StrongSelf;
//                [self makeReservationRequestBarType:_barType];
//            }];
//        }
//        else {
            [self makeReservationRequestBarType:_barType];
//        }
    }
    else {
        [self makeReservationRequestBarType:_barType];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ((__bridge id)context == self) {
        if ([keyPath isEqualToString:@"followed"]) {
            BOOL isFollowed = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
            [self refreshFollowedButtonStatus:isFollowed];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if ([self.delegate respondsToSelector:@selector(navigationBarTap)]){
        [self.delegate navigationBarTap];
    }
}

- (void)updateScoreAndSubtitleConst:(BOOL)hasSubtitle {
    if (hasSubtitle) {
        [_scoreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_centerY).offset(kOffsetCenterY + 2);
            make.centerX.equalTo(self.mas_centerX);
        }];
    } else {
        [_scoreLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY).offset(kOffsetCenterY);
            make.centerX.equalTo(self.mas_centerX);
        }];
    }
}

#pragma mark - 旧代码，待重写

//分享
- (void)makeShare:(id)sender
{
    [_activityActionManager clearCondition];
    
    if (_activityActionManager == nil) {
        _activityActionManager = [[TTActivityShareManager alloc] init];
    }
    
    
    
    __block NSMutableArray * activityItems = nil;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:_activityActionManager forKey:@"manager"];
    [params setValue:self.chatroom.overallModel forKey:@"model"];
    
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"getShareItems" object:nil withParams:params complete:^(id  _Nullable result) {
        activityItems = result;
    }];
    
    if (_phoneShareView == nil) {
        self.phoneShareView = [[SSActivityView alloc] init];
        _phoneShareView.delegate = self;
        _phoneShareView.activityItems = activityItems;
    }
    
    [_phoneShareView showOnViewController:[TTUIResponderHelper topViewControllerFor:self]];
    
    // event track
    if ([sender isKindOfClass:[UIButton class]]) {
        [self eventTrackWithLabel:@"share_button"];
    }
}

//预约

- (void)makeReservationRequestBarType:(TTLiveFakeNavigationBarType)type
{
    NSString *flag = (type == TTLiveFakeNavigationBarTypeSlide) ? @"low_" : @"";
    
    // event track
    [self eventTrackWithLabel:[NSString stringWithFormat:@"reserve_%@click",flag]];
    //统计
    //    [[TTLiveManager sharedManager] trackerMainLiveLabel:[NSString stringWithFormat:@"reserve_%@click",flag]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.chatroom.overallModel.liveId forKey:@"live_id"];
    [params setValue:[NSNumber numberWithBool:self.isFollowed] forKey:@"unfollow"];
    
    
    NSString *url = [NSString stringWithFormat:@"%@/follow/",[CommonURLSetting liveTalkURLString]];
    //直播间关注，勿与用户关注混淆
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:@"POST" needCommonParams:YES callback:^(NSError *error,id jsonObj){
        
        if (error) {
            
            if ([self.delegate respondsToSelector:@selector(ttLiveFakeNavigationBarReserve:success:)]) {
                [self.delegate ttLiveFakeNavigationBarReserve:self.isFollowed success:NO];
            }
            
            NSString *text ;
            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                text = [jsonObj objectForKey:@"tips"];
            }
            if (text!=nil) {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                          indicatorText:text
                                         indicatorImage:nil
                                            autoDismiss:YES
                                         dismissHandler:nil];
            }
            
            //            if (self.isFollowed) {
            //                [[TTLiveManager sharedManager] trackerMainLiveLabel:[NSString stringWithFormat:@"reserve_%@fail",flag]];
            //            } else {
            //                [[TTLiveManager sharedManager] trackerMainLiveLabel:[NSString stringWithFormat:@"reserve_%@cancel_fail",flag]];
            //            }
            // event track
            [self eventTrackWithLabel:[NSString stringWithFormat:@"reserve_%@%@fail", flag, self.isFollowed ? @"" : @"cancel_"]];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setValue:self.chatroom.overallModel.liveId forKey:@"live_id"];
            [dic setValue:@(error.code) forKey:@"error_code"];
            [[TTMonitor shareManager] trackService:@"ttlive_follow" status:self.isFollowed extra:dic];
            
            return;
        }
        
        self.dataModel.followed = @(!self.isFollowed);
        
        if ([self.delegate respondsToSelector:@selector(ttLiveFakeNavigationBarReserve:success:)]) {
            [self.delegate ttLiveFakeNavigationBarReserve:self.isFollowed success:YES];
        }
        
        //统计
        if (self.isFollowed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TTLiveMainVCIncreaseNewFollowNotice object:nil];
        }
        if (!isEmptyString(self.chatroom.overallModel.liveId)) {
            [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:self.chatroom.overallModel.liveId
                                                             actionType:self.isFollowed?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                               itemType:TTFollowItemTypeDefault
                                                               userInfo:nil];
        }
        // event track
        [self eventTrackWithLabel:[NSString stringWithFormat:@"reserve_%@%@", flag, self.isFollowed ? @"success" : @"cancel"]];
        
        if ([self.dataModel.followed boolValue]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TTFollowSuccessForPushGuideNotification object:nil userInfo:@{@"reason": @(50)}];
        }
    }];
}


#pragma mark -- SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (itemType == TTActivityTypeNone) {
        //        [[TTLiveManager sharedManager] trackerMainLiveLabel:@"share_cancel_button"];
        // event track
        [self eventTrackWithLabel:@"share_cancel_button"];
    }
    else {
        
        if (view == _phoneShareView){
            _activityActionManager.isShareMedia = NO;
            
            UIImage *image = nil;
            TTLiveMainViewController *mainVC = (TTLiveMainViewController *)[self ss_nextResponderWithClass:[TTLiveMainViewController class]];
            if (mainVC) {
                image = mainVC.headerView.backgroundImageView.imageView.image;
            }
            if (image) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.image = image;
                UIImage *liveImage = [UIImage imageNamed:@"chatroom_icon_share_live"];
                liveImage = [liveImage imageScaleAspectToMaxSize:imageView.image.size.height];
                image = [UIImage drawImage:liveImage inImage:imageView.image atPoint:CGPointMake(image.size.width / 2, image.size.height / 2)];
            } else {
                image = [UIImage imageNamed:@"chatroom_icon_share_live_picture"];
            }
            _activityActionManager.shareImage = image;
            _activityActionManager.shareToWeixinMomentOrQZoneImage = image;
            
            TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.chatroom.overallModel.liveShareGroupId.stringValue itemID:nil impressionID:nil aggrType:1];
            _activityActionManager.groupModel = groupModel;
            [_activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor:self] sourceObjectType:TTShareSourceObjectTypeLiveChatRoom uniqueId:nil adID:nil platform:TTSharePlatformTypeOfMain groupFlags:nil];
            
            //统计
            NSString *event = [TTActivityShareManager tagNameForShareSourceObjectType:TTShareSourceObjectTypeLiveChatRoom];
            NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
            [self.chatroom eventTrackWithEvent:event label:label];
            //            [[TTLiveManager sharedManager] trackerEvent:tag label:label tab:nil extValue:nil];
            //            [self sendLiveShareTrackWithItemType:itemType];
        }
    }
}

#pragma mark - Event Track

- (void)eventTrackWithLabel:(NSString *)label
{
    [self.chatroom eventTrackWithEvent:@"live" label:label];
}

@end
