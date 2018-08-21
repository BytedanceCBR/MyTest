//
//  TTHistoryViewController.m
//  Article
//
//  Created by fengyadong on 16/11/22.
//
//

#import "TTHistoryViewController.h"
#import "TTFeedBaseDelegate.h"
#import "TTFeedHistoryViewModel.h"
#import "ArticleTitleImageView.h"
#import <TTAccountBusiness.h>
#import "TTAuthorizeManager.h"
#import "TTNavigationController.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ArticleURLSetting.h"
#import <SDWebImage/SDWebImageCompat.h>
#import "TTFooterDeleteView.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIScrollView+Refresh.h"
#import "TTHistoryEntryGroup.h"
#import "TTFeedSectionHeaderFooterControl.h"
#import "ExploreCellBase.h"
#import "ExploreCellViewBase.h"
#import "ExploreMixListDefine.h"

#import "NSObject+FBKVOController.h"

#import "TTLoginDialogStrategyManager.h"
#import "TTSwipePageViewController.h"
@interface TTHistoryViewController () <TTFeedContainerViewModelDelegate, UIViewControllerErrorHandler, CustomTableViewCellEditDelegate, TTFeedBaseProtocol, TTFooterDeleteViewDelegate>

@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) TTFeedHistoryViewModel *viewModel;
@property (nonatomic, strong) TTFeedBaseDelegate *tableViewDelegate;
@property (nonatomic, strong) SSThemedView *bottomTipView;
@property (nonatomic, strong) TTFooterDeleteView *deleteView;

@end

@implementation TTHistoryViewController

