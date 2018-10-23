//
//  WDWendaListViewController.m
//  Article
//
//  Created by ZhangLeonardo on 15/12/10.
//
//

#import "WDWendaListViewController.h"
#import "WDWendaListViewController+TableViewCategory.h"
#import "WDWendaListFooterView.h"
#import "WDWendaMoreListViewController.h"
#import "WDWendaListTabView.h"
#import "WDQuestionFoldReasonEntity.h"
#import "WDMonitorManager.h"
#import "WDFontDefines.h"
#import "WDListViewModel.h"
#import "WDListViewModel+ShareCategory.h"
#import "WDWendaListQuestionHeader.h"
#import "WDWendaListQuestionHeaderNew.h"
#import "WDParseHelper.h"
#import "WDSettingHelper.h"
#import "WDWendaFirstWritterPopupView.h"
#import "WDCommonLogic.h"
#import "WDShareUtilsHelper.h"
#import "WDDefines.h"

#import "TTActionSheetController.h"
#import "SSWebViewBackButtonView.h"
#import "TTGroupModel.h"
#import "NSObject+FBKVOController.h"
#import "SSThemed.h"
#import "TTNavigationController.h"
#import "TTStringHelper.h"
#import "UIButton+TTAdditions.h"
#import "TTThemedAlertController.h"
#import "TTViewWrapper.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTRoute.h"
#import <TTShareManager.h>
#import <TTShareActivity.h>
#import "UIViewController+Refresh_ErrorHandler.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "TTIndicatorView.h"
#import "SSNavigationBar.h"
#import <TTInteractExitHelper.h>
#import <TTRoute/TTRoute.h>
#import "WDListCellLayoutModel.h"
#import "WDListCellViewModel.h"
#import "WDListCellDataModel.h"
#import <TTImpression/TTRelevantDurationTracker.h>
#import <TTVideoService/TTFFantasyTracker.h>

#define kListBottomBarHeight (self.view.tt_safeAreaInsets.bottom ? self.view.tt_safeAreaInsets.bottom + 44 : 44)

static NSString * const WukongListTipsHasShown = @"kWukongListTipsHasShown";

@interface WDWendaListViewController ()<UIViewControllerErrorHandler, WDWendaFirstWritterPopupViewDelegate, UIActionSheetDelegate, TTShareManagerDelegate,TTInteractExitProtocol>

@property (nonatomic, strong) TTViewWrapper *wrapperView;

@property (nonatomic, strong) WDWendaListQuestionHeader <WDWendaListQuestionHeaderProtocol>*questionHeaderA;
@property (nonatomic, strong) WDWendaListQuestionHeaderNew <WDWendaListQuestionHeaderProtocol>*questionHeaderB;

@property (nonatomic, strong) WDWendaListFooterView *listFooterView;
@property (nonatomic, strong) WDWendaListTabView *bottomTabView;

@property (nonatomic, strong) SSThemedView *topBgView; // 顶部白色背景条

@property (nonatomic, strong) TTActionSheetController  *actionSheetController;
@property (nonatomic, strong) DetailActionRequestManager *actionManager;
@property (nonatomic, strong) TTShareManager *shareManager;

@property (nonatomic, assign) BOOL isViewAppear;//用于记录声明周期函数如viewDidAppear等
@property (nonatomic, assign) BOOL hasAddsubviews; // 是否增加了子视图

@property (nonatomic, assign) BOOL notFirstShow;

@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSMutableArray *readAnswerArray;

@property (nonatomic, assign) CGFloat lastStatusBarHeight;

@property (nonatomic, strong) NSMutableDictionary *layoutModelDict;
@property (nonatomic, copy) NSString *rid;

@end

@implementation WDWendaListViewController

+ (void)load
{
    RegisterRouteObjWithEntryName(@"wenda_list");
}

