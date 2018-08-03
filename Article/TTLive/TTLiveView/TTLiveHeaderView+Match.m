//
//  TTLiveHeaderView+Match.m
//  Article
//
//  Created by matrixzk on 8/11/16.
//
//

#import "TTLiveHeaderView+Match.h"

#import "UIButton+WebCache.h"
#import "NSStringAdditions.h"
#import "UIButton+TTAdditions.h"

#import <Masonry.h>
#import "TTAdapterManager.h"
#import "TTRoute.h"

#import "SSWebViewController.h"
#import "TTLiveCellHelper.h"
#import "TTLiveStreamDataModel.h"
#import "NSStringAdditions.h"
#import "TTBusinessManager+StringUtils.h"
#import "UIImage+Masking.h"
#import "UIButton+SDAdapter.h"

static CGFloat kWidthOfMatchTeamLogo = 38;
static NSInteger teamLogoTag = 110;
static NSInteger teamNameTag = 111;
@implementation TTLiveHeaderView (Match)

- (void)setupSubviews4LiveTypeMatch
{
    CGFloat navHeight = 44;
    UIView *leftTeamView = [self teamLogoAndNameViewWithPositionIsLeft:YES];
    [self addSubview:leftTeamView];
    self.matchTeamView = leftTeamView;
    [leftTeamView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(navHeight + TTLivePadding(14) + self.heightOffset);//15是距离顶部的距离，64是导航栏+status的高度
    }];
    
    UIView *rightTeamView = [self teamLogoAndNameViewWithPositionIsLeft:NO];
    [self addSubview:rightTeamView];
    [rightTeamView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(leftTeamView);
    }];
    
    CGFloat maxWidthOfCenterLabel = CGRectGetWidth(self.frame)/2 - TTLivePadding(kWidthOfMatchTeamLogo + 4);
    
    // 比赛日期
    SSThemedLabel *startDateLabel = [self labelWithColorKey:kColorText12 fontSize:TTLiveFontSize(17)];
    [self addSubview:startDateLabel];
    self.matchStartDateLabel = startDateLabel;
    [startDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(leftTeamView.mas_top).offset(20);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(maxWidthOfCenterLabel);
    }];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.dataModel.start_time.doubleValue];
    startDateLabel.text = [NSString stringWithFormat:@"%@ %@", [TTBusinessManager stringChineseMMDDFormWithDate:startDate], [TTBusinessManager stringHHMMFormWithDate:startDate]];
    
    // 比赛状态和关注人数
