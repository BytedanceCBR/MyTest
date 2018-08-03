//
//  ArticleMomentDetailViewController.m
//  Article
//
//  Created by Zhang Leonardo on 14-5-26.
//
//

#import "ArticleMomentDetailViewController.h"
#import "ArticleMomentDetailView.h"
#import "ExploreMomentListCellHeaderItem.h"

#import "TTDeviceHelper.h"
#import "UIButton+TTAdditions.h"
#import "UIImage+TTThemeExtension.h"
#import "SSNavigationBar.h"
#import "UIViewController+Track.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTRoute.h"
#import "NewsDetailLogicManager.h"
#import "TTTabBarProvider.h"
#import "TTUGCTrackerHelper.h"

@interface ArticleMomentDetailViewController ()
@property(nonatomic, strong)ArticleMomentDetailView * detailView;
@property(nonatomic, strong)ArticleMomentManager * momentManager;
@property(nonatomic, assign)ArticleMomentSourceType sourceType;
@property(nonatomic, assign)BOOL showWriteComment;
@property(nonatomic, assign)BOOL showComment;
@property(nonatomic, assign)BOOL enterFromClickComment; //通过点击评论按钮进入，目前UGC在用
@property(nonatomic, weak) id<ExploreMomentListCellUserActionItemDelegate> delegate;
@property(nonatomic, copy)NSDictionary * extraTracks; //统计透传，通过页面shcema获取（gd_ext_json）
@property (nonatomic, strong)NSNumber *clickArea;
@end

@implementation ArticleMomentDetailViewController

- (void)dealloc
{
    self.momentManager = nil;
    self.momentModel = nil;
    self.detailView = nil;
}

- (id)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _extraTracks = [TTUGCTrackerHelper trackExtraFromBaseCondition:paramObj.allParams];
        NSDictionary *params = paramObj.allParams;
        NSString *momentID = [params objectForKey:@"id"];
        if (!isEmptyString(momentID)) {
            ArticleMomentModel * model = [[ArticleMomentModel alloc] initWithDictionary:@{@"id":momentID}];
            self.momentModel = model;
        }
        _showWriteComment = [params tt_boolValueForKey:@"writeComment"];
        _showComment = [params tt_boolValueForKey:@"showComment"];
        _enterFromClickComment = [params tt_boolValueForKey:@"clickComment"];
        _sourceType = [params tt_integerValueForKey:@"sourceType"];
        _itemID = [params tt_stringValueForKey:@"itemId"];
        _categoryID = [params tt_stringValueForKey:@"category_id"];
        _gtype = [params tt_integerValueForKey:@"gtype"];
        _recommendReson = [params tt_stringValueForKey:@"recommendReson"];
        _recommendType = [params tt_objectForKey:@"recommendType"];
        _following = [params tt_objectForKey:@"follow"];
        _clickArea = [params tt_objectForKey:@"clickArea"];
        if ([_extraTracks tt_objectForKey:@"click_area"]){
            _clickArea = [_extraTracks tt_objectForKey:@"click_area"];
        }
        NSString *enterFrom = [_extraTracks objectForKey:@"enter_from"];
        if (enterFrom && [enterFrom hasPrefix:@"click_"]){
            _categoryID = [enterFrom stringByReplacingOccurrencesOfString:@"click_" withString:@""];
        }
        NSMutableDictionary *trackerDic = [NSMutableDictionary dictionary];
        [trackerDic setValue:_itemID forKey:@"value"];
        [trackerDic setValue:momentID forKey:@"ext_value"];
        [trackerDic setValue:_recommendReson forKey:@"recommend_reason"];
        [trackerDic setValue:_recommendType forKey:@"recommend_reason_type"];
        [trackerDic setValue:_following forKey:@"follow"];
        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [self trackEvent:@"go_detail" forLabel:enterFrom dict:trackerDic.copy containExtra:YES];
        }
        
        //log3.0 doubleSending
        NSMutableDictionary *logv3Dic = [NSMutableDictionary dictionaryWithCapacity:5];
        [logv3Dic setValue:_groupModel.groupID forKey:@"group_id"];
        [logv3Dic setValue:_itemID forKey:@"item_id"];
        [logv3Dic setValue:[NewsDetailLogicManager enterFromValueForLogV3WithClickLabel:enterFrom categoryID:_categoryID] forKey:@"enter_from"];
        [logv3Dic setValue:_categoryID forKey:@"category_name"];
        
        [logv3Dic setValue:momentID forKey:@"moment_id"];
        [logv3Dic setValue:_recommendReson forKey:@"recommend_reason"];
        [logv3Dic setValue:_recommendType forKey:@"recommend_reason_type"];
        [logv3Dic setValue:_following forKey:@"follow"];
        //log_pb
        NSDictionary *logPbDict = nil;
        NSString *logPbString = [params tt_stringValueForKey:@"log_pb"];
        if (!isEmptyString(logPbString)) {
            NSError *parseError = nil;
            logPbDict = [NSJSONSerialization JSONObjectWithData:[logPbString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
            if (!parseError) {
                [logv3Dic setValue:logPbDict forKey:@"log_pb"];
            }
        }

        [TTTrackerWrapper eventV3:@"go_detail" params:logv3Dic isDoubleSending:YES];
    }
    return self;
}