- (void)dealloc
{
    _answerListView.delegate = nil;
    _answerListView.dataSource = nil;
    [self _unregist];
    [self sendTrackWithLabel:@"back"];
    if (self.viewModel.questionEntity == nil) {
        [self sendTrackWithLabel:@"back_no_content"];
    }
    
    if (!isEmptyString(_rid)) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        if (!SSIsEmptyDictionary(self.viewModel.gdExtJson)) {
            [dict setValuesForKeysWithDictionary:self.viewModel.gdExtJson];
        }
        [dict setValue:_rid forKey:@"rule_id"];
        [dict setValue:self.viewModel.qID forKey:@"group_id"];
        [dict setValue:@"wenda_question" forKey:@"message_type"];
        [TTTracker eventV3:@"push_page_back_to_feed" params:[dict copy]];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    NSString * qid = [paramObj.allParams objectForKey:kWendaListQID];
    if ([qid longLongValue] != 0) {//容错， 防止服务端把类型传错
        qid = [NSString stringWithFormat:@"%@", qid];
    }
    if (isEmptyString(qid)) {//容错处理，防止服务端吧qid传成id
        qid = [paramObj.allParams objectForKey:@"id"];
        if ([qid longLongValue] != 0) {//容错， 防止服务端把类型传错
            qid = [NSString stringWithFormat:@"%@", qid];
        }
    }
    
    self.adjustPosition = ([[paramObj.allParams objectForKey:@"isLargeVideo"] boolValue] && [[paramObj.allParams objectForKey:@"video_auto_play"] boolValue]);
    NSDictionary *apiParam = [WDParseHelper apiParamFromBaseCondition:paramObj.allParams];
    NSDictionary *extraDicts = [WDParseHelper gdExtJsonFromBaseCondition:paramObj.allParams];
    BOOL needReturn = [[paramObj.userInfo.extra tt_stringValueForKey:kWDListNeedReturnKey] boolValue];
    NSString *rid = [paramObj.allParams tt_stringValueForKey:@"rid"];
    self = [self initWithQuestionID:qid
                      baseCondition:extraDicts
                       apiParameter:apiParam
                         needReturn:needReturn
                                rid:rid];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithQuestionID:(NSString *)qID
                     baseCondition:(NSDictionary *)baseCondition
                      apiParameter:(NSDictionary *)apiParameter
                        needReturn:(BOOL)needReturn
{
    return [self initWithQuestionID:qID baseCondition:baseCondition apiParameter:apiParameter needReturn:needReturn rid:nil];
}

- (instancetype)initWithQuestionID:(NSString *)qID
                     baseCondition:(NSDictionary *)baseCondition
                      apiParameter:(NSDictionary *)apiParameter
                        needReturn:(BOOL)needReturn
                               rid:(NSString *)rid
{
    self = [super init];
    if (self) {
        self.viewModel = [[WDListViewModel alloc] initWithQid:qID gdExtJson:baseCondition apiParameter:apiParameter needReturn:needReturn];
        _readAnswerArray = @[].mutableCopy;
        _rid = [rid copy];

        WeakSelf;
        self.viewModel.editBlock = ^(void){
            StrongSelf;
            [self enterModifyPage];
        };
        self.viewModel.deleteBlock = ^(void) {
            StrongSelf;
            [self deleteQuestion];
        };
        self.viewModel.closeBlock = ^{
            StrongSelf;
            [self.navigationController popViewControllerAnimated:YES];
        };

        self.layoutModelDict = [NSMutableDictionary dictionary];
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.viewModel.gdExtJson];
//        [dict setValue:@"enter" forKey:@"label"];
//        [dict setValue:self.viewModel.qID forKey:@"value"];
        [self sendTrackWithDict:dict];
        
        //go detail
        NSMutableDictionary * goDetailDict = [NSMutableDictionary dictionaryWithDictionary:self.viewModel.gdExtJson];
//        [goDetailDict setValue:@"go_detail" forKey:@"tag"];
//        [goDetailDict setValue:[self enterFrom] forKey:@"label"];
//        [goDetailDict setValue:self.viewModel.qID forKey:@"value"];
//        [goDetailDict setValue:@"umeng" forKey:@"category"];

//        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
//            [TTTrackerWrapper eventData:goDetailDict];
//        }
        

        //Wenda_V3_DoubleSending
        NSMutableDictionary *v3Dic = [NSMutableDictionary dictionaryWithDictionary:baseCondition];
        
        [v3Dic setValue:@"question" forKey:@"page_type"];
        [v3Dic setValue:@"house_app2c_v2" forKey:@"event_type"];
        
        if ([v3Dic[@"parent_enterfrom"] isEqualToString:@""]) {
            [v3Dic setValue:@"be_null" forKey:@"parent_enterfrom"];
        }
        if ([v3Dic[@"from_gid"] isEqualToString:@""]) {
            [v3Dic setValue:@"be_null" forKey:@"from_gid"];
        }
        if ([v3Dic[@"enterfrom_answerid"] isEqualToString:@""]) {
            [v3Dic setValue:@"be_null" forKey:@"enterfrom_answerid"];
        }
        
        [v3Dic removeObjectForKey:@"origin_source"];
        [v3Dic removeObjectForKey:@"author_id"];
        [v3Dic removeObjectForKey:@"article_type"];
        [v3Dic removeObjectForKey:@"pct"];
        [v3Dic setValue:self.viewModel.qID forKey:@"group_id"];
        [TTTracker eventV3:@"go_detail" params:v3Dic isDoubleSending:NO];

        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChanged) name:kSettingFontSizeChangedNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(statusbarFrameDidChangeNotification)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidBecomeActiveNotification)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        NSString *ansid = [self.viewModel.gdExtJson objectForKey:@"ansid"];
        if (!isEmptyString(ansid)) {
            [TTFFantasyTracker sharedInstance].lastGid = ansid;
        }
        else if (!isEmptyString(self.viewModel.qID)) {
            [TTFFantasyTracker sharedInstance].lastGid = self.viewModel.qID;
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isViewAppear = YES;
    [self _willAppear];
    [_answerListView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.lastStatusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isViewAppear = NO;
    [self _willDisappear];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kExploreNeedStopAllMovieViewPlaybackNotification"
                                                        object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self sendReadPct];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([TTDeviceHelper isPadDevice]) {
        
        if (!_answerListView) return;
        
        [self layoutSubviewFrame];
    
        [self.questionHeader reload];

        [self reloadListView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _regist];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //导航
    SSWebViewBackButtonView *backButtonView = [[SSWebViewBackButtonView alloc] init];
    [backButtonView showCloseButton:NO];
    [backButtonView.backButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];

    UIBarButtonItem *moreButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self moreButton]];
    self.navigationItem.rightBarButtonItems = @[moreButtonItem];
 
    [self firstLoadContent];
    [self reloadThemeUI];
}

