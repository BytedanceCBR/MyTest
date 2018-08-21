//
//  TTVFeedListBaseBottomContainerView.m
//  Article
//
//  Created by pei yun on 2017/3/31.
//
//

#import "TTVFeedListBaseBottomContainerView.h"
#import "TTVFeedCellMoreActionManager.h"
#import "TTVMoreActionHeader.h"
#import "NSObject+FBKVOController.h"
#import <libextobjc/extobjc.h>
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+Extension.h"
#import "ExploreMovieView.h"
#import "TTURLUtils.h"
#import "TTVideoCommon.h"
#import "TTMessageCenter.h"
#import "TTVFeedCellActionMessage.h"
#import "TTRoute.h"
//#import "TTRepostViewController.h"
//#import "TTRepostOriginModels.h"
#import "TTVFeedItem+TTVConvertToArticle.h"
//#import "TTShareToRepostManager.h"
#import "TTVerifyIconHelper.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "TTRelevantDurationTracker.h"
#import "TTUGCTrackerHelper.h"
#import "ExploreMomentDefine.h"

extern NSString * const TTActivityContentItemTypeForwardWeitoutiao;
extern NSString * const TTActivityContentItemTypeCommodity;
extern UIColor *tt_ttuisettingHelper_cellViewBackgroundColor(void);

@interface TTVFeedListBaseBottomContainerView ()

@property (nonatomic, assign) BOOL shouldHiddenAvatarView;//非广告样式下头像url为空时，不展示头像
@property (nonatomic, assign) BOOL shouldHiddenTypeLabel;//非广告样式下，displaylabel为空时，隐藏类型标签
@property (nonatomic, strong) TTVFeedCellMoreActionManager *moreActionMananger;
@property (nonatomic, strong) TTAsyncCornerImageView   *avatarView;//头像
@property (nonatomic, strong) TTIconLabel              *avatarLabel;//名称
@property (nonatomic, strong) TTAlphaThemedButton      *avatarLabelButton;
@property (nonatomic, strong) UILabel                  *typeLabel;//推广标志
@property (nonatomic, strong) ArticleVideoActionButton *moreButton;//更多按钮
@property (nonatomic, strong) TTAlphaThemedButton      *avatarViewButton;

@end

@implementation TTVFeedListBaseBottomContainerView

- (void)dealloc
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        @weakify(self);
        [self.KVOController observe:self.avatarLabelButton keyPath:@keypath(self.avatarLabelButton, alpha) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            @strongify(self);
            self.avatarLabel.alpha = self.avatarLabelButton.alpha;
            self.avatarView.alpha = self.avatarLabelButton.alpha;
        }];
    }
    return self;
}

#pragma mark - lazy UI

/** 头像 */
- (TTAsyncCornerImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, 0, [self.class avatarHeight], [self.class avatarHeight]) allowCorner:YES];
        _avatarView.borderWidth = 0;
        _avatarView.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        _avatarView.cornerRadius = [self.class avatarHeight] / 2;
        _avatarView.placeholderName = @"big_defaulthead_head";
        [_avatarView setupVerifyViewForLength:32.f adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_newSize:standardSize];
        }];
        [self addSubview:_avatarView];
    }
    return _avatarView;
}

/** 头条号或者来源名称 */
- (TTIconLabel *)avatarLabel {
    if (!_avatarLabel) {
        _avatarLabel = [[TTIconLabel alloc] init];
        _avatarLabel.backgroundColor = [UIColor clearColor];
//        if (ttvs_isVideoFeedCellHeightAjust() > 1) {
//            _avatarLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[TTDeviceUIUtils tt_fontSize:14]];
//        }else{
//            _avatarLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
//        }
        _avatarLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        _avatarLabel.textAlignment = NSTextAlignmentLeft;
        _avatarLabel.textColorThemeKey = kColorText1;
        [self addSubview:_avatarLabel];
    }
    return _avatarLabel;
}

