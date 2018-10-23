//
//  TTArticleBaseCellView.m
//  Article
//
//  Created by 杨心雨 on 16/8/23.
//
//

#import "TTArticleBaseCellView.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "ExploreEntryManager.h"
#import "TTTrackerWrapper.h"
#import "ExploreMixListDefine.h"
#import "ExploreEntryDefines.h"
#import "TTIndicatorView.h"
#import "ArticleShareManager.h"
#import "TTRoute.h"
#import "TTNavigationController.h"
#import "UIImage+TTThemeExtension.h"
#import "TTStringHelper.h"
#import "TTDeviceHelper.h"
#import "TTActionSheetController.h"
#import "TTReportManager.h"

#import "ExploreOrderedData+TTAd.h"



// MARK: - TTArticleBaseCellView
/** 文章类型基类 */
@interface TTArticleBaseCellView ()
@property (nonatomic, strong) TTActionSheetController *actionSheetController;
@end

@implementation TTArticleBaseCellView

@synthesize originalData = _originalData;

/** 功能区控件 */
- (TTArticleFunctionView *)functionView {
    if (_functionView == nil) {
        _functionView = [[TTArticleFunctionView alloc] init];
        _functionView.delegate = self;
        [self addSubview:_functionView];
    }
    return _functionView;
}
    
/** 更多控件 */
- (SSThemedButton *)moreView {
    if (_moreView == nil) {
        _moreView = [[SSThemedButton alloc] init];
        _moreView.imageName = @"function_icon";
        CGFloat side = kMoreViewSide() + kMoreViewExpand() * 2;
        _moreView.frame = CGRectMake(0, 0, side, side);
        [_moreView addTarget:self action: @selector(moreViewClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_moreView];
    }
    return _moreView;
}

/** 标题控件 */
- (TTLabel *)titleView {
    if (_titleView == nil) {
        _titleView = [[TTLabel alloc] init];
        _titleView.textColorKey = kTitleViewTextColor();
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.numberOfLines = kTitleViewLineNumber();
        _titleView.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleView];
    }
    return _titleView;
}

/** 摘要控件 */
- (TTLabel *)abstractView {
    if (_abstractView == nil) {
        _abstractView = [[TTLabel alloc] init];
        _abstractView.textColorKey = kAbstractViewTextColor();
        _abstractView.backgroundColor = [UIColor clearColor];
        _abstractView.numberOfLines = kAbstractViewLineNumber();
        _abstractView.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_abstractView];
    }
    return _abstractView;
}

/** 评论控件 */
- (TTArticleCommentView *)commentView {
    if (_commentView == nil) {
        _commentView = [[TTArticleCommentView alloc] init];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentButtonClick)];
        _commentView.userInteractionEnabled = YES;
        [_commentView addGestureRecognizer:tapGestureRecognizer];
        [self addSubview:_commentView];
    }
    return _commentView;
}

/** 图片(视频)控件 */
- (TTArticlePicView *)picView {
    if (_picView == nil) {
        _picView = [[TTArticlePicView alloc] initWithStyle:TTArticlePicViewStyleNone];
        [self addSubview:_picView];
    }
    return _picView;
}