- (id)initWithMomentID:(NSString *)momentID
{
    if (isEmptyString(momentID)) {
        return nil;
    }
    ArticleMomentModel * model = [[ArticleMomentModel alloc] initWithDictionary:@{@"id":momentID}];
    self = [self initWithMomentModel:model];
    if (self) {
        
    }
    return self;
}

- (id)initWithComment:(id<TTCommentModelProtocol>)commentModel
           groupModel:(TTGroupModel *)groupModel
          momentModel:(ArticleMomentModel *)momentModel
             delegate:(id<ExploreMomentListCellUserActionItemDelegate>)delegate
     showWriteComment:(BOOL)show
{
    self = [super init];
    if (self) {
        _commentModel = commentModel;
        _groupModel = groupModel;
        _showWriteComment = show;
        //此处在MRC环境下必须使用self.
        self.momentModel = momentModel;
        _sourceType = ArticleMomentSourceTypeArticleDetail;
        _delegate = delegate;
    }
    return self;
}

- (id)initWithMomentModel:(ArticleMomentModel *)momentModel momentManager:(ArticleMomentManager *)momentManager
{
    self = [self initWithMomentModel:momentModel momentManager:momentManager sourceType:ArticleMomentSourceTypeNotAssign];
    if (self) {
        
    }
    return self;
}



- (id)initWithMomentModel:(ArticleMomentModel *)momentModel momentManager:(ArticleMomentManager *)momentManager sourceType:(ArticleMomentSourceType)sourceType
{
    self = [super init];
    if (self) {
        self.sourceType = sourceType;
        self.momentModel = momentModel;
        self.momentManager = momentManager;
    }
    return self;
}

- (id)initWithMomentModel:(ArticleMomentModel *)momentModel
{
    self = [super init];
    if (self) {
        self.momentModel = momentModel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.sourceType == ArticleMomentSourceTypeArticleDetail) {
        [self.momentModel setDigged:self.commentModel.userDigged];
        self.detailView = [[ArticleMomentDetailView alloc] initWithFrame:self.view.bounds
                                                                commentId:[self.commentModel.commentID longLongValue]
                                                              momentModel:self.momentModel
                                                                 delegate:self.delegate
                                                        showWriteComment:_showWriteComment];
    }
    else {
        self.detailView = [[ArticleMomentDetailView alloc] initWithFrame:self.view.bounds
                                                              momentModel:_momentModel
                                                     articleMomentManager:_momentManager
                                                               sourceType:_sourceType
                                                          replyMomentCommentModel:self.replyMomentCommentModel
                                                            showWriteComment:_showWriteComment];
    }
    self.detailView.groupModel = self.groupModel;
    self.detailView.fromThread = self.fromThread;
    self.detailView.showComment = self.showComment;
    self.detailView.categoryID = self.categoryID;
    self.detailView.extraTrackDict = self.extraTracks;
    self.detailView.enterFromClickComment = self.enterFromClickComment;
    _detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_detailView];
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(@"详情", nil)];
    TTAlphaThemedButton * moreButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    [moreButton setImage:[UIImage themedImageNamed:@"new_more_titlebar.png"] forState:UIControlStateNormal];
    [moreButton sizeToFit];
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        [moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -2)];
    }
    else {
        [moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -4)];
    }
    [moreButton addTarget:self action:@selector(arrowButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    
    //只有U11和微头条详情页才开启 stay_page
    if (_sourceType == ArticleMomentSourceTypeFeed || (_sourceType == ArticleMomentSourceTypeMomentDetail && [TTTabBarProvider isWeitoutiaoOnTabBar])) {
        self.ttTrackStayEnable = YES;
    }
}

- (void)arrowButtonClicked{
    wrapperTrackEvent(@"update_detail", @"title_bar_more_click");
    [[self.detailView getDetailViewHeaderItem] arrowButtonClicked];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_detailView didAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self p_syncCommentModelWithMomentModel];
    [_detailView willDisappear];
    [self trySendCurrentPageStayTime];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)p_syncCommentModelWithMomentModel {
    self.commentModel.userDigged = self.commentModel.userDigged || self.detailView.momentModel.digged;
    self.commentModel.digCount = @(MAX([self.commentModel.digCount intValue], self.detailView.momentModel.diggsCount));
    self.commentModel.replyCount = @(self.detailView.momentModel.commentsCount);
    
}
#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground
{
    [self trySendCurrentPageStayTime];
}