- (void)addSubviewsIfNeeded {

    if (self.hasAddsubviews)
        return;
    
    self.hasAddsubviews = YES;
    
    if ([TTDeviceHelper isPadDevice]) {
        self.wrapperView = [[TTViewWrapper alloc] initWithFrame:self.view.bounds];
        self.wrapperView.height = self.view.bounds.size.height - 44;
        
        [self.wrapperView addSubview:[self centerBgView]];
        [self.wrapperView addSubview:self.topBgView];
        [self.wrapperView addSubview:self.answerListView];
        
        self.wrapperView.targetView = self.answerListView;
        [self.view addSubview:self.wrapperView];
    } else {
        [self.view addSubview:self.topBgView];
        [self.view addSubview:self.answerListView];
    }
    
//    //底部tab
//    [self.view addSubview:self.bottomTabView];
    
    //监听变化
    WeakSelf;
    [self.KVOController observe:self.questionHeader keyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        CGRect newFrame = [change[@"new"] CGRectValue];
        CGRect oldFrame = [change[@"old"] CGRectValue];
        if (newFrame.size.height != oldFrame.size.height) {
            CGFloat offsetY = self.answerListView.contentOffset.y;
            self.answerListView.tableHeaderView = nil;
            self.answerListView.tableHeaderView = self.questionHeader;
            [self.answerListView setContentOffset:CGPointMake(0, offsetY)];
        }
    }];}

- (void)firstLoadContent
{
    [self tt_startUpdate];
    [self.viewModel refresh];

    WeakSelf;
    [self.viewModel requestFinishBlock:^(NSError *error) {
        StrongSelf;

        self.error = error;

        [self tt_endUpdataData:NO error:error];
        
        if (error.code == TTNetworkErrorCodeSuccess) {
            
            // 此时再去加载子view
            [self addSubviewsIfNeeded];
            self.topBgView.hidden = NO;
            self.bottomTabView.hidden = NO;
            [self layoutSubviewFrame];
            if (self.wrapperView) {
                [self.view bringSubviewToFront:self.wrapperView];
            } else {
                [self.view bringSubviewToFront:self.answerListView];
            }
            [self.view bringSubviewToFront:self.bottomTabView];
            
            [self reloadListViewNeedRefreshHeader:YES];
            
            if ([self.viewModel.dataModelsArray count] == 0) {
                if (self.viewModel.questionEntity.normalAnsCount.longLongValue > 0) {
                    [self sendTrackWithLabel:@"enter_0_fold"];
                } else {
                    [self sendTrackWithLabel:@"enter_0"];
                }
            }
            //刷新底部tab按钮数据
//            [self.bottomTabView refresh];
        } else {
            if (error.code == 67686) {
                self.ttErrorView.viewType = TTFullScreenErrorViewTypeDeleted;
                self.navigationItem.rightBarButtonItems = nil;
            }
            [self sendTrackWithLabel:@"enter_api_fail"];
        }
        
//        [self buildTitleView];
    }];
}