- (instancetype)initWithHistoryType:(TTHistoryType)type {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
        _historyType = type;
        self.viewModel = [[TTFeedHistoryViewModel alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc {
}

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = YES;
        self.viewModel = [[TTFeedHistoryViewModel alloc] initWithDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.ttHideNavigationBar = YES;
    
    SSThemedView * themeView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
    themeView.backgroundColorThemeKey = kColorBackground3;//@"BackgroundColor1";
    self.view = themeView;
    
    [self setupTableView];
    [self setupFooterView];
    
    self.tableViewDelegate = [[TTFeedBaseDelegate alloc] init];
    self.tableViewDelegate.delegate = self;
    [self.tableViewDelegate updateTableView:self.tableView viewModel:self.viewModel];
    
}

- (void)setupTableView {
    self.tableView = [[SSThemedTableView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundColorThemeKey = kColorBackground3;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.view addSubview:self.tableView];
    
    self.viewModel.targetVC = self;
    
    //历史列表不可以下拉刷新
    //    [self.tableView tt_addDefaultPullDownRefreshWithHandler:^{
    //        StrongSelf;
    //        [self.viewModel startFetchDataLoadMore:NO fromLocal:NO fromRemote:YES reloadType:ListDataOperationReloadFromTypeLoadMore];
    //    }];
    WeakSelf;
    [self.tableView tt_addDefaultPullUpLoadMoreWithHandler:^{
        StrongSelf;
        if (self.historyType == TTHistoryTypeRefresh) {
            [self.viewModel startFetchDataLoadMore:YES fromLocal:YES fromRemote:NO reloadType:ListDataOperationReloadFromTypeUserManual];
        } else {
            [self.viewModel startFetchDataLoadMore:YES fromLocal:NO fromRemote:YES reloadType:ListDataOperationReloadFromTypeUserManual];
        }
    }];
    
    [self setTableViewBottomInset:0];
    
    [self.KVOController observe:self.tableView keyPath:@"contentSize" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        NSValue *newContentSize = [change valueForKey:NSKeyValueChangeNewKey];
        CGFloat heightOffset = [newContentSize CGSizeValue].height;
        if (heightOffset > 0 && heightOffset < self.tableView.height && heightOffset + kTTPullRefreshHeight > self.tableView.height && !self.tableView.hasMore) {
            [self setTableViewBottomInset:self.tableView.isEditing ? kTTPullRefreshHeight + kFooterDeleteViewHeight :
             kTTPullRefreshHeight];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotInterestNotification:) name:kExploreMixListNotInterestNotification object:nil];
}

- (void)receiveNotInterestNotification:(NSNotification *)notification
{
    if ([SSCommonLogic feedRefreshClearAllEnable]) {
        if (_historyType == TTHistoryTypeRefresh) {
            id item = [[notification userInfo] objectForKey:kExploreMixListNotInterestItemKey];
            ExploreOrderedData *orderData = nil; //被dislike的数据
            if ([item isKindOfClass:[ExploreOrderedData class]]) {
                orderData = (ExploreOrderedData *)item;
                orderData.originalData.notInterested = @(YES);
                [orderData save];
                [self.viewModel deleteItem:orderData];
                [self.tableView reloadData];
            }
        }
    }
}

- (void)setupFooterView {
    if (!_deleteView) {
        _deleteView = [[TTFooterDeleteView alloc] initWithFrame:CGRectZero viewModel:self.viewModel canClearAll:YES];
        _deleteView.delegate = self;
        WeakSelf;
        _deleteView.didDelete = ^(BOOL clearAll, TTFeedMultiDeleteViewModel *viewModel){
            StrongSelf;
            if (clearAll) {
                [self.viewModel.deletingGroups addObjectsFromArray:self.viewModel.allItems];
            }
            [self.viewModel deleteItemsClearAll:clearAll historyType:self.historyType finishBlock:^(NSError *error, id jsonObj) {
                //统计
                BOOL deleteSuccess = YES;
                if (error || ![((NSDictionary *)jsonObj) tt_boolValueForKey:@"result"]) {
                    deleteSuccess = NO;
                }
                NSString *tagString = nil;
                if (self.historyType == TTHistoryTypeRead) {
                    tagString = @"read_history";
                } else if (self.historyType == TTHistoryTypeReadPush) {
                    tagString = @"push_history";
                } else {
                    tagString = @"refresh_history";
                }
                if (clearAll) {
                    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:1];
                    [extraDict setValue:@(deleteSuccess) forKey:@"success"];
                    wrapperTrackEventWithCustomKeys(tagString, @"delete_all", nil, nil, [extraDict copy]);
                    
                } else {
                    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
                    [extraDict setValue:@(self.deleteView.totalDeletingCount) forKey:@"count"];
                    BOOL hasBatchDeletingGroup = NO;
                    for (TTHistoryEntryGroup *group in self.viewModel.deletingGroups) {
                        if (group.isDeleting) {
                            hasBatchDeletingGroup = YES;
                            break;
                        }
                    }
                    [extraDict setValue:@(hasBatchDeletingGroup) forKey:@"batch_delete"];
                    [extraDict setValue:@(deleteSuccess) forKey:@"success"];
                    wrapperTrackEventWithCustomKeys(tagString, @"delete", nil, nil, [extraDict copy]);
                }
                
                if (!error && [((NSDictionary *)jsonObj) tt_boolValueForKey:@"result"]) {
                    for (TTHistoryEntryGroup *group in self.viewModel.deletingGroups) {
                        if (group.isEntireDeleting || group.deletingItems.count == group.totalCount || clearAll) {
                            [self.viewModel removeDataSourceItemIfNeeded:group];
                        } else {
                            NSMutableArray *mutableOrderedDataList = [NSMutableArray arrayWithArray:group.orderedDataList];
                            if (group.deletingItems.count > 0) {
                                [mutableOrderedDataList removeObjectsInArray:[group.deletingItems allObjects]];
                                group.totalCount -= group.deletingItems.count;
                            } else if(group.excludeItems.count > 0) {
                                for (ExploreOrderedData *data in group.orderedDataList) {
                                    if (![group.excludeItems containsObject:data]) {
                                        [mutableOrderedDataList removeObject:data];
                                    }
                                }
                                group.totalCount = group.excludeItems.count;
                            }
                            group.orderedDataList = [mutableOrderedDataList copy];
                        }
                    }
                    
                    [self cancelAllDeletingItems];
                    [self.deleteView changeDeletingCountIfNeeded];
                    
                    if ([self tt_hasValidateData]) {
                        [self.tableView reloadData];
                    } else {
                        [self.viewModel startFetchDataLoadMore:NO fromLocal:NO fromRemote:YES reloadType:ListDataOperationReloadFromTypeAuto];
                    }
                    
                    [self didEditButtonPressed:nil];
                } else {
                    //失败弹窗提示
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"删除失败，请稍后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                }
            }];
        };
        [self.view addSubview:_deleteView];
        _deleteView.hidden = YES;
        [_deleteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.mas_equalTo(@(kFooterDeleteViewHeight + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom));
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self tt_performSelector:@selector(fetchRemoteData) onlyOnceInSelector:_cmd];
    [self.tableView setScrollsToTop:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self calloutLoginIfNeed];
    if(self.historyType == TTHistoryTypeReadPush && self.tt_ControllerIsVisiable) {
        [self showPushHistoryLoginDialogIfNeeded];
    }
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.tableView setScrollsToTop:NO];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.tableView reloadData];
}

- (void)fetchRemoteData {
    BOOL pushHistoryEnable = [[TTLoginDialogStrategyManager sharedInstance] pushHistoryEnable];
    if(pushHistoryEnable) {
        if([TTAccountManager isLogin]) {
            [self.viewModel startFetchDataLoadMore:NO fromLocal:NO fromRemote:YES reloadType:ListDataOperationReloadFromTypeAuto];
        } else {
            [self tt_startUpdate];
            [self showNoLoginHintViewIfNeeded];
        }
        
    } else {
        if ([SSCommonLogic feedRefreshClearAllEnable]) {
            if (self.historyType == TTHistoryTypeRefresh) {
                [self.viewModel startFetchDataLoadMore:NO fromLocal:YES fromRemote:NO reloadType:ListDataOperationReloadFromTypeAuto];
                return;
            }
        }
        
        //未登录状态下阅读历史列表不展示
        if (self.historyType == TTHistoryTypeReadPush || [TTAccountManager isLogin]) {
            [self.viewModel startFetchDataLoadMore:NO fromLocal:NO fromRemote:YES reloadType:ListDataOperationReloadFromTypeAuto];
        } else {
            [self tt_startUpdate];
            [self showNoLoginHintViewIfNeeded];
        }
    }
}

#pragma mark - TTFeedFavoriteHistoryProtocol
- (void)didEditButtonPressed:(id)sender {
    self.tableView.editing = !self.tableView.editing;
    
    if (self.tableView.editing) {
        self.deleteView.hidden = NO;
        [self setTableViewBottomInset:kTTPullRefreshHeight + kFooterDeleteViewHeight + self.view.tt_safeAreaInsets.bottom];
    }
    else {
        self.deleteView.hidden = YES;
        [self setTableViewBottomInset:kTTPullRefreshHeight];
        [self cancelAllDeletingItems];
        [self.deleteView changeDeletingCountIfNeeded];
    }
    
    [self.tableView reloadData];
}

- (BOOL)isCurrentVCEditing {
    return self.tableView.isEditing;
}

- (void)cleanupDataSource {
    [self.viewModel cleanupDataSource];
}

#pragma mark - TTFeedContainerViewModelDelegate

- (NSString *)URLStringForHTTPRequst {
    return [ArticleURLSetting getHistoryURLString];
}

- (NSString *)methodForHTTPRequst {
    return @"GET";
}

- (NSDictionary *)getParamsForHTTPRequest {
    
    NSNumber *beHotTime = nil;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    if(self.viewModel.loadMore) {
        if([self.viewModel.allItems count] > 0) {
            TTHistoryEntryGroup *lastGroup = [self.viewModel.allItems lastObject];
            if ([lastGroup isKindOfClass:[TTHistoryEntryGroup class]]) {
                ExploreOrderedData *lastObject = lastGroup.orderedDataList.lastObject ;
                if ([lastObject isKindOfClass:[ExploreOrderedData class]]) {
                    beHotTime = @(lastObject.behotTime);
                }
            }
        }
    }
    
    if (self.viewModel.loadMore && beHotTime) {
        [param setValue:beHotTime forKey:@"max_time"];
    }
    
    [param setObject:[NSNumber numberWithInt:100] forKey:@"count"];
    
    [param setValue:self.historyType == TTHistoryTypeRead ? @"read" : @"push" forKey:@"history_type"];
    
    return [param copy];
}

- (NSString *)concernID {
    return @"";
}

- (NSString *)categoryID {
    return @"_history";
}

- (ExploreOrderedDataListType)listType {
    return self.historyType == TTHistoryTypeRead ? ExploreOrderedDataListTypeReadHistory : ExploreOrderedDataListTypePushHistory;
}

- (ExploreOrderedDataListLocation)listLocation {
    return ExploreOrderedDataListLocationCategory;
}

- (NSUInteger)refer {
    return 1;
}

- (Class)orderedDataClass {
    return [TTHistoryEntryGroup class];
}

- (BOOL)asyncPersistence {
    return YES;
}

- (BOOL)needPesistence {
    return NO;
}

- (void)didFetchDataformRemote:(BOOL)formRemote error:(NSError *)error {
    
    if (![self tt_hasValidateData]) {
        self.ttViewType = TTFullScreenErrorViewTypeEmpty;
    }
    
    [self tt_endUpdataData:[self tt_hasValidateData] error:error];
    
    if (self.viewModel.loadMore) {
        [self.tableView finishPullUpWithSuccess:!error];
    } else {
        if(formRemote) {
            [self.tableView finishPullDownWithSuccess:!error];
        }
    }
    
    if (!error) {
        self.tableView.hasMore = self.viewModel.canLoadMore;
        [self.tableView reloadData];
    }
}

#pragma mark -- UIViewControllerErrorHandler
- (BOOL)tt_hasValidateData {
    return self.viewModel.allItems.count > 0;
}

- (void)refreshData {
    [self.viewModel startFetchDataLoadMore:NO fromLocal:NO fromRemote:YES reloadType:ListDataOperationReloadFromTypeNone];
}

- (void)sessionExpiredAction {
    if(self.historyType == TTHistoryTypeReadPush) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:@"sslocal://ak_login_traffic?"] userInfo:nil];
    } else {
        [self showLoginGuideViewWithSource:@"history_fixed"];
    }
}