- (TTAlphaThemedButton *)avatarLabelButton {
    if (!_avatarLabelButton) {
        _avatarLabelButton = [[TTAlphaThemedButton alloc] init];
        [_avatarLabelButton addTarget:self action:@selector(didClickAvatarButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_avatarLabelButton];
    }
    return _avatarLabelButton;
}

- (TTAlphaThemedButton *)avatarViewButton {
    if (ttvs_isVideoFeedCellHeightAjust() < 2) {
        return nil;
    }
    if (!_avatarViewButton) {
        _avatarViewButton = [[TTAlphaThemedButton alloc] init];
        [_avatarViewButton addTarget:self action:@selector(didClickAvatarButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_avatarViewButton];
    }
    return _avatarViewButton;
}

/** 标签 */
- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.backgroundColor = [UIColor clearColor];
        _typeLabel.font = [UIFont systemFontOfSize:12];
        _typeLabel.textAlignment = NSTextAlignmentCenter;
        _typeLabel.textColor = [UIColor colorWithHexString:@"999999"];
        
        [self addSubview:_typeLabel];
    }
    return _typeLabel;
}

/** 更多按钮 */
- (ArticleVideoActionButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [[ArticleVideoActionButton alloc] init];
        _moreButton.minHeight = [TTDeviceUIUtils tt_newPadding:32.0];
        _moreButton.centerAlignImage = YES;
        _moreButton.minWidth = 44.f;
        [_moreButton addTarget:self action:@selector(moreActionClicked)];
        [self addSubview:_moreButton];
    }
    return _moreButton;
}

#pragma mark - configure UI

- (void)updateAvatarViewWithUrl:(NSString *)avatarUrl sourceText:(NSString *)sourceText
{
    if (!isEmptyString(avatarUrl)) {
        [self.avatarView tt_setImageWithURLString:avatarUrl];
        self.shouldHiddenAvatarView = NO;
    }
    else {
        if (!isEmptyString(sourceText)) {
            NSString *firstName = [sourceText substringToIndex:1];
            [self.avatarView tt_setImageText:firstName fontSize:[TTDeviceUIUtils tt_fontSize:12] textColorThemeKey:kColorText8 backgroundColorThemeKey:nil backgroundColors:[self randomSourceBackgroundColors]];
            self.shouldHiddenAvatarView = NO;
        }
        else{
            self.shouldHiddenAvatarView = YES;
        }
    }
    self.avatarView.hidden = YES;
}

- (void)updateAvatarVerifyWithAuthInfo:(NSString *)userAuthInfo userDecoration:(NSString *)userDecoration userId:(NSString *)userId
{
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:userAuthInfo decoratorInfo:userDecoration sureQueryWithID:YES userID:userId];
}

- (void)updateAvatarLabelWithText:(NSString *)avatarText
{
    if (isEmptyString(avatarText)) {
        avatarText = @"";
    }
    [self.avatarLabel setText:avatarText];
    [self.avatarLabel refreshIconView];
}