/** 直播标签 */
- (SSThemedLabel *)liveTextView {
    if (_liveTextView == nil) {
        _liveTextView = [[SSThemedLabel alloc] init];
        _liveTextView.width = 44;
        _liveTextView.height = 20;
        _liveTextView.textColorThemeKey = kColorText12;
        _liveTextView.backgroundColorThemeKey = kColorBackground15;
        _liveTextView.numberOfLines = kTitleViewLineNumber();
        _liveTextView.lineBreakMode = NSLineBreakByTruncatingTail;
        _liveTextView.layer.cornerRadius = self.liveTextView.height / 2;
        _liveTextView.clipsToBounds = YES;
        _liveTextView.textAlignment = NSTextAlignmentCenter;
        _liveTextView.text = @"直播";
        _liveTextView.font = [UIFont systemFontOfSize:10];
        _liveTextView.contentInset = UIEdgeInsetsMake(0, 3, 0, 0);
        _liveTextView.right = self.picView.width - 6;
        _liveTextView.bottom = self.picView.height - 6;
        
        UIView *redDot = [[UIView alloc] init];
        redDot.frame = CGRectMake(6, self.liveTextView.height / 2 - 3, 6, 6);
        redDot.backgroundColor = [UIColor colorWithHexString:@"f85959"];
        redDot.layer.cornerRadius = 3;
        [_liveTextView addSubview:redDot];
        _liveTextView.hidden = YES;
        [self.picView addSubview:_liveTextView];
    }
    return _liveTextView;
}

/** 信息栏控件 */
- (TTArticleInfoView *)infoView {
    if (_infoView == nil) {
        _infoView = [[TTArticleInfoView alloc] init];
        _infoView.delegate = self;
        [self addSubview:_infoView];
    }
    return _infoView;
}

/** 底部分割线 */
- (SSThemedView *)bottomLineView {
    if (_bottomLineView == nil) {
        _bottomLineView = [[SSThemedView alloc] init];
        _bottomLineView.backgroundColorThemeKey = kBottomLineViewBackgroundColor();
        [self addSubview:_bottomLineView];
    }
    return _bottomLineView;
}

/** 标签(置顶样式专用) */
- (TTArticleTagView *)tagView {
    if (_tagView == nil) {
        _tagView = [[TTArticleTagView alloc] init];
        [self addSubview:_tagView];
    }
    return _tagView;
}

/** 视图是否高亮 */
- (void)setIsViewHighlighted:(BOOL)isViewHighlighted {
    BOOL oldValue = _isViewHighlighted;
    _isViewHighlighted = isViewHighlighted;
    if (_isViewHighlighted != oldValue) {
        NSString *key = [NSString stringWithFormat:@"%@%@", kColorBackground4, (_isViewHighlighted ? @"Highlighted" : @"")];
        self.backgroundColor = [UIColor tt_themedColorForKey:key];
    }
}

- (ExploreItemActionManager *)itemActionManager {
    if (_itemActionManager == nil) {
        _itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    return _itemActionManager;
}

- (TTActivityShareManager *)activityActionManager {
    if (_activityActionManager == nil) {
        _activityActionManager = [[TTActivityShareManager alloc] init];
    }
    return _activityActionManager;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readModeChanged:) name:kReadModeChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subscribeStatusChanged:) name:kEntrySubscribeStatusChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    self.orderedData = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReadModeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kEntrySubscribeStatusChangedNotification object:nil];
}