//    SSThemedLabel *matchStatusLabel = [self labelWithColorKey:kColorText12 fontSize:TTLiveFontSize(10)];
//    [self addSubview:matchStatusLabel];
//    self.matchStatusLabel = matchStatusLabel;
//    CGFloat labelOffsetY = TTLivePadding(12) - TTLiveSafePaddingOfLabel(startDateLabel) - TTLiveSafePaddingOfLabel(matchStatusLabel);
//    [matchStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(startDateLabel.mas_bottom).offset(labelOffsetY);
//        make.centerX.equalTo(startDateLabel);
//        make.width.mas_equalTo(maxWidthOfCenterLabel);
//    }];
//    matchStatusLabel.text = [NSString stringWithFormat:@"%@  %@%@", self.dataModel.status_display, self.dataModel.participated, self.dataModel.participated_suffix];
    
    // 比分
    CGFloat scoreLabelPadding = TTLivePadding(32);
    SSThemedLabel *scoreLabel = [[SSThemedLabel alloc] init];
    UIView *scoreView = [[UIView alloc] init];
    scoreView.backgroundColor = [UIColor clearColor];
    [self addSubview:scoreView];
    self.matchScoreView = scoreView;
    [scoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(leftTeamView).offset(TTLivePadding(5));
        make.centerX.equalTo(self);
    }];
    SSThemedLabel *symbolLabel = [[SSThemedLabel alloc] init];
    symbolLabel.text = @":";
    symbolLabel.font = [UIFont fontWithName:@"DINCondensed-Bold" size:30];
    symbolLabel.textColorThemeKey = kColorText12;
    [scoreView addSubview:symbolLabel];
    [symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(scoreView).offset(-2);
        make.centerX.equalTo(scoreView);
    }];
    SSThemedLabel *leftScoreLabel = [[SSThemedLabel alloc] init];
    leftScoreLabel.text = @"888";
    leftScoreLabel.textColorThemeKey = kColorText12;
    leftScoreLabel.font = [UIFont fontWithName:@"DINCondensed-Bold" size:30];
    leftScoreLabel.textAlignment = NSTextAlignmentCenter;
    [leftScoreLabel sizeToFit];
    [scoreView addSubview:leftScoreLabel];
    self.matchScoreLeftLabel = leftScoreLabel;
    [leftScoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scoreView);
        make.centerY.equalTo(scoreView).offset(3);
        make.right.equalTo(symbolLabel.mas_left).offset(-scoreLabelPadding);
        make.width.mas_equalTo(leftScoreLabel.width);
        make.height.mas_equalTo(leftScoreLabel.height);
    }];
    SSThemedLabel *rightScoreLabel = [[SSThemedLabel alloc] init];
    rightScoreLabel.text = @"888";
    rightScoreLabel.textColorThemeKey = kColorText12;
    rightScoreLabel.font = [UIFont fontWithName:@"DINCondensed-Bold" size:30];
    rightScoreLabel.textAlignment = NSTextAlignmentCenter;
    [rightScoreLabel sizeToFit];
    [scoreView addSubview:rightScoreLabel];
    self.matchScoreRightLabel = rightScoreLabel;
    [rightScoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(scoreView);
        make.centerY.equalTo(scoreView).offset(3);
        make.left.equalTo(symbolLabel.mas_right).offset(scoreLabelPadding);
        make.width.mas_equalTo(rightScoreLabel.width);
        make.height.mas_equalTo(rightScoreLabel.height);
    }];
    [scoreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(leftScoreLabel);
    }];
    leftScoreLabel.text = [NSString stringWithFormat:@"%ld",self.dataModel.background.match.team1_score.integerValue];
    rightScoreLabel.text = [NSString stringWithFormat:@"%ld",self.dataModel.background.match.team2_score.integerValue];
    
    
    SSThemedLabel *subtitle = [[SSThemedLabel alloc] init];
    subtitle.font = [UIFont boldSystemFontOfSize:12];
    subtitle.textColorThemeKey = kColorText12;
    subtitle.textAlignment = NSTextAlignmentCenter;
    subtitle.text = self.dataModel.subtitle;
    [self addSubview:subtitle];
    self.matchSubtitleLabel = subtitle;
    [subtitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(leftTeamView);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(maxWidthOfCenterLabel);
    }];
    
    CGFloat teamPadding = 44;
    if ([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]){
        teamPadding = 28;
    }
    //添加一下球队位置约束
    [leftTeamView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.matchScoreView.mas_left).offset(TTLivePadding(-teamPadding));
    }];
    
    [rightTeamView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.matchScoreView.mas_right).offset(TTLivePadding(teamPadding));
    }];
    
    // 先hide
    startDateLabel.hidden = subtitle.hidden = scoreLabel.hidden = YES;
    
    self.matchVideoLinkBtnArray = [[NSMutableArray alloc] initWithCapacity:2];

    // 根据直播状态配置UI
    [self setupUIWithMatchStatus:self.dataModel.status.integerValue];
  
    if (self.chatroom.topInfoModel.status.integerValue == TTLiveStatusOver){
        self.matchSubtitleLabel.text = self.chatroom.topInfoModel.status_display;
    }else{
        self.matchSubtitleLabel.text = self.chatroom.topInfoModel.subtitle;
    }
/*
#if DEBUG
    // 测试H5外链随直播状态切换
    UIButton *testButton = [UIButton buttonWithType:UIButtonTypeCustom];
    testButton.backgroundColor = [UIColor purpleColor];
    [self addSubview:testButton];
    [testButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(80, 20));
        make.left.equalTo(self);
    }];
    WeakSelf;
    [testButton addTarget:self withActionBlock:^{
        StrongSelf;
        if (self.currentLiveStatus == TTLiveStatusPre) {
            self.currentLiveStatus = TTLiveStatusPlaying;
        } else if (self.currentLiveStatus == TTLiveStatusPlaying) {
            self.currentLiveStatus = TTLiveStatusOver;
        } else if (self.currentLiveStatus == TTLiveStatusOver) {
            self.currentLiveStatus = TTLiveStatusPre;
        }
        [self setupMatchVideoLinkButtonWithLiveStatus:self.currentLiveStatus];
    } forControlEvent:UIControlEventTouchUpInside];
#endif
 */
}