- (void)_loadMore
{
    if (![self.viewModel hasMore]) {
        return;
    }
    if ([self.viewModel isLoading]) {
        return;
    }
    [self sendTrackWithLabel:@"loadmore"];
    WeakSelf;
    [self.viewModel loadMoreFinishBlock:^(NSError *error) {
        StrongSelf;
        if (error.code != TTNetworkErrorCodeSuccess) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"加载失败" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
        [self reloadListViewNeedRefreshHeader:NO];
    }];
}

- (void)_enterMoreListController
{
    [self sendTrackWithLabel:@"fold"];
    NSMutableDictionary *gdExtJson = [self.viewModel.gdExtJson mutableCopy];
    NSDictionary *apiParam = [WDParseHelper routeJsonWithOriginJson:self.viewModel.apiParameter source:kWDWendaListViewControllerUMEventName];
    WDWendaMoreListViewController *controller = [[WDWendaMoreListViewController alloc] initWithQuestionID:self.viewModel.qID baseCondition:[gdExtJson copy] apiParameter:apiParam];
    [self.navigationController pushViewController:controller animated:YES];
    self.viewModel.questionEntity.answerIDS = [self.viewModel answerIDArray];
}

- (void)enterModifyPage
{
    
}

- (void)deleteQuestion
{

}

- (void)reloadListViewNeedRefreshHeader:(BOOL)need
{
    if (!_answerListView) return;
    
    if (need) {
        self.questionHeader.hidden = NO;
        [self.questionHeader reload];
        [self.questionHeader refreshLayout];
    }

    [self reloadListView];
    
//    if (!_adjustPosition && ![TTDeviceHelper isPadDevice] && !self.viewModel.canEditTags && (self.viewModel.hasTags && self.answerListView.contentOffset.y == 0) && (self.viewModel.questionRelatedStatus == WDQuestionRelatedStatusNormal) && !self.viewModel.showRewardView) {
//        [self.answerListView setContentOffset:CGPointMake(0, 35) animated:NO];
//    }
    
}

- (void)reloadListView
{
    [_answerListView reloadData];
    [self refreshFooterView];
}

- (void)refreshFooterView
{
    if ([self.viewModel hasMore]) {
        _answerListView.tableFooterView = nil;
    }
    else {
        //是否替换为引导回答界面
        if (_needShowEmptyView) {
            if (!_listFooterView) {
                self.listFooterView = [[WDWendaListFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kWDWendaListNoAnswerFooterViewHeight)];
                self.listFooterView.viewModel = self.viewModel;
            }
            self.listFooterView.height = kWDWendaListNoAnswerFooterViewHeight;
            _answerListView.tableFooterView = self.listFooterView;
            [self.listFooterView setTitle:@"暂无回答" isShowArrow:NO isNoAnswers:YES isNew:YES clickedBlock:nil];
        }
        else if (_needShowFoldView && [self isFoldTipViewDataAvailable]) {
            if (!_listFooterView) {
                self.listFooterView = [[WDWendaListFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kWDWendaListFooterViewHeight)];
                self.listFooterView.viewModel = self.viewModel;
            }
            self.listFooterView.height = kWDWendaListFooterViewHeight;
            _answerListView.tableFooterView = self.listFooterView;
            WeakSelf;
            [self.listFooterView setTitle:[NSString stringWithFormat:@"%@",self.viewModel.moreListAnswersTitle] isShowArrow:YES isNoAnswers:NO clickedBlock:^{
                StrongSelf;
                [self _enterMoreListController];
            }];
        }
        else {
            _answerListView.tableFooterView = nil;
        }
    }
}

- (BOOL)isFoldTipViewDataAvailable
{
    return !isEmptyString(self.viewModel.questionEntity.foldReasonEntity.title) &&
    !isEmptyString(self.viewModel.questionEntity.foldReasonEntity.openURL);
}

