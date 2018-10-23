//
//  WDWendaMoreListViewController.m
//  Article
//
//  Created by ZhangLeonardo on 15/12/14.
//
//

#import "WDWendaMoreListViewController.h"
#import "WDWendaMoreListViewController+TableViewCategory.h"
#import "WDMoreListViewModel+ShareCategory.h"
#import "WDWendaMoreListHeaderView.h"
#import "WDQuestionFoldReasonEntity.h"
#import "WDParseHelper.h"
#import "WDCommonLogic.h"
#import "WDShareUtilsHelper.h"

#import "TTAlphaThemedButton.h"
#import "TTStringHelper.h"
#import "UIButton+TTAdditions.h"
#import "TTRoute.h"
#import <TTShareManager.h>

#import <TTUserSettings/TTUserSettingsManager+FontSettings.h>
#import "UIViewController+Refresh_ErrorHandler.h"
#import "SSNavigationBar.h"
#import "TTIndicatorView.h"
#import "TTViewWrapper.h"
#import "TTGroupModel.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"
#import "WDDefines.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "WDMoreListCellLayoutModel.h"
#import "WDMoreListCellViewModel.h"
#import "WDListCellDataModel.h"

extern NSString * const kWDWendaListViewControllerUMEventName;

@interface WDWendaMoreListViewController ()<UIViewControllerErrorHandler, TTShareManagerDelegate>
@property (nonatomic, strong) TTViewWrapper *wrapperView;

// add by zjing隐藏为什么折叠
//@property (nonatomic, strong) WDWendaMoreListHeaderView *listHeaderView;

@property (nonatomic, assign) BOOL isViewAppear;//用于记录声明周期函数如viewDidAppear等
@property (nonatomic, strong) DetailActionRequestManager * actionManager;
@property (nonatomic, strong) TTShareManager *shareManager;

@property (nonatomic, strong) NSMutableDictionary *layoutModelDict;

@end

@implementation WDWendaMoreListViewController

+ (void)load
{
    RegisterRouteObjWithEntryName(@"wenda_list_more");
}

- (void)dealloc
{
    [self _unregist];
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
    NSDictionary *apiParam = [WDParseHelper apiParamFromBaseCondition:paramObj.allParams];
    NSDictionary * extraDicts = [WDParseHelper gdExtJsonFromBaseCondition:paramObj.allParams];
    self = [self initWithQuestionID:qid
                      baseCondition:extraDicts
                       apiParameter:apiParam];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithQuestionID:(NSString *)qID
                     baseCondition:(NSDictionary *)baseCondition
                      apiParameter:(NSDictionary *)apiParameter
{
    self = [super init];
    if (self) {
        self.viewModel = [[WDMoreListViewModel alloc] initWithQid:qID gdExtJson:baseCondition apiParameter:apiParameter];
        self.layoutModelDict = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontChanged) name:kSettingFontSizeChangedNotification object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.answerListView reloadData];
    
    self.isViewAppear = YES;
    [self _willAppear];
    
    if (self.viewModel.questionEntity.normalAnsCount.longLongValue == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isViewAppear = NO;
    [self _willDisappear];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _regist];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:@"折叠回答"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self moreButton]];

    CGRect ansFrame = [self p_frameForDetailView];
    self.answerListView = [[SSThemedTableView alloc] initWithFrame:ansFrame style:UITableViewStylePlain];
    self.answerListView.backgroundColorThemeKey = kColorBackground3;
    self.answerListView.delegate = self;
    self.answerListView.dataSource = self;
//    self.answerListView.tableHeaderView = self.listHeaderView;
    self.answerListView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([TTDeviceHelper isPadDevice]) {
        self.wrapperView = [[TTViewWrapper alloc] initWithFrame:self.view.bounds];
        [self.wrapperView addSubview:self.answerListView];
        self.wrapperView.targetView = self.answerListView;
        [self.view addSubview:self.wrapperView];
    } else {
        [self.view addSubview:_answerListView];
    }
        
    [self tt_startUpdate];
    
    [self firstLoadData];
    [self reloadThemeUI];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([TTDeviceHelper isPadDevice]) {
        self.answerListView.frame = [self p_frameForDetailView];
        [self.answerListView reloadData];
    }
}

