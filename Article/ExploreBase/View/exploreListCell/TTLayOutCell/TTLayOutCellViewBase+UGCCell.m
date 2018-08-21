//
//  TTLayOutCellViewBase+UGCCell.m
//  Article
//
//  Created by 王双华 on 16/11/10.
//
//

#import "TTLayOutCellViewBase+UGCCell.h"
#import "ExploreOrderedData+TTAd.h"

@implementation TTLayOutCellViewBase (UGCCell)
/** 喜欢 */
- (void)setupSubviewsForUGCCell
{
    /** 喜欢控件 */
    SSThemedLabel *likeLabel = [[SSThemedLabel alloc] init];
    likeLabel.font = [UIFont tt_fontOfSize:kLikeViewFontSize()];
    likeLabel.textColorThemeKey = kLikeViewTextColor();
    likeLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    likeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    UITapGestureRecognizer *likeLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(likeViewClick)];
    likeLabel.userInteractionEnabled = YES;
    [likeLabel addGestureRecognizer:likeLabelTapGestureRecognizer];
    [self addSubview:likeLabel];
    self.likeLabel = likeLabel;
    
    /** 是否已关注 */
    SSThemedLabel *subscriptLabel = [[SSThemedLabel alloc] init];
    subscriptLabel.font = [UIFont tt_fontOfSize:12.f];
    subscriptLabel.textColorThemeKey = kColorText3;
    subscriptLabel.text = NSLocalizedString(@"已关注", nil);
    subscriptLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    [self addSubview:subscriptLabel];
    self.subscriptLabel = subscriptLabel;
    
    /** 实体词 */
    SSThemedLabel *entityLabel = [[SSThemedLabel alloc] init];
    entityLabel.textColorThemeKey = kSourceViewTextColor();
    entityLabel.font = [UIFont tt_fontOfSize:kSourceViewFontSize()];
    entityLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    UITapGestureRecognizer *entityLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(entityViewClick)];
    entityLabel.userInteractionEnabled = YES;
    [entityLabel addGestureRecognizer:entityLabelTapGestureRecognizer];
    [self addSubview:entityLabel];
    self.entityLabel = entityLabel;
    
    /** 向右箭头 */
    SSThemedImageView *moreImageView = [[SSThemedImageView alloc] init];
    moreImageView.imageName = @"right_arrow_icon";
    moreImageView.enableNightCover = NO;
    [self addSubview:moreImageView];
    self.moreImageView = moreImageView;
    
    /** 向下箭头查看更多选项 */
    SSThemedButton *moreButton = [[SSThemedButton alloc] init];
    moreButton.imageName = @"function_icon";
    [moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:moreButton];
    self.moreButton = moreButton;
    
    /** 右下角的时间控件 */
    SSThemedLabel *timeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    timeLabel.textColorThemeKey = kColorText9;
    timeLabel.font = [UIFont tt_fontOfSize:kInfoViewFontSize()];
    timeLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    timeLabel.numberOfLines = 1;
    [self addSubview:timeLabel];
    self.timeLabel = timeLabel;
}

- (void)likeViewClick
{
    NSString *recommendUrl = [self.orderedData recommendUrl];
    if (!isEmptyString(recommendUrl)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:recommendUrl]];
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"click_reason" value:[@(self.orderedData.article.uniqueID) stringValue] source:nil extraDic:self.extraDic];
    }
}

- (void)entityViewClick
{
    NSString *sourceDescOpenUrl = [[self.orderedData article] sourceDescOpenUrl];
    if (!isEmptyString(sourceDescOpenUrl)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:sourceDescOpenUrl]];
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"click_entity" value:[@(self.orderedData.article.uniqueID) stringValue] source:nil extraDic:self.extraDic];
    }
}

- (void)moreButtonClick
{
    [self showMoreMenu];
    [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"click_more" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:[self extraDic]];
}