#pragma mark -- CustomTableViewCellEditDelegate

- (BOOL)isFakeEditing {
    return YES;
}

- (UIControl *)customEditControl {
    SSThemedButton *editButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [editButton setImageName:@"delete_default"];
    [editButton setSelectedImageName:@"delete_selected"];
    
    return editButton;
}

- (CGFloat)customEditIndent {
    return 53.f;
}

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath isSelected:(BOOL)isSelected {
    if (self.tableView.isEditing) {
        ExploreCellBase *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        TTHistoryEntryGroup *group = [self.viewModel.allItems objectAtIndex:indexPath.section];
        
        if (isSelected) {
            if (cell.cellData && [cell.cellData isKindOfClass:[ExploreOrderedData class]]) {
                [cell setCustomControlSelected:YES];
                if (!group.isDeleting) {
                    [[self.viewModel mutableSetValueForKey:@"deletingItems"] addObject:cell.cellData];
                    [self.viewModel.deletingGroups addObject:group];
                    [group.deletingItems addObject:cell.cellData];
                    if (group.deletingItems.count == group.totalCount) {
                        group.isEntireDeleting = YES;
                        [self.tableView reloadData];
                    }
                } else {
                    [group.excludeItems removeObject:cell.cellData];
                    [self.deleteView changeDeletingCountIfNeeded];
                    //整组都被选中的时候sectionHeader应该联动
                    if (group.excludeItems.count == 0) {
                        group.isEntireDeleting = YES;
                        [self.tableView reloadData];
                    }
                }
            }
        } else {
            if (cell.cellData && [cell.cellData isKindOfClass:[ExploreOrderedData class]]) {
                [cell setCustomControlSelected:NO];
                if (!group.isDeleting) {
                    BOOL shouldReload = group.deletingItems.count == group.totalCount;
                    [[self.viewModel mutableSetValueForKey:@"deletingItems"] removeObject:cell.cellData];
                    [group.deletingItems removeObject:cell.cellData];
                    if (SSIsEmptyArray(group.deletingItems)) {
                        [self.viewModel.deletingGroups removeObject:group];
                    }
                    if(shouldReload) {
                        group.isEntireDeleting = NO;
                        [self.tableView reloadData];
                    }
                } else {
                    group.isEntireDeleting = NO;
                    [group.excludeItems addObject:cell.cellData];
                    [self.deleteView changeDeletingCountIfNeeded];
                    [self.tableView reloadData];
                }
            }
        }
    }
}