- (void)locateIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row <= self.viewModel.dataModelsArray.count) {
        [self.answerListView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)addReadAnswerID:(NSString *)answerID
{
    if (![self.readAnswerArray containsObject:answerID]) {
        [self.readAnswerArray addObject:answerID];
    }
}

- (void)layoutSubviewFrame
{
    self.topBgView.frame = [self p_frameForTopBgView];
    
    //需要及时根据参数更新位置
    CGRect frame = [self p_frameForListView];
    CGFloat bottomHeight = 0;
    frame.size.height -= bottomHeight;
    self.answerListView.frame = frame;
    
    frame.origin.y = frame.size.height + kNavigationBarHeight;
    frame.size.height = bottomHeight;
    self.bottomTabView.frame = frame;
}

- (WDListCellLayoutModel *)getCellLayoutModelFromDataModel:(WDListCellDataModel *)dataModel {
    NSString *key = [NSString stringWithFormat:@"%@",dataModel.uniqueId];
    WDListCellLayoutModel *layoutModel = [self.layoutModelDict objectForKey:key];
    if (layoutModel) {
        return layoutModel;
    }
    layoutModel = [[WDListCellLayoutModel alloc] initWithDataModel:dataModel];
    if (isEmptyString(dataModel.answerEntity.questionTitle)) {
        dataModel.answerEntity.questionTitle = self.viewModel.questionEntity.title;
    }
    [self.layoutModelDict setObject:layoutModel forKey:key];
    return layoutModel;
}

#pragma mark - Private

- (void)sendReadPct
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.viewModel.gdExtJson];
    NSInteger percent = 0;
    NSInteger pageCount = 0;
    if (self.listViewHasScroll) {
        NSInteger maxNumber = (self.viewModel.dataModelsArray.count < 5) ? self.viewModel.dataModelsArray.count : 5;
        if (maxNumber > 0) {
            percent = self.readAnswerArray.count * 100 / maxNumber ;
            pageCount = ceil(self.readAnswerArray.count / 2.0f);
        }
    }
    if (percent < 0.0f) {
        percent = 0.0f;
    }
    if (percent > 100.0f) {
        percent = 100.0f;
    }
    
    [dict setValue:@(percent) forKey:@"pct"];
    [dict setValue:@(pageCount) forKey:@"page_count"];
    if ([dict objectForKey:@"ansid"]) {
        [dict setValue:[dict objectForKey:@"ansid"] forKey:@"group_id"];
    } else {
        [dict setValue:self.viewModel.qID forKey:@"group_id"];
    }
    
    [dict setValue:[self.viewModel.gdExtJson objectForKey:@"category_name"] forKey:@"category_name"];
    dict[@"event_type"] = @"house_app2c_v2";

    [TTTracker eventV3:@"read_pct" params:[dict copy]];
}

#pragma mark frame

- (CGRect)p_frameForListView
{
    if ([TTDeviceHelper isPadDevice]) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        return CGRectMake(edgePadding, kNavigationBarHeight, windowSize.width - edgePadding*2, windowSize.height - kNavigationBarHeight);
    }
    else {
        CGRect rect = CGRectMake(0, kNavigationBarHeight, SSWidth(self.view), SSHeight(self.view) - kNavigationBarHeight);
        return rect;
    }
}

- (CGRect)p_frameForTopBgView {
    if ([TTDeviceHelper isPadDevice]) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        return CGRectMake(edgePadding, kNavigationBarHeight, windowSize.width - edgePadding*2, 0);
    }
    else {
        return CGRectMake(0, kNavigationBarHeight, [UIScreen mainScreen].bounds.size.width, 0);
    }
}

#pragma mark - Notification

- (void)fontChanged
{
    for (WDListCellLayoutModel *layoutModel in self.layoutModelDict.allValues) {
        [layoutModel setNeedReCalculateLayout];
    }
    [self reloadListViewNeedRefreshHeader:NO];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground3);
}

- (void)statusbarFrameDidChangeNotification {
    [self refreshSubViewFrameIfNeeded];
}

- (void)appDidBecomeActiveNotification {
    [self refreshSubViewFrameIfNeeded];
}

