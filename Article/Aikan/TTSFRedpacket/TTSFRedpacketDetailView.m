//
//  TTSFRedpacketDetailView.m
//  he_uidemo
//
//  Created by chenjiesheng on 2017/11/29.
//  Copyright © 2017年 Bytedance. All rights reserved.
//

#import "TTSFRedpacketDetailView.h"
#import <ExploreAvatarView.h>
#import <UIColor+TTThemeExtension.h>
#import <SSThemed.h>
#import <TTDeviceUIUtils.h>
#import <UIViewAdditions.h>
#import "TTSFRedpacketMahjongWinnerDetailView.h"
#import "TTSFRedpacketRainDetailView.h"
#import "TTSFRedpacketPostTinyVideoDetailView.h"
#import "TTSFRedpacketTinyVideoDetailView.h"
#import "TTSFRedpacketInviteNewUserDetailView.h"
#import "TTSFRedpacketNewbeeDetailView.h"
#import "TTSFRedpacketSunshineDetailView.h"
#import "TTHProjectSharePanelTipModel.h"
#import "TTSFTracker.h"
#import "UIImage+TTSFResource.h"
#import "TTSFQRManager.h"
#import <SDWebImageManager.h>

#define kFontSizeBottomTipLabel             [TTDeviceUIUtils tt_newFontSize:12.f]

#define kPaddingBottomTipLabel              [TTDeviceUIUtils tt_newPadding:17.f]
#define kRadiuoCurveLayer                   [TTDeviceUIUtils tt_newPadding:38.f]
#define kTTAvatarViewSize                   [TTDeviceUIUtils tt_newPadding:60.f]

@implementation TTSFRedpacketDetailViewModel

@end

@interface TTSFRedpacketDetailView () <TTVBaseDemandPlayerDelegate>

@property (nonatomic, strong)CAGradientLayer        *curveLayer;
@property (nonatomic, copy) NSString *sponsorWebURLString;
@property (nonatomic, strong) TTHProjectSharePanelTipModel *tipModel;
@property (nonatomic, strong) UIImageView *bgImageView;

@end
@implementation TTSFRedpacketDetailView

