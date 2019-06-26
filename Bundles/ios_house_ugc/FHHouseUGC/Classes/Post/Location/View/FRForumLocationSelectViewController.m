//
//  FRForumLocationSelectViewController.m
//  Article
//
//  Created by 王霖 on 15/7/13.
//
//

#import "FRForumLocationSelectViewController.h"
#import "FRForumLocationSelectViewModel.h"
#import "FRForumLocationSingleLineCell.h"
#import "FRForumLocationDoubleLineCell.h"
#import "FRForumLocationLoadMoreCell.h"

#import "TTGoogleMapGeocoder.h"
#import <TTUIWidget/TTThemedAlertController.h>
#import <TTUIWidget/SSNavigationBar.h>
#import <TTThemed/TTThemeManager.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <TTLocationManager/TTLocationManager.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTPlatformBaseLib/TTTrackerWrapper.h>
#import <TTUGCFoundation/FRLocationEntity.h>
#import "TTPostThreadKitchenConfig.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
// 因为用了UISearchDisplayController，整个类压警告

@interface FRForumLocationSelectViewController ()<UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) SSThemedTableView *locationsList;
@property (nonatomic, strong) FRForumLocationSelectViewModel *nearbyViewModel;
@property (nonatomic, strong) FRForumLocationSelectViewModel *previousValidSearchViewModel;
@property (nonatomic, strong) FRForumLocationSelectViewModel *searchViewModel;

@property (nonatomic, strong) TTSelectedLocationCompletion selectedLocationCompletion;
@property (nonatomic, strong) FRLocationEntity *preSelectedLocation;

@property (nonatomic, assign) BOOL isFirstLoadNearbyPoiLocFinish;
@property (nonatomic, strong) NSDate *loadNearbyStartDate;
@property (nonatomic, strong) NSDate *searchStartDate;

@property (nonatomic, assign) BOOL isHideNilLocationCell;

@property (nonatomic, assign) BOOL lastSearchContainsZeroResult;

@end

@implementation FRForumLocationSelectViewController

#pragma mark - Life cycle

-(instancetype)initWithSelectedLocation:(FRLocationEntity *)location placemarks:(NSArray<TTPlacemarkItem *> *)placemarks completionHandle:(TTSelectedLocationCompletion)completion {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.selectedLocationCompletion = completion;
        self.nearbyViewModel = [[FRForumLocationSelectViewModel alloc] init];
        [_nearbyViewModel lastPlacemarks:placemarks];
        if (location != nil) {
            [_nearbyViewModel insertLocation:location atIndex:0];
            self.preSelectedLocation = location;
        }
    }
    return self;
}

-(instancetype _Nonnull)initWithSelectedLocation:(FRLocationEntity * _Nullable)location placemarks:(NSArray <TTPlacemarkItem *> * _Nullable)placemarks hideNilLocationCell:(BOOL)isHideNilLocationCell completionHandle:(TTSelectedLocationCompletion _Nullable)completion {
    
    self = [self initWithSelectedLocation:location placemarks:placemarks completionHandle:completion];
    if (self) {
        self.isHideNilLocationCell = isHideNilLocationCell;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithSelectedLocation:nil placemarks:nil completionHandle:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithSelectedLocation:nil placemarks:nil completionHandle:nil];
}