// 该方法只在直播状态变化时调用
- (void)setupUIWithMatchStatus:(TTLiveStatus)liveStatus
{
    switch (liveStatus) {
            
        case TTLiveStatusPre:
        {
            self.matchStartDateLabel.hidden = NO;
//            self.matchStatusLabel.hidden = NO;
            self.matchScoreView.hidden = YES;
            self.matchSubtitleLabel.hidden = YES;
        }
            break;
            
        case TTLiveStatusPlaying:
        case TTLiveStatusOver:
        {
            self.matchStartDateLabel.hidden = YES;
//            self.matchStatusLabel.hidden = NO;
            self.matchScoreView.hidden = NO;
            self.matchSubtitleLabel.hidden = NO;
            
//            [self.matchStatusLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(self.matchScoreLabel.mas_bottom);
//                make.centerX.equalTo(self.matchScoreLabel);
//            }];
        }
            break;
            
        default:
            break;
    }
    
    // 视频直播H5外链
    [self setupMatchVideoLinkButtonWithLiveStatus:liveStatus];
}

- (void)refreshMatchStatusWithModel:(TTLiveStreamDataModel *)model
{
    TTLiveStatus liveStatus = model.status.integerValue;
    
    if (self.currentLiveStatus != liveStatus) {
        self.currentLiveStatus = liveStatus;
        
        [self setupUIWithMatchStatus:liveStatus];
    }
    
//    self.matchStatusLabel.text = [NSString stringWithFormat:@"%@  %@%@", model.status_display, model.participated, self.dataModel.participated_suffix];
    
    if (!self.matchScoreView.hidden && liveStatus != TTLiveStatusPre) {
        self.matchScoreLeftLabel.text = [NSString stringWithFormat:@"%ld",model.score1.integerValue];
        self.matchScoreRightLabel.text = [NSString stringWithFormat:@"%ld",model.score2.integerValue];
    }
    if (liveStatus == TTLiveStatusOver){
        self.matchSubtitleLabel.text = model.status_display;
    }else{
        self.matchSubtitleLabel.text = model.subtitle;
    }
}

- (UIView *)teamLogoAndNameViewWithPositionIsLeft:(BOOL)isLeft
{
    UIView *bgView = [UIView new];
    
    UIImageView *bgBlueImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatroom_teamlogo_shadow"]];
    bgBlueImgView.userInteractionEnabled = NO;
    [bgView addSubview:bgBlueImgView];
    
    UIButton *teamLogo = [UIButton buttonWithType:UIButtonTypeCustom];
    teamLogo.clipsToBounds = YES;

    teamLogo.tag = teamLogoTag;
    teamLogo.adjustsImageWhenHighlighted = NO;
    WeakSelf;
    [teamLogo addTarget:self withActionBlock:^{
        StrongSelf;
        NSString *openURLStr = isLeft ? self.dataModel.background.match.team1_url : self.dataModel.background.match.team2_url;
        if (!isEmptyString(openURLStr)) {
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openURLStr]];
            // evnet track
            [self.chatroom eventTrackWithEvent:@"live" label:@"cell_match_head"];
        }
    } forControlEvent:UIControlEventTouchUpInside];
    [bgView addSubview:teamLogo];
    [teamLogo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(TTLivePadding(kWidthOfMatchTeamLogo), TTLivePadding(kWidthOfMatchTeamLogo)));
        make.top.equalTo(bgView);
        make.left.equalTo(bgView);
        make.right.equalTo(bgView);
    }];
    
    [bgBlueImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(teamLogo);
    }];
    
    SSThemedLabel *teamNameLabel = [self labelWithColorKey:kColorText12 fontSize:TTLiveFontSize(13)];
    teamNameLabel.font = [UIFont boldSystemFontOfSize:TTLiveFontSize(13)];
    teamNameLabel.tag = teamNameTag;
    [bgView addSubview:teamNameLabel];
    [teamNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(teamLogo.mas_bottom).offset(TTLivePadding(6));
        make.centerX.equalTo(teamLogo);
        make.bottom.mas_equalTo(bgView.mas_bottom);
    }];
    
    NSString *teamName;
    NSDictionary *logoDict;
    if (isLeft) {
        teamName = self.dataModel.background.match.team1_name;
        logoDict = self.dataModel.background.match.team1_icon;
    } else {
        teamName = self.dataModel.background.match.team2_name;
        logoDict = self.dataModel.background.match.team2_icon;
    }
    
    if (teamName.length > 8) {
        teamName = [teamName substringWithRange:NSMakeRange(0, 8)];
    }
    
    [teamLogo sda_setBackgroundImageWithURL:[NSURL URLWithString:[logoDict tt_stringValueForKey:@"url"]]
                                  forState:UIControlStateNormal
                          placeholderImage:[UIImage imageNamed:@"chatroom_background_image"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight){
                                         [teamLogo setBackgroundImage:[image tt_nightImage] forState:UIControlStateNormal];
                                     }
                          }];
    teamNameLabel.text = teamName;
    [teamNameLabel sizeToFit];
    
    return bgView;
}


