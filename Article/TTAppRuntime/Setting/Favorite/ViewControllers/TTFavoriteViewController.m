//
//  TTFavoriteViewController.m
//  Article
//
//  Created by fengyadong on 16/11/17.
//
//

#import "TTFavoriteViewController.h"
#import "TTFeedBaseDelegate.h"
#import "TTFeedMultiDeleteViewModel.h"
#import "ArticleTitleImageView.h"
#import <TTAccountBusiness.h>
#import "TTAuthorizeManager.h"
#import "TTNavigationController.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ArticleURLSetting.h"
#import <SDWebImage/SDWebImageCompat.h>
#import "TTFooterDeleteView.h"
#import "ExploreItemActionManager.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "UIScrollView+Refresh.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreCellViewBase.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "TTLoadMoreView.h"
#import "ExploreItemActionManager.h"
#import "NSObject+FBKVOController.h"

#import "TTUGCDefine.h"
#import "TTLoginDialogStrategyManager.h"
#import <TTAccountSDK.h>
#import <BDAccountSDK.h>
//#import "Thread.h"
#import "ExploreMomentDefine.h"

#define kHasBottomTipFavlistClosedUserDefaultKey @"kHasBottomTipFavlistClosedUserDefaultKey"

@interface TTFavoriteViewController () <TTFeedContainerViewModelDelegate, UIViewControllerErrorHandler, CustomTableViewCellEditDelegate, TTFeedBaseProtocol, TTFooterDeleteViewDelegate>

@property (nonatomic, strong) SSThemedTableView *tableView;
@property (nonatomic, strong) TTFeedMultiDeleteViewModel *viewModel;
@property (nonatomic, strong) TTFeedBaseDelegate *tableViewDelegate;
@property (nonatomic, strong) SSThemedView *bottomTipView;
@property (nonatomic, strong) TTFooterDeleteView *deleteView;
@property (nonatomic, strong) ExploreItemActionManager *itemActionManager;

@end

@implementation TTFavoriteViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.viewModel = [[TTFeedMultiDeleteViewModel alloc] initWithDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [self removeNotification];
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
    [self showLoginHintIfNeeded];
    
    self.tableViewDelegate = [[TTFeedBaseDelegate alloc] init];
    self.tableViewDelegate.delegate = self;
    [self.tableViewDelegate updateTableView:self.tableView viewModel:self.viewModel];
    [self registerNotification];
}

