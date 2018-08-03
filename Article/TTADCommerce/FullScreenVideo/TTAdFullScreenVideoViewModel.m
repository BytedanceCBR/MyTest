//
//  TTAdFullScreenVideoViewModel.m
//  Article
//
//  Created by matrixzk on 28/07/2017.
//
//

#import "TTAdFullScreenVideoViewModel.h"

#import "TTActivityShareManager.h"
#import "SSActivityView.h"
#import "TTActionSheetController.h"
#import "ArticleShareManager.h"
#import "TTUIResponderHelper.h"
#import "TTReportManager.h"
#import "TTAlphaThemedButton.h"
#import "TTLabelTextHelper.h"
#import "TTDiggButton.h"
#import "TTCollectionButton.h"
#import "TTRoute.h"
#import "TTDetailModel.h"
#import "NewsDetailLogicManager.h"
#import <TTBaseLib/JSONAdditions.h>
#import "ExploreDetailManager.h"
#import "TTAccountManager.h"
#import "TTVideoTip.h"
#import "ExploreItemActionManager.h"
#import "ArticleInfoManager.h"
#import "TTAppLinkManager.h"
#import "TTAdCallManager.h"
#import "TTAdTrackManager.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTTrackerProxy.h"
#import "TTServiceCenter.h"
#import "TTAdManagerProtocol.h"
#import "TTURLTracker.h"
#import <TTBaseLib/TTURLUtils.h>
#import <TTBaseLib/TTDeviceUIUtils.h>
#import "TTAdFullScreenVideoBottomActionView.h"


@interface TTAdFullScreenVideoViewModel () <SSActivityViewDelegate, ExploreDetailManagerDelegate, ArticleInfoManagerDelegate>

@property (nonatomic, strong) TTActivityShareManager *activityActionManager;
@property (nonatomic, strong) SSActivityView *shareView;
@property (nonatomic, strong) TTActionSheetController *actionSheetController;
@property (nonatomic, strong) TTDetailModel *detailModel;
@property (nonatomic, weak)   UIViewController *hostVC;
@property (nonatomic, strong) ExploreItemActionManager *itemActionManager;

@property (nonatomic, strong) TTDiggButton *diggButton;
@property (nonatomic, strong) TTCollectionButton *collectionButton;
@property (nonatomic, strong) UILabel *collectionLabel;
@property (nonatomic, strong) TTAlphaThemedButton *leftActionButton;
@property (nonatomic, strong) TTAlphaThemedButton *rightActionButton;
@property (nonatomic, strong) CALayer *bottomViewLayer;

@property (nonatomic, strong) ArticleInfoManager *infoManager;

@property (nonatomic, strong) NSDictionary *adInfo;

// 第三方监控
@property (nonatomic, strong) NSArray *adTrackUrlList;
@property (nonatomic, strong) NSArray *adClickTrackUrlList;
@property (nonatomic, strong) NSArray *adPlayTrackUrlList;
@property (nonatomic, strong) NSArray *adActivePlayTrackUrlList;
@property (nonatomic, strong) NSArray *adPlayoverTrackUrlList;

@end

@implementation TTAdFullScreenVideoViewModel

//- (void)dealloc
//{
//    NSLog(@">>>>>> Dealloc : TTAdFullScreenVideoViewModel.");
//}

- (instancetype)initWithParamObj:(TTRouteParamObj *)paramObj hostVC:(UIViewController *)hostVC
{
    self = [super init];
    if (self) {
        _hostVC = hostVC;
        _detailModel = [self detailModelWithParamObj:paramObj];
        
        _infoManager = [ArticleInfoManager new];
        _infoManager.delegate = self;
        
        [self fetchDetailInfo];
    }
    return self;
}

#pragma mark -

- (void)fetchDetailInfo
{
    [self.infoManager cancelAllRequest];
    
    Article *article = self.detailModel.article;
    
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    [condition setValue:article.groupModel forKey:kArticleInfoManagerConditionGroupModelKey];
    if ([[article.comment allKeys] containsObject:@"comment_id"]) {
        [condition setValue:[article.comment objectForKey:@"comment_id"] forKey:kArticleInfoManagerConditionTopCommentIDKey];
    }
    
    NSString *videoSubjectID = [article videoSubjectID];
    if (videoSubjectID && [self.detailModel isFromList]) {
        condition[kArticleInfoRelatedVideoSubjectIDKey] = videoSubjectID;
    }
    
    NSString *zzCommentsID = [article zzCommentsIDString];
    if (!isEmptyString(zzCommentsID)) {
        [condition setValue:zzCommentsID forKey:@"zzids"];
    }
    
    if (!isEmptyString(self.detailModel.adLogExtra)) {
        [condition setValue:self.detailModel.adLogExtra forKey:@"log_extra"];
    }
    
    [condition setValue:(self.detailModel.orderedData.ad_id ? : self.detailModel.adID) forKey:@"ad_id"];
    
    [condition setValue:self.detailModel.categoryID forKey:kArticleInfoManagerConditionCategoryIDKey];
    [condition setValue:self.detailModel.clickLabel forKey:@"from"];
    [condition setValue:@(0x40) forKey:@"flags"];
    [condition setValue:@(1) forKey:@"article_page"];
    [self.infoManager startFetchArticleInfo:condition];
}


