//
//  TTLiveBaseCell.m
//  Article
//
//  Created by 杨心雨 on 16/8/18.
//
//

#import "TTLiveBaseCell.h"
#import "Live.h"
#import "TTTrackerWrapper.h"
#import "TTUISettingHelper.h"
#import "TTArticleCellConst.h"
#import "TTArticleCellHelper.h"
#import "ExploreMixListDefine.h"
#import "TTDeviceHelper.h"
#import "TTNetworkManager.h"
#import "TTIndicatorView.h"
#import "TTFollowNotifyServer.h"
#import <TTTracker/TTTrackerProxy.h>
#import "TTRoute.h"
#import "TTURLTracker.h"
#import "TTPlatformSwitcher.h"
#import "TTFeedDislikeView.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTADTrackEventLinkModel.h"

extern NSString * const TTFollowSuccessForPushGuideNotification;

@implementation TTLiveBaseCell

+ (Class)cellViewClass {
    return [TTLiveBaseCell class];
}

- (CGFloat)paddingTopBottomForCellView {
    return 0;
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(TTFeedContainerViewModel *)viewModel {
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
    Live *live = (Live *)((ExploreOrderedData *)self.cellData).originalData;
    [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString: live.url]];
    wrapperTrackEventWithCustomKeys(@"livetalk", @"click", [NSString stringWithFormat:@"%@", live.liveId], nil, @{@"stat": [NSString stringWithFormat:@"%@", live.status]});
}

@end

@interface TTLiveBaseCellView ()

@property (nonatomic) BOOL isViewHighlighted;

@end

@implementation TTLiveBaseCellView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveEntityChanged:) name:TTLiveMainVCDeallocNotice object:nil];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TTLiveMainVCDeallocNotice object:nil];
}

- (void)liveEntityChanged:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    if ([self.orderedData live]) {
        [[self.orderedData live] updateWithDataContentObj:userInfo];
    }
}

- (BOOL)shouldRefresh {
    if ([self.orderedData live]) {
        return [[self.orderedData live] needRefreshUI];
    }
    return NO;
}

- (void)refreshDone {
    if ([self.orderedData live]) {
        [self.orderedData live].needRefreshUI = NO;
    }
}

/** 标题 */
- (TTLabel *)titleView {
    if (_titleView == nil) {
        _titleView = [[TTLabel alloc] init];
        _titleView.textColor = [TTUISettingHelper cellViewTitleColor];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.numberOfLines = 2;
        _titleView.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleView];
    }
    return _titleView;
}

/** 不感兴趣 */
- (SSThemedButton *)dislikeView {
    if (_dislikeView == nil) {
        _dislikeView = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _dislikeView.imageName = @"add_textpage";
        [_dislikeView addTarget:self action:@selector(dislikeViewClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_dislikeView];
        if(self.listType == ExploreOrderedDataListTypeFavorite ||
           self.listType == ExploreOrderedDataListTypeReadHistory ||
           self.listType == ExploreOrderedDataListTypePushHistory) {
            _dislikeView.hidden = YES;
        }
    }
    return _dislikeView;
}

/** 图片 */
- (TTImageView *)picView {
    if (_picView == nil) {
        _picView = [[TTImageView alloc] init];
        _picView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _picView.backgroundColorThemeKey = kColorBackground2;
        _picView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        [self addSubview:_picView];
    }
    return _picView;
}

/** 头像1 */
- (TTLiveFeedAvatarView *)avatarView1 {
    if (_avatarView1 == nil) {
        _avatarView1 = [[TTLiveFeedAvatarView alloc] init];
        [self.picView addSubview:_avatarView1];
    }
    return _avatarView1;
}

/** 头像2 */
- (TTLiveFeedAvatarView *)avatarView2 {
    if (_avatarView2 == nil) {
        _avatarView2 = [[TTLiveFeedAvatarView alloc] init];
        [self.picView addSubview:_avatarView2];
    }
    return _avatarView2;
}

/** 明星简介 */
- (SSThemedLabel *)introduceView {
    if (_introduceView == nil) {
        _introduceView = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 14)];
        _introduceView.textColorThemeKey = kColorText10;
        _introduceView.font = [UIFont tt_fontOfSize:([TTDeviceHelper isScreenWidthLarge320] ? 14: 12)];
        _introduceView.layer.shadowColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.85] CGColor];
        _introduceView.layer.shadowRadius = 2.5;
        _introduceView.layer.shadowOpacity = 0.85;
        _introduceView.layer.shadowOffset = CGSizeMake(0, 0);
        [self.picView addSubview:_introduceView];
        
    }
    return _introduceView;
}