- (void)firstLoadData
{
    [self.viewModel refresh];
    WeakSelf;
    [self.viewModel requestFinishBlock:^(NSError *error) {
        StrongSelf;
        [self tt_endUpdataData:[self.viewModel.dataModelsArray count] > 0 error:error];
        if (error.code == TTNetworkErrorCodeSuccess) {
            [self firstLoadDataSuccess];
        }
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
    WeakSelf;
    [self.viewModel loadMoreFinishBlock:^(NSError *error) {
        StrongSelf;
        if (error.code != TTNetworkErrorCodeSuccess) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"加载失败" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
        [self reloadListView];
    }];
    
    [self sendTrackWithLabel:@"loadmore"];
}

- (void)firstLoadDataSuccess {
    [self reloadListView];
}

- (void)reloadListView
{
    [_answerListView reloadData];
}

- (WDMoreListCellLayoutModel *)getCellLayoutModelFromDataModel:(WDListCellDataModel *)dataModel {
    NSString *key = [NSString stringWithFormat:@"%@",dataModel.uniqueId];
    WDMoreListCellLayoutModel *layoutModel = [self.layoutModelDict objectForKey:key];
    if (layoutModel) {
        return layoutModel;
    }
    layoutModel = [[WDMoreListCellLayoutModel alloc] initWithDataModel:dataModel];
    if (isEmptyString(dataModel.answerEntity.questionTitle)) {
        dataModel.answerEntity.questionTitle = self.viewModel.questionEntity.title;
    }
    [self.layoutModelDict setObject:layoutModel forKey:key];
    return layoutModel;
}

#pragma mark - Notification

- (void)fontChanged
{
    for (WDMoreListCellLayoutModel *layoutModel in self.layoutModelDict.allValues) {
        [layoutModel setNeedReCalculateLayout];
    }
    [self reloadListView];
}

- (void)themeChanged:(NSNotification *)notification
{
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground3);
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData
{
    return [self.viewModel.dataModelsArray count] > 0;
}

- (void)refreshData
{
    [self firstLoadData];
}

- (void)sessionExpiredAction
{
}

#pragma mark - TTShareManagerDelegate

- (void)shareManager:(TTShareManager *)shareManager
         clickedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{
    if (isEmptyString(self.viewModel.qID)) {
        return;
    }
    
    NSString *label = [WDShareUtilsHelper labelNameForShareActivity:activity];
    NSMutableDictionary *dict = [self.viewModel.gdExtJson mutableCopy];
    [dict setValue:self.viewModel.qID forKey:@"source"];
    [TTTracker category:@"umeng" event:kWDWendaListViewControllerUMEventName label:label dict:[dict copy]];
    
    TTGroupModel *groupModel = [[TTGroupModel alloc] initWithGroupID:self.viewModel.qID];
    TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
    context.groupModel = groupModel;
    context.mediaID = self.viewModel.qID;
    [self.actionManager setContext:context];
    DetailActionRequestType requestType = [WDShareUtilsHelper requestTypeForShareActivityType:activity];
    [self.actionManager startItemActionByType:requestType];
}

- (void)shareManager:(TTShareManager *)shareManager
       completedWith:(id<TTActivityProtocol>)activity
          sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
               error:(NSError *)error
                desc:(NSString *)desc
{
    NSString *label = [WDShareUtilsHelper labelNameForShareActivity:activity shareState:(error ? NO : YES)];
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionary];
    [extraDict setValue:self.viewModel.qID forKey:@"media_id"];
    
    ttTrackEventWithCustomKeys(kWDWendaListViewControllerUMEventName, label, self.viewModel.qID, nil, extraDict);
}

#pragma mark frame

- (CGRect)p_frameForDetailView
{
    CGSize windowSize = [TTUIResponderHelper windowSize];
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        return CGRectMake(edgePadding, kNavigationBarHeight, windowSize.width - edgePadding*2, windowSize.height - kNavigationBarHeight);
    } else {
        CGRect rect = CGRectMake(0, kNavigationBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - kNavigationBarHeight);
        return rect;
        
    }
}

#pragma mark -- share

- (void)moreButtonPressed
{
    WDQuestionEntity * questionEntity = [self.viewModel questionEntity];
    if (questionEntity.shareData == nil) {
        return;
    }
    
    NSMutableArray *contentItems = @[].mutableCopy;
    [contentItems addObject:[self.viewModel wd_shareItems]];
    [contentItems addObject:[self.viewModel wd_customItems]];
    [self.shareManager displayActivitySheetWithContent:[contentItems copy]];
    
    [self sendTrackWithLabel:@"share_button"];
}

#pragma mark -- event

- (void)sendTrackWithLabel:(NSString *)label
{
    if (isEmptyString(label)) {
        return;
    }
    [TTTracker event:kWDWendaListViewControllerUMEventName label:label];
}

#pragma mark -- showing util

- (BOOL)_isListShowing
{
    return _isViewAppear;
}

#pragma mark - getter

//- (WDWendaMoreListHeaderView *)listHeaderView {
//    if (!_listHeaderView) {
//        _listHeaderView = [[WDWendaMoreListHeaderView alloc] initWithFrame:CGRectMake(0, 0, SSWidth(self.answerListView), kWDWendaMoreListHeaderViewHeight)];
//        typeof(self) __weak weakSelf = self;
//        [_listHeaderView setTitle:weakSelf.viewModel.questionEntity.foldReasonEntity.title clickedBlock:^{
//            NSURL *url = [TTStringHelper URLWithURLString:weakSelf.viewModel.questionEntity.foldReasonEntity.openURL];
//            [[TTRoute sharedRoute] openURLByViewController:url userInfo:nil];
//            [weakSelf sendTrackWithLabel:@"why"];
//        }];
//    }
//    return _listHeaderView;
//}

- (TTAlphaThemedButton *)moreButton
{
    TTAlphaThemedButton *moreButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    moreButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    moreButton.imageName = @"new_more_titlebar.png";
    [moreButton sizeToFit];
    
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        [moreButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -2)];
    } else {
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

@end