- (void)updateTypeLabelWithText:(NSString *)typeText
{
    self.shouldHiddenTypeLabel = YES;
    if (!isEmptyString(typeText)) {
        self.shouldHiddenTypeLabel = NO;
        [self.typeLabel setText:typeText];
        [self.typeLabel sizeToFit];
        self.typeLabel.width += 3 * 2;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarLabelButton.hidden = YES;
    self.avatarViewButton.hidden = YES;
    self.avatarView.hidden = YES;
    self.moreButton.hidden = NO;
    self.typeLabel.hidden = self.shouldHiddenTypeLabel;
}

- (NSArray<NSString *> *)randomSourceBackgroundColors {
    int index = arc4random() % 5;
    switch (index) {
        case 0:
            return @[@"90ccff", @"48667f"];
        case 1:
            return @[@"cccccc", @"666666"];
        case 2:
            return @[@"bfa1d0", @"5f5068"];
        case 3:
            return @[@"80c184", @"406042"];
        case 4:
            return @[@"e7ad90", @"735648"];
        default:
            return @[@"ff9090", @"7f4848"];
    }
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.backgroundColor = tt_ttuisettingHelper_cellViewBackgroundColor();
    
    [self.moreButton setImage:[UIImage themedImageNamed:@"More"] forState:UIControlStateNormal];
    [self.moreButton setImage:[UIImage themedImageNamed:@"More"] forState:UIControlStateHighlighted];
    [self.moreButton updateThemes];
}

static CGFloat sAvatarHeigth = 0;
+ (CGFloat)avatarHeight {
    if (sAvatarHeigth) {
        return sAvatarHeigth;
    }
    if (ttvs_isVideoFeedCellHeightAjust() > 1)
    {
        sAvatarHeigth = [TTDeviceUIUtils tt_newPadding:40];
    }else{
        sAvatarHeigth = [TTDeviceUIUtils tt_newPadding:32.0];
    }
    return sAvatarHeigth;
}

static CGFloat avatarBorderWidth = 0;
+ (CGFloat)avatarViewBorderWidth
{
    if (avatarBorderWidth) {
        return avatarBorderWidth;
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = 2;
    if (ttvs_isVideoFeedCellHeightAjust() > 1){
        avatarBorderWidth = width/scale;
    }else{
        avatarBorderWidth = 0;
    }
    return avatarBorderWidth;
}

#pragma mark - actions
- (void)moreActionClicked
{
    [self _moreAction];
    [self.moreActionMananger moreButtonClickedWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.cellEntity.originData] activityAction:^(NSString *type) {
        if (self.moreActionType) {
            self.moreActionType(type);
        }
    }];
}

- (void)moreActionOnMovieTopViewClicked
{
    [self _moreAction];
    [self.moreActionMananger moreActionOnMovieTopViewWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.cellEntity.originData] activityAction:^(NSString *type) {
        if (self.moreActionType) {
            self.moreActionType(type);
        }
    }];
}

- (void)_moreAction
{
    self.moreActionMananger = [[TTVFeedCellMoreActionManager alloc] init];
    self.moreActionMananger.categoryId = self.categoryId;
    self.moreActionMananger.responder = self;
    self.moreActionMananger.cellEntity = self.cellEntity.originData;
    self.moreActionMananger.dislikePopFromView = self.moreButton;
    self.moreActionMananger.playVideo = self.cellEntity.playVideo;
    @weakify(self);
    self.moreActionMananger.didClickActivityItemAndQueryProcess = ^BOOL(NSString *type) {
//        @strongify(self);
//        if ([type isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
//            [self forwardToWeitoutiao];
//            return YES;
//        }
        return NO;
    };
    self.moreActionMananger.shareToRepostBlock = ^(TTActivityType type) {
        @strongify(self);
        [self shareToRepostWithActivityType:type];
    };
    self.moreActionMananger.didClickDislikeSubmitButtonBlock = ^(TTVFeedItem *cellEntity, NSArray *filterWords, CGRect dislikeAnchorFrame, TTDislikeSourceType dislikeSourceType) {
        @strongify(self);
        SAFECALL_MESSAGE(TTVFeedCellActionMessage, @selector(message_dislikeWithCellEntity:filterWords:dislikeAnchorFrame:dislikeSource:), message_dislikeWithCellEntity:self.cellEntity filterWords:filterWords dislikeAnchorFrame:dislikeAnchorFrame dislikeSource:dislikeSourceType);
    };

}

- (void)bottomViewShareAction
{
    [self _shareAction];
    [self.moreActionMananger shareButtonClickedWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.cellEntity.originData] activityAction:^(NSString *type) {
        
    }];
}

- (void)shareActionClicked
{
    [self _shareAction];
    [self.moreActionMananger shareButtonOnMovieClickedWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.cellEntity.originData] activityAction:^(NSString *type) {
        
    }];
}

- (void)shareActionOnMovieTopViewClicked
{
    [self _shareAction];
    [self.moreActionMananger shareActionOnMovieTopViewWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.cellEntity.originData] activityAction:^(NSString *type) {

    }];
}