/** 体育比赛副标题 */
- (SSThemedLabel *)subtitleView {
    if (_subtitleView == nil) {
        _subtitleView = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 14)];
        _subtitleView.textColorThemeKey = kColorText10;
        _subtitleView.font = [UIFont tt_fontOfSize:14];
        [self.picView addSubview:_subtitleView];
    }
    return _subtitleView;
}

/** 比分 */
- (TTScoreView *)scoreView {
    if (_scoreView == nil) {
        _scoreView = [[TTScoreView alloc] init];
        [self.picView addSubview:_scoreView];
    }
    return _scoreView;
}

/** 播放按钮 */
- (SSThemedImageView *)playView {
    if (_playView == nil) {
        _playView = [[SSThemedImageView alloc] init];
        [self.picView addSubview:_playView];
    }
    return _playView;
}

/** 在线人数 */
- (SSThemedLabel *)onlineView {
    if (_onlineView == nil) {
        _onlineView = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 0, ([TTDeviceHelper isScreenWidthLarge320] ? 14 : 12))];
        _onlineView.textColorThemeKey = kColorText2;
        _onlineView.font = [UIFont tt_fontOfSize:([TTDeviceHelper isScreenWidthLarge320] ? 14 : 12)];
        [self addSubview:_onlineView];
    }
    return _onlineView;
}

/** XX人在线 */
- (SSThemedLabel *)onlineConstView {
    if (_onlineConstView == nil) {
        _onlineConstView = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, 0, ([TTDeviceHelper isScreenWidthLarge320] ? 14 : 12))];
        _onlineConstView.textColorThemeKey = kColorText2;
        _onlineConstView.font = [UIFont tt_fontOfSize:([TTDeviceHelper isScreenWidthLarge320] ? 14 : 12)];
        [self addSubview:_onlineConstView];
    }
    return _onlineConstView;
}

/** 状态 */
- (TTLiveStatusView *)statusView {
    if (_statusView == nil) {
        _statusView = [[TTLiveStatusView alloc] init];
        [self addSubview:_statusView];
    }
    return _statusView;
}

- (TTImageView *)sourceView {
    if (_sourceView == nil) {
        _sourceView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        _sourceView.backgroundColorThemeKey = kColorBackground1;
        _sourceView.layer.cornerRadius = 8;
        _sourceView.layer.borderWidth = 1;
        _sourceView.borderColorThemeKey = kColorLine1;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sourceViewClick:)];
        [_sourceView addGestureRecognizer:tapRecognizer];
        _sourceView.userInteractionEnabled = YES;
        _sourceView.hidden = YES;
        [self addSubview:_sourceView];
    }
    return _sourceView;
}

- (TTLabel *)sourceLabel {
    if (_sourceLabel == nil) {
        _sourceLabel = [[TTLabel alloc] init];
        _sourceLabel.font = [UIFont tt_fontOfSize:12];
        _sourceLabel.lineHeight = ceil([UIFont tt_fontOfSize:12].lineHeight);
        _sourceLabel.textColorKey = kColorText3;
        [self addSubview:_sourceLabel];
    }
    return _sourceLabel;
}

- (TTArticleTagView *)tagView {
    if (_tagView == nil) {
        _tagView = [[TTArticleTagView alloc] init];
        [self addSubview:_tagView];
    }
    return _tagView;
}

- (TTFollowThemeButton *)followView {
    if (_followView == nil) {
        _followView = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType102 followedType:TTFollowedType102];
        [_followView addTarget:self action:@selector(followButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_followView];
    }
    return _followView;
}

/** 顶部分割面 */
- (SSThemedView *)topRect {
    if (_topRect == nil) {
        _topRect = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, kCellSeprateViewHeight())];
        _topRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_topRect];
    }
    return _topRect;
}

/** 底部分割线 */
- (SSThemedView *)bottomRect {
    if (_bottomRect == nil) {
        _bottomRect = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, kCellSeprateViewHeight())];
        _bottomRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_bottomRect];
    }
    return _bottomRect;
}