#pragma mark ArticleInfoManagerDelegate

- (void)articleInfoManager:(ArticleInfoManager *)manager getStatus:(NSDictionary *)dict
{
    [[self.detailModel sharedDetailManager] updateArticleByData:dict];
    
    self.adInfo = [[dict tt_dictionaryValueForKey:@"ad_info"] copy];
    
    if (!self.adInfo) return;
    
    self.adTrackUrlList = [[self.adInfo tt_arrayValueForKey:@"track_url_list"] copy];
    self.adPlayTrackUrlList = [[self.adInfo tt_arrayValueForKey:@"play_track_url_list"] copy];
    self.adClickTrackUrlList = [[self.adInfo tt_arrayValueForKey:@"click_track_url_list"] copy];
    self.adActivePlayTrackUrlList = [[self.adInfo tt_arrayValueForKey:@"active_play_track_url_list"] copy];
    self.adPlayoverTrackUrlList = [[self.adInfo tt_arrayValueForKey:@"playover_track_url_list"] copy];
    
    [self eventTrack4ThirdPartyMonitorWithType:TTAdFSVideoThirdPartyMonitorTypeEnter];
}

- (void)articleInfoManagerLoadDataFinished:(ArticleInfoManager *)manager
{
    [self refreshBottomView];
}

- (void)articleInfoManagerFetchInfoFailed:(ArticleInfoManager *)manager
{
    // TODO: failed
}


#pragma mark - Action

- (void)showSharePannel
{
    [_activityActionManager clearCondition];
    if (!_activityActionManager) {
        self.activityActionManager = [[TTActivityShareManager alloc] init];
    }
    NSMutableArray *activityItems = [ArticleShareManager shareActivityManager:self.activityActionManager
                                                          setArticleCondition:self.detailModel.article
                                                                         adID:@(self.detailModel.article.adIDStr.longLongValue)
                                                                   showReport:YES
                                                                       withQQ:YES];
    _shareView = [[SSActivityView alloc] init];
    _shareView.delegate = self;
    _shareView.activityItems = activityItems;
    id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
    [adManagerInstance share_showInAdPage:self.detailModel.adID.stringValue
                                  groupId:self.detailModel.article.groupModel.groupID];
    [_shareView showOnViewController:[TTUIResponderHelper correctTopViewControllerFor:nil] useShareGroupOnly:NO];
}

- (void)diggButtonDidPressedWithType:(TTDiggButtonClickType)type
{
    if (TTDiggButtonClickTypeAlreadyDigg == type) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"您已经赞过" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    } else if (TTDiggButtonClickTypeDigg == type) {
        
        if (!_itemActionManager) {
            self.itemActionManager = [[ExploreItemActionManager alloc] init];
        }
        
        self.detailModel.article.userLike = [NSNumber numberWithBool:YES];
        self.detailModel.article.likeCount = [NSNumber numberWithInt:[self.detailModel.article.likeCount intValue] + 1];
        [self.detailModel.article save];
        
        [self.diggButton setDiggCount:self.detailModel.article.likeCount.intValue];
        [self.diggButton sizeToFit];
        
        [self.itemActionManager sendActionForOriginalData:self.detailModel.article adID:nil actionType:DetailActionTypeLike finishBlock:nil];
        
        // TODO: 点赞打点
        
    }
}

- (void)collectionButtonDidPressed
{
    ExploreDetailManager *manager = [self.detailModel sharedDetailManager];
    manager.delegate = self;
    // 调用新增的方法，传入控制器对象，以吊起登录弹窗
    [manager changeFavoriteButtonClicked:1 viewController:self.hostVC];
    
    if ([SSCommonLogic accountABVersionEnabled]) return;
    
    if (self.detailModel.article.userRepined) {
        // TODO: 收藏打点
        WeakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            StrongSelf;
            if (![TTAccountManager isLogin] && ![TTVideoTip hasTipFavLoginUserDefaultKey]) {
                
                wrapperTrackEvent(@"pop", @"login_detail_favor_show");
                
                [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeFavor source:@"detail_first_favor" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
                    if (type == TTAccountAlertCompletionEventTypeTip) {
                        [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self.hostVC] type:TTAccountLoginDialogTitleTypeDefault source:@"detail_first_favor" completion:^(TTAccountLoginState state) {
                        }];
                    }
                }];
                
                [TTVideoTip setHasTipFavLoginUserDefaultKey:YES];
            }
            
        });
    } else {
        // TODO: 取消收藏打点
    }
}