- (void)refreshSubViewFrameIfNeeded {
    CGFloat newStatusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    if (newStatusBarHeight == 0) return;
    if (self.lastStatusBarHeight != newStatusBarHeight) {
        self.lastStatusBarHeight = newStatusBarHeight;
        
        CGRect frame = [self p_frameForListView];
        CGFloat bottomHeight = kListBottomBarHeight;
        frame.size.height -= bottomHeight;
        self.answerListView.frame = frame;
        
        frame.origin.y = frame.size.height + kNavigationBarHeight;
        frame.size.height = bottomHeight;
        self.bottomTabView.frame = frame;
    }
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData
{
    return NO;
//    if (self.error && self.error.code == kCFURLErrorNotConnectedToInternet) {
//        return NO;
//    } else {
//        return YES;
//    }
}

- (void)refreshData
{
    [self firstLoadContent];
}

- (void)emptyViewBtnAction
{
    [self firstLoadContent];
}

- (void)handleError:(NSError *)error
{
     [self firstLoadContent];
}

#pragma mark - action & response

- (void)buildTitleView
{
    SSThemedImageView *imageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
    imageView.imageName = @"wukonglogo_ask_bar";
    [imageView sizeToFit];
    self.navigationItem.titleView = imageView;
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleViewTaped:)]];
}

- (void)titleViewTaped:(UITapGestureRecognizer *)gesture
{
    NSString *urlString = [WDCommonLogic wukongURL];
    if (!isEmptyString(urlString) && [NSURL URLWithString:urlString]) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:urlString] userInfo:nil];
    }
}

- (void)moreButtonPressed
{
    if (self.viewModel.questionEntity.shareData == nil) {
        return;
    }

    NSMutableArray *contentItems = @[].mutableCopy;
    [contentItems addObject:[self.viewModel wd_shareItems]];
    [contentItems addObject:[self.viewModel wd_customItems]];
    [self.shareManager displayActivitySheetWithContent:[contentItems copy]];
    
    [self sendTrackWithLabel:@"share_button"];
}

#pragma mark - TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{

    NSString *label = [WDShareUtilsHelper labelNameForShareActivity:activity];
    NSMutableDictionary *dict = [self.viewModel.gdExtJson mutableCopy];
//    [dict setValue:self.viewModel.questionEntity.qid forKey:@"source"];
    [WDListViewModel trackEvent:kWDWendaListViewControllerUMEventName label:label gdExtJson:[dict copy]];
    
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.viewModel.qID];
    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = groupModel;
    context.mediaID = self.viewModel.qID;
    [self.actionManager setContext:context];
    DetailActionRequestType requestType = [WDShareUtilsHelper requestTypeForShareActivityType:activity];
    [self.actionManager startItemActionByType:requestType];
    NSString *media_id = self.viewModel.qID;
    if (self.viewModel.gdExtJson && [self.viewModel.gdExtJson objectForKey:@"ansid"]) {
        media_id = [self.viewModel.gdExtJson objectForKey:@"ansid"];
    }
//    dict[@"source"] = nil;
    dict[@"parent_enterfrom"] = nil;
    dict[@"from_gid"] = nil;
    dict[@"enterfrom_answerid"] = nil;
    dict[@"author_id"] = nil;
    dict[@"article_type"] = nil;
    dict[@"event_type"] = @"house_app2c_v2";
    [dict setValue:media_id forKey:@"ansid"];
    [dict setValue:media_id forKey:@"qid"];
    [dict setValue:self.viewModel.qID forKey:@"group_id"];
//    [dict setValue:self.viewModel.questionEntity.qid forKey:@"source"];
    [dict setValue:@"detail" forKey:@"position"];
    dict[@"category_name"] = [self.viewModel.gdExtJson objectForKey:@"category_name"];
//    [dict setValue:self.ansEntity.ansid forKey:@"group_id"];
    dict[@"enter_from"] = [self enterFrom];

    [dict setValue:[[self class] sharePlatformByRequestType: requestType] forKey:@"share_platform"];
    [TTTracker eventV3:@"rt_share_to_platform" params:[dict copy]];


}