/** 视图是否高亮 */
- (void)setIsViewHighlighted:(BOOL)isViewHighlighted {
    BOOL oldValue = _isViewHighlighted;
    _isViewHighlighted = isViewHighlighted;
    if (_isViewHighlighted != oldValue) {
        if (_isViewHighlighted) {
            self.backgroundColor = [TTUISettingHelper cellViewHighlightedBackgroundColor];
            self.titleView.textColor = [TTUISettingHelper cellViewHighlightedtTitleColor];
        } else {
            self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
            self.titleView.textColor = [TTUISettingHelper cellViewTitleColor];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    self.isViewHighlighted = highlighted;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    if ([self isViewHighlighted]) {
        self.backgroundColor = [TTUISettingHelper cellViewHighlightedBackgroundColor];
        self.titleView.textColor = [TTUISettingHelper cellViewHighlightedtTitleColor];
    } else {
        
        self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        self.titleView.textColor = [TTUISettingHelper cellViewTitleColor];
    }
}

- (void)updateTitleView {
    if ([[self.orderedData live] title]) {
        self.titleView.lineHeight = kTitleViewLineHeight();
        self.titleView.font = [UIFont tt_fontOfSize:kTitleViewFontSize()];
        self.titleView.text = [[self.orderedData live] title];
    }
}

- (void)updatePicView {
    NSString *picUrl = [[self.orderedData live] picUrl];
    [self.picView setImageWithURLStringInTrafficSaveMode:picUrl placeholderImage:nil];
}

- (void)updateAvatarView {
    Live *live = [self.orderedData live];
    if (live && [live star]) {
        self.avatarView2.hidden = YES;
        [self.avatarView1 updateAvatarViewWithStar:[live star]];
    } else if (live && [live match]) {
        self.avatarView2.hidden = NO;
        if ([[live match] team1]) {
            [self.avatarView1 updateAvatarViewWithTeam:[[live match] team1]];
        }
        if ([[live match] team2]) {
            [self.avatarView2 updateAvatarViewWithTeam:[[live match] team2]];
        }
    }
}

- (void)updateIntroduceView {
    if ([[[self.orderedData live] star] title]) {
        self.introduceView.text = [[[self.orderedData live] star] title];
        [self.introduceView sizeToFit];
    }
}

- (void)updateSubtitleView {
    if ([[[self.orderedData live] match] title]) {
        self.subtitleView.text = [[[self.orderedData live] match] title];
        _subtitleView.font = [UIFont tt_fontOfSize:(([TTDeviceHelper is480Screen] || [TTDeviceHelper is568Screen]) ? 12 : 14)];
        [self.subtitleView sizeToFit];
    }
}

- (void)updateScoreView {
    Live *live = [self.orderedData live];
    if (live && [live match] && [live status]) {
        [self.scoreView updateScore:[live match] status:[[live status] integerValue]];
    }
}

- (void)updatePlayView {
    if ([[self.orderedData live] video]) {
        self.playView.imageName = @"Play";
        [self.playView sizeToFit];
    }
}

- (void)updateOnlineView {
    Live *live = [self.orderedData live];
    if (live && [live participated] && [live participatedSuffix]) {
        self.onlineView.text = [[live participated] stringValue];
        self.onlineConstView.text = [live participatedSuffix];
        [self.onlineView sizeToFit];
        [self.onlineConstView sizeToFit];
    }
}

- (void)updateStatusView {
    if ([[self.orderedData live] status]) {
        [self.statusView updateStatus:[self.orderedData live] status:[[[self.orderedData live] status] integerValue]];
    }
}

- (void)updateInfoView {
    if ([self.orderedData live]) {
        if ([self.orderedData isShowSourceImage]) {
            [self.sourceView setImageWithURLStringInTrafficSaveMode:[self.orderedData live].sourceAvatar placeholderImage:nil];
        }
        self.sourceLabel.text = [self.orderedData live].source;
        [self.tagView updateTypeIcon:self.orderedData];
        self.followView.followed = [[self.orderedData live].followed boolValue];
    }
}

- (void)dislikeViewClick {
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = self.orderedData.live.filterWords;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.live.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = self.dislikeView.center;
    [dislikeView showAtPoint:point
                    fromView:self.dislikeView
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
    [self trackAdDislikeClick];
    if (![self.orderedData live]) {
        return;
    }
    [TTTrackerWrapper ttTrackEventWithCustomKeys:@"livetalk" label:@"dislike_click" value:[[[self.orderedData live] liveId] stringValue] source:nil extraDic:@{@"stat": ([[self.orderedData live] status] != nil ? [[self.orderedData live] status] : 0)}];
}

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)view {
    if (![self.orderedData live]) {
        return;
    }
    
    NSArray *filterWords = [view selectedWords];
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if ([filterWords count] > 0) {
        userInfo[kExploreMixListNotInterestWordsKey] = filterWords;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
    [self trackAdDislikeConfirm:filterWords];
    [TTTrackerWrapper ttTrackEventWithCustomKeys:@"livetalk" label:@"dislike_success" value:[[[self.orderedData live] liveId] stringValue] source:nil extraDic:@{@"stat": ([[self.orderedData live] status] != nil ? [[self.orderedData live] status] : @0)}];
}

- (void)trackAdDislikeClick
{
    if (self.orderedData.adIDStr.longLongValue > 0) {
        [self trackWithTag:@"embeded_ad" label:@"dislike" extra:nil];
    }
}

- (void)trackAdDislikeConfirm:(NSArray *)filterWords
{
    if (self.orderedData.adIDStr.longLongValue > 0) {
        NSMutableDictionary *extra = [@{} mutableCopy];
        [extra setValue:filterWords forKey:@"filter_words"];
        [self trackWithTag:@"embeded_ad" label:@"final_dislike" extra:@{@"ad_extra_data": [extra JSONRepresentation]}];
    }
}

- (void)trackWithTag:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra {
    NSCParameterAssert(tag != nil);
    NSCParameterAssert(label != nil);
    TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
    NSMutableDictionary *events = [NSMutableDictionary dictionaryWithCapacity:10];
    [events setValue:@"umeng" forKey:@"category"];
    [events setValue:tag forKey:@"tag"];
    [events setValue:label forKey:@"label"];
    [events setValue:@(nt) forKey:@"nt"];
    [events setValue:@"1" forKey:@"is_ad_event"];
    [events setValue:self.orderedData.ad_id forKey:@"value"];
    [events setValue:self.orderedData.log_extra forKey:@"log_extra"];
    if (extra) {
        [events addEntriesFromDictionary:extra];
    }
    [TTTracker eventData:events];
}

- (void)sourceViewClick:(id)sender {
    NSString *sourceOpenUrl = self.orderedData.live.sourceOpenUrl;
    if (!isEmptyString(sourceOpenUrl)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:sourceOpenUrl]];
    }
}

#pragma mark 关注Follow
- (void)followButtonClick:(id)sender {
    if (_followView.isLoading) {
        return;
    }
    [_followView startLoading];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.orderedData.live.liveId forKey:@"live_id"];
    [params setValue:self.orderedData.live.followed forKey:@"unfollow"];
    
    NSString *url = [NSString stringWithFormat:@"%@/follow/",[CommonURLSetting liveTalkURLString]];
    
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:params method:@"POST" needCommonParams:YES callback:^(NSError *error,id jsonObj){
        StrongSelf;
        [self.followView stopLoading:^{
            StrongSelf;
            if (error) {
                [self liveReserve:[self.orderedData.live.followed boolValue] success:NO];
                
                NSString *text ;
                if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                    text = [jsonObj objectForKey:@"tips"];
                }
                if (text != nil) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                              indicatorText:text
                                             indicatorImage:nil
                                                autoDismiss:YES
                                             dismissHandler:nil];
                }
                return;
            }
            
            [self liveReserve:!([self.orderedData.live.followed boolValue] ?: NO) success:YES];
            
            if (!isEmptyString([self.orderedData.live.liveId stringValue])) {
                [[TTFollowNotifyServer sharedServer] postFollowNotifyWithID:[self.orderedData.live.liveId stringValue]
                                                                 actionType:self.orderedData.live.followed?TTFollowActionTypeFollow:TTFollowActionTypeUnfollow
                                                                   itemType:TTFollowItemTypeDefault
                                                                   userInfo:nil];
            }
            
            if ([self.orderedData.live.followed boolValue]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:TTFollowSuccessForPushGuideNotification object:nil userInfo:@{@"reason": @(50)}];
            }
        }];
    }];
    
    Live *live = [self.orderedData live];
    if (!isEmptyString(self.orderedData.ad_id)) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:live.logExtra forKey:@"log_extra"];
        [dict setValue:[NSNumber numberWithLongLong:live.uniqueID] forKey:@"ext_value"];
        [dict setValue:@([[TTTrackerProxy sharedProxy] connectionType]) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        [dict setValue:live.status forKey:@"live_status"];
        wrapperTrackEventWithCustomKeys(@"embeded_ad", [live.followed boolValue] ? @"click_unfollow" : @"click_follow", self.orderedData.ad_id, nil, dict);
    }
}