- (void)setOriginalData:(ExploreOriginalData *)originalData {
    _extraDic = nil;
    if (_originalData) {
        [_originalData removeObserver:self forKeyPath:@"commentCount"];
        [_originalData removeObserver:self forKeyPath:@"userRepined"];
        [_originalData removeObserver:self forKeyPath:@"hasRead"];
        [_originalData removeObserver:self forKeyPath:@"likeCount"];
    }
    _originalData = originalData;
    if (_originalData) {
        [_originalData addObserver:self forKeyPath:@"commentCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_originalData addObserver:self forKeyPath:@"userRepined" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_originalData addObserver:self forKeyPath:@"hasRead" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_originalData addObserver:self forKeyPath:@"likeCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (NSDictionary *)extraDic {
    if (_extraDic == nil) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        if ([self.orderedData originalData]) {
            if (self.originalData.uniqueID > 0) {
                dic[@"item_id"] = @(self.originalData.uniqueID);
            }
            if ([self.orderedData categoryID]) {
                dic[@"category_id"] = [self.orderedData categoryID];
            }
            if ([self.orderedData concernID]) {
                dic[@"concern_id"] = [self.orderedData concernID];
            }
            dic[@"refer"] = [NSNumber numberWithInteger:[self refer]];
            dic[@"gtype"] = @1;
        }
        _extraDic = dic;
    }
    return _extraDic;
}

// MARK: 监听及日夜间模式
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    NSNumber *oldValue = change[NSKeyValueChangeOldKey];
    NSNumber *newValue = change[NSKeyValueChangeNewKey];
    if (!newValue) {
        return;
    }
    
    if (keyPath && oldValue != newValue) {
        if ([keyPath isEqualToString:@"userRepined"]) {
            [self updateInfoView];
        } else if ([keyPath isEqualToString:@"commentCount"] || [keyPath isEqualToString:@"likeCount"]) {
            [self updateInfoView];
        } else if ([keyPath isEqualToString:@"hasRead"]) {
            self.titleView.highlighted = [newValue boolValue];
            self.abstractView.highlighted = [newValue boolValue];
            [self.functionView updateReadState:[newValue boolValue]];
            [self.commentView updateCommentState:[newValue boolValue]];
        }
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self. backgroundColor = [UIColor clearColor];
}

- (void)readModeChanged:(NSNotification *)notification {
    [self refreshUI];
}

- (void)subscribeStatusChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateFunctionView];
    });
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    self.isViewHighlighted = highlighted;
}

// MARK: 控件更新
/** 更新功能区 */
- (void)updateFunctionView {
    if (self.orderedData) {
        [self.functionView updateFunction:self.orderedData refer:[self refer]];
    }
}

/** 更新标签(置顶样式专用) */
- (void)updateTagView {
    if (self.orderedData) {
        [self.tagView updateTypeIcon:self.orderedData];
    }
}

/** 更新标题 */
- (void)updateTitleView:(CGFloat)fontSize isBold:(BOOL)isBold lineHeight:(CGFloat)lineHeight firstLineIndent:(CGFloat)firstLineIndent {
    Article *article = [self.orderedData article];
    if (article) {
        if (!isEmptyString([article title])) {
            self.titleView.lineHeight = lineHeight;
            self.titleView.font = isBold ? [UIFont tt_boldFontOfSize:fontSize] : [UIFont tt_fontOfSize:fontSize];
            self.titleView.firstLineIndent = firstLineIndent;
            self.titleView.text = [article title];
            self.titleView.highlighted = [[article hasRead] boolValue];
        } else {
            self.titleView.text = nil;
        }
    }
}

- (void)updateTitleView {
    [self updateTitleView:kTitleViewFontSize() isBold:NO lineHeight:kTitleViewLineHeight() firstLineIndent:0];
}

/** 更新摘要 */
- (void)updateAbstractView {
    Article *article = [self.orderedData article];
    if (article) {
        BOOL displayAbstractView = [TTArticleCellHelper shouldDisplayAbstractView:article listType:self.listType mustShow:[self.orderedData isShowAbstract]];
        if (displayAbstractView) {
            self.abstractView.hidden = NO;
            self.abstractView.font = [UIFont tt_fontOfSize:kAbstractViewFontSize()];
            self.abstractView.lineHeight = kAbstractViewLineHeight();
            self.abstractView.text = article.abstract;
            self.abstractView.highlighted = [[article hasRead] boolValue];
        } else {
            self.abstractView.hidden = YES;
        }
    }
}

/** 更新评论 */
- (void)updateCommentView {
    Article *article = [self.orderedData article];
    if (article) {
        BOOL displayCommentView = [TTArticleCellHelper shouldDisplayCommentView:article listType:self.listType];
        if (displayCommentView) {
            self.commentView.hidden = NO;
            [self.commentView updateComment:self.orderedData];
        } else {
            self.commentView.hidden = YES;
        }
    }
}

/** 更新图片(视频) */
- (void)updatePicView {
    if (self.orderedData) {
        [self.picView updatePics:self.orderedData];
    }
}