+ (NSString*)sharePlatformByRequestType:(DetailActionRequestType)requestType {
    switch (requestType) {
        case DetailActionTypeWeixinShare:
            return @"weixin_moments";
            break;
        case DetailActionTypeWeixinFriendShare:
            return @"weixin";
            break;
        case DetailActionTypeQQShare:
            return @"qq";
            break;
        case DetailActionTypeQQZoneShare:
            return @"qzone";
            break;
        default:
            return @"be_null";
    }
    return @"be_null";
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc
{
    NSString *label = [WDShareUtilsHelper labelNameForShareActivity:activity shareState:(error ? NO : YES)];
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    NSString *media_id = self.viewModel.qID;
    if (self.viewModel.gdExtJson && [self.viewModel.gdExtJson objectForKey:@"ansid"]) {
        media_id = [self.viewModel.gdExtJson objectForKey:@"ansid"];
    }
    [extraDict setValue:media_id forKey:@"media_id"];
    ttTrackEventWithCustomKeys(kWDWendaListViewControllerUMEventName, label, self.viewModel.qID, nil, extraDict);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = -scrollView.contentOffset.y;
    if (offsetY <= 0) {
        offsetY = 0;
    }
    self.topBgView.height = offsetY;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"删除问题"]) {
        WeakSelf;
        [self.viewModel deleteQuestionWithFinishBlock:^(NSString *tips, NSError *error) {
            StrongSelf;
            if (!error) {
                [self dismissSelf];
            } else {
                [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(tips, nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
            }
        }];
    }
}

#pragma mark -- event

- (NSString *)enterFrom
{
    //go detail
    NSString * enterFrom = [self.viewModel.gdExtJson objectForKey:kWDEnterFromKey];
    if (isEmptyString(enterFrom)) {
        enterFrom = @"unknown";
    }
    return enterFrom;
}

- (void)sendTrackWithLabel:(NSString *)label
{
    [WDListViewModel trackEvent:kWDWendaListViewControllerUMEventName label:label gdExtJson:self.viewModel.gdExtJson];
}

- (void)sendTrackWithDict:(NSDictionary *)dictInfo
{
    if (![dictInfo isKindOfClass:[NSDictionary class]] ||
        [dictInfo count] == 0) {
        return;
    }
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:dictInfo];
    [dict setValue:kWDWendaListViewControllerUMEventName forKey:@"tag"];
    [dict setValue:@"umeng" forKey:@"category"];
    [TTTracker eventData:dict];
}

#pragma mark -- stay page

- (void)_sendCurrentPageStayTime:(NSTimeInterval)duration
{
    NSTimeInterval errorStayTime = [[WDSettingHelper sharedInstance_tt]
                                    pageStayErrorTime];
    
    if (duration > 200 && duration < errorStayTime * 1000.0) {
        
        //stay_page
        NSMutableDictionary *stayPageDict = [self.viewModel.gdExtJson mutableCopy];
        stayPageDict[@"category"] = @"umeng";
        stayPageDict[@"tag"] = @"stay_page";
        stayPageDict[@"label"] = [self enterFrom];
        stayPageDict[@"value"] = self.viewModel.qID;
        stayPageDict[@"ext_value"] = @((NSInteger)duration);

        if (![TTTrackerWrapper isOnlyV3SendingEnable]) {
            [TTTrackerWrapper eventData:stayPageDict];
        }
        //Wenda_V3_DoubleSending
        NSMutableDictionary *v3Dic = [NSMutableDictionary dictionaryWithDictionary:self.viewModel.gdExtJson];
        [v3Dic setValue:self.viewModel.qID forKey:@"group_id"];
        [v3Dic setValue:@((NSInteger)duration) forKey:@"stay_time"];
        
        if ([[v3Dic tt_stringValueForKey:@"enter_from"] isEqualToString:@"click_apn"]) {
            [v3Dic setValue:@"click_news_notify" forKey:@"enter_from"];
        }
        [v3Dic setValue:@"question" forKey:@"page_type"];

        if ([v3Dic[@"parent_enterfrom"] isEqualToString:@""]) {
            [v3Dic setValue:@"be_null" forKey:@"parent_enterfrom"];
        }
        if ([v3Dic[@"from_gid"] isEqualToString:@""]) {
            [v3Dic setValue:@"be_null" forKey:@"from_gid"];
        }
        if ([v3Dic[@"enterfrom_answerid"] isEqualToString:@""]) {
            [v3Dic setValue:@"be_null" forKey:@"enterfrom_answerid"];
        }
        [v3Dic setValue:@"house_app2c_v2" forKey:@"event_type"];
        
        [v3Dic removeObjectForKey:@"author_id"];

        [TTTracker eventV3:@"stay_page" params:v3Dic isDoubleSending:NO];
        
        NSString *groupId = self.viewModel.qID;
        NSString *ansId = [self.viewModel.gdExtJson objectForKey:@"ansid"];
        if (!isEmptyString(ansId)) {
            groupId = ansId;
        }
        [[TTRelevantDurationTracker sharedTracker] appendRelevantDurationWithGroupID:groupId itemID:groupId enterFrom:[self enterFrom] categoryName:[self.viewModel.gdExtJson objectForKey:@"category_name"] stayTime:duration logPb:[self.viewModel.gdExtJson objectForKey:@"log_pb"] answerID:ansId questionID:self.viewModel.qID enterFromAnswerID:nil parentEnterFrom:nil];
    }
    else {

        [[TTMonitor shareManager] trackService:WDListErrorPageStayService
                                         status:0
                                         extra:nil];
        
        
    }
}