- (void)didGenerateCell:(ExploreCellBase *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        TTHistoryEntryGroup *group = [self.viewModel.allItems objectAtIndex:indexPath.section];
        if (cell.cellData && [self.viewModel isKindOfClass:[TTFeedHistoryViewModel class]]) {
            if ((group.isDeleting && ![group.excludeItems containsObject:cell.cellData]) || [self.viewModel.deletingItems containsObject:cell.cellData]) {
                [cell setCustomControlSelected:YES];
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            } else {
                [cell setCustomControlSelected:NO];
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
    }
    cell.cellView.userInteractionEnabled = !self.tableView.editing;
}

- (TTFeedSectionHeaderFooterControl *)sectionHeaderControlForSection:(NSUInteger)section{
    if (self.historyType == TTHistoryTypeRefresh) {
        return nil;
    }
    
    TTHistoryEntryGroup *group = [self.viewModel.allItems objectAtIndex:section];
    
    TTFeedSectionHeaderFooterControl *headerControl = [[TTFeedSectionHeaderFooterControl alloc] init];
    headerControl.backgroudColorThemedKey = kColorBackground3;
    
    //第一个sectionHeader没有顶部的分割线
    if (section == 0) {
        [headerControl hideBorderLineAtBottom:NO];
    }
    
    if (!headerControl.editButton) {
        headerControl.editButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [headerControl.editButton setImageName:@"delete_default"];
        [headerControl.editButton setSelectedImageName:@"delete_selected"];
        headerControl.editButton.userInteractionEnabled = NO;
        if (self.tableView.isEditing) {
            headerControl.editButton.hidden = NO;
        } else {
            headerControl.editButton.hidden = YES;
        }
        [headerControl addSubview:headerControl.editButton];
        __weak typeof(headerControl) weakControl = headerControl;
        [headerControl.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakControl);
            make.left.equalTo(weakControl).offset([TTUIResponderHelper paddingForViewWidth:self.tableView.width] + 15.f);
        }];
    }
    
    if (!headerControl.headerLabel) {
        headerControl.headerLabel = [[SSThemedLabel alloc] init];
        headerControl.headerLabel.text = [self.viewModel headerTextForGroup:group];
        headerControl.headerLabel.textColorThemeKey = kColorText14;
        headerControl.headerLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14.f]];
        [headerControl addSubview:headerControl.headerLabel];
        
        __weak typeof(headerControl) weakControl = headerControl;
        [headerControl.headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(weakControl);
            if (self.tableView.isEditing) {
                make.left.equalTo(weakControl.editButton.mas_right).offset(15.f);
            } else {
                make.left.equalTo(weakControl).offset([TTUIResponderHelper paddingForViewWidth:self.tableView.width] + [TTDeviceUIUtils tt_padding:15.f]);
            }
        }];
    }
    
    WeakSelf;
    headerControl.didSelect = ^(BOOL isSelected) {
        StrongSelf;
        if (!self.tableView.isEditing) {
            return;
        }
        
        if (isSelected) {
            [self.viewModel.deletingGroups addObject:group];
        } else {
            [self.viewModel.deletingGroups removeObject:group];
        }
        
        group.isDeleting = isSelected;
        group.isEntireDeleting = isSelected;
        [group.excludeItems removeAllObjects];
        for (ExploreOrderedData *deletingItem in group.orderedDataList) {
            [[self.viewModel mutableSetValueForKey:@"deletingItems"] removeObject:deletingItem];
        }
        
        [self.deleteView changeDeletingCountIfNeeded];
        [self.tableView reloadData];
    };
    
    headerControl.selected = group.isEntireDeleting;
    headerControl.editButton.selected = headerControl.selected;
    
    return headerControl;
}