/** 更新信息栏 */
- (void)updateInfoView {
    if (self.orderedData) {
        [self.infoView updateInfoView:self.orderedData];
    }
}

/** 更新底部分割线 */
- (void)updateBottomLineView {}

/** 布局更多控件(置顶样式设置center = true) */
- (void)layoutMoreViewWithCenter:(BOOL)center {
    self.moreView.right = self.width - kPaddingRight() + kMoreViewExpand();
    if (center) {
        self.moreView.centerY = self.centerY;
    } else {
        self.moreView.centerY = self.functionView.centerY;
    }
    if ([[self.orderedData actionList] count] > 0) {
        self.moreView.hidden = NO;
    } else {
        self.moreView.hidden = YES;
    }
}

- (void)layoutMoreView {
    [self layoutMoreViewWithCenter:NO];
}

// MARK: 更多控件协议
- (void)moreViewClick {
    [self showMenu];
    [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"click_more" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:[self extraDic]];
}

- (void)showMenu {
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
                // 订阅／取消订阅号
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
                                NSString *description = [NSString stringWithFormat:@"取消关注「%@」", des];;
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
                        NSNumber *adID = isEmptyString(self.orderedData.ad_id) ? nil : @(self.orderedData.ad_id.longLongValue);
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
                        self.actionSheetController = [[TTActionSheetController alloc] init];
                        [self.actionSheetController insertReportArray:[TTReportManager fetchReportArticleOptions]];
                        WeakSelf;
                        [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
                            StrongSelf;
                            if (parameters[@"report"]) {
                                TTGroupModel *groupModel = self.orderedData.article.groupModel;
                                TTReportContentModel *model = [[TTReportContentModel alloc] init];
                                model.groupID = groupModel.groupID;
                                model.itemID = groupModel.itemID;
                                model.aggrType = @(groupModel.aggrType);
                                [[TTReportManager shareInstance] startReportContentWithType:parameters[@"report"] inputText:parameters[@"criticism"] contentType:kTTReportContentTypeArticle reportFrom:TTReportFromByEnterFromAndCategory(nil, self.orderedData.categoryID) contentModel:model extraDic:nil animated:YES];
                            }
                        }];
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
    CGPoint p = self.moreView.center;
    [popupView showAtPoint:p fromView:self.moreView];
}

- (void)dislikeButtonClicked:(NSArray<NSString *> *)selectedWords onlyOne:(BOOL)onlyOne {
    if (!self.orderedData) {
        return;
    }
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[kExploreMixListNotInterestItemKey] = self.orderedData;
    
    NSMutableDictionary *extraValueDic = [[NSMutableDictionary alloc] init];
    extraValueDic[@"log_extra"] = self.orderedData.log_extra;
    
    
    if ([selectedWords count] > 0) {
        userInfo[kExploreMixListNotInterestWordsKey] = selectedWords;
        if (onlyOne) {
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"confirm_dislike_only_reason" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:extraValueDic];
        } else {
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"confirm_dislike_with_reason" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:extraValueDic];
        }
    } else {
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"confirm_dislike_no_reason" value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:extraValueDic];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

- (void)dislikeButtonClicked:(NSArray<NSString *> *)selectedWords {
    [self dislikeButtonClicked:selectedWords onlyOne:NO];
}

// MARK: 功能区协议
- (void)functionViewLikeViewClick {
    NSString *recommendUrl = [self.orderedData recommendUrl];
    if (!isEmptyString(recommendUrl)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:recommendUrl]];
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"click_reason" value:[@(self.orderedData.article.uniqueID) stringValue] source:nil extraDic:self.extraDic];
    }
}

- (void)functionViewPGCClick {
    NSString *sourceUrl = [[self.orderedData article] sourceOpenUrl];
    if (!isEmptyString(sourceUrl)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:sourceUrl]];
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"click_source" value:[@(self.orderedData.article.uniqueID) stringValue] source:nil extraDic:self.extraDic];
    }
}