- (void)dealloc
{
    [self.playVideo.player stop];
    [self.playVideo removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"no retain cycle");
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.scrollView addSubview:self.curveBackView];
        [self bringSubviewToFront:self.navBar];
        [self.scrollView sendSubviewToBack:self.curveBackView];
        [self.contentView addSubview:self.myRpTipButton];
        if (@available(iOS 11.0, *)) {
            self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.curveView.hidden = YES;
        self.navBarTitleLabel.hidden = YES;
        self.navBar.backgroundColor = [UIColor clearColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

+ (TTSFRedpacketDetailView *)createDetailViewWithViewType:(enum TTSFRedPacketViewType)viewType withFrame:(CGRect)frame
{
    switch (viewType) {
        case TTSFRedPacketViewTypeMahjongWinner:
            return [[TTSFRedpacketMahjongWinnerDetailView alloc] initWithFrame:frame];
        case TTSFRedPacketViewTypeRain:
            return [[TTSFRedpacketRainDetailView alloc] initWithFrame:frame];
        case TTSFRedPacketViewTypePostTinyVideo:
            return [[TTSFRedpacketPostTinyVideoDetailView alloc] initWithFrame:frame];
        case TTSFRedPacketViewTypeTinyVideo:
            return [[TTSFRedpacketTinyVideoDetailView alloc] initWithFrame:frame];
        case TTSFRedPacketViewTypeInviteNewUser:
            return [[TTSFRedpacketInviteNewUserDetailView alloc] initWithFrame:frame];
        case TTSFRedPacketViewTypeNewbee:
            return [[TTSFRedpacketNewbeeDetailView alloc] initWithFrame:frame];
        case TTSFRedPacketViewTypeSunshine:
            return [[TTSFRedpacketSunshineDetailView alloc] initWithFrame:frame];
        default:
            return [[TTSFRedpacketDetailView alloc] initWithFrame:frame];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.backgroundColor = [UIColor colorWithHexString:@"0xfefaf1"];
    
//    self.avatarView.size = CGSizeMake(kTTAvatarViewSize, kTTAvatarViewSize);
    // 顶部弧形layer的中间顶点高度
    self.avatarView.centerY = self.width * 142.f/375.f - self.navBar.bottom;
    self.avatarView.centerX = self.scrollView.width/2;
    self.coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:.02];
    self.coverView.hidden = NO;
    self.contentView.top = self.avatarView.bottom + [TTDeviceUIUtils tt_newPadding:12.f];
    self.nameLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
    self.nameLabel.top = 0;
    self.nameLabel.centerX = self.contentView.width/2;
    self.descriptionLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
    self.descriptionLabel.top = self.nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:8.f];
    self.descriptionLabel.centerX = self.contentView.width/2;

    self.moneyLabel.width = [TTDeviceUIUtils tt_newPadding:320.f];
    self.moneyLabel.centerX = (self.contentView.width + [TTDeviceUIUtils tt_newFontSize:14.f]) / 2;
    self.moneyLabel.top = self.descriptionLabel.bottom + [TTDeviceUIUtils tt_newPadding:52.f];
    
    self.withdrawButton.top = self.moneyLabel.bottom + [TTDeviceUIUtils tt_newPadding:8];
    
    // 适配一下4s,放不开
    if ([TTDeviceHelper getDeviceType] == TTDeviceMode480) {
        self.moneyLabel.top = self.descriptionLabel.bottom + [TTDeviceUIUtils tt_newPadding:5.f];
        self.withdrawButton.top = self.moneyLabel.bottom - 8.f;
    }
    
    self.scrollView.frame = self.bounds;
    self.scrollView.contentInset = UIEdgeInsetsMake(self.navBar.height, 0, 0, 0);
    self.curveBackView.top = -self.navBar.height;
    self.withdrawButton.hidden = YES;
    
    CGFloat viewWidth = self.width - kPaddingLeftPlayerView * 2;
    CGFloat viewHeight = viewWidth * 9 / 16.0;
    self.playVideo.size = CGSizeMake(viewWidth, viewHeight);
    self.playVideo.centerX = self.centerX;
    self.playVideo.bottom = self.height - kPaddingBottomPlayerView;
    
    self.playVideoBgView.frame = self.playVideo.frame;
    
    self.myRpTipButton.top = self.moneyLabel.bottom;
    self.myRpTipButton.centerX = self.contentView.width/2;
    
    if ([TTDeviceHelper getDeviceType] == TTDeviceMode480) {
        self.myRpTipButton.top = self.moneyLabel.bottom - 8.f;
    }
}

- (void)safeAreaInsetsDidChange
{
    [super safeAreaInsetsDidChange];
    if (@available(iOS 11.0, *)) {
        if (self.safeAreaInsets.bottom != 0) {
            self.playVideo.bottom = self.height - kPaddingBottomPlayerView - self.tt_safeAreaInsets.bottom;
            self.bgImageView.top = [TTDeviceUIUtils tt_newPadding:253.f];
        }
    }
}

- (void)configWithViewModel:(TTRedPacketDetailBaseViewModel *)viewModel
{
    [super configWithViewModel:viewModel];
    if ([viewModel isKindOfClass:[TTSFRedpacketDetailViewModel class]]) {
        TTSFRedpacketDetailViewModel *sfViewModel = (TTSFRedpacketDetailViewModel *)viewModel;
        self.rpViewModel = sfViewModel;
        // 设置头像，如果sponsor信息为空，展示头条icon。如果有其他定制，子类重新设置
        if (!isEmptyString(sfViewModel.sponsor.icon)) {
            [self.avatarView setImageWithURLString:sfViewModel.sponsor.icon];
        } else {
            [self.avatarView.imageView setImage:[UIImage ttsf_imageNamed:@"rp_toutiao_icon.png"]];
        }
        self.avatarView.disableNightMode = YES;
        
        self.coverView.hidden = NO;
        
        self.nameLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:19.f]];
        self.nameLabel.text = !isEmptyString(sfViewModel.sponsor.name) ? sfViewModel.sponsor.name : @"今日头条";
        [self.nameLabel sizeToFit];
        
        self.descriptionLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
        self.descriptionLabel.numberOfLines = 1;
        self.descriptionLabel.text = !isEmptyString(sfViewModel.sponsor.content) ? sfViewModel.sponsor.content : @"新年大吉 恭喜发财";
        [self.descriptionLabel sizeToFit];
        
        NSMutableAttributedString *moneyAmount = [[NSMutableAttributedString alloc] initWithString:viewModel.money attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:48]]}];
        [moneyAmount appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"  元" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]]}]];
        self.moneyLabel.attributedText = moneyAmount;
        self.moneyLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        
        self.bgImageView = [[UIImageView alloc] initWithImage:[UIImage ttsf_imageNamed:@"rp_detail_bg.png"]];
        [self.bgImageView sizeToFit];
        self.bgImageView.centerX = self.width/2;
        self.bgImageView.bottom = self.height - [TTDeviceUIUtils tt_newPadding:32.f];
        if ([TTDeviceHelper getDeviceType] == TTDeviceMode812) {
            self.bgImageView.top = [TTDeviceUIUtils tt_newPadding:253.f];
        }
        [self addSubview:self.bgImageView];
        
        TTVBasePlayerModel *playerModel = [[TTVBasePlayerModel alloc] init];
        playerModel.videoID = sfViewModel.sponsor.vid;
        playerModel.enableBackgroundManager = YES;
        self.playVideo = [[TTVBasePlayVideo alloc] initWithFrame:CGRectZero playerModel:playerModel];
        self.playVideo.player.delegate = self;
        self.playVideo.player.tipCreator = [TTSFRedPacketPlayVideoTipCreator new];
        self.playVideo.player.bottomBarView.hidden = YES;
        self.playVideo.player.controlView.hidden = YES;
        self.playVideo.playerModel.enableCommonTracker = NO;
        self.playVideo.playerModel.disableControlView = YES;
        
        // 子类需要时展示并播放
        [self addSubview:self.playVideo];
        self.playVideo.hidden = YES;
        
        self.playVideoBgView = [[UIImageView alloc] initWithImage:[UIImage ttsf_imageNamed:@"play_video_bg.png"]];
        [self addSubview:self.playVideoBgView];
        self.playVideoBgView.hidden = YES;
        
        [self bringSubviewToFront:self.playVideoBgView];
        
        [self configSharePanelWithModel:sfViewModel];
        [self.shareButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.navBar addSubview:self.shareButton];
        
        if (self.navigationController && self.navigationController.topViewController == self.viewController && self.navigationController.viewControllers.count > 1) {
            //从我的红包页进入
            [self.navBarLeftButton setTitle:nil forState:UIControlStateNormal];
            [self.navBarLeftButton setImage:[UIImage ttsf_imageNamed:@"sf_back_arrow"] forState:UIControlStateNormal];
            [self.navBarLeftButton sizeToFit];
            self.navBarLeftButton.centerY = self.shareButton.centerY;
            self.navBarLeftButton.left = [TTDeviceUIUtils tt_newPadding:14.f];
            WeakSelf;
            [self.navBarLeftButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            [self.navBarLeftButton addTarget:self withActionBlock:^{
                StrongSelf;
                if (self.viewController.navigationController) {
                    [self.viewController.navigationController popViewControllerAnimated:YES];
                }
            } forControlEvent:UIControlEventTouchUpInside];
        }
        
        [self.navBarLeftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.tipModel = [[TTHProjectSharePanelTipModel alloc] init];
        self.tipModel.interfaceTipViewIdentifier = @"TTHProjectSharePanelTipView";
        self.tipModel.shareInfo = sfViewModel.shareInfo;
        self.tipModel.shareContentType = TTSFShareContentTypeWebPage;
        self.tipModel.disablePlatform = TTSFShareSupportPlatformSaveImage;
        self.tipModel.trackDict = ({
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:@"red_env" forKey:@"share_type"];
            if ([NSStringFromClass(self.class) isEqualToString:@"TTSFRedpacketMahjongWinnerDetailView"]) {
                [dict setValue:@"mahjong_event" forKey:@"event_type"];
            } else if ([NSStringFromClass(self.class) isEqualToString:@"TTSFRedpacketRainDetailView"]) {
                [dict setValue:@"game" forKey:@"event_type"];
            } else {
                [dict setValue:@"all_event" forKey:@"event_type"];
            }
            [dict copy];
        });
    }
    [self layoutSubviews];
}