- (void)actionButtonPressedWithInfo:(NSDictionary *)infoDict
{
    if (![infoDict isKindOfClass:[NSDictionary class]]) return;
    
    NSString *type = [infoDict tt_stringValueForKey:@"type"];
    
    if (isEmptyString(type)) return;
    
    if ([type isEqualToString:@"action"]) {
        
        NSString *phoneNum = [infoDict tt_stringValueForKey:@"phone_number"];
        if (phoneNum.integerValue == 0) return;
        
        TTAdCallListenModel *callModel = [TTAdCallListenModel new];
        callModel.ad_id = self.detailModel.adID.stringValue;
        callModel.log_extra = self.detailModel.adLogExtra;
        callModel.dailTime = [NSDate date];
        callModel.position = @"detail_call";
        callModel.dailActionType = @(1);
        [[TTAdCallManager sharedManager] callAdModel:callModel];
        [TTAdCallManager callWithNumber:phoneNum];
        
        [self eventTrackWithLabel:@"click_call"];
        
    } else if ([type isEqualToString:@"counsel"]) {
        
        [self openWebPageWithURL:[infoDict tt_stringValueForKey:@"web_url"]];
        [self eventTrackWithLabel:@"click_counsel"];
        
    } else if ([type isEqualToString:@"web"]) {
        
        [self eventTrackWithLabel:@"ad_click"];
        
        NSString *webURLStr = [infoDict tt_stringValueForKey:@"web_url"];
        NSString *openURLStr = [infoDict tt_stringValueForKey:@"open_url"];
        
        NSDictionary *logExtraDict = @{@"log_extra": self.detailModel.adLogExtra ? : @""};
        
        BOOL canOpenApp = [TTAppLinkManager dealWithWebURL:webURLStr openURL:openURLStr sourceTag:@"detail_ad" value:self.detailModel.adID.stringValue extraDic:logExtraDict];
        
        if (canOpenApp) return;
        
        NSURL *openURL = [TTStringHelper URLWithURLString:openURLStr];
        if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
            [[TTRoute sharedRoute] openURLByPushViewController:openURL userInfo:TTRouteUserInfoWithDict(logExtraDict)];
        } else {
            [self openWebPageWithURL:webURLStr];
        }
    }
    
    [self eventTrack4ThirdPartyMonitorWithType:TTAdFSVideoThirdPartyMonitorTypeClick];
}

- (void)openWebPageWithURL:(NSString *)webURL
{
    if (isEmptyString(webURL)) return;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:webURL forKey:@"url"];
    [params setValue:[self.adInfo tt_stringValueForKey:@"title"] forKey:@"title"];
    [params setValue:self.detailModel.adID.stringValue forKey:@"ad_id"];
    [params setValue:self.detailModel.adLogExtra forKey:@"log_extra"];
    NSURL *schema = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:params];
    if ([[TTRoute sharedRoute] canOpenURL:schema]) {
        [[TTRoute sharedRoute] openURLByPushViewController:schema];
    }
}


#pragma mark - UI Helper

- (void)refreshBottomView
{
    [_diggButton setDiggCount:self.detailModel.article.likeCount.intValue];
    [_diggButton sizeToFit];
    
    _collectionButton.selected = self.detailModel.article.userRepined;
    
    NSArray *buttonInfoArray = [self effectiveActionButtonListInfo];
    
    if (buttonInfoArray.count == 1) {
        [self setupActionButton:self.rightActionButton withInfo:buttonInfoArray.firstObject];
        
        self.rightActionButton.alpha = 0;
        [UIView animateWithDuration:.25 animations:^{
            self.rightActionButton.alpha = 1;
        }];
    } else if (buttonInfoArray.count > 1) {
        [self setupActionButton:_rightActionButton withInfo:buttonInfoArray[1]];
        [self setupActionButton:_leftActionButton withInfo:buttonInfoArray.firstObject];
        
        self.leftActionButton.alpha = self.rightActionButton.alpha = 0;
        [UIView animateWithDuration:.25 animations:^{
            self.leftActionButton.alpha = self.rightActionButton.alpha = 1;
        }];
    }
}