- (CGFloat)sectionHeaderControlHeightForSection:(NSUInteger)section {
    return [TTDeviceUIUtils tt_padding:36.f];
}

#pragma mark - TTFooterDeleteViewDelegate

- (NSString *)clearAllTitleString {
    return [NSString stringWithFormat:@"确定清空全部%@吗？", [self nameForHistoryType]];
}

- (NSString *)deleteTitleString {
    return [NSString stringWithFormat:@"确定删除%lld条%@吗？",self.deleteView.totalDeletingCount, [self nameForHistoryType]];
}

#pragma mark - Helper

- (NSString *)nameForHistoryType {
    return self.historyType == TTHistoryTypeRead ? @"阅读历史" : @"推送历史";
}

- (void)setTableViewBottomInset:(CGFloat)bottomInset {
    if (self.historyType == TTHistoryTypeRefresh) {
        return;
    }
    
    CGFloat fixOffset = 0.f;
    
    if (self.tableView.contentSize.height > 0 && self.tableView.contentSize.height < self.tableView.height && self.tableView.contentSize.height + kTTPullRefreshHeight > self.tableView.height && bottomInset != 0 && !self.tableView.hasMore) {
        fixOffset = self.tableView.height - self.tableView.contentSize.height;
        bottomInset += fixOffset;
    }
    
    [self.tableView setOriginContentInset:UIEdgeInsetsMake(0, 0, bottomInset, 0)];
    [self.tableView setTtContentInset:UIEdgeInsetsMake(0, 0, bottomInset, 0)];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, bottomInset, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, bottomInset - kTTPullRefreshHeight - fixOffset, 0)];
    
    //先注掉，否则列表会跳动
    //    if (self.tableView.contentSize.height - self.tableView.contentOffset.y > self.tableView.height - bottomInset) {
    //        self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - (self.tableView.height - bottomInset));
    //    }
}