#pragma mark - Setup H5 SourceButton

- (void)setupMatchVideoLinkButtonWithLiveStatus:(TTLiveStatus)liveStatus
{
    // 清除现有view
    [self.matchVideoLinkBtnArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.matchVideoLinkBtnArray removeAllObjects];
    
    switch (liveStatus) {
            
        case TTLiveStatusPre:
        case TTLiveStatusPlaying:
            // 显示直播外链
            [self showVideoLiveSourceButtons];
            break;
            
        case TTLiveStatusOver:
            // 若有集锦回放外链，则切换显示；若无，则不显示
            [self showVideoCollectionAndPlaybackSourceButtons];
            break;
            
        default:
            break;
    }
}

- (void)showVideoLiveSourceButtons
{
    TTLiveMatchVideoH5SourceInfo *videoLiveSource = self.dataModel.background.match.matchVideoLiveSource;
    videoLiveSource.sourceType = TTLiveMatchVideoH5SourceTypeLive;
    [self setupVideoSourceButtonsWithSrcInfo:videoLiveSource];
    
/*
#if DEBUG
    // 特定情形打点自测
    // 单个和两个直播源的情形
    TTLiveMatchVideoH5SourceInfo *videoLiveSource = self.dataModel.background.match.matchVideoLiveSource;
    TTLiveMatchVideoH5SourceInfo *srcInfo = [TTLiveMatchVideoH5SourceInfo new];
    // srcInfo.videoSourceArray = @[videoLiveSource.videoSourceArray.firstObject, videoLiveSource.videoSourceArray[1]];
    srcInfo.videoSourceArray = @[videoLiveSource.videoSourceArray.firstObject];
    srcInfo.sourceType = TTLiveMatchVideoH5SourceTypeLive;
    [self setupVideoSourceButtonsWithSrcInfo:srcInfo];
#endif
 */
}

- (void)showVideoCollectionAndPlaybackSourceButtons
{
    TTLiveMatchVideoH5SourceInfo *videoCollectionSource = self.dataModel.background.match.matchVideoCollectionSource;
    videoCollectionSource.sourceType = TTLiveMatchVideoH5SourceTypeCollection;
    TTLiveMatchVideoH5SourceInfo *videoPlaybackSource = self.dataModel.background.match.matchVideoPlaybackSource;
    videoPlaybackSource.sourceType = TTLiveMatchVideoH5SourceTypePlayback;

/*
#if DEBUG
    // 特定情形打点自测
    // 其一为单数
    // videoCollectionSource.videoSourceArray = @[videoCollectionSource.videoSourceArray.firstObject];
    // videoPlaybackSource.videoSourceArray = @[videoPlaybackSource.videoSourceArray.firstObject];
    // 其一为空
    // videoCollectionSource.videoSourceArray = @[];
    videoPlaybackSource.videoSourceArray = @[];
#endif
 */
    
    NSArray *leftSrcDetailArray = videoCollectionSource.videoSourceArray;
    NSArray *rightSrcDetailArray = videoPlaybackSource.videoSourceArray;
    
    if (leftSrcDetailArray.count > 0 && rightSrcDetailArray.count > 0) {
        
        [self setupDoubleVideoSourceButtonsWithLeftbtnSourceInfo:videoCollectionSource rightBtnSourceInfo:videoPlaybackSource];
        
    } else if (leftSrcDetailArray.count > 0) { // 只有集锦
        
        [self setupVideoSourceButtonsWithSrcInfo:videoCollectionSource];
        
    } else if (rightSrcDetailArray.count > 0) { // 只有回放
        
        [self setupVideoSourceButtonsWithSrcInfo:videoPlaybackSource];
        
    }
}