- (void)_shareAction
{
    self.moreActionMananger = [[TTVFeedCellMoreActionManager alloc] init];
    self.moreActionMananger.categoryId = self.cellEntity.categoryId;
    self.moreActionMananger.responder = self;
    self.moreActionMananger.cellEntity = self.cellEntity.originData;
    self.moreActionMananger.playVideo = self.cellEntity.playVideo;
    @weakify(self);
    self.moreActionMananger.didClickActivityItemAndQueryProcess = ^BOOL(NSString *type) {
//        @strongify(self);
//        if ([type isEqualToString:TTActivityContentItemTypeForwardWeitoutiao]) {
//            [self forwardToWeitoutiao];
//            return YES;
//        }
        return NO;
    };
    self.moreActionMananger.shareToRepostBlock = ^(TTActivityType type) {
        @strongify(self);
        [self shareToRepostWithActivityType:type];
    };

}

- (void)directShareOnmovieFinishViewWithActivityType:(NSString *)activityType
{
    [self _shareAction];
    [self.moreActionMananger directShareOnMovieFinishViewWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.cellEntity.originData] activityType:activityType activityAction:^(NSString *activityType) {
  }];
}

- (void)directShareOnMovieViewWithActivityType:(NSString *)activityType
{
    [self _shareAction];
    [self.moreActionMananger directShareOnMovieViewWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.cellEntity.originData] activityType:activityType activityAction:^(NSString *activityType) {
    }];
}


- (void)dealShareButtonOnBottomViewWithActivityType:(NSString *)activityType
{
    [self _shareAction];
    [self.moreActionMananger directShareOnBottomViewWithModel:[TTVFeedCellMoreActionModel modelWithArticle:self.cellEntity.originData] activityType:activityType activityAction:^(NSString *activityType) {
    }];

}
//- (void)forwardToWeitoutiao {
//    //实际转发对象为文章，操作对象为文章
//    [TTRepostViewController presentRepostToWeitoutiaoViewControllerWithRepostType:TTThreadRepostTypeArticle
//                                                                    originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.cellEntity.originData.ttv_convertedArticle]
//                                                                     originThread:nil
//                                                                   originShortVideoOriginalData:nil
//                                                                operationItemType:TTRepostOperationItemTypeArticle
//                                                                  operationItemID:self.cellEntity.originData.itemID
//                                                                   repostSegments:nil];
//}

- (void)shareToRepostWithActivityType:(TTActivityType)activityType {
//    [[TTShareToRepostManager sharedManager] shareToRepostWithActivityType:activityType
//                                                               repostType:TTThreadRepostTypeArticle
//                                                        operationItemType:TTRepostOperationItemTypeArticle
//                                                          operationItemID:self.cellEntity.originData.itemID
//                                                            originArticle:[[TTRepostOriginArticle alloc] initWithArticle:self.cellEntity.originData.ttv_convertedArticle]
//                                                             originThread:nil
//                                                           originShortVideoOriginalData:nil
//                                                        originWendaAnswer:nil
//                                                           repostSegments:nil];
}