- (void)showMoreMenu {
    Article *article = [self.orderedData article];
    if (!article) {
        return;
    }
    NSArray<NSDictionary *> *actionList = [self.orderedData actionList];
    if ([actionList count] <= 0) {
        return;
    }
    NSMutableArray<TTActionListItem *> *actionItem = [[NSMutableArray<TTActionListItem *> alloc] init];
    for (NSDictionary *action in actionList) {
        NSNumber *type = action[@"action"];
        if (type) {
            NSInteger typeNum = [type integerValue];
            switch (typeNum) {
                    // 不感兴趣
                case 1:
                {
                    NSString *description = @"不感兴趣";
                    NSString *iconName = @"ugc_icon_not_interested";
                    if (!isEmptyString([action stringValueForKey:@"desc" defaultValue:nil])) {
                        description = [action stringValueForKey:@"desc" defaultValue:nil];
                    }
                    NSMutableArray<TTFeedDislikeWord *> *dislikeWords = [[NSMutableArray<TTFeedDislikeWord *> alloc] init];
                    NSNumber *groupId = @(article.uniqueID);
                    if (groupId == nil) {
                        break;
                    }
                    NSArray<NSDictionary *> *filterWords = [article filterWords];
                    if (filterWords) {
                        for (NSDictionary *words in filterWords) {
                            TTFeedDislikeWord *word = [[TTFeedDislikeWord alloc] initWithDict:words];
                            [dislikeWords addObject:word];
                        }
                    }
                    
                    NSMutableDictionary *extraValueDic = [[NSMutableDictionary alloc] init];
                    extraValueDic[@"log_extra"] = self.orderedData.log_extra;
                
                    
                    if ([dislikeWords count] > 0) {
                        WeakSelf;
                        TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:description iconName:iconName hasSub:YES action:^{
                            StrongSelf;
                            if (self.orderedData) {
                                [[TTActionPopView shareView] showDislikeView:self.orderedData dislikeWords:dislikeWords groupID:groupId];
                            }
                            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"show_dislike_with_reason" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:extraValueDic];
                        }];
                        [actionItem addObject:item];
                    } else {
                        WeakSelf;
                        TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:description iconName:iconName hasSub:NO action:^{
                            StrongSelf;
                            if (self.orderedData) {
                                [[TTActionPopView shareView] showDislikeView:self.orderedData dislikeWords:dislikeWords groupID:groupId];
                            }
                            [self dislikeButtonClicked:[[NSArray<NSString *> alloc] init]];
                        }];
                        [actionItem addObject:item];
                    }
                }
                    break;
                    // 不喜欢某一项
                case 2:
                {
                    NSString *iconName = @"ugc_icon_dislike";
                    NSString *desc = action[@"desc"];
                    NSDictionary *filterWord = action[@"extra"];
                    if (!isEmptyString(desc) && filterWord) {
                        NSString *dislikeId = [[[TTFeedDislikeWord alloc] initWithDict:filterWord] ID];
                        if (!isEmptyString(dislikeId)) {
                            WeakSelf;
                            TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:desc iconName:iconName action:^{
                                StrongSelf;
                                [self dislikeButtonClicked:@[dislikeId] onlyOne:YES];
                            }];
                            [actionItem addObject:item];
                        }
                    }
                }
                    break;
                    // 订阅／取消订阅头条号
                case 3:
                {
                    NSDictionary *mediaInfo = [article mediaInfo];
                    NSString *des = mediaInfo[@"name"];
                    NSString *mediaId = mediaInfo[@"media_id"];
                    if (mediaInfo && !isEmptyString(des) && !isEmptyString(mediaId)) {
                        ExploreEntry *entry = [[ExploreEntryManager sharedManager] fetchEntyWithMediaID:mediaId];
                        if (entry == nil) {
                            NSString *sourceName = mediaInfo[@"name"];
                            NSString *sourceUrl = mediaInfo[@"avatar_url"];
                            BOOL subscibed = [[article isSubscribe] boolValue];
                            
                            NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
                            info[@"id"] = mediaId;
                            info[@"media_id"] = mediaId;
                            info[@"type"] = [NSNumber numberWithInteger:ExploreEntryTypePGC];
                            info[@"is_subscribed"] = [NSNumber numberWithBool:subscibed];
                            info[@"name"] = sourceName;
                            info[@"icon"] = sourceUrl;
                            entry = [[ExploreEntryManager sharedManager] insertExploreEntry:info save:YES];
                        }
                        if (entry) {
                            if ([entry subscribed]) {
                                NSString *iconName = @"ugc_icon_unsubscribe";
                                NSString *description = [NSString stringWithFormat:@"取消关注「%@」", des];
                                NSString *cancelIndicatorText = NSLocalizedString(@"已取消关注", nil);
                                
                                if (!isEmptyString([action stringValueForKey:@"desc" defaultValue:nil])) {
                                    description = [action stringValueForKey:@"desc" defaultValue:nil];
                                }
                                WeakSelf;
                                TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:description iconName:iconName action:^{
                                    StrongSelf;
                                    [[ExploreEntryManager sharedManager] unsubscribeExploreEntry:entry notify:YES notifyFinishBlock:nil];
                                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:cancelIndicatorText indicatorImage:nil autoDismiss:YES dismissHandler:nil];
                                    [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"pgc_unsubscribe" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:self.extraDic];
                                }];
                                [actionItem addObject:item];
                            } else {
                                NSString *iconName = @"ugc_icon_subscription";
                                NSString *description = [NSString stringWithFormat:@"关注「%@」", des];
                                
                                if (!isEmptyString([action stringValueForKey:@"desc" defaultValue:nil])) {
                                    description = [action stringValueForKey:@"desc" defaultValue:nil];
                                }
                                WeakSelf;
                                TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:description iconName:iconName action:^{
                                    StrongSelf;
                                    [[ExploreEntryManager sharedManager] subscribeExploreEntry:entry notify:YES notifyFinishBlock:nil];
//                                    if ([TTFirstConcernManager firstTimeGuideEnabled]) {
//                                        TTFirstConcernManager *manager = [[TTFirstConcernManager alloc] init];
//                                        [manager showFirstConcernAlertViewWithDismissBlock:^{
//                                            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"将增加推荐此头条号内容", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
//                                        }];
//                                    }
//                                    else{
                                        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"将增加推荐此头条号内容", nil) indicatorImage:[UIImage themedImageNamed:@"doneicon_popup_textpage"] autoDismiss:YES dismissHandler:nil];
//                                    }
                                    [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"pgc_subscribe" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:self.extraDic];
                                }];
                                [actionItem addObject:item];
                            }
                        }
                    }
                }
                    break;
                    // 分享
                case 7:
                {
                    NSString *iconName = @"ugc_icon_share";
                    NSString *description = @"分享";
                    if (!isEmptyString([action stringValueForKey:@"desc" defaultValue:nil])) {
                        description = [action stringValueForKey:@"desc" defaultValue:nil];
                    }
                    WeakSelf;
                    TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:description iconName:iconName action:^{
                        StrongSelf;
                        NSNumber *adID = isEmptyString(self.orderedData.ad_id) ? nil : @([self.orderedData.ad_id longLongValue]);
                        NSArray *activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager setArticleCondition:article adID:adID showReport:NO];
                        NSMutableArray<TTActivity *> *group1 = [[NSMutableArray<TTActivity *> alloc] init];
                        for (id activity in activityItems) {
                            TTActivity *acti = (TTActivity *)activity;
                            if (acti) {
                                [group1 addObject:acti];
                            }
                        }
                        self.phoneShareView = [[SSActivityView alloc] init];
                        self.phoneShareView.delegate = self;
                        [self.phoneShareView showActivityItems:@[group1]];
                        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"list_share" label:@"share_button" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:self.extraDic];
                    }];
                    [actionItem addObject:item];
                }
                    break;
                    // 举报
                case 9:
                {
                    NSString *iconName = @"ugc_icon_report";
                    NSString *description = @"举报";
                    if (!isEmptyString([action stringValueForKey:@"desc" defaultValue:nil])) {
                        description = [action stringValueForKey:@"desc" defaultValue:nil];
                    }
                    WeakSelf;
                    TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:description iconName:iconName action:^{
                        StrongSelf;
                        [self triggerReportAction];
                        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"report" value:[@(self.orderedData.article.uniqueID) stringValue] source:nil extraDic:self.extraDic];
                    }];
                    [actionItem addObject:item];
                }
                    break;
                default:
                    break;
            }
        } else {
            continue;
        }
    }
    
    if ([actionItem count] <= 0) {
        return;
    }
    
    TTActionPopView *popupView = [[TTActionPopView alloc] initWithActionItems:actionItem width:self.width];
    popupView.delegate = self;
    CGPoint p = self.moreButton.center;
    [popupView showAtPoint:p fromView:self.moreButton];
}