- (TTSpringActivityEventType)trackEventTypeWithRedPacketDetailType
{
    if ([NSStringFromClass(self.class) isEqualToString:@"TTSFRedpacketMahjongWinnerDetailView"]) {
        return TTSpringActivityEventTypeMahjong;
    } else if ([NSStringFromClass(self.class) isEqualToString:@"TTSFRedpacketRainDetailView"]) {
        return TTSpringActivityEventTypeGame;
    } else if ([NSStringFromClass(self.class) isEqualToString:@"TTSFRedpacketPostTinyVideoDetailView"] ||
               [NSStringFromClass(self.class) isEqualToString:@"TTSFRedpacketTinyVideoDetailView"]) {
        return TTSpringActivityEventTypeShortVideo;
    } else if ([NSStringFromClass(self.class) isEqualToString:@"TTSFRedpacketInviteNewUserDetailView"] ||
               [NSStringFromClass(self.class) isEqualToString:@"TTSFRedpacketNewbeeDetailView"]) {
        return TTSpringActivityEventTypeNewUsers;
    } else {
        return TTSpringActivityEventTypeAll;
    }
}

- (UIButton *)myRpTipButton
{
    if (_myRpTipButton == nil) {
        _myRpTipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_myRpTipButton setTitle:@"已存入\"我的-我的红包\", 可提现" forState:UIControlStateNormal];
        [_myRpTipButton setTitleColor:[UIColor colorWithHexString:@"0x2a90d7"] forState:UIControlStateNormal];
        _myRpTipButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
        [_myRpTipButton sizeToFit];
        [_myRpTipButton addTarget:self action:@selector(myRpTipButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _myRpTipButton;
}

- (CAGradientLayer *)curveLayer
{
    if (_curveLayer == nil) {
        _curveLayer = [CAGradientLayer layer];
        CGFloat curveLayerHeight = self.width * 142.f/375.f;
        _curveLayer.frame = CGRectMake(0, 0, self.width, curveLayerHeight + 70.f);
        [_curveLayer setColors:@[
                                (id) [UIColor colorWithHexString:@"EF514A"].CGColor,
                                (id) [UIColor colorWithHexString:@"EF514A"].CGColor
                                ]];
        [_curveLayer setLocations:@[@(0),@(1)]];
        [_curveLayer setStartPoint:CGPointMake(.5, 0)];
        [_curveLayer setEndPoint:CGPointMake(.5, 1)];
        _curveLayer.zPosition = -1;
        CGFloat maskLayerWidth = self.width;
        CGFloat maskLayerHeight = curveLayerHeight - kRadiuoCurveLayer;
        
        UIBezierPath *strokePath = [UIBezierPath bezierPath];
        [strokePath moveToPoint:CGPointMake(maskLayerWidth, 0)];
        [strokePath addLineToPoint:CGPointMake(0, 0)];
        [strokePath addLineToPoint:CGPointMake(0, maskLayerHeight)];
        [strokePath addQuadCurveToPoint:CGPointMake(maskLayerWidth, maskLayerHeight) controlPoint:CGPointMake(maskLayerWidth / 2, curveLayerHeight + 45.f)]; // 控制点是切线焦点
        [strokePath closePath];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = strokePath.CGPath;
        _curveLayer.mask = maskLayer;
    }
    return _curveLayer;
}

- (UIView *)curveBackView
{
    if (_curveBackView == nil) {
        _curveBackView = [[UIView alloc] init];
        _curveBackView.frame = CGRectMake(0, 0, self.width, self.height);
        _curveBackView.userInteractionEnabled = NO;
        [_curveBackView.layer addSublayer:self.curveLayer];
    }
    return _curveBackView;
}

- (UIButton *)shareButton
{
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setHitTestEdgeInsets:UIEdgeInsetsMake(-11, -11, -11, -11)];
        [_shareButton setTitle:@"分享" forState:UIControlStateNormal];
        _shareButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]];
        [_shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_shareButton sizeToFit];
        _shareButton.centerY = self.navBarLeftButton.centerY;
        _shareButton.right = self.navBar.width - [TTDeviceUIUtils tt_newPadding:15.f];
    }
    return _shareButton;
}