- (void)trackStartedByAppWillEnterForground
{
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)trySendCurrentPageStayTime
{
    if (self.ttTrackStartTime == 0) {//当前页面没有在展示过
        return;
    }
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration <= 200) {//低于200毫秒，忽略
        self.ttTrackStartTime = 0;
        [self tt_resetStayTime];
        return;
    }
    
    [self _sendCurrentPageStayTime:duration];
    
    self.ttTrackStartTime = 0;
    [self tt_resetStayTime];
}

- (void)_sendCurrentPageStayTime:(NSTimeInterval)duration
{
    if (self.sourceType == ArticleMomentSourceTypeMomentDetail && [TTTabBarProvider isWeitoutiaoOnTabBar]) {
        NSMutableDictionary *stayPageDict = [[NSMutableDictionary alloc] init];
        [stayPageDict setValue:@"umeng" forKey:@"category"];
        [stayPageDict setValue:@"stay_page" forKey:@"tag"];
        [stayPageDict setValue:@"micronews_detail" forKey:@"label"];
        [stayPageDict setValue:self.detailView.momentModel.ID forKey:@"item_id"];
        [stayPageDict setValue:self.detailView.momentModel.group.ID forKey:@"value"];
        [stayPageDict setValue:@"micronews" forKey:@"page_type"];
        [stayPageDict setValue:@"micronews_list" forKey:@"refer"];
        [stayPageDict setValue:@"micronews_post" forKey:@"group_type"];
        [stayPageDict setValue:@(duration/1000.0) forKey:@"ext_value"];
        [TTTrackerWrapper eventData:stayPageDict];
    }
    else {
        NSMutableDictionary * trackerDic = [NSMutableDictionary dictionary];
        [trackerDic setValue:_itemID forKey:@"value"];
        [trackerDic setValue:@(duration/1000.0) forKey:@"ext_value"];
        [self trackEvent:@"stay_page"
                forLabel:[_extraTracks objectForKey:@"enter_from"]
                    dict:trackerDic.copy
            containExtra:YES];
    }
}

#pragma mark - Tracker

- (void)trackEvent:(NSString *)event forLabel:(NSString *)label dict:(NSDictionary *)dict containExtra:(BOOL)contain {
    if (isEmptyString(event) || isEmptyString(label)) {
        return;
    }
    
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    if (contain && self.extraTracks.count > 0) {
        //加入统计透传字段
        [dictionary addEntriesFromDictionary:self.extraTracks];
    }
    if ([dict count] > 0) {
        [dictionary addEntriesFromDictionary:dict];
    }
    [dictionary setValue:@"umeng" forKey:@"category"];
    [dictionary setValue:event forKey:@"tag"];
    [dictionary setValue:label forKey:@"label"];
    [dictionary setValue:_itemID forKey:@"item_id"];
    [dictionary setValue:@(_gtype) forKey:@"gtype"];
    [dictionary setValue:_clickArea forKey:@"click_area"];
    [TTTrackerWrapper eventData:dictionary];
}

@end