- (void)setupTableView {
    self.tableView = [[SSThemedTableView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundColorThemeKey = kColorBackground3;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.view addSubview:self.tableView];
    
    self.viewModel.targetVC = self;
    
    //收藏下拉刷新先去掉
    //    [self.tableView tt_addDefaultPullDownRefreshWithHandler:^{
    //        StrongSelf;
    //        [self.viewModel startFetchDataLoadMore:NO fromLocal:[self tt_hasValidateData] ? NO : YES fromRemote:YES reloadType:ListDataOperationReloadFromTypeLoadMore];
    //    }];
    
    WeakSelf;
    [self.tableView tt_addDefaultPullUpLoadMoreWithHandler:^{
        StrongSelf;
        [self.viewModel startFetchDataLoadMore:YES fromLocal:NO fromRemote:YES reloadType:ListDataOperationReloadFromTypeUserManual];
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
}

- (void)setupFooterView {
    if (!_deleteView) {
        _deleteView = [[TTFooterDeleteView alloc] initWithFrame:CGRectZero viewModel:self.viewModel canClearAll:NO];
        _deleteView.delegate = self;
        WeakSelf;
        _deleteView.didDelete = ^(BOOL clearAll, TTFeedMultiDeleteViewModel *viewModel){
            StrongSelf;
            NSArray * orderedDataGroup = [viewModel.deletingItems allObjects];
            [self.itemActionManager unfavoriteForOrderedDataGroup:orderedDataGroup finishBlock:^(id userInfo, NSError *error) {
                BOOL deleteSuccess = YES;
                
                if (!error && [[userInfo tt_stringValueForKey:@"message"] isEqualToString:@"success"]) {
                    for (ExploreOrderedData *orderedData in orderedDataGroup) {
                        [ExploreItemActionManager removeOrderedData:orderedData];
                    }
                    [self.viewModel removeDataSourceArrayIfNeeded:[viewModel.deletingItems allObjects]];
                    if ([self tt_hasValidateData]) {
                        [self.tableView reloadData];
                    } else {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.viewModel startFetchDataLoadMore:NO fromLocal:NO fromRemote:YES reloadType:ListDataOperationReloadFromTypeAuto];
                        });
                    }
                    
                    [self didEditButtonPressed:nil];
                } else {
                    deleteSuccess = NO;
                    //失败弹窗提示
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"删除失败，请稍后重试", nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                }
                
                NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithCapacity:2];
                [extraDict setValue:@(self.deleteView.totalDeletingCount) forKey:@"count"];
                [extraDict setValue:@(deleteSuccess) forKey:@"success"];
                
                wrapperTrackEventWithCustomKeys(@"favorite", @"delete", nil, nil, [extraDict copy]);
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

- (void)showLoginHintIfNeeded {
    
    if (![TTAccountManager isLogin] && ![TTDeviceHelper isPadDevice] && ![self hasBottomTipFavlistClosedUserDefaultKey] && [self hasTipFavlistLoginUserDefaultKey] && ![[TTLoginDialogStrategyManager sharedInstance] myFavorEnable]) {
        if (!_bottomTipView) {
            
            CGFloat kBottomButtonHeight = [TTDeviceHelper isScreenWidthLarge320]? 54:44;
            
            
            _bottomTipView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-kBottomButtonHeight - [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom,self.view.frame.size.width, kBottomButtonHeight + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom)];
            _bottomTipView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            _bottomTipView.backgroundColorThemeKey = kColorBackground11;
            [self.view addSubview:_bottomTipView];
            
            SSThemedLabel * lb = [[SSThemedLabel alloc] initWithFrame:CGRectMake(15, 5, _bottomTipView.frame.size.width - 125, kBottomButtonHeight-10)];
            lb.numberOfLines = 0;
            lb.minimumScaleFactor = 0.6f;
            lb.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            lb.text = @"登录并同步收藏内容，云端永久保存！";
            lb.font = [UIFont systemFontOfSize:14];
            if (![TTDeviceHelper isScreenWidthLarge320]) {
                lb.font = [UIFont systemFontOfSize:12];
                lb.frame = CGRectMake(15, 5, _bottomTipView.frame.size.width - 105, kBottomButtonHeight-10);
            }
            lb.textColorThemeKey = kColorText10;
            [_bottomTipView addSubview:lb];
            
            
            SSThemedButton * closeButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
            closeButton.imageName = @"titlebar_close";
            closeButton.frame = CGRectMake(_bottomTipView.frame.size.width-50, 5,50, kBottomButtonHeight-10);
            closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            [closeButton addTarget:self action:@selector(closeButtonTouched) forControlEvents:UIControlEventTouchUpInside];
            [_bottomTipView addSubview:closeButton];
            
            NSString * title = @"立即同步";
            SSThemedButton * _bottomTipButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
            _bottomTipButton.titleColorThemeKey = kColorText8;
            _bottomTipButton.backgroundColorThemeKey = kColorBackground7;
            _bottomTipButton.layer.cornerRadius = 7.0f;
            _bottomTipButton.frame = CGRectMake(_bottomTipView.frame.size.width-115 , (kBottomButtonHeight-30)/2,70, 30);
            _bottomTipButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [_bottomTipButton setTitle:title forState:UIControlStateNormal];
            [_bottomTipButton.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
            if (![TTDeviceHelper isScreenWidthLarge320]) {
                [_bottomTipButton.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
                _bottomTipButton.frame = CGRectMake(_bottomTipView.frame.size.width-100 , (kBottomButtonHeight-24)/2,55, 24);
                
            }
            [_bottomTipButton addTarget:self action:@selector(openLoginViewController) forControlEvents:UIControlEventTouchUpInside];
            [_bottomTipView addSubview:_bottomTipButton];
            
            
        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView setScrollsToTop:YES];
    [self tt_performSelector:@selector(fetchRemoteData) onlyOnceInSelector:_cmd];
    if (![TTAccountManager isLogin] && ![self hasBottomTipFavlistClosedUserDefaultKey] && self.deleteView.hidden) {
        _bottomTipView.hidden = NO;
    }
    else {
        _bottomTipView.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    BOOL myFavorEnable = [[TTLoginDialogStrategyManager sharedInstance] myFavorEnable];
    if(myFavorEnable) {
        [self showFavorLoginDialogIfNeeded];
    } else {
        if (![self hasTipFavlistLoginUserDefaultKey] && ![[BDAccount sharedAccount] isLogin]) {
            
            [self setHasTipFavlistLoginUserDefaultKey:YES];
            
            wrapperTrackEvent(@"auth", @"fav_pop");
            
//            [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:@"sslocal://ak_login_traffic?"] userInfo:nil];
            
            [TTAccountManager presentQuickLoginFromVC:self type:TTAccountLoginDialogTitleTypeDefault source:nil completion:^(TTAccountLoginState state) {
//                if (self.completeBlock) {
//                    self.completeBlock(state == TTAccountLoginStateLogin);
//                }
//                if (state == TTAccountLoginStateLogin) {
//                    [self dismissSelfWithNoAnimation];
//                }
            }];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.tableView setScrollsToTop:NO];
}

- (void)fetchRemoteData {
    BOOL myFavorEnable = [[TTLoginDialogStrategyManager sharedInstance] myFavorEnable];
    if(myFavorEnable) {
        if([TTAccountManager isLogin]) {
            [self.viewModel startFetchDataLoadMore:NO fromLocal:NO fromRemote:YES reloadType:ListDataOperationReloadFromTypeAuto];
        } else {
            [self showNoLoginHintViewIfNeeded];
        }
    } else {
        [self.viewModel startFetchDataLoadMore:NO fromLocal:NO fromRemote:YES reloadType:ListDataOperationReloadFromTypeAuto];
    }
}

#pragma mark - Notification

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteThreadNotification:)
                                                 name:kTTForumDeleteThreadNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deleteCommentRepostNotification:)
                                                 name:kDeleteCommentNotificationKey
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(originalDataUpdate:)
                                                 name:kExploreOriginalDataUpdateNotification
                                               object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deleteThreadNotification:(NSNotification *)notification {
    if (self.tableView.isEditing) {
        return;
    }
    int64_t threadID = [notification.userInfo tt_longlongValueForKey:kTTForumThreadID];
    __block ExploreOrderedData * orderedData = nil;
    [self.viewModel.allItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            if ([(ExploreOrderedData *)obj originalData].uniqueID == threadID) {
                orderedData = obj;
                *stop = YES;
            }
        }
    }];
    if (orderedData) {
        if ([self.viewModel removeDataSourceItemIfNeeded:orderedData]) {
            [self.tableView reloadData];
        }
    }
}

- (void)deleteCommentRepostNotification:(NSNotification *)notification{
    
    if (self.tableView.isEditing) {
        return;
    }
    
    int64_t commentRepostID = [notification.userInfo tt_longlongValueForKey:@"id"];
    __block ExploreOrderedData * orderedData = nil;
    [self.viewModel.allItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            if ([(ExploreOrderedData *)obj originalData].uniqueID == commentRepostID) {
                orderedData = obj;
                *stop = YES;
            }
        }
    }];
    if (orderedData) {
        if ([self.viewModel removeDataSourceItemIfNeeded:orderedData]) {
            [self.tableView reloadData];
        }
    }
}

- (void)originalDataUpdate:(NSNotification *)notification {
    if (self.tableView.isEditing) {
        return;
    }
    int64_t uniqueID = [[notification userInfo] tt_longlongValueForKey:@"uniqueID"];
    [self.viewModel.allItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ExploreOrderedData class]]) {
            if ([(ExploreOrderedData *)obj originalData].uniqueID == uniqueID) {
                [(ExploreOrderedData *)obj clearCachedCellType];
                [(ExploreOrderedData *)obj clearCacheHeight];
                [self.tableView reloadData];
                *stop = YES;
            }
        }
    }];
}