- (void)setupActionButton:(UIButton *)button withInfo:(NSDictionary *)infoDict
{
    if (![infoDict isKindOfClass:[NSDictionary class]]) return;
    
    WeakSelf;
    [button addTarget:self withActionBlock:^{
        StrongSelf;
        [self actionButtonPressedWithInfo:infoDict];
    } forControlEvent:UIControlEventTouchUpInside];
    [button setTitle:[infoDict tt_stringValueForKey:@"button_text"] forState:UIControlStateNormal];
    button.hidden = NO;
}

- (NSArray *)effectiveActionButtonListInfo
{
    NSArray *buttonListInfoArray = [self.adInfo tt_arrayValueForKey:@"button_list"];
    if (buttonListInfoArray.count == 0) {
        return nil;
    }
    
    NSMutableArray *invalidateButtonInfo = [NSMutableArray arrayWithCapacity:1];
    
    [buttonListInfoArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull infoDict, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![infoDict isKindOfClass:[NSDictionary class]]) {
            [invalidateButtonInfo addObject:infoDict];
            return;
        }
        
        NSString *type = [infoDict tt_stringValueForKey:@"type"];
        NSString *buttonText = [infoDict tt_stringValueForKey:@"button_text"];
        
        if ([type isEqualToString:@"action"]) {
            
            NSString *phoneNum = [infoDict tt_stringValueForKey:@"phone_number"];
            if (phoneNum.integerValue == 0) {
                [invalidateButtonInfo addObject:infoDict];
                return;
            }
            
            if (isEmptyString(buttonText)) {
                [infoDict setValue:@"立即拨打" forKey:@"button_text"];
            }
            
        } else if ([type isEqualToString:@"counsel"]) {
            
            if (isEmptyString([infoDict tt_stringValueForKey:@"web_url"])) {
                [invalidateButtonInfo addObject:infoDict];
                return;
            }
            
            if (isEmptyString(buttonText)) {
                [infoDict setValue:@"立即咨询" forKey:@"button_text"];
            }
            
        } else if ([type isEqualToString:@"web"]) {
            
            if (isEmptyString([infoDict tt_stringValueForKey:@"web_url"]) && isEmptyString([infoDict tt_stringValueForKey:@"open_url"])) {
                [invalidateButtonInfo addObject:infoDict];
                return;
            }
            
            if (isEmptyString(buttonText)) {
                [infoDict setValue:@"查看详情" forKey:@"button_text"];
            }
            
        } else {
            [invalidateButtonInfo addObject:infoDict];
        }
        
    }];
    
    if (invalidateButtonInfo.count > 0) {
        NSMutableArray *resultArray = [buttonListInfoArray mutableCopy];
        [resultArray removeObjectsInArray:invalidateButtonInfo];
        
        return [resultArray copy];
    }
    
    return buttonListInfoArray;
}