- (void)configSharePanelWithModel:(TTSFRedpacketDetailViewModel *)detailViewModel
{
    if (!_sharePanel) {
        _sharePanel = [[TTHProjectSharePanelTipView alloc] initWithShareInfo:detailViewModel.shareInfo];
        _sharePanel.hidden = YES;
    }
}

- (void)shareAction:(id)sender
{
    UIButton *shareButton = (UIButton *)sender;
    self.sharePanel.hidden = NO;
    
    WeakSelf;
    [TTSFQRManager downLoadInfoWithInfoDict:[self.rpViewModel.shareInfo copy] withCompletion:^(UIImage *image) {
        StrongSelf;
        self.tipModel.shareImage = image;
    } shareType:TTSFQRShareTypeOther mahjong:nil];
    
    [TTInterfaceTipManager appendNonDirectorTipWithModel:self.tipModel];
    shareButton.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTTInterfaceTipViewSpringDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        shareButton.userInteractionEnabled = YES;
    });
}

- (void)dismissShareView
{
    _sharePanel.hidden = YES;
}

- (void)redPacketDidFinishTransitionAnimation
{
    
}

- (void)myRpTipButtonPressed
{
    if (self.viewController.navigationController) {
        if (self.viewController == self.viewController.navigationController.topViewController && self.viewController.navigationController.viewControllers.count > 1) {
            NSInteger popToIndex = self.viewController.navigationController.viewControllers.count - 2;
            UIViewController *naibourVC = [self.viewController.navigationController.viewControllers objectAtIndex:popToIndex];
            if ([naibourVC isKindOfClass:NSClassFromString(@"TTSFMyRedPacketViewController")]) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
        }
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://redpackage_sf_my_rp?from=%ld", [self trackEventTypeWithRedPacketDetailType]]];
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        [[TTRoute sharedRoute] openURLByPushViewController:url];
    }
}

- (void)startVideoIfNeed
{
    if (self.playVideo.player && self.playVideo.hidden == NO) {
        [self.playVideo.player play];
        self.playVideo.player.bottomBarView.hidden = YES;
        self.playVideo.player.controlView.hidden = YES;
    }
}

- (void)stopVideoIfNeed
{
    if ( self.playVideo.player && self.playVideo.hidden == NO) {
        [self.playVideo.player pause];
    }
}

- (void)appDidEnterBackgroundNotification
{
    [self stopVideoIfNeed];
}

- (void)appWillEnterForegroundNotification
{
    // 当前页面在展示时再start video
    if (nil != self.window) {
        [self startVideoIfNeed];
    }
}

#pragma TTVBaseDemandPlayerDelegate

- (void)playerPlaybackState:(TTVVideoPlaybackState)state
{
    if (state == TTVVideoPlaybackStateFinished) {
        [self.playVideo.player play];
    }
}

@end