- (void)setupVideoSourceButtonsWithSrcInfo:(TTLiveMatchVideoH5SourceInfo *)sourceInfo
{
    if (sourceInfo.videoSourceArray.count == 0) {
        return;
    }
    
    if (sourceInfo.videoSourceArray.count == 2) {
        
        TTLiveMatchVideoH5SourceInfo *leftSrcInfo = [TTLiveMatchVideoH5SourceInfo new];
        leftSrcInfo.videoSourceArray = @[sourceInfo.videoSourceArray.firstObject];
        TTLiveMatchVideoH5SourceInfo *rightSrcInfo = [TTLiveMatchVideoH5SourceInfo new];
        rightSrcInfo.videoSourceArray = @[sourceInfo.videoSourceArray.lastObject];
        leftSrcInfo.sourceType = rightSrcInfo.sourceType = sourceInfo.sourceType;
        [self setupDoubleVideoSourceButtonsWithLeftbtnSourceInfo:leftSrcInfo rightBtnSourceInfo:rightSrcInfo];
        
    } else {
        // 1个或多于2个的情况
        [self setupSingleVideoSourceButtonWithSourceInfo:sourceInfo];
    }
}

- (void)setupDoubleVideoSourceButtonsWithLeftbtnSourceInfo:(TTLiveMatchVideoH5SourceInfo *)leftBtnSrcInfo rightBtnSourceInfo:(TTLiveMatchVideoH5SourceInfo *)rightBtnSrcInfo
{
    NSArray *leftSrcDetailArray = leftBtnSrcInfo.videoSourceArray;
    NSArray *rightSrcDetailArray = rightBtnSrcInfo.videoSourceArray;
    
    if (leftSrcDetailArray.count == 0) {
        [self setupSingleVideoSourceButtonWithSourceInfo:rightBtnSrcInfo];
        return;
    } else if (rightSrcDetailArray.count == 0) {
        [self setupSingleVideoSourceButtonWithSourceInfo:leftBtnSrcInfo];
        return;
    }
    
    CGFloat buttonPadding = TTLivePadding(10);
    
    /// Left
    UIButton *leftSrcButton;
    if (leftSrcDetailArray.count == 1) {
        
        TTLiveMatchVideoH5SourceDetail *srcDetail = leftSrcDetailArray.firstObject;

        leftSrcButton = [self videoSourceButtonWithTitle:[(TTLiveMatchVideoH5SourceDetail *)leftSrcDetailArray.firstObject title] needIcon:leftBtnSrcInfo.sourceType == TTLiveMatchVideoH5SourceTypeLive];;
        WeakSelf;
        [leftSrcButton addTarget:self withActionBlock:^{
            StrongSelf;
            [self showVideoDetailWithURL:srcDetail.openURL];
            // event track
            [self eventTrack4H5SourceButtonPressedWithSourceInfo:leftBtnSrcInfo];
        } forControlEvent:UIControlEventTouchUpInside];
        
    } else { // (>1)
        
        leftSrcButton = [self videoSourceButtonWithTitle:isEmptyString(leftBtnSrcInfo.title) ? @"选择视频源" : leftBtnSrcInfo.title needIcon:leftBtnSrcInfo.sourceType == TTLiveMatchVideoH5SourceTypeLive];
        WeakSelf;
        [leftSrcButton addTarget:self withActionBlock:^{
            StrongSelf;
            [self showVideoSourceListWithSourceInfo:leftBtnSrcInfo];
        } forControlEvent:UIControlEventTouchUpInside];
    }
    [self addSubview:leftSrcButton];
    [leftSrcButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-20);
        make.right.equalTo(self.mas_centerX).offset(-buttonPadding);
    }];
    
    
    /// Right
    UIButton *rightSrcButton;
    if (rightSrcDetailArray.count == 1) {
        
        TTLiveMatchVideoH5SourceDetail *srcDetail = rightSrcDetailArray.firstObject;
        rightSrcButton = [self videoSourceButtonWithTitle:[srcDetail title] needIcon:rightBtnSrcInfo.sourceType == TTLiveMatchVideoH5SourceTypeLive];;
        WeakSelf;
        [rightSrcButton addTarget:self withActionBlock:^{
            StrongSelf;
            [self showVideoDetailWithURL:srcDetail.openURL];
            // event track
            [self eventTrack4H5SourceButtonPressedWithSourceInfo:rightBtnSrcInfo];
        } forControlEvent:UIControlEventTouchUpInside];
        
    } else { // (>1)
        
        rightSrcButton = [self videoSourceButtonWithTitle:isEmptyString(rightBtnSrcInfo.title) ? @"选择视频源" : rightBtnSrcInfo.title needIcon:rightBtnSrcInfo.sourceType == TTLiveMatchVideoH5SourceTypeLive];
        WeakSelf;
        [rightSrcButton addTarget:self withActionBlock:^{
            StrongSelf;
            [self showVideoSourceListWithSourceInfo:rightBtnSrcInfo];
        } forControlEvent:UIControlEventTouchUpInside];
    }
    [self addSubview:rightSrcButton];
    [rightSrcButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-20);
        make.left.equalTo(self.mas_centerX).offset(buttonPadding);
    }];
    
    [self.matchVideoLinkBtnArray addObject:leftSrcButton];
    [self.matchVideoLinkBtnArray addObject:rightSrcButton];
}