#pragma mark -- showing util

- (BOOL)_isListShowing
{
    return _isViewAppear;
}

#pragma mark - getter

- (TTAlphaThemedButton *)moreButton
{
    TTAlphaThemedButton *moreButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    moreButton.imageName = @"new_more_titlebar.png";
    [moreButton sizeToFit];
    
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        [moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -2)];
    }
    else {
        [moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -4)];
    }
    [moreButton addTarget:self action:@selector(moreButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *dictSetting = [[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"];
    if ([dictSetting tt_boolValueForKey:@"f_wenda_share_enable"]){
        return moreButton;
    }else
    {
        return nil;
    }
}

- (SSThemedView<WDWendaListQuestionHeaderProtocol> *)questionHeader
{
    if (!_questionHeaderA) {
        _questionHeaderA = [[WDWendaListQuestionHeader alloc] initWithFrame:CGRectMake(0, 0, SSWidth(self.answerListView), 0) viewModel:self.viewModel];
        _questionHeaderA.hidden = YES;
    }
    return _questionHeaderA;
}

- (SSThemedTableView *)answerListView
{
    if (!_answerListView) {
        CGRect frame = [self p_frameForListView];
        _answerListView = [[SSThemedTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _answerListView.backgroundColor = [UIColor clearColor];
        _answerListView.delegate = self;
        _answerListView.dataSource = self;
        _answerListView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _answerListView.tableHeaderView = self.questionHeader;
        _answerListView.estimatedRowHeight = 0;
    }
    return _answerListView;
}

- (SSThemedView *)bottomTabView
{
    if (!_bottomTabView) {
        CGRect frame = [self p_frameForListView];
        CGFloat bottomHeight = kListBottomBarHeight;
        frame.origin.y = frame.size.height + kNavigationBarHeight - bottomHeight;
        frame.size.height = bottomHeight;
        _bottomTabView = [[WDWendaListTabView alloc] initWithFrame:frame viewModel:self.viewModel];
        _bottomTabView.backgroundColorThemeKey = kColorBackground4;
        _bottomTabView.hidden = YES;
    }
    
    return _bottomTabView;
}

- (SSThemedView *)centerBgView {
    CGSize windowSize = [TTUIResponderHelper windowSize];
    CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
    CGFloat bgWidth = windowSize.width - edgePadding*2;
    CGFloat bgLeft = edgePadding;
    SSThemedView *bgView = [[SSThemedView alloc] initWithFrame:CGRectMake(bgLeft, 0, bgWidth, self.view.bounds.size.height - 44)];
    bgView.backgroundColorThemeKey = kColorBackground3;
    return bgView;
}

- (SSThemedView *)topBgView {
    if (!_topBgView) {
        _topBgView = [[SSThemedView alloc] initWithFrame:[self p_frameForTopBgView]];
        _topBgView.backgroundColorThemeKey = kColorBackground4;
        _topBgView.hidden = YES;
    }
    return _topBgView;
}

- (DetailActionRequestManager *)actionManager
{
    if (!_actionManager) {
        _actionManager = [[DetailActionRequestManager alloc] init];
    }
    return _actionManager;
}

- (TTShareManager *)shareManager {
    if (!_shareManager) {
        _shareManager = [[TTShareManager alloc] init];
        _shareManager.delegate = self;
    }
    return _shareManager;
}

#pragma mark -- TTInteractExitProtocol

- (UIView *)suitableFinishBackView
{
    return _answerListView;
}

@end