#pragma mark - TTFeedFavoriteHistoryProtocol
- (void)didEditButtonPressed:(id)sender {
    self.tableView.editing = !self.tableView.editing;
    
    if (self.tableView.editing) {
        self.deleteView.hidden = NO;
        self.bottomTipView.hidden = YES;
        [self setTableViewBottomInset:kTTPullRefreshHeight+kFooterDeleteViewHeight + self.view.tt_safeAreaInsets.bottom];
    }
    else {
        self.deleteView.hidden = YES;
        self.bottomTipView.hidden = NO;
        [self setTableViewBottomInset:kTTPullRefreshHeight];
        for (ExploreOrderedData *deletingItem in [self.viewModel.deletingItems copy]) {
            [[self.viewModel mutableSetValueForKey:@"deletingItems"] removeObject:deletingItem];
        }
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

- (void)closeButtonTouched {
    [_bottomTipView removeFromSuperview];
    [self setHasBottomTipFavlistClosedUserDefaultKey:YES];
}

- (void)openLoginViewController {
    [TTAccountManager presentQuickLoginFromVC:self type:TTAccountLoginDialogTitleTypeFavor source:@"favor_bottom" isPasswordStyle:NO completion:^(TTAccountLoginState state) {
    }];
}

#pragma mark - tip stuff

#define kHasTipFavlistLoginUserDefaultKey @"kHasTipFavlistLoginUserDefaultKey"

- (void)setHasTipFavlistLoginUserDefaultKey:(BOOL) hasTip {
    [[NSUserDefaults standardUserDefaults] setBool:hasTip forKey:kHasTipFavlistLoginUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasTipFavlistLoginUserDefaultKey {
    
    BOOL result = [[NSUserDefaults standardUserDefaults] boolForKey:kHasTipFavlistLoginUserDefaultKey];
    return result;
}


- (void)setHasBottomTipFavlistClosedUserDefaultKey:(BOOL) hasTip {
    [[NSUserDefaults standardUserDefaults] setBool:hasTip forKey:kHasBottomTipFavlistClosedUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)hasBottomTipFavlistClosedUserDefaultKey {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHasBottomTipFavlistClosedUserDefaultKey];
}

#pragma mark - TTFeedContainerViewModelDelegate

- (NSString *)URLStringForHTTPRequst {
    return [ArticleURLSetting getFavoritesURLString];
}

- (NSString *)methodForHTTPRequst {
    return @"GET";
}

- (NSDictionary *)getParamsForHTTPRequest {
    
    NSNumber *beHotTime = nil;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    
    if(self.viewModel.loadMore) {
        if([self.viewModel.allItems count] > 0) {
            ExploreOrderedData *lastObject = [self.viewModel.allItems lastObject];
            if ([lastObject isKindOfClass:[ExploreOrderedData class]]) {
                beHotTime = @(lastObject.behotTime);
            }
        }
    } else {
        if([self.viewModel.allItems count] > 0) {
            ExploreOrderedData *firstObject = [self.viewModel.allItems firstObject];
            if ([firstObject isKindOfClass:[ExploreOrderedData class]]) {
                beHotTime = @(firstObject.behotTime);
            }
        }
    }
    
    if (self.viewModel.loadMore && beHotTime) {
        [param setValue:beHotTime forKey:@"max_repin_time"];
    }
    else if (beHotTime) {
        [param setValue:beHotTime forKey:@"min_repin_time"];
    }
    else {
        [param setValue:[NSNumber numberWithInt:0] forKey:@"min_repin_time"];
    }
    
    [param setObject:[NSNumber numberWithInt:100] forKey:@"count"];
    
    return [param copy];
}

- (NSString *)concernID {
    return @"";
}

- (NSString *)categoryID {
    return @"_favorite";
}

- (ExploreOrderedDataListType)listType {
    return ExploreOrderedDataListTypeFavorite;
}

- (ExploreOrderedDataListLocation)listLocation {
    return ExploreOrderedDataListLocationCategory;
}

- (NSUInteger)refer {
    return 1;
}

- (Class)orderedDataClass {
    return [ExploreOrderedData class];
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
    
    [self.view bringSubviewToFront:self.bottomTipView];
    
    if (!error) {
        self.tableView.hasMore = self.viewModel.canLoadMore;
        
        if([self.viewModel.increaseItems count] == 0) {
            self.tableView.hasMore = NO;
        }
        
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
        if (isSelected) {
            if ([cell.cellData isKindOfClass:[ExploreOrderedData class]]) {
                [cell setCustomControlSelected:YES];
                [[self.viewModel mutableSetValueForKey:@"deletingItems"] addObject:cell.cellData];
            }
        } else {
            if ([cell.cellData isKindOfClass:[ExploreOrderedData class]]) {
                [cell setCustomControlSelected:NO];
                [[self.viewModel mutableSetValueForKey:@"deletingItems"] removeObject:cell.cellData];
            }
        }
    } else {
        ExploreCellBase *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSUInteger index = [self.viewModel.allItems indexOfObject:cell.cellData];
        WeakSelf;
        [self.KVOController observe:cell.cellData keyPath:@"originalData.userRepined" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            NSUInteger oldValue = [[change objectForKey:NSKeyValueChangeOldKey] unsignedIntegerValue];
            NSUInteger newValue = [[change objectForKey:NSKeyValueChangeNewKey] unsignedIntegerValue];
            //收藏状态发送变化再更新视图
            if (oldValue != newValue) {
                //取消收藏
                if (newValue == 0) {
                    if ([self.viewModel removeDataSourceItemIfNeeded:cell.cellData]) {
                        @try {
                            if (self.viewModel.allItems.count > 0) {
                                [self.tableView beginUpdates];
                                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                [self.tableView endUpdates];
                            } else {
                                [self.tableView beginUpdates];
                                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                                [self.tableView endUpdates];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [self fetchRemoteData];
                                });
                            }
                        } @catch (NSException *exception) {
                        } @finally {
                        }
                    }
                } else if(newValue == 1) {
                    if ([self.viewModel insertDataSourceItem:cell.cellData atIndex:index]) {
                        @try {
                            if (self.viewModel.allItems.count > 1) {
                                [self.tableView beginUpdates];
                                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                [self.tableView endUpdates];
                            } else {
                                [self.tableView reloadData];
                                self.ttErrorView.hidden = YES;
                            }
                        } @catch (NSException *exception) {
                        } @finally {
                        }
                    }
                }
            }
        }];
    }
}


#pragma mark - TTFeedBaseProtocol

- (void)didGenerateCell:(ExploreCellBase *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        if ([self.viewModel.deletingItems containsObject:cell.cellData]) {
            [cell setCustomControlSelected:YES];
        } else {
            [cell setCustomControlSelected:NO];
        }
    }
    cell.cellView.userInteractionEnabled = !self.tableView.editing;
}