- (void)liveReserve:(BOOL)reserve success:(BOOL)success
{
    NSString *text;
    NSString *trackLabel;
    //状态
    if (!success && reserve) {
        text = @"取消关注失败!";
        self.orderedData.live.followed = @1;
        trackLabel = @"reserve_cancel_fail";
    }
    else if (!success && !reserve) {
        text = @"关注失败!";
        self.orderedData.live.followed = @0;
        trackLabel = @"reserve_fail";
    }
    else if (success && reserve) {
        text = @"关注成功";
        self.orderedData.live.followed = @1;
        trackLabel = @"reserve_success";
    }
    else if (success && !reserve) {
        text = @"已取消关注";
        self.orderedData.live.followed = @0;
        trackLabel = @"reserve_cancel";
    }
    wrapperTrackEventWithCustomKeys(@"livetalk", trackLabel, [[[self.orderedData live] liveId] stringValue], nil, @{@"stat": ([[self.orderedData live] status] ?: @0)});
    
    self.followView.followed = reserve;
    
    //提示
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                              indicatorText:text
                             indicatorImage:nil
                                autoDismiss:YES
                             dismissHandler:nil];
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    Live *live = [self.orderedData live];
    NSString *ad_id = self.orderedData.ad_id;
    NSMutableDictionary *baseDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    [baseDic setValue:ad_id forKey:@"ad_id"];
    [baseDic setValue:self.orderedData.log_extra forKey:@"log_extra"];
    [baseDic setValue:self.orderedData.logPb forKey:@"log_pb"];
    [baseDic setValue:self.orderedData.groupSource forKey:@"group_source"];
    [baseDic setValue:context.categoryId forKey:@"category_id"];

    [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString: live.url] userInfo:TTRouteUserInfoWithDict(baseDic)];
    
    wrapperTrackEventWithCustomKeys(@"livetalk", @"click", [NSString stringWithFormat:@"%@", live.liveId], nil, @{@"stat": [NSString stringWithFormat:@"%@", live.status]});
    
    if ([ad_id longLongValue] > 0) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setValue:self.orderedData.log_extra forKey:@"log_extra"];
        [dict setValue:[NSNumber numberWithLongLong:live.uniqueID] forKey:@"ext_value"];
        [dict setValue:@([[TTTrackerProxy sharedProxy] connectionType]) forKey:@"nt"];
        [dict setValue:@"1" forKey:@"is_ad_event"];
        [dict setValue:live.status forKey:@"live_status"];
        
        if (self.orderedData && self.orderedData.adEventLinkModel) {
            NSString *adEventLinkJsonString = [self.orderedData.adEventLinkModel adEventLinkJsonStringWithTag:@"embeded_ad" WithLabel:@"click"];
            if (!isEmptyString(adEventLinkJsonString)) {
                [dict setValue:adEventLinkJsonString forKey:@"ad_extra_data"];
            }
        }
    
        wrapperTrackEventWithCustomKeys(@"embeded_ad", @"click", ad_id, nil, dict);
        if (self.orderedData.adModel.click_track_url_list) {
            ttTrackURLsModel(self.orderedData.adModel.click_track_url_list, [[TTURLTrackerModel alloc] initWithAdId:ad_id logExtra:self.orderedData.log_extra]);
        } else {
            ttTrackURLsModel(self.orderedData.adClickTrackURLs, [[TTURLTrackerModel alloc] initWithAdId:ad_id logExtra:self.orderedData.log_extra]);
        }
    }
}

@end