- (UIView *)buildTopViewWithBackButtonPressedBlock:(void(^)(void))backActionBlock
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.hostVC.view.frame), 64)];
    
    // GradientLayer
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.locations = @[@0, @1];
    gradientLayer.colors = @[(__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor,
                             (__bridge id)[UIColor clearColor].CGColor];
    gradientLayer.frame = topView.bounds;
    [topView.layer addSublayer:gradientLayer];
    
    CGFloat kIconMargin = 12, kIconSize = 24;
    
    // BackButton
    TTAlphaThemedButton *backButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    backButton.imageName = @"titlebar_close_white";
    backButton.frame = CGRectMake(kIconMargin, kIconMargin, kIconSize, kIconSize);
    backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    [backButton addTarget:self withActionBlock:^{
        !backActionBlock ? : backActionBlock();
    } forControlEvent:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    // MoreButton
    TTAlphaThemedButton *moreButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    moreButton.imageName = @"new_morewhite_titlebar";
    moreButton.enableNightMask = NO;
    moreButton.frame = CGRectMake(CGRectGetWidth(topView.frame) - kIconMargin - kIconSize, kIconMargin, kIconSize, kIconSize);
    moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    WeakSelf;
    [moreButton addTarget:self withActionBlock:^{
        StrongSelf;
        [self showSharePannel];
    } forControlEvent:UIControlEventTouchUpInside];
    [topView addSubview:moreButton];
    
    return topView;
}

- (UIView *)buildBottomView
{
    CGFloat kFontSizeOfTitle = [TTDeviceUIUtils tt_newFontSize:18],
    kMarginOfTitleLbl = 15,
    kTopPaddingOfTitleLbl = [TTDeviceUIUtils tt_newPadding:37],
    kTopPaddingOfActionBtn = [TTDeviceUIUtils tt_newPadding:10],
    widthOfTitleLbl = CGRectGetWidth(self.hostVC.view.frame) - kMarginOfTitleLbl * 2,
    heightOfTitleLbl = [TTLabelTextHelper heightOfText:self.detailModel.article.title
                                              fontSize:kFontSizeOfTitle
                                              forWidth:widthOfTitleLbl
                          constraintToMaxNumberOfLines:2],
    
    heightOfBottomView = kTopPaddingOfTitleLbl + heightOfTitleLbl + kTopPaddingOfActionBtn + 28 + 15;
    CGFloat kWidthOfActionButton = 72, kHeightOfActionButton = 28;
    
    UIView *bottomView = [[TTAdFullScreenVideoBottomActionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.hostVC.view.frame) - heightOfBottomView,
                                                                  CGRectGetWidth(self.hostVC.view.frame), heightOfBottomView)];
   
    
    CGFloat y = 0;
    y += kTopPaddingOfTitleLbl;
    // TitleLabel
    SSThemedLabel *titleLbl = [[SSThemedLabel alloc] initWithFrame:CGRectMake(kMarginOfTitleLbl, y, widthOfTitleLbl, heightOfTitleLbl)];
    titleLbl.text = self.detailModel.article.title; // TODO: ???
    titleLbl.textColor = [UIColor colorWithHexString:@"#E8E8E8"];
    titleLbl.font = [UIFont systemFontOfSize:kFontSizeOfTitle];
    titleLbl.numberOfLines = 2;
    [bottomView addSubview:titleLbl];
    y += heightOfTitleLbl;
    
    y += kTopPaddingOfActionBtn;
    // DiggButton
    _diggButton = [TTDiggButton diggButtonWithStyleType:TTDiggButtonStyleTypeBigNumber];
    _diggButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [_diggButton setImage:[UIImage imageNamed:@"white_like"] forState:UIControlStateNormal];
    [_diggButton setImage:[UIImage imageNamed:@"white_like_press"] forState:UIControlStateSelected];
    [_diggButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    CGFloat fontSize = 12;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f) {
        _diggButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        _diggButton.titleLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightThin];
#pragma clang diagnostic pop
    }
    [_diggButton setTitleEdgeInsets:UIEdgeInsetsMake(1, 2, 0, -2)];
    _diggButton.selected = self.detailModel.article.userLike.boolValue;
    WeakSelf;
    [_diggButton setClickedBlock:^(TTDiggButtonClickType type) {
        StrongSelf;
        [self diggButtonDidPressedWithType:type];
    }];
    [_diggButton setDiggCount:self.detailModel.article.likeCount.intValue];
    [_diggButton sizeToFit];
    CGFloat y1 = (kHeightOfActionButton -  CGRectGetHeight(_diggButton.frame)) / 2;
    _diggButton.frame = (CGRect){kMarginOfTitleLbl, y + y1, _diggButton.frame.size};
    [bottomView addSubview:_diggButton];
    
    
    // CollectionButton
    _collectionButton = [TTCollectionButton collectionButtonWithType:TTCollectionButtonTypeLight nightModeEnable:NO];
    _collectionButton.frame = (CGRect){CGRectGetMaxX(_diggButton.frame) + [TTDeviceUIUtils tt_newPadding:30],
                                       y + y1, _collectionButton.frame.size};
    _collectionButton.selected = self.detailModel.article.userRepined;
    _collectionButton.didPressedBlock = ^(BOOL isCollected) {
        StrongSelf;
        [self collectionButtonDidPressed];
    };
    [bottomView addSubview:_collectionButton];
    
    
    // CollectionLabel
    _collectionLabel = [UILabel new];
    _collectionLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
    _collectionLabel.font = [UIFont systemFontOfSize:12];
    _collectionLabel.text = @"收藏";
    [_collectionLabel sizeToFit];
    _collectionLabel.center = CGPointMake(CGRectGetMaxX(_collectionButton.frame) + 4 + CGRectGetWidth(_collectionLabel.frame) / 2, _collectionButton.center.y);
    [bottomView addSubview:_collectionLabel];
    
    
    // RightActionButton
   
    _rightActionButton = [self createActionButton];
    _rightActionButton.frame = CGRectMake(CGRectGetWidth(bottomView.frame) - kWidthOfActionButton - kMarginOfTitleLbl,
                                          y,
                                          kWidthOfActionButton, kHeightOfActionButton);
    _rightActionButton.hidden = YES;
    [bottomView addSubview:_rightActionButton];
    
    
    // LeftActionButton
    _leftActionButton = [self createActionButton];
    _leftActionButton.frame = (CGRect){CGRectGetMinX(_rightActionButton.frame) - kWidthOfActionButton - [TTDeviceUIUtils tt_newPadding:10],
                                       y, _rightActionButton.frame.size};
    _leftActionButton.hidden = YES;
    [bottomView addSubview:_leftActionButton];
    
    y += kHeightOfActionButton;
    y += 15;
    
    return bottomView;
}