- (void)setupSingleVideoSourceButtonWithSourceInfo:(TTLiveMatchVideoH5SourceInfo *)sourceInfo
{
    NSArray *sourceDetailArray = sourceInfo.videoSourceArray;
    if (sourceDetailArray.count == 0) {
        return;
    }
    
    UIButton *srcButton;
    if (sourceDetailArray.count == 1) {
        TTLiveMatchVideoH5SourceDetail *sourceDetail = sourceDetailArray.firstObject;
        srcButton = [self videoSourceButtonWithTitle:sourceDetail.title needIcon:sourceInfo.sourceType == TTLiveMatchVideoH5SourceTypeLive];
        WeakSelf;
        [srcButton addTarget:self withActionBlock:^{
            StrongSelf;
            [self showVideoDetailWithURL:sourceDetail.openURL];
            // event track
            [self eventTrack4H5SourceButtonPressedWithSourceInfo:sourceInfo];
        } forControlEvent:UIControlEventTouchUpInside];
        
    } else { // (>1)
        srcButton = [self videoSourceButtonWithTitle:isEmptyString(sourceInfo.title) ? @"选择视频源" : sourceInfo.title needIcon:sourceInfo.sourceType == TTLiveMatchVideoH5SourceTypeLive];
        WeakSelf;
        [srcButton addTarget:self withActionBlock:^{
            StrongSelf;
            [self showVideoSourceListWithSourceInfo:sourceInfo];
        } forControlEvent:UIControlEventTouchUpInside];
    }
    
    [self addSubview:srcButton];
    [srcButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-20);
        make.centerX.equalTo(self);
    }];
    
    [self.matchVideoLinkBtnArray addObject:srcButton];
}