- (void)dealloc {
    _searchController.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)changePreSelectLocation:(FRLocationEntity * _Nullable)location {
    self.preSelectedLocation = location;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    TTNavigationBarItemContainerView *leftBarButton = [SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfLeft withTitle:NSLocalizedString(@"取消", nil) target:self action:@selector(dismiss:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    
    self.locationsList = [[SSThemedTableView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _locationsList.backgroundColorThemeKey = kColorBackground4;
    _locationsList.separatorStyle = UITableViewCellSeparatorStyleNone;
    _locationsList.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _locationsList.delegate = self;
    _locationsList.dataSource = self;
    [self.view addSubview:self.locationsList];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, 44)];
    searchBar.delegate = self;
    searchBar.translucent = NO;
    [searchBar setBackgroundImage:[[UIImage themedImageNamed:@"searchbar_location"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    [searchBar setImage:[UIImage themedImageNamed:@"search_discover"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [searchBar setImage:[UIImage themedImageNamed:@"search_discover_press"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateHighlighted];
    
    [searchBar setSearchFieldBackgroundImage:[UIImage themedImageNamed:@"searchbox_search"] forState:UIControlStateNormal];
    [searchBar setSearchFieldBackgroundImage:[UIImage themedImageNamed:@"searchbox_search_press"] forState:UIControlStateHighlighted];
    
    searchBar.placeholder = NSLocalizedString(@"搜索附近的位置", nil) ;
    if ([[[TTThemeManager sharedInstance_tt] currentThemeName] isEqualToString:@"night"]) {
        searchBar.barStyle = UIBarStyleBlack;
    } else {
        searchBar.barStyle = UIBarStyleDefault;
    }
    UITextField *textField = (UITextField *)[self containerView:searchBar searchSubViewWithClass:[UITextField class]];
    textField.font = [UIFont systemFontOfSize:14];
    textField.textColor = [[TTThemeManager sharedInstance_tt] themedColorForKey:kColorText1];
    searchBar.tintColor = [[TTThemeManager sharedInstance_tt] themedColorForKey:kColorText1];
    _locationsList.tableHeaderView = searchBar;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    _searchController.searchResultsDelegate = self;
    _searchController.searchResultsDataSource = self;
    _searchController.delegate = self;
    
    //UISearchDisplayController的searchBar和tableview关联之后,会在tableview上添加添加一个子view。去之，防止夜间模式下拉tableview时候，出现白块（view）。Orz
    [[[_locationsList subviews] firstObject] removeFromSuperview];
    
    if (!self.isHideNilLocationCell) { // 显示 不选地址 cell
        if (_preSelectedLocation == nil) {
            [_locationsList selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
            [_locationsList selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    else {  // 隐藏 不选地址 cell
        if (_preSelectedLocation != nil) {
            [_locationsList selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
    if (![self locationServiceAvailable]) {
        [self performSelector:@selector(showOpenLocationAlert) withObject:self afterDelay:1];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if (self.nearbyViewModel.isLastLoadError) {
        __weak typeof(self) weakSelf = self;
        [self.nearbyViewModel loadNearbyLocationsWithCompletionHandle:^(FRLocationEntity *cityLocationItem, NSArray *locationItems, NSError *error) {
            [weakSelf.locationsList reloadData];
        }];
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = [_nearbyViewModel.locationItems count];
    if (tableView == _locationsList) {
        if (!self.isHideNilLocationCell) {
            number += 2;//不显示地理位置 和 加载更多
        }
        else {
            number += 1;//加载更多
        }
        return number;
    } else {
        if (_searchViewModel == nil) {
            return 0;
        } else {
            return [_searchViewModel.locationItems count]+1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _locationsList) {
        NSInteger count = _nearbyViewModel.locationItems.count + 2;
        if (count - 1 == indexPath.row) {
            //加载更多
            return kForumLocationLoadMoreCell;
        } else {
            if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXSeries]) {
                return 54;
            } else {
                return 50;
            }
        }
    } else {
        if ([_searchViewModel.locationItems count] == indexPath.row) {
            //加载更多
            return kForumLocationLoadMoreCell;
        } else {
            if ([TTDeviceHelper is667Screen] || [TTDeviceHelper is736Screen] || [TTDeviceHelper isIPhoneXSeries]) {
                return 54;
            } else {
                return 50;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *singleLineCellIndentifier = @"singleLineCellIndentifier";
    static NSString *doubleLineCellIndentifier = @"doubleLineCellIndentifier";
    static NSString *loadMoreCellIdentifier    = @"loadMoreCellIdentifier";
    
    if (tableView == _locationsList) {
        
        NSInteger count;
        if (!self.isHideNilLocationCell) {
            count = _nearbyViewModel.locationItems.count + 2;
        } else {
            count = _nearbyViewModel.locationItems.count + 1;
        }
        
        if (count -1 == indexPath.row) {
            FRForumLocationLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:loadMoreCellIdentifier];
            if (cell == nil) {
                cell = [[FRForumLocationLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
            }
            
            if (_nearbyViewModel.isLastLoadError) {
                
                cell.state = FRForumLocationLoadMoreCellStateFailed;
                
            } else if (_nearbyViewModel.isQuery || _nearbyViewModel.hasMore) {
                if (_loadNearbyStartDate == nil) {
                    self.loadNearbyStartDate = [NSDate date];
                }
                cell.state = FRForumLocationLoadMoreCellStateLoading;
                __weak typeof(self) weakSelf = self;
                [_nearbyViewModel loadNearbyLocationsWithCompletionHandle:^(FRLocationEntity *cityLocationItem, NSArray *locationItems, NSError *error) {
                    long long timeInterval = [[NSDate date] timeIntervalSinceDate:weakSelf.loadNearbyStartDate] * 1000;
                    if (error == nil && locationItems.count > 0) {
                        //加载附近位置成功
                        if (weakSelf.isFirstLoadNearbyPoiLocFinish == NO) {
                            weakSelf.isFirstLoadNearbyPoiLocFinish = YES;
                            [weakSelf trackWithEvent:@"topic_post" label:@"location" extraDictionary:@{@"value":[NSNumber numberWithLongLong:timeInterval]}];
                            
                            [weakSelf trackWithEvent:@"topic_post" label:@"location_request_finish" extraDictionary:@{
                                                                                                                  @"value":[NSNumber numberWithLongLong:timeInterval],
                                                                                                                  @"ext_value":@(0)
                                                                                                                  }];
                        }
                        NSMutableArray *insetIndexs = [NSMutableArray array];
                        NSInteger i = weakSelf.nearbyViewModel.locationItems.count - locationItems.count + 1;
                        if (cityLocationItem != nil) {
                            //本次加载数据时候获取到了城市信息
                            [insetIndexs addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
                        }
                        for (NSInteger j = 0; j<locationItems.count; j ++) {
                            [insetIndexs addObject:[NSIndexPath indexPathForRow:i + j inSection:0]];
                        }
                        [weakSelf.locationsList beginUpdates];
                        [weakSelf.locationsList reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                        [weakSelf.locationsList insertRowsAtIndexPaths:insetIndexs withRowAnimation:UITableViewRowAnimationFade];
                        [weakSelf.locationsList endUpdates];
                    } else if (error == nil){
                        //没有更多附近位置
                        if (weakSelf.isFirstLoadNearbyPoiLocFinish == NO) {
                            weakSelf.isFirstLoadNearbyPoiLocFinish = YES;
                            [weakSelf trackWithEvent:@"topic_post" label:@"location" extraDictionary:@{@"value":[NSNumber numberWithLongLong:timeInterval]}];
                            
                            [weakSelf trackWithEvent:@"topic_post" label:@"location_request_finish" extraDictionary:@{
                                                                                                                  @"ext_value":[NSNumber numberWithLongLong:timeInterval],
                                                                                                                  @"value":@(0)
                                                                                                                  }];
                        }
                        [weakSelf.locationsList beginUpdates];
                        [weakSelf.locationsList reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                        if (cityLocationItem != nil) {
                            [weakSelf.locationsList insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                        }
                        [weakSelf.locationsList endUpdates];
                    } else {
                        if (weakSelf.isFirstLoadNearbyPoiLocFinish == NO) {
                            weakSelf.isFirstLoadNearbyPoiLocFinish = YES;
                            [weakSelf trackWithEvent:@"topic_post" label:@"location" extraDictionary:@{@"ext_value":[NSNumber numberWithLongLong:timeInterval]}];
                            
                            [weakSelf trackWithEvent:@"topic_post" label:@"location_request_finish" extraDictionary:@{
                                                                                                                  @"ext_value":[NSNumber numberWithLongLong:timeInterval],
                                                                                                                  @"value":@(0)
                                                                                                                  }];
                        }
                        //加载出错
                        [weakSelf.locationsList reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }];
            } else {
                cell.state = FRForumLocationLoadMoreCellStateNoMore;
            }
            
            return cell;
        } else {
            
            if (!self.isHideNilLocationCell) {
                switch (indexPath.row) {
                    case 0:{
                        FRForumLocationSingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:singleLineCellIndentifier];
                        if (cell == nil) {
                            cell = [[FRForumLocationSingleLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:singleLineCellIndentifier];
                        }
                        cell.title = NSLocalizedString(@"不显示位置", nil);
                        cell.cellStyle = FRForumLocationSingleLineCellStyleValue1;
                        return cell;
                    }
                    case 1:{
                        FRLocationEntity *firstLocation = [_nearbyViewModel.locationItems firstObject];
                        if (firstLocation.locationType == FRLocationEntityTypeCity) {
                            FRForumLocationSingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:singleLineCellIndentifier];
                            if (cell == nil) {
                                cell = [[FRForumLocationSingleLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:singleLineCellIndentifier];
                            }
                            cell.title = NSLocalizedString([[_nearbyViewModel.locationItems firstObject] city], nil);
                            cell.cellStyle = FRForumLocationSingleLineCellStyleDefault;
                            return cell;
                        } else {
                            FRForumLocationDoubleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:doubleLineCellIndentifier];
                            if (cell == nil) {
                                cell = [[FRForumLocationDoubleLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:doubleLineCellIndentifier];
                            }
                            cell.location = [_nearbyViewModel.locationItems firstObject];
                            return cell;
                        }
                    }
                    default:{
                        FRForumLocationDoubleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:doubleLineCellIndentifier];
                        if (cell == nil) {
                            cell = [[FRForumLocationDoubleLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:doubleLineCellIndentifier];
                        }
                        cell.location = [_nearbyViewModel.locationItems objectAtIndex:indexPath.row - 1];
                        return cell;
                    }
                }
            } else {
                switch (indexPath.row) {
                    case 0:{
                        FRLocationEntity *firstLocation = [_nearbyViewModel.locationItems firstObject];
                        if (firstLocation.locationType == FRLocationEntityTypeCity) {
                            FRForumLocationSingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:singleLineCellIndentifier];
                            if (cell == nil) {
                                cell = [[FRForumLocationSingleLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:singleLineCellIndentifier];
                            }
                            cell.title = NSLocalizedString([[_nearbyViewModel.locationItems firstObject] city], nil);
                            cell.cellStyle = FRForumLocationSingleLineCellStyleDefault;
                            return cell;
                        } else {
                            FRForumLocationDoubleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:doubleLineCellIndentifier];
                            if (cell == nil) {
                                cell = [[FRForumLocationDoubleLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:doubleLineCellIndentifier];
                            }
                            cell.location = [_nearbyViewModel.locationItems firstObject];
                            return cell;
                        }
                    }
                    default:{
                        FRForumLocationDoubleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:doubleLineCellIndentifier];
                        if (cell == nil) {
                            cell = [[FRForumLocationDoubleLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:doubleLineCellIndentifier];
                        }
                        cell.location = [_nearbyViewModel.locationItems objectAtIndex:indexPath.row];
                        return cell;
                    }
                }
            }
        }
        
    } else {
        //search result table
        NSInteger count = [_searchViewModel.locationItems count] + 1;
        if ([_searchViewModel.locationItems count] == indexPath.row) {
            FRForumLocationLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:loadMoreCellIdentifier];
            if (cell == nil) {
                cell = [[FRForumLocationLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMoreCellIdentifier];
            }
            if (_searchViewModel.isLastLoadError) {
                
                cell.state = FRForumLocationLoadMoreCellStateFailed;
                
            } else if (_searchViewModel.isQuery || _searchViewModel.hasMore) {
                cell.state = FRForumLocationLoadMoreCellStateLoading;
                __weak typeof(self) weakSelf = self;
                [_searchViewModel searchNearbyLocationsWithKeyword:self.searchController.searchBar.text CompletionHandle:^(FRLocationEntity *cityLocationItem, NSArray *locationItems, NSError *error) {
                    if (locationItems.count > 0) {
                        weakSelf.lastSearchContainsZeroResult = NO;
                    } else {
                        weakSelf.lastSearchContainsZeroResult = YES;
                    }
                    if (error == nil && locationItems.count > 0) {
                        //搜索附近位置成功
                        NSInteger i = weakSelf.searchViewModel.locationItems.count - locationItems.count;
                        NSMutableArray *insetIndex = [NSMutableArray array];
                        for (NSInteger j = 0; j<locationItems.count; j++) {
                            [insetIndex addObject:[NSIndexPath indexPathForRow:i+j inSection:0]];
                        }
                        [weakSelf.searchController.searchResultsTableView beginUpdates];
                        [weakSelf.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                        [weakSelf.searchController.searchResultsTableView insertRowsAtIndexPaths:insetIndex withRowAnimation:UITableViewRowAnimationFade];
                        [weakSelf.searchController.searchResultsTableView endUpdates];
                        
                    } else {
                        // 没有更多附近位置 || 加载出错
                            if (weakSelf.searchViewModel) {
                                [weakSelf.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.searchViewModel.locationItems.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                            }
                    }
                    
                }];
            } else {
                cell.state = FRForumLocationLoadMoreCellStateNoMore;
            }
            return cell;
        } else {
            FRForumLocationDoubleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:doubleLineCellIndentifier];
            if (cell == nil) {
                cell = [[FRForumLocationDoubleLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:doubleLineCellIndentifier];
            }
            cell.location = [_searchViewModel.locationItems objectAtIndex:indexPath.row];
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.locationsList) {
        
        NSInteger count;
        if (!self.isHideNilLocationCell) {
            count = _nearbyViewModel.locationItems.count + 2;
        } else {
            count = _nearbyViewModel.locationItems.count + 1;
        }
        
        if (count -1 == indexPath.row) {
            if (_nearbyViewModel.isLastLoadError) {
                __weak typeof(self) weakSelf = self;
                [_nearbyViewModel loadNearbyLocationsWithCompletionHandle:^(FRLocationEntity *cityLocationItem, NSArray *locationItems, NSError *error) {
                    
                    if (error == nil && locationItems.count > 0) {
                        //加载附近位置成功
                        
                        NSMutableArray *insetIndexs = [NSMutableArray array];
                        NSInteger i = weakSelf.nearbyViewModel.locationItems.count - locationItems.count + 1;
                        if (cityLocationItem != nil) {
                            //本次加载数据时候获取到了城市信息
                            [insetIndexs addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
                        }
                        for (NSInteger j = 0; j<locationItems.count; j ++) {
                            [insetIndexs addObject:[NSIndexPath indexPathForRow:i + j inSection:0]];
                        }
                        [weakSelf.locationsList beginUpdates];
                        [weakSelf.locationsList reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                        [weakSelf.locationsList insertRowsAtIndexPaths:insetIndexs withRowAnimation:UITableViewRowAnimationFade];
                        [weakSelf.locationsList endUpdates];
                        
                    } else if (error == nil){
                        //没有更多附近位置
                        [weakSelf.locationsList beginUpdates];
                        [weakSelf.locationsList reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                        if (cityLocationItem != nil) {
                            [weakSelf.locationsList insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                        }
                        [weakSelf.locationsList endUpdates];
                    } else {
                        //加载出错
                        [weakSelf.locationsList reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }];
                
            }
            
            NSInteger indexOffset;
            if (!self.isHideNilLocationCell) {
                indexOffset = 1;
            } else {
                indexOffset = 0;
            }
            if (_preSelectedLocation == nil) {
                if (!self.isHideNilLocationCell) {
                    [_locationsList selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
            else if (_preSelectedLocation.locationType == FRLocationEntityTypeCity){
                [_locationsList selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 + indexOffset inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            else if ([[_nearbyViewModel.locationItems firstObject] locationType] == FRLocationEntityTypeCity){
                [_locationsList selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 + indexOffset inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            else {
                [_locationsList selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 + indexOffset inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            
        } else {
            if (!self.isHideNilLocationCell) {
                if (_selectedLocationCompletion) {
                    switch (indexPath.row) {
                        case 0:{
                            [self trackWithEvent:@"topic_post" label:@"non_location" extraDictionary:nil];
                            _selectedLocationCompletion(nil, NO);
                        }
                            break;
                        default:{
                            [TTTrackerWrapper eventV3:@"confirm_location" params:nil];
                            _selectedLocationCompletion([_nearbyViewModel.locationItems objectAtIndex:indexPath.row - 1], NO);
                        }
                            break;
                    }
                }
            } else {
                if (_selectedLocationCompletion) {
                    [TTTrackerWrapper eventV3:@"confirm_location" params:nil];
                    _selectedLocationCompletion([_nearbyViewModel.locationItems objectAtIndex:indexPath.row], NO);
                }
            }
            
            [self dismiss:nil];
        }
        
    } else {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSInteger count = [self.searchViewModel.locationItems count]+1;
        if ([cell isKindOfClass:[FRForumLocationLoadMoreCell class]]) {
            __weak typeof(self) weakSelf = self;
            [_searchViewModel searchNearbyLocationsWithKeyword:self.searchController.searchBar.text CompletionHandle:^(FRLocationEntity *cityLocationItem, NSArray *locationItems, NSError *error) {
                
                if (error == nil && locationItems.count > 0) {
                    //搜索附近位置成功
                    
                    NSInteger i = weakSelf.searchViewModel.locationItems.count - locationItems.count;
                    NSMutableArray *insetIndex = [NSMutableArray array];
                    for (NSInteger j = 0; j<locationItems.count; j++) {
                        [insetIndex addObject:[NSIndexPath indexPathForRow:i+j inSection:0]];
                    }
                    [weakSelf.searchController.searchResultsTableView beginUpdates];
                    [weakSelf.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    [weakSelf.searchController.searchResultsTableView insertRowsAtIndexPaths:insetIndex withRowAnimation:UITableViewRowAnimationFade];
                    [weakSelf.searchController.searchResultsTableView endUpdates];
                } else if (error == nil){
                    //没有更多附近位置
                    [weakSelf.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.searchViewModel.locationItems.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                } else {
                    //加载出错
                    [weakSelf.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.searchViewModel.locationItems.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
            }];
        } else {
            if (_selectedLocationCompletion) {
                [self trackWithEvent:@"topic_post" label:@"confirm" extraDictionary:nil];
                _selectedLocationCompletion([_searchViewModel.locationItems objectAtIndex:indexPath.row], NO);
            }
            [self dismiss:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView != self.locationsList) {
        return 44.f;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView != self.locationsList) {
        return [UIView new];
    }
    return nil;
}

#pragma UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [TTTrackerWrapper eventV3:@"click_search_location" params:nil];
    BOOL locationServiceAvailabel = [self locationServiceAvailable];
    if (locationServiceAvailabel) {
        return YES;
    } else {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if(status == kCLAuthorizationStatusNotDetermined) {
            [[TTLocationManager sharedManager] startGeolocatingWithCompletionHandler:nil];
        } else {
            [self showOpenLocationAlert];
        }
        return NO;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // 国外 || settings 不做地址suggest
    if (![TTGoogleMapGeocoder ifInChina:[[TTLocationManager sharedManager] systemPlacemarkItem].coordinate] || ![TTKitchen getBOOL:kTTKUGCPostLocationSuggestEnable]) {
        return;
    }
    
    if (self.searchViewModel && self.searchViewModel.locationItems.count > 0) {
        self.previousValidSearchViewModel = [self.searchViewModel copy];
    }
    if (!self.searchViewModel) {
        self.searchViewModel = [[FRForumLocationSelectViewModel alloc] init];
    }
    
    if (self.searchViewModel.locationItems.count == 0) {
        [_searchController.searchResultsTableView reloadData];
    }
    
    if (isEmptyString(searchText)) {
        self.previousValidSearchViewModel = nil;
        return;
    }
    
    if (!isEmptyString(self.previousValidSearchViewModel.keyword) && [searchText containsString:self.previousValidSearchViewModel.keyword] && self.lastSearchContainsZeroResult) {
        return;
    }
    
    [self.searchViewModel cancelPreviousRequest];
    
    self.searchStartDate = [NSDate date];
    __weak typeof(self) weakSelf = self;
    NSInteger count = [self.searchViewModel.locationItems count] + 1;
    [_searchViewModel searchNearbyLocationsWithKeyword:searchText CompletionHandle:^(FRLocationEntity *cityLocationItem, NSArray *locationItems, NSError *error) {
        long long timeInterval = [[NSDate date] timeIntervalSinceDate:weakSelf.searchStartDate] * 1000;
        if (error == nil && locationItems.count > 0) {
            //搜索附近位置成功
            [weakSelf trackWithEvent:@"topic_post" label:@"search_location" extraDictionary:@{@"value":[NSNumber numberWithLongLong:timeInterval]}];
            [weakSelf trackWithEvent:@"topic_post" label:@"search_success_location" extraDictionary:nil];
            weakSelf.lastSearchContainsZeroResult = NO;
            
            NSInteger resultCount = locationItems.count + 1;
            
            NSMutableArray *reloadIndex = [NSMutableArray array];
            NSMutableArray *deleteIndex = [NSMutableArray array];
            NSMutableArray *insetIndex = [NSMutableArray array];
            NSInteger cellCount = [weakSelf.searchController.searchResultsTableView numberOfRowsInSection:0];
            for (NSInteger index = 0; index < MIN(cellCount, resultCount); index++) {
                [reloadIndex addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            }
            if (cellCount > resultCount) {
                for (NSInteger index = resultCount; index < cellCount; index++) {
                    [deleteIndex addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                }
            } else if (cellCount < resultCount) {
                for (NSInteger index = cellCount; index < resultCount; index++) {
                    [insetIndex addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                }
            }
            
            if ([weakSelf.searchController.searchResultsTableView numberOfRowsInSection:0] == reloadIndex.count) {
                [weakSelf.searchController.searchResultsTableView beginUpdates];
                [weakSelf.searchController.searchResultsTableView reloadRowsAtIndexPaths:reloadIndex withRowAnimation:UITableViewRowAnimationFade];
                if (deleteIndex.count > 0) {
                    [weakSelf.searchController.searchResultsTableView deleteRowsAtIndexPaths:deleteIndex withRowAnimation:UITableViewRowAnimationFade];
                }
                if (insetIndex.count > 0) {
                    [weakSelf.searchController.searchResultsTableView insertRowsAtIndexPaths:insetIndex withRowAnimation:UITableViewRowAnimationFade];
                }
                [weakSelf.searchController.searchResultsTableView endUpdates];
            } else {
                [weakSelf.searchController.searchResultsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                [weakSelf.searchController.searchResultsTableView reloadData];
            }
        } else {
            
            if (error == nil) {
                //没有更多附近位置
                [weakSelf trackWithEvent:@"topic_post" label:@"search_location" extraDictionary:nil];
                [weakSelf trackWithEvent:@"topic_post" label:@"search_fail_location" extraDictionary:nil];
            } else {
                //加载出错
                [weakSelf trackWithEvent:@"topic_post" label:@"search_location" extraDictionary:@{@"ext_value":[NSNumber numberWithLongLong:timeInterval]}];
            }
            
            if (weakSelf.previousValidSearchViewModel && weakSelf.previousValidSearchViewModel.locationItems.count > 0) {
                // 复用上次刷新数据
                weakSelf.searchViewModel = weakSelf.previousValidSearchViewModel;
                weakSelf.lastSearchContainsZeroResult = YES;
                NSInteger resultCount = weakSelf.previousValidSearchViewModel.locationItems.count + 1;
                
                NSMutableArray *reloadIndex = [NSMutableArray array];
                NSInteger cellCount = [weakSelf.searchController.searchResultsTableView numberOfRowsInSection:0];
                for (NSInteger index = 0; index < MIN(cellCount, resultCount); index++) {
                    [reloadIndex addObject:[NSIndexPath indexPathForRow:index inSection:0]];
                }
                
                if ([weakSelf.searchController.searchResultsTableView numberOfRowsInSection:0] != reloadIndex.count) {
                    [weakSelf.searchController.searchResultsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    [weakSelf.searchController.searchResultsTableView reloadData];
                }
            } else {
                // 展示空数据
                if (weakSelf.searchViewModel) {
                    [weakSelf.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.searchViewModel.locationItems.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
            
        }
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    // 国内不响应搜索按钮，走原逻辑
    if ([TTGoogleMapGeocoder ifInChina:[[TTLocationManager sharedManager] systemPlacemarkItem].coordinate] && [TTKitchen getBOOL:kTTKUGCPostLocationSuggestEnable]) {
        return;
    }
    
    self.searchViewModel = [[FRForumLocationSelectViewModel alloc] init];
    [_searchController.searchResultsTableView reloadData];
    
    self.searchStartDate = [NSDate date];
    __weak typeof(self) weakSelf = self;
    NSInteger count = [self.searchViewModel.locationItems count] + 1;
    [_searchViewModel searchNearbyLocationsWithKeyword:searchBar.text CompletionHandle:^(FRLocationEntity *cityLocationItem, NSArray *locationItems, NSError *error) {
        long long timeInterval = [[NSDate date] timeIntervalSinceDate:weakSelf.searchStartDate] * 1000;
        if (error == nil && locationItems.count > 0) {
            //搜索附近位置成功
            [self trackWithEvent:@"topic_post" label:@"search_location" extraDictionary:@{@"value":[NSNumber numberWithLongLong:timeInterval]}];
            [self trackWithEvent:@"topic_post" label:@"search_success_location" extraDictionary:nil];
            NSInteger i = weakSelf.searchViewModel.locationItems.count - locationItems.count;
            NSMutableArray *insetIndex = [NSMutableArray array];
            for (NSInteger j = 0; j<locationItems.count; j++) {
                [insetIndex addObject:[NSIndexPath indexPathForRow:i+j inSection:0]];
            }
            [weakSelf.searchController.searchResultsTableView beginUpdates];
            [weakSelf.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.searchController.searchResultsTableView insertRowsAtIndexPaths:insetIndex withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.searchController.searchResultsTableView endUpdates];
            
        } else if (error == nil){
            //没有更多附近位置
            [self trackWithEvent:@"topic_post" label:@"search_location" extraDictionary:nil];
            [self trackWithEvent:@"topic_post" label:@"search_fail_location" extraDictionary:nil];
            [weakSelf.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.searchViewModel.locationItems.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            //加载出错
            [self trackWithEvent:@"topic_post" label:@"search_location" extraDictionary:@{@"ext_value":[NSNumber numberWithLongLong:timeInterval]}];
            [weakSelf.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.searchViewModel.locationItems.count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
}

#pragma mark - UISearchDisplayDelegate
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [controller.searchBar setShowsCancelButton:YES animated:YES];
    //注：searchBar和UISearchDisplayController关联后，cancel按钮的即使设置了searchBar的barTintColor，颜色也不对。因此需要找到并且设置。
    //先hidden是为了防止在夜间模式下颜色切换怪异问题。Orz
    UIButton *cancelButton;
    UIView *topView = controller.searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            cancelButton = (UIButton*)subView;
        }
    }
    if (cancelButton) {
        cancelButton.hidden = YES;
    }
}
- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    //注：searchBar和UISearchDisplayController关联后，cancel按钮的即使设置了searchBar的barTintColor，颜色也不对。因此需要找到并且设置。
    //设置正确颜色后，取消hidden。Orz
    UIButton *cancelButton;
    UIView *topView = controller.searchBar.subviews[0];
    for (UIView *subView in topView.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
            cancelButton = (UIButton*)subView;
        }
    }
    if (cancelButton) {
        [cancelButton setTitleColor:[[TTThemeManager sharedInstance_tt] themedColorForKey:kColorText6] forState:UIControlStateNormal];
        //        [cancelButton setTitleColor:[[TTThemeManager sharedInstance_tt] themedColorForKey:kColorText6Highlighted] forState:UIControlStateHighlighted];
        cancelButton.hidden = NO;
    }
}
- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    [controller.searchBar setShowsCancelButton:NO animated:YES];
    self.searchViewModel = nil;
    self.previousValidSearchViewModel = nil;
    [controller.searchResultsTableView reloadData];
}
- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    tableView.backgroundColor = [[TTThemeManager sharedInstance_tt] themedColorForKey:kColorBackground4];
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {}
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView  {}
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {}
- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    //注：去掉无结果的"无结果"labl
    controller.searchResultsTableView.tableFooterView = [[UIView alloc] init];
    for (UIView *subView in [controller.searchResultsTableView subviews]) {
        if ([subView isKindOfClass:[UILabel class]]) {
            subView.hidden = YES;
        }
    }
    if (searchString.length == 0) {
        self.searchViewModel = nil;
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Target selector
- (void)dismiss:(id)sender {
    if (_isFirstLoadNearbyPoiLocFinish == NO) {
        self.isFirstLoadNearbyPoiLocFinish = YES;
        long long timeInterval = [[NSDate date] timeIntervalSinceDate:_loadNearbyStartDate] * 1000;
        [self trackWithEvent:@"topic_post" label:@"location" extraDictionary:@{@"ext_value":[NSNumber numberWithLongLong:timeInterval]}];
    }
    if (sender != nil) {
        [self trackWithEvent:@"topic_post" label:@"cancel_location" extraDictionary:nil];
    }
    
    if (_selectedLocationCompletion) {
        _selectedLocationCompletion(nil, YES);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Track
- (void)trackWithEvent:(NSString *)event
                 label:(NSString *)label
       extraDictionary:(NSDictionary *)extraDictionary{
    if (isEmptyString(event) || isEmptyString(label)) {
        return;
    }
    
    NSMutableDictionary * dictionary;
    if (extraDictionary.count > 0) {
        dictionary = [NSMutableDictionary dictionaryWithDictionary:extraDictionary];
    } else {
        dictionary = [NSMutableDictionary dictionary];
    }
    
    if ( self.trackDic.count > 0) {
        [dictionary addEntriesFromDictionary:self.trackDic];
    }
    
    [dictionary setValue:@"umeng" forKey:@"category"];
    [dictionary setValue:event forKey:@"tag"];
    [dictionary setValue:label forKey:@"label"];
    [TTTrackerWrapper eventData:dictionary];
}


#pragma mark - Util
- (UIView *)containerView:(nullable UIView *)containerView searchSubViewWithClass:(nullable Class)class {
    if ([containerView isKindOfClass:class]) {
        return containerView;
    } else {
        NSMutableArray *allSubView = [NSMutableArray arrayWithArray:[containerView subviews]];
        while ([allSubView count] > 0) {
            UIView *subView  = [allSubView objectAtIndex:0];
            [allSubView removeObjectAtIndex:0];
            if ([subView isKindOfClass:class]) {
                return subView;
            } else {
                [allSubView addObjectsFromArray:[subView subviews]];
            }
        }
    }
    return nil;
}

- (BOOL)locationServiceAvailable {
    return [[self class] locationServiceAvailable];
}

- (void)showOpenLocationAlert {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wtautological-pointer-compare"
    BOOL canOpenSettings = &UIApplicationOpenSettingsURLString != NULL;
#pragma clang diagnostic pop
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:self.categoryID forKey:@"enter_type"];
    [TTTrackerWrapper eventV3:@"post_location_auth_show" params:params];
    
    NSString *message = canOpenSettings ? NSLocalizedString(@"开启定位，添加你的位置（去设置项允许今日头条获取你的位置）", nil) : NSLocalizedString(@"开启定位，添加你的位置（设置>隐私>定位服务>开启今日头条定位服务）", nil);
    TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:NSLocalizedString(@"定位服务不可用", nil) message:message preferredType:TTThemedAlertControllerTypeAlert];
    if (canOpenSettings) {
        [self trackWithEvent:@"topic_post" label:@"request1_show_location" extraDictionary:nil];
        [alertController addActionWithTitle:NSLocalizedString(@"取消", nil) actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self trackWithEvent:@"topic_post" label:@"refuse_location" extraDictionary:nil];
            
            NSMutableDictionary *params = [NSMutableDictionary new];
            [params setValue:self.categoryID forKey:@"enter_type"];
            [TTTrackerWrapper eventV3:@"post_location_auth_refuse" params:params];
        }];
        [alertController addActionWithTitle:NSLocalizedString(@"现在开启", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            [self trackWithEvent:@"topic_post" label:@"accept_location" extraDictionary:nil];
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
            
            NSMutableDictionary *params = [NSMutableDictionary new];
            [params setValue:self.categoryID forKey:@"enter_type"];
            [TTTrackerWrapper eventV3:@"post_location_auth_accept" params:params];
        }];
    } else {
        [self trackWithEvent:@"topic_post" label:@"request2_location_show" extraDictionary:nil];
        [alertController addActionWithTitle:NSLocalizedString(@"确定", nil) actionType:TTThemedAlertActionTypeNormal actionBlock:nil];
    }
    [alertController showFrom:self animated:YES];
}

+ (BOOL)locationServiceAvailable {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied ||status ==kCLAuthorizationStatusNotDetermined) {
        return NO;
    }
    return YES;
}

@end
#pragma clang diagnostic pop