- (void)triggerReportAction {
    Article *article = [self.orderedData article];
    if (!article) {
        return;
    }
    
    self.actionSheetController = [[TTActionSheetController alloc] init];
    [self.actionSheetController insertReportArray:[TTReportManager fetchReportArticleOptions]];
    
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeDislike completion:^(NSDictionary * _Nonnull parameters) {
        if (parameters[@"report"]) {
            NSString *groupID = [NSString stringWithFormat:@"%lld", self.orderedData.article.uniqueID];
            TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:groupID];
            TTReportContentModel *model = [[TTReportContentModel alloc] init];
            model.groupID = groupModel.groupID;
            model.itemID = groupModel.itemID;
            model.aggrType = @(groupModel.aggrType);
            
            [[TTReportManager shareInstance] startReportContentWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:kTTReportContentTypeForum reportFrom:TTReportFromByEnterFromAndCategory(nil, self.orderedData.categoryID) contentModel:model extraDic:nil animated:YES];
        }
    }];
    
}

- (void)dislikeButtonClicked:(NSArray<NSString *> *)selectedWords {
    [self dislikeButtonClicked:selectedWords onlyOne:NO];
}

- (void)layoutComponentsForUGCCell
{
    [self layoutLikeLabel];
    [self layoutEntityLabel];
    [self layoutTimeLabel];
    [self layoutMoreImageView];
    [self layoutMoreButton];
}