- (void)didClickAvatarButton:(id)sender
{
    TTVFeedItem *videoFeed = self.cellEntity.originData;
    TTVVideoArticle *article = [videoFeed article];
    NSMutableDictionary * eventContext = [[NSMutableDictionary alloc] init];
    [eventContext setValue:[videoFeed uniqueIDStr] forKey:@"group_id"];
    [eventContext setValue:[videoFeed itemID] forKey:@"item_id"];
    NSString * screenName = [NSString stringWithFormat:@"channel_%@", self.categoryId];
    
    //page_type=0表示只显示视频
    [ExploreMovieView removeAllExploreMovieView];
    
    TTVUserInfo *userInfo = [videoFeed videoUserInfo];
    int64_t userId = userInfo.userId;
    
    NSString *openPGCURL = nil;
    NSString *openProfileUrl = nil;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    
    [dict setValue:[videoFeed uniqueIDStr] forKey:@"value"];
    
    [[TTRelevantDurationTracker sharedTracker] beginRelevantDurationTracking];
    [[TTRelevantDurationTracker sharedTracker] appendRelevantDurationWithGroupID:self.cellEntity.originData.groupModel.groupID
                                                                          itemID:self.cellEntity.originData.groupModel.itemID
                                                                       enterFrom:nil
                                                                    categoryName:self.categoryId
                                                                        stayTime:0
                                                                           logPb:nil];
    if (!isEmptyString(article.sourceOpenURL) && ![videoFeed hasVideoSubjectID])
    {
        NSString *urlString = article.sourceOpenURL;
        if ([article.sourceOpenURL rangeOfString:@"pgcprofile"].location != NSNotFound ||
            [article.sourceOpenURL rangeOfString:@"media_account"].location != NSNotFound) {
            urlString = [urlString stringByAppendingString:@"&page_source=1"];
        }
        
        urlString = [TTUGCTrackerHelper schemaTrackForPersonalHomeSchema:urlString categoryName:self.cellEntity.categoryId fromPage:@"list_video" groupId:self.cellEntity.originData.uniqueIDStr profileUserId:nil];
        NSURL *url = [TTURLUtils URLWithString:urlString];
        
        [[TTRoute sharedRoute] openURLByPushViewController:url];
        NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
        [extraDic setValue:[NSString stringWithFormat:@"%lld", userId] forKey:@"ext_value"];
        [extraDic setValue:[NSString stringWithFormat:@"%lld", article.groupId] forKey:@"value"];
        [dict setValue:extraDic forKey:@"extra"];
        [TTTrackerWrapper category:@"umeng" event:@"video" label:@"feed_enter_pgc_film" dict:dict];
//            [TTLogManager logEvent:@"feed_enter_pgc_film" context:eventContext screenName:screenName];
    }
    else
    {
        if ([videoFeed hasVideoSubjectID]) {
            openPGCURL = article.sourceOpenURL;
            NSDictionary *extraDic = @{@"pgc":@(1), @"video_subject_id" : article.videoDetailInfo.videoSubjectId};
            [dict setValue:extraDic forKey:@"extra"];
        } else if (userId > 0) {
            openPGCURL = [TTVideoCommon PGCOpenURLWithMediaID:[NSString stringWithFormat:@"%lld", userId]
                                                    enterType:kPGCProfileEnterSourceVideoFeedAuthor];
            
            [dict setValue:[NSString stringWithFormat:@"%lld", userId]  forKey:@"ext_value"];
            
            NSDictionary *extraDic = @{@"pgc":@(1)};
            [dict setValue:extraDic forKey:@"extra"];
        }
        //增加item_id
        openPGCURL = [NSString stringWithFormat:@"%@&item_id=%@&page_source=%@",openPGCURL, videoFeed.itemID, @(1)];
        [TTTrackerWrapper category:@"umeng" event:@"video" label:@"feed_enter_pgc" dict:dict];
//            [TTLogManager logEvent:@"click_feed_pgc" context:eventContext screenName:screenName];
        
    }
    
    openPGCURL = [TTUGCTrackerHelper schemaTrackForPersonalHomeSchema:openPGCURL categoryName:self.cellEntity.categoryId fromPage:@"list_video" groupId:self.cellEntity.originData.uniqueIDStr profileUserId:nil];
    if (!isEmptyString(openPGCURL)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openPGCURL]];
    }
    NSMutableDictionary *dictV3 = [NSMutableDictionary dictionary];
    [dictV3 setValue:[NSString stringWithFormat:@"%lld", userId] forKey:@"user_id"];
    [dictV3 setValue:@"list" forKey:@"position"];
    [TTTrackerWrapper eventV3:@"enter_homepage" params:dictV3 isDoubleSending:YES];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if (view == self.avatarLabel) {
        return self.avatarLabelButton;
    }
    
    if (!view) {
        if (!self.avatarView.hidden) {
            CGPoint pointTouched = [self convertPoint:point toView:self.avatarView];
            view = [self.avatarViewButton hitTest:pointTouched withEvent:event];
        }
    }
    return view;
}

@end