- (void)cancelAllDeletingItems {
    for (ExploreOrderedData *deletingItem in [self.viewModel.deletingItems copy]) {
        [[self.viewModel mutableSetValueForKey:@"deletingItems"] removeObject:deletingItem];
    }
    for (TTHistoryEntryGroup *group in self.viewModel.deletingGroups) {
        group.isDeleting = NO;
        group.isEntireDeleting = NO;
        [group.deletingItems removeAllObjects];
        [group.excludeItems removeAllObjects];
    }
    [self.viewModel.deletingGroups removeAllObjects];
}

#pragma mark - Login

#define kHasTipReadHistoryLoginGuideShown @"kHasTipReadHistoryLoginGuideShown"

- (void)setHasReadHistoryGuideShown:(BOOL)hasShown {
    [[NSUserDefaults standardUserDefaults] setBool:hasShown forKey:kHasTipReadHistoryLoginGuideShown];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasReadHistoryGuideShown {
    BOOL result = [[NSUserDefaults standardUserDefaults] boolForKey:kHasTipReadHistoryLoginGuideShown];
    return result;
}

- (void)calloutLoginIfNeed {
    if (![TTAccountManager isLogin] && ![self hasReadHistoryGuideShown] && self.historyType == TTHistoryTypeRead) {
        [self showLoginGuideViewWithSource:@"history_pop"];
    }
}

- (void)showLoginGuideViewWithSource:(NSString *)source {
    
    [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:@"sslocal://ak_login_traffic?"] userInfo:nil];
    [self setHasReadHistoryGuideShown:YES];
}

- (void)showNoLoginHintViewIfNeeded {
    if (![TTAccountManager isLogin]) {
        self.ttViewType = TTFullScreenErrorViewTypeSessionExpired;
        [self.view tt_endUpdataData:[self tt_hasValidateData] error:[NSError errorWithDomain:kCommonErrorDomain code:kSessionExpiredErrorCode userInfo:nil]];
        self.ttErrorView.errorMsg.text = NSLocalizedString(@"暂未登录", nil);
    }
}

- (void)showPushHistoryLoginDialogIfNeeded
{
    if([[TTLoginDialogStrategyManager sharedInstance] pushHistoryShouldShowDialogIfNeeded]) {
        NSInteger pushHistoryTotalTime = [[TTLoginDialogStrategyManager sharedInstance] pushHistoryTotalTime];
        [[TTLoginDialogStrategyManager sharedInstance] setPushHistoryTotalTime:++pushHistoryTotalTime];
       
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:@"sslocal://ak_login_traffic?"] userInfo:nil];
    }
}

@end