#pragma mark - TTFooterDeleteViewDelegate

- (NSString *)clearAllTitleString {
    return NSLocalizedString(@"确定清空全部收藏吗？",nil);
}

- (NSString *)deleteTitleString {
    return [NSString stringWithFormat:@"确定删除%lld条收藏吗？",self.deleteView.totalDeletingCount];
}

#pragma mark - Helper

- (ExploreItemActionManager *)itemActionManager {
    if (!_itemActionManager) {
        _itemActionManager = [[ExploreItemActionManager alloc] init];
    }
    return _itemActionManager;
}

- (void)setTableViewBottomInset:(CGFloat)bottomInset {
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

- (void)showNoLoginHintViewIfNeeded {
    if (![TTAccountManager isLogin]) {
        self.ttViewType = TTFullScreenErrorViewTypeSessionExpired;
        [self.view tt_endUpdataData:[self tt_hasValidateData] error:[NSError errorWithDomain:kCommonErrorDomain code:kSessionExpiredErrorCode userInfo:nil]];
        self.ttErrorView.errorMsg.text = NSLocalizedString(@"暂未登录", nil);
    }
}

- (void)sessionExpiredAction
{
    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeMyFavor source:@"favorite_fixed" completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if(type == TTAccountAlertCompletionEventTypeTip) {
            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"favorite_fixed" completion:nil];
        }
    }];
    
}

- (void)showFavorLoginDialogIfNeeded
{
    if([[TTLoginDialogStrategyManager sharedInstance] myFavorShouldShowDialogIfNeeded]) {
        wrapperTrackEvent(@"auth", @"fav_pop");
        NSInteger myFavorTotalTime = [[TTLoginDialogStrategyManager sharedInstance] myFavorTotalTime];
        [[TTLoginDialogStrategyManager sharedInstance] setMyFavorTotalTime:++myFavorTotalTime];
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeMyFavor source:@"favor_popup" completion:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
            if(type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"favor_popup" completion:nil];
            }
        }];
    }
}

@end