- (CGFloat)heightOfBottomViewWith:(CGFloat)width {
    CGFloat kFontSizeOfTitle = [TTDeviceUIUtils tt_newFontSize:18],
    kMarginOfTitleLbl = 15,
    kTopPaddingOfTitleLbl = [TTDeviceUIUtils tt_newPadding:37],
    kTopPaddingOfActionBtn = [TTDeviceUIUtils tt_newPadding:10],
    widthOfTitleLbl = width - kMarginOfTitleLbl * 2,
    heightOfTitleLbl = [TTLabelTextHelper heightOfText:self.detailModel.article.title
                                              fontSize:kFontSizeOfTitle
                                              forWidth:widthOfTitleLbl
                          constraintToMaxNumberOfLines:2];
    CGFloat kHeightOfActionButton = 28;
    
    CGFloat y = kTopPaddingOfTitleLbl;
    y += heightOfTitleLbl;
    y += kTopPaddingOfActionBtn;
    y += kHeightOfActionButton;
    y += 15;
    
    return y;
}

- (TTAlphaThemedButton *)createActionButton
{
    TTAlphaThemedButton *actionButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    actionButton.backgroundColor = [UIColor colorWithHexString:@"#F85959"];
    [actionButton setTitleColor:[UIColor colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    actionButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
    actionButton.layer.cornerRadius = 4;
    
    return actionButton;
}


#pragma mark - SSActivityViewDelegate

- (void)activityView:(SSActivityView *)view didCompleteByItemType:(TTActivityType)itemType
{
    if (itemType == TTActivityTypeReport) {
        self.actionSheetController = [[TTActionSheetController alloc] init];
        [self.actionSheetController insertReportArray:[TTReportManager fetchReportVideoOptions]];
        WeakSelf;
        [self.actionSheetController performWithSource:TTActionSheetSourceTypeReport completion:^(NSDictionary * _Nonnull parameters) {
            StrongSelf;
            if (parameters[@"report"]) {
                TTReportContentModel *model = [[TTReportContentModel alloc] init];
                model.groupID = self.detailModel.article.groupModel.groupID;
                model.videoID = self.detailModel.article.videoID;
                [[TTReportManager shareInstance] startReportVideoWithType:parameters[@"report"]
                                                                inputText:parameters[@"criticism"]
                                                              contentType:kTTReportContentTypeAD
                                                               reportFrom:TTReportFromByEnterFromAndCategory(self.detailModel.clickLabel, self.detailModel.categoryID)
                                                             contentModel:model
                                                                 extraDic:nil
                                                                 animated:YES];
            }
        }];
    } else {
        [self.activityActionManager performActivityActionByType:itemType
                                               inViewController:[TTUIResponderHelper correctTopViewControllerFor:nil]
                                               sourceObjectType:TTShareSourceObjectTypeArticle
                                                       uniqueId:@(self.detailModel.article.uniqueID).stringValue
                                                           adID:self.detailModel.article.adIDStr
                                                       platform:TTSharePlatformTypeOfMain
                                                     groupFlags:self.detailModel.article.groupFlags];
    }
    self.shareView = nil;
}


#pragma mark - Data

- (TTDetailModel *)detailModelWithParamObj:(TTRouteParamObj *)paramObj
{
    TTDetailModel *detailModel = [TTDetailModel new];
    
    Article *tArticle = nil;
    NSDictionary *params = paramObj.allParams;
    
    detailModel.baseCondition = [params copy];
    //原始schema
    detailModel.originalSchema = [paramObj.sourceURL absoluteString];
    //动态ID
    detailModel.dongtaiID = [params stringValueForKey:@"dongtai_id" defaultValue:@""];
    
    if ([params valueForKey:@"ttDragToRoot"]) {
        detailModel.ttDragToRoot = [[params valueForKey:@"ttDragToRoot"] boolValue];
    }
    if ([params valueForKey:@"isFloatVideoController"]) {
        detailModel.isFloatVideoController = [[params valueForKey:@"isFloatVideoController"] boolValue];
    }
    NSMutableDictionary * condition = [NSMutableDictionary dictionaryWithCapacity:10];
    id groupIdValue = params[@"groupid"]?:params[@"group_id"];
    if (groupIdValue) {
        NSNumber *groupID = @([[NSString stringWithFormat:@"%@", groupIdValue] longLongValue]);
        NSNumber *fixedgroupID = [SSCommonLogic fixNumberTypeGroupID:groupID];
        NSString *itemID = [params objectForKey:@"item_id"];
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:3];
        [query setValue:fixedgroupID forKey:@"uniqueID"];
        [query setValue:itemID forKey:@"itemID"];
        
        NSString * gdLabel = [params objectForKey:@"gd_label"];
        
        if ([params.allKeys containsObject:@"ordered_data"]) {
            detailModel.orderedData = [params objectForKey:@"ordered_data"];
        }
        
        NSString *adOpenUrl = [params objectForKey:@"article_url"];
        if (!isEmptyString(adOpenUrl)) {
            detailModel.adOpenUrl = adOpenUrl;
        }
        
        NewsGoDetailFromSource fSource = NewsGoDetailFromSourceUnknow;
        if (!isEmptyString(gdLabel)) {
            detailModel.gdLabel = gdLabel;
            fSource = [NewsDetailLogicManager fromSourceByString:gdLabel];
        } else if ([[params allKeys] containsObject:kNewsGoDetailFromSourceKey]) {
            fSource = [params[kNewsGoDetailFromSourceKey] intValue];
        }
        
        detailModel.fromSource = fSource;
        
        if ([params valueForKey:@"from_gid"]) {
            detailModel.relateReadFromGID = [params valueForKey:@"from_gid"];
        }
        
        NSNumber * adID = nil;
        if ([[params allKeys] containsObject:@"ad_id"]) {
            adID = @([[params objectForKey:@"ad_id"] longLongValue]);
            [condition setValue:adID forKey:kNewsDetailViewConditionADIDKey];
            [query setValue:adID forKey:@"ad_id"];
            detailModel.adID = adID;
        }
        if ([[params allKeys] containsObject:@"log_extra"]) {
            NSString * logExtra = [params objectForKey:@"log_extra"] ?  [params objectForKey:@"log_extra"] : @"";
            [condition setValue:logExtra forKey:kNewsDetailViewConditionADLogExtraKey];
            detailModel.adLogExtra = logExtra;
        }
        
        if (isEmptyString(detailModel.adLogExtra)) {
            NSString *logExtra = !isEmptyString(detailModel.orderedData.log_extra)?detailModel.orderedData.log_extra:@"";
            [condition setValue:logExtra forKey:kNewsDetailViewConditionADLogExtraKey];
            detailModel.adLogExtra = logExtra;
        }
        
        if (detailModel.orderedData) {
            tArticle = detailModel.orderedData.article;
        }
        if (!tArticle) {
            NSString *primaryID = [Article primaryIDByUniqueID:[fixedgroupID longLongValue] itemID:itemID adID:[adID stringValue]];
            tArticle = [Article objectForPrimaryKey:primaryID];
        }
        if (!tArticle) {
            tArticle = [Article objectWithDictionary:query];
        }
        
        if ([[params allKeys] containsObject:@"group_flags"]) {
            tArticle.groupFlags = @([[params objectForKey:@"group_flags"] intValue]);
        } else {
            if (tArticle.groupFlags.integerValue==0 || tArticle.groupFlags.integerValue==kArticleGroupFlagsDetailTypeArticleSubject) {
                tArticle.groupFlags = @(kArticleGroupFlagsDetailTypeArticleSubject);
            }
        }
        if (params[@"aggr_type"]) {
            tArticle.aggrType = @([params[@"aggr_type"] integerValue]);
        }
        if (params[@"flags"]) {
            long long flags = [params[@"flags"] longLongValue];
            tArticle.articleType = flags & 0x1;
        } else {
            if ([params[@"article_type"] respondsToSelector:@selector(integerValue)]) {
                tArticle.articleType = [params[@"article_type"] integerValue];
            }
        }
        if ([[params allKeys] containsObject:@"natant_level"]) {
            tArticle.natantLevel = @([[params objectForKey:@"natant_level"] intValue]);
        }
        if ([[params allKeys] containsObject:@"stat_params"] && [[params objectForKey:@"stat_params"] isKindOfClass:[NSDictionary class]]) {
            detailModel.statParams = [params objectForKey:@"stat_params"];
        }
        if ([[params allKeys] containsObject:@"video_type"]) {
            tArticle.videoType = @([[params objectForKey:@"video_type"] intValue]);
        }
        
        detailModel.article = tArticle;
        detailModel.isArticleReliable = [detailModel tt_isArticleReliable];
        [tArticle save];
        
        NSString * categoryID = [params objectForKey:kNewsDetailViewConditionCategoryIDKey];
        if (!isEmptyString(categoryID)) {
            [condition setValue:categoryID forKey:kNewsDetailViewConditionCategoryIDKey];
            detailModel.categoryID = categoryID;
        }
        
        NSString *gdExtJson = [params objectForKey:@"gd_ext_json"];
        if (!isEmptyString(gdExtJson)) {
            gdExtJson = [gdExtJson stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSDictionary *dict = [NSString tt_objectWithJSONString:gdExtJson error:&error];;
            if (!error && [dict isKindOfClass:[NSDictionary class]]) {
                detailModel.gdExtJsonDict = dict;
            } else {//如果解析有问题，替换+号后解析
                gdExtJson = [gdExtJson stringByReplacingOccurrencesOfString:@"+" withString:@" "];
                error = nil;
                NSDictionary *dict = [NSString tt_objectWithJSONString:gdExtJson error:&error];;
                if (!error && [dict isKindOfClass:[NSDictionary class]]) {
                    detailModel.gdExtJsonDict = dict;
                }
            }
        }
        
        if ([params objectForKey:@"msg_id"]) {
            detailModel.msgID = [params tt_stringValueForKey:@"msg_id"];
        }
        
        detailModel.needQuickExit = [params tt_boolValueForKey:@"is_quick_exit"];
    }
    
    return detailModel;
}

#pragma mark - ExploreDetailManagerDelegate

- (void)detailManager:(ExploreDetailManager *)manager showTipMsg:(NSString *)tipMsg
{
    if (isEmptyString(tipMsg)) return;
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:nil autoDismiss:YES dismissHandler:nil];
}

- (void)detailManager:(ExploreDetailManager *)manager showTipMsg:(NSString *)tipMsg icon:(UIImage *)image
{
    if (isEmptyString(tipMsg)) return;
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:nil];
}