- (UIButton *)videoSourceButtonWithTitle:(NSString *)title needIcon:(BOOL)need
{
    TTAlphaThemedButton *sourceButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom]; // TTAlphaThemedButton
    sourceButton.adjustsImageWhenHighlighted = NO;
    sourceButton.layer.masksToBounds = YES;
    sourceButton.layer.cornerRadius = 4;
    sourceButton.titleLabel.font = [UIFont systemFontOfSize:TTLiveFontSize(14)];
    sourceButton.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    if (need){
        [sourceButton setImage:[UIImage themedImageNamed:@"chatroom_icon_video_match"] forState:UIControlStateNormal];
        sourceButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 0);
        sourceButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 0);
    }
    sourceButton.backgroundColorThemeKey = kColorBackground15;
    [sourceButton setTitleColor:[UIColor tt_themedColorForKey:kColorText12] forState:UIControlStateNormal];
    [sourceButton setTitle:title forState:UIControlStateNormal];
    return sourceButton;
}

#pragma mark - Handle H5 SourceButton

- (void)showVideoDetailWithURL:(NSString *)urlStr
{
    if (isEmptyString(urlStr)) {
        return;
    }
    
    NSURL *openURL = [NSURL URLWithString:urlStr];
    if ([urlStr hasPrefix:@"http"]) {
        [SSWebViewController openWebViewForNSURL:openURL title:@"网页浏览" navigationController:self.navigationController supportRotate:NO];
    } else {
        [[TTRoute sharedRoute] openURLByPushViewController:openURL];
    }
}

- (void)showVideoSourceListWithSourceInfo:(TTLiveMatchVideoH5SourceInfo *)sourceInfo
{
    NSArray *sourceDetailArray = sourceInfo.videoSourceArray;
    if (sourceDetailArray.count == 0) {
        return;
    }
    
    self.currentVideoSourceInfo = sourceInfo;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    [sourceDetailArray enumerateObjectsUsingBlock:^(TTLiveMatchVideoH5SourceDetail * _Nonnull sourceDetail, NSUInteger idx, BOOL * _Nonnull stop) {
        [actionSheet addButtonWithTitle:sourceDetail.title];
    }];
    [actionSheet showInView:self.chatroom.view];
    
    // event track
    [self eventTrack4H5SourceButtonPressedWithSourceInfo:sourceInfo];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // NSLog(@">>>> %@, %@", self.currentVideoSourceDetailArray, @(buttonIndex));
    
    NSArray *sourceDetailArray = self.currentVideoSourceInfo.videoSourceArray;
    
    NSInteger index = buttonIndex - 1;
    if (index >= 0 && index < sourceDetailArray.count) {
        TTLiveMatchVideoH5SourceDetail *srcDetail = sourceDetailArray[index];
        if (![[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:srcDetail.title]) {
            return;
        }
        [self showVideoDetailWithURL:srcDetail.openURL];
        
        // event track
        TTLiveMatchVideoH5SourceInfo *srcInfo = [TTLiveMatchVideoH5SourceInfo new];
        srcInfo.sourceType = self.currentVideoSourceInfo.sourceType;
        srcInfo.videoSourceArray = @[@""];
        [self eventTrack4H5SourceButtonPressedWithSourceInfo:srcInfo];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.currentVideoSourceInfo = nil;
    // NSLog(@">>>> %@, %@", self.currentVideoSourceDetailArray, @(buttonIndex));
}


#pragma mark - Event Track

- (void)eventTrack4H5SourceButtonPressedWithSourceInfo:(TTLiveMatchVideoH5SourceInfo *)sourceInfo
{
    NSArray *sourceDetailArray = sourceInfo.videoSourceArray;
    NSString *subLabel;
    switch (sourceInfo.sourceType) {
        case TTLiveMatchVideoH5SourceTypeLive:
            subLabel = @"live";
            break;
        case TTLiveMatchVideoH5SourceTypeCollection:
            subLabel = @"ht";
            break;
        case TTLiveMatchVideoH5SourceTypePlayback:
            subLabel = @"back";
            break;
        default:
            break;
    }
    
    if (isEmptyString(subLabel)) {
        return;
    }
    
    NSString *eventLabel;
    if (sourceDetailArray.count == 1) {
        eventLabel = [NSString stringWithFormat:@"sport_%@_click", subLabel];
    } else if (sourceDetailArray.count > 1) {
        eventLabel = [NSString stringWithFormat:@"sport_%@_source_click", subLabel];
    }
    
    if (isEmptyString(eventLabel)) {
        return;
    }
    
    [self.chatroom eventTrackWithEvent:@"live" label:eventLabel];
}

@end