- (void)functionViewEntityClick {
    NSString *sourceDescOpenUrl = [[self.orderedData article] sourceDescOpenUrl];
    if (!isEmptyString(sourceDescOpenUrl)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:sourceDescOpenUrl]];
        [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"click_entity" value:[@(self.orderedData.article.uniqueID) stringValue] source:nil extraDic:self.extraDic];
    }
}

// MARK: 信息栏协议
- (void)digButtonClick:(TTDiggButton *)button {
    if (self.originalData == nil) {
        return;
    }
    if ([[self.originalData userLike] boolValue]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经赞过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        return;
    }
    [self.originalData setUserLike:[NSNumber numberWithBool:YES]];
    NSNumber *likeCount = [self.originalData likeCount];
    if (likeCount == nil) {
        likeCount = @0;
    }
    likeCount = [NSNumber numberWithLongLong:[likeCount longLongValue] + 1];
    [[self.orderedData originalData] setLikeCount:likeCount];
    [button setDiggCount:[likeCount longLongValue]];
    CGFloat centerY = button.centerY;
    [button sizeToFit];
    button.centerY = centerY;

    @try {
        [self.originalData save];
        //[[SSModelManager sharedManager] save:nil];
    } @catch (NSException *exception) {
        NSLog(@"save fail with error");
    }
    
    [self.itemActionManager sendActionForOriginalData:self.originalData adID:nil actionType:DetailActionTypeLike finishBlock:^(id userInfo, NSError *error) {
    }];

    [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"like" value:[@(self.orderedData.article.uniqueID) stringValue] source:nil extraDic:self.extraDic];
}

/**
 实现 TTArticleInfoViewDelegate 方法
 */
- (void)commentButtonClick {
    [TTTrackerWrapper ttTrackEventWithCustomKeys:@"new_list" label:@"comment" value:[@(self.orderedData.article.uniqueID) stringValue] source:nil extraDic:self.extraDic];
    
    TTFeedCellSelectContext *context = [TTFeedCellSelectContext new];
    context.refer = [self getRefer];
    context.orderedData = self.orderedData;
    context.clickComment = YES;
    if (self.isCardSubCellView) {
        context.categoryId = self.cardCategoryId;
    } else {
        context.categoryId = self.orderedData.categoryID;
    }
    [self didSelectWithContext:context];
}

- (NSString *)screenName {
    if (!isEmptyString(self.orderedData.categoryID)) {
        return [NSString stringWithFormat:@"channel_%@",self.orderedData.categoryID];
    }
    if (!isEmptyString(self.orderedData.concernID)) {
        return  [NSString stringWithFormat:@"channel_%@",self.orderedData.concernID];
    }
    return @"channel_unknown";
}

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType {
    if (view == self.phoneShareView) {
        NSString *uniqueID = [@(self.orderedData.article.uniqueID) stringValue];
        BOOL hasVideo = ([[[self.orderedData article] hasVideo] boolValue] || [[self.orderedData article] isVideoSubject]);
        [self.activityActionManager performActivityActionByType:itemType inViewController:[TTUIResponderHelper topViewControllerFor:self] sourceObjectType:(hasVideo ? TTShareSourceObjectTypeVideoList : TTShareSourceObjectTypeUGCFeed) uniqueId:uniqueID adID:nil platform:TTSharePlatformTypeOfMain groupFlags:[[self.orderedData article] groupFlags]];
        self.phoneShareView = nil;
        
        NSString *label = [TTActivityShareManager labelNameForShareActivityType:itemType];
        if (label) {
            [TTTrackerWrapper ttTrackEventWithCustomKeys:@"list_share" label:label value:[[TTActionPopView shareGroupId] stringValue] source:nil extraDic:self.extraDic];
        }
    }
}

@end