- (void)detailManager:(ExploreDetailManager *)manager showTipMsg:(NSString *)tipMsg icon:(UIImage *)image dismissHandler:(DismissHandler)handler
{
    if (isEmptyString(tipMsg)) return;
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:tipMsg indicatorImage:image autoDismiss:YES dismissHandler:handler];
}

#pragma mark - Event track

- (void)eventTrackWithLabel:(NSString *)label
{
    [self eventTrackWithLabel:label extraDict:nil];
}

- (void)eventTrackWithLabel:(NSString *)label extraDict:(NSDictionary *)dict
{
    if (isEmptyString(label)) return;
    
    NSMutableDictionary *extraDict = [@{@"log_extra"   : self.detailModel.adLogExtra ? : @"",
                                        @"nt"          : @([[TTTrackerProxy sharedProxy] connectionType]),
                                        @"is_ad_event" : @"1"} mutableCopy];
    if (dict.count > 0) {
        [extraDict addEntriesFromDictionary:dict];
    }
    
    [TTAdTrackManager trackWithTag:@"embeded_ad" label:label value:self.detailModel.orderedData.ad_id extraDic:[extraDict copy]];
    
    // TODO: delete
    /*
    [extraDict addEntriesFromDictionary:@{@"event" : @"embeded_ad",
                                          @"label" : label,
                                          @"value" : self.detailModel.orderedData.ad_id}];
    NSLog(@">>>>>> ad event track : \n%@", extraDict);
     */
}

- (void)eventTrack4ThirdPartyMonitorWithType:(TTAdFSVideoThirdPartyMonitorType)type
{
    NSArray *trackURLArray;
    
    switch (type) {
        case TTAdFSVideoThirdPartyMonitorTypeEnter:
        {
            trackURLArray = self.adTrackUrlList;
        } break;
            
        case TTAdFSVideoThirdPartyMonitorTypeBreak:
        {
            trackURLArray = self.adPlayoverTrackUrlList;
        } break;
            
        case TTAdFSVideoThirdPartyMonitorTypePlay:
        {
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.adActivePlayTrackUrlList];
            [array addObjectsFromArray:self.adPlayTrackUrlList];
            trackURLArray = [array copy];
        } break;
            
        case TTAdFSVideoThirdPartyMonitorTypeClick:
        {
            trackURLArray = self.adClickTrackUrlList;
        } break;
            
        default:
            break;
    }
    
    if (trackURLArray.count == 0) return;
    
    TTURLTrackerModel *trackModel = [[TTURLTrackerModel alloc] initWithAdId:self.detailModel.adID.stringValue logExtra:self.detailModel.adLogExtra];
    ttTrackURLsModel(trackURLArray, trackModel);
}

@end