- (void)layoutLikeLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.likeLabel.hidden = cellLayOut.likeLabelHidden;
    if (!self.likeLabel.hidden) {
        self.likeLabel.frame = cellLayOut.likeLabelFrame;
        NSString *likeString = [TTLayOutCellDataHelper getLikeStringWithOrderedData:self.orderedData];
        self.likeLabel.text = likeString;
    }
}

- (void)layoutEntityLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.entityLabel.hidden = cellLayOut.entityLabelHidden;
    if (!self.entityLabel.hidden) {
        self.entityLabel.frame = cellLayOut.entityLabelFrame;
        NSString *entityString = [TTLayOutCellDataHelper getEntityStringWithOrderedData:self.orderedData];
        self.entityLabel.text = entityString;
    }
}

- (void)layoutTimeLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.timeLabel.hidden = cellLayOut.timeLabelHidden;
    if (!self.timeLabel.hidden) {
        self.timeLabel.frame = cellLayOut.timeLabelFrame;
        NSString *timeString = [TTLayOutCellDataHelper getTimeStringWithOrderedData:self.orderedData];
        self.timeLabel.text = timeString;
    }
}

- (void)layoutSubscriptLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.subscriptLabel.hidden = cellLayOut.subscriptLabelHidden;
    if (!self.subscriptLabel.hidden) {
        self.subscriptLabel.frame = cellLayOut.subscriptLabelFrame;
    }
}

- (void)layoutMoreImageView
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.moreImageView.hidden = cellLayOut.moreImageViewHidden;
    if (!self.moreImageView.hidden) {
        self.moreImageView.frame = cellLayOut.moreImageViewFrame;
    }
}

- (void)layoutMoreButton
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.moreButton.hidden = cellLayOut.moreButtonHidden;
    if (!self.moreButton.hidden) {
        self.moreButton.frame = cellLayOut.moreButtonFrame;
    }
}
@end
