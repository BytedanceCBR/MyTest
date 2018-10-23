//
//  VideoListView.m
//  Video
//
//  Created by 于 天航 on 12-8-10.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoListView.h"
#import "VideoListCell.h"
#import "SSLoadMoreCell.h"
#import "SSTablePullRefreshView.h"
#import "SSListNotifyBarView.h"
#import "VideoDetailViewController.h"
#import "VideoRecommendViewController.h"
#import "UIColorAdditions.h"

#import "VideoData.h"
#import "OrderedVideoData.h"
#import "ListDataHeader.h"
#import "VideoListDataHeader.h"
#import "VideoGetUpdatesNumberManager.h"
#import "VideoListDataOperationManager.h"
#import "VideoLocalFavoriteManager.h"
#import "VideoMainViewController.h"
#import "MobClick.h"
#import "DetailActionRequestManager.h"

#define LoadMoreCellHeight 60.f
#define kFirstRecentRefreshTag 1

@interface VideoListView () <UITableViewDelegate, UITableViewDataSource, SSTablePullRefreshViewDelegate, DetailActionRequestManagerDelegate, VideoGetUpdatesNumberDelegate> {
    
    BOOL _isLoading;
    BOOL _canLoadMore;
    
    BOOL _refreshAuto;
    BOOL _hasStartGetUpdateNumber;
    BOOL _hasGetDataList;
    BOOL _loadNewest;
    
    DataSortType _sortType;
}

@property (nonatomic, retain) UITableView *listView;
@property (nonatomic, retain) SSTablePullRefreshView *refreshView;
@property (nonatomic, retain) SSListNotifyBarView *listNotifyBarView;
@property (nonatomic, retain) UIView *loadingView;

@property (nonatomic, assign) VideoGetUpdatesNumberManager *updatesNumberManager;
@property (nonatomic, assign) VideoListDataOperationManager *dataOperation;
@property (nonatomic, retain) NSMutableDictionary *operationContext;
@property (nonatomic, retain) NSMutableDictionary *condition;
@property (nonatomic, retain) NSMutableArray *dataList;

@property (nonatomic, retain) DetailActionRequestManager *actionManager;    // for slide right unrepin operation in repinView
@property (nonatomic, retain) NSMutableArray *scanCellArray;  // for track

@end


@implementation VideoListView

@synthesize trackEventName = _trackEventName;
@synthesize scanCellArray = _scanCellArray;
@synthesize listView = _listView;
@synthesize loadingView = _loadingView;
@synthesize refreshView=_refreshView;
@synthesize listNotifyBarView=_listNotifyBarView;

@synthesize operationContext = _operationContext;
@synthesize condition = _condition;
@synthesize dataList = _dataList;
@synthesize dataOperation = _dataOperation;
@synthesize updatesNumberManager = _updatesNumberManager;
@synthesize actionManager = _actionManager;

- (void)dealloc
{
    if ([_trackEventName isEqualToString:@"video_tag"] && _scanCellArray) {
        [MobClick event:@"video_tab" label:@"scan_cell" acc:[_scanCellArray count]];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _updatesNumberManager.delegate = nil;
    
    self.trackEventName = nil;
    self.scanCellArray = nil;
    self.listView = nil;
    self.refreshView = nil;
    self.listNotifyBarView = nil;
    self.loadingView = nil;
    self.operationContext = nil;
    self.dataList = nil;
    self.condition = nil;
    self.dataOperation = nil;
    self.updatesNumberManager = nil;
    self.actionManager = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame condition:(NSDictionary *)condition
{
    self = [super initWithFrame:frame];
    if (self) {

        self.dataOperation = [VideoListDataOperationManager sharedOperation];
        self.dataList = [[[NSMutableArray alloc] init] autorelease];
        self.condition = [[condition mutableCopy] autorelease];

        if (!condition) {
	        [_condition setObject:[NSNumber numberWithInt:ListDataTypeVideo] forKey:kListDataTypeKey];
	        [_condition setObject:[NSNumber numberWithInt:DataSortTypeRecent] forKey:kListDataConditionSortTypeKey];
        }
        
        _sortType = [[_condition objectForKey:kListDataConditionSortTypeKey] intValue];
        
        if (_sortType == DataSortTypeRecent || _sortType == DataSortTypeHot) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(reportWillResignActiveNotification:)
                                                         name:UIApplicationWillResignActiveNotification
                                                       object:[UIApplication sharedApplication]];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(reportWillTerminateNotification:)
                                                         name:UIApplicationWillTerminateNotification
                                                       object:[UIApplication sharedApplication]];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadDataFinished:)
                                                     name:ssGetListDataFinishedNotification
                                                   object:nil];
        [self loadView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame condition:nil];
}

#pragma mark - View Lifecycle

- (void)loadView
{
    CGRect vFrame = self.bounds;
    CGRect tmpFrame = vFrame;
    
    self.listView = [[[UITableView alloc] initWithFrame:tmpFrame] autorelease];
    _listView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listView.delegate = self;
    _listView.dataSource = self;
    [self addSubview:_listView];

    tmpFrame = _listView.bounds;
    tmpFrame.origin.y = 0 - tmpFrame.size.height;
    
    self.refreshView = [[[SSTablePullRefreshView alloc] initWithFrame:tmpFrame] autorelease];
    _refreshView.delegate = self;
    [_listView addSubview:_refreshView];
    
    tmpFrame.origin.y = 0.f;
    tmpFrame.size.height = SSUIFloatNoDefault(@"vuListNotifyBarHeight");
    
    self.listNotifyBarView = [[[SSListNotifyBarView alloc] initWithFrame:tmpFrame orientation:self.interfaceOrientation] autorelease];
    
    UIImage *portraitNotifyBackgroundImage = [UIImage imageNamed:@"bar_syn.png"];
    portraitNotifyBackgroundImage = [portraitNotifyBackgroundImage stretchableImageWithLeftCapWidth:floorf(portraitNotifyBackgroundImage.size.width/2)
                                                                                       topCapHeight:floorf(portraitNotifyBackgroundImage.size.height/2)];
    UIImageView *portraitNotifyBackgroundImageView = [[[UIImageView alloc] initWithImage:portraitNotifyBackgroundImage] autorelease];
    portraitNotifyBackgroundImageView.frame = _listNotifyBarView.bounds;
    
    _listNotifyBarView.portraitBackgroundView = portraitNotifyBackgroundImageView;
    [_listNotifyBarView setTextColor:SSUIStringNoDefault(@"vuStandardBlueColor")
                     textShadowColor:SSUIStringNoDefault(@"vuStandardBlueColor")
                    textShadowOffset:CGSizeZero];
//    [_listNotifyBarView showBottomShadow];
    
    [self addSubview:_listNotifyBarView];
    [self bringSubviewToFront:_listNotifyBarView];
}

- (void)didAppear
{
    [super didAppear];
    
    if (_hasGetDataList) {
        [self loadDataFromLocal:YES fromRemote:NO loadMore:NO getStats:NO loadNewest:_loadNewest loadAllLocal:NO clearCache:NO];
    }
    else {
        switch (_sortType) {
            case DataSortTypeRecent:
            case DataSortTypeHot:
                if (positionRecordOn()) {
                    
                    NSDictionary *condition = positionRecordCondition(_sortType);
                    if ([condition objectForKey:kVideoPositionRecordConditionLatestTimestampKey]
                        && [condition objectForKey:kVideoPositionRecordConditionEarliestTimestampKey]) {
                        
                        [_condition setObject:[condition objectForKey:kVideoPositionRecordConditionLatestTimestampKey]
                                       forKey:kVideoListDataConditionLatestKey];
                        [_condition setObject:[condition objectForKey:kVideoPositionRecordConditionEarliestTimestampKey]
                                       forKey:kVideoListDataConditionEarliestKey];
                        
                        [self loadDataFromLocal:YES fromRemote:NO loadMore:NO getStats:YES loadNewest:NO loadAllLocal:YES clearCache:YES];
                    }
                    else {
                        [self loadDataFromLocal:YES fromRemote:YES loadMore:NO getStats:YES loadNewest:YES loadAllLocal:NO clearCache:YES];
                    }
                }
                else {
                    [self loadDataFromLocal:YES fromRemote:YES loadMore:NO getStats:YES loadNewest:YES loadAllLocal:NO clearCache:YES];
                }
                break;
            case DataSortTypeFavorite:
                [self loadDataFromLocal:YES fromRemote:YES loadMore:NO getStats:YES loadNewest:YES loadAllLocal:NO clearCache:YES];
                break;
            default:
                break;
        }
    }
}

#pragma mark - public

- (void)refresh
{
    _refreshAuto = YES;
    [_refreshView refreshAuto:_listView];
}

#pragma mark - Actions

- (void)recordPosition
{
    if (_sortType == DataSortTypeRecent || _sortType == DataSortTypeHot) {
        if ([[_listView visibleCells] count] > 0) {
            if ([[[_listView visibleCells] objectAtIndex:0] isKindOfClass:[VideoListCell class]]) {
                
                VideoListCell *lastCell = [[_listView visibleCells] objectAtIndex:0];
                VideoData *video = lastCell.videoData;
                
                NSDictionary *recordCondition = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 ((VideoData *)[_dataList objectAtIndex:0]).behotTime, kVideoPositionRecordConditionLatestTimestampKey,
                                                 ((VideoData *)[_dataList lastObject]).behotTime, kVideoPositionRecordConditionEarliestTimestampKey,
                                                 video.behotTime, kVideoPositionRecordConditionPositionTimestampKey,
                                                 nil];
                setPositionRecordCondition(recordCondition, _sortType);
            }
        }
    }
}

- (void)reportWillResignActiveNotification:(NSNotification *)notification
{
    [self recordPosition];
}

- (void)reportWillTerminateNotification:(NSNotification *)notification
{
    [self recordPosition];
}

#pragma mark - ListDataOperation

- (BOOL)isFirstRecentRefresh
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * refreshed = [defaults objectForKey:@"VideoListViewRecentHasRefreshed"];
    if (refreshed == nil || ![refreshed boolValue]) {
        return YES;
    }
    return NO;
}

- (void)setRecentHasRefreshed
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:YES] forKey:@"VideoListViewRecentHasRefreshed"];
    [defaults synchronize];
}

- (void)openRecommendViewController
{
    trackEvent([SSCommon appName], _trackEventName, @"no_update_recommend");
//    if ([SSCommon isPadDevice]) {
//        if (_recommendView) {
//            [self closeAndReleaseRecommendView];
//        }
//        else {
//            float edge1 = screenSize().width;
//            float edge2 = screenSize().height;
//            float offsetY = [[UIApplication sharedApplication] isStatusBarHidden] ? 0 : MIN([[UIApplication sharedApplication] statusBarFrame].size.height, [[UIApplication sharedApplication] statusBarFrame].size.width);
//            float largeEdge = edge1 > edge2 ? edge1 : edge2;
//            float shortEdge = edge1 < edge2 ? edge1 : edge2;
//            CGRect commentPortraitFrame = CGRectMake(shortEdge - 480, offsetY, 480, largeEdge - offsetY);
//            CGRect commentLandscapeFrame = CGRectMake(largeEdge - 480, offsetY, 480, shortEdge - offsetY);
//            VideoHDRecommendView *recommendView = [[[VideoHDRecommendView alloc] initWithPortraitFrame:commentPortraitFrame landscapeFrame:commentLandscapeFrame currentOrientation:self.interfaceOrientation] autorelease];
//            self.recommendView = recommendView;
//            [recommendView show];
//            [recommendView willAppear];
//            [recommendView didAppear];
//            recommendView.closeTarget = self;
//            recommendView.closeSelector = @selector(closeAndReleaseRecommendView);
//        }
//    }
//    else {
        VideoRecommendViewController *controller = [[[VideoRecommendViewController alloc] init] autorelease];
        UINavigationController *nav = [SSCommon topViewControllerFor:self].navigationController;
        [nav pushViewController:controller animated:YES];
//    }
}

- (void)unRepinData:(VideoData *)video
{
    if ([video.userRepined boolValue] == YES) {
        
        [[VideoLocalFavoriteManager sharedManager] unRepinData:video];
        
        _actionManager.delegate = nil;
        
        self.actionManager = [[[DetailActionRequestManager alloc] init] autorelease];
        _actionManager.delegate = self;
        NSMutableDictionary *actionRequestCondition = [[NSMutableDictionary alloc] initWithCapacity:10];
        [actionRequestCondition setObject:[NSString stringWithFormat:@"%@", video.groupID] forKey:kDetailActionItemIDKey];
        
        [_actionManager setCondition:actionRequestCondition];
        [actionRequestCondition release];
        [_actionManager startItemActionByType:DetailActionTypeUnFavourite];
    }
}

- (BOOL)needTrackScanCell:(VideoData *)video
{
    if (!_scanCellArray) {
        self.scanCellArray = [NSMutableArray array];
    }
    
    BOOL needTrack = ![_scanCellArray containsObject:video.groupID];
    if (needTrack) {
        [_scanCellArray addObject:video.groupID];
    }
    return needTrack;
}

- (void)displayloadingView
{
    if(!_loadingView) {
        self.loadingView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];

        NSString *loadingImageName = nil;
        switch (_sortType) {
            case DataSortTypeRecent:
            case DataSortTypeHot:
                loadingImageName = @"video_loading.png";
                break;
            case DataSortTypeFavorite:
                loadingImageName = @"conllect_loading.png";
                break;
            default:
                break;
        }

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:loadingImageName]];
        _loadingView.frame = imageView.bounds;
        [_loadingView addSubview:imageView];
        _loadingView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [imageView release];
    }
    
    [self addSubview:_loadingView];
    [self bringSubviewToFront:_loadingView];
}

- (void)loadDataFromLocal:(BOOL)local fromRemote:(BOOL)remote loadMore:(BOOL)more getStats:(BOOL)stats loadNewest:(BOOL)newest loadAllLocal:(BOOL)allLocal clearCache:(BOOL)clear
{
    if (!_isLoading) {
        _isLoading = YES;
        _loadNewest = newest;
        
        if (!self.operationContext) {
            NSMutableDictionary *operationContext = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     _condition, kSSDataOperationConditionKey,
                                                     [NSNumber numberWithBool:local], kSSDataOperationFromLocalKey,
                                                     [NSNumber numberWithBool:remote], kSSDataOperationFromRemoteKey,
                                                     [NSNumber numberWithBool:more], kSSDataOperationLoadMoreKey,
                                                     [NSNumber numberWithBool:stats], kVideoDataOperationGetStatsKey,
                                                     [NSNumber numberWithBool:newest], kVideoDataOperationLoadNewestKey,
                                                     [NSNumber numberWithBool:allLocal], kVideoDataOperationLoadAllLocalKey,
                                                     [NSNumber numberWithBool:clear], kVideoDataOperationClearCacheKey,
                                                     nil];
            self.operationContext = operationContext;
        }
        else {
            [_operationContext setObject:_condition forKey:kSSDataOperationConditionKey];
            [_operationContext setObject:[NSNumber numberWithBool:local] forKey:kSSDataOperationFromLocalKey];
            [_operationContext setObject:[NSNumber numberWithBool:remote] forKey:kSSDataOperationFromRemoteKey];
            [_operationContext setObject:[NSNumber numberWithBool:more] forKey:kSSDataOperationLoadMoreKey];
            [_operationContext setObject:[NSNumber numberWithBool:stats] forKey:kVideoDataOperationGetStatsKey];
            [_operationContext setObject:[NSNumber numberWithBool:newest] forKey:kVideoDataOperationLoadNewestKey];
            [_operationContext setObject:[NSNumber numberWithBool:allLocal] forKey:kVideoDataOperationLoadAllLocalKey];
            [_operationContext setObject:[NSNumber numberWithBool:clear] forKey:kVideoDataOperationClearCacheKey];
        }
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoDataOperationRebuildKey object:self];
        [_dataOperation startExecute:_operationContext];
    }
}

- (void)loadMore
{
    if (_canLoadMore) {
        [self loadDataFromLocal:NO fromRemote:YES loadMore:YES getStats:NO loadNewest:_loadNewest loadAllLocal:NO clearCache:YES];
    }
}

- (void)scrollToRecordPosition
{
    NSDictionary *recordCondition = positionRecordCondition(_sortType);
    NSTimeInterval position = [[recordCondition objectForKey:kVideoPositionRecordConditionPositionTimestampKey] doubleValue];
    
    [_dataList enumerateObjectsUsingBlock:^(VideoData *video, NSUInteger idx, BOOL *stop) {
        if ([video.behotTime doubleValue] <= position) {
            [_listView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]
                             atScrollPosition:UITableViewScrollPositionTop
                                     animated:NO];
            *stop = YES;
        }
    }];
}

- (void)scrollToTopPostion
{
    [_listView scrollRectToVisible:CGRectMake(0, 0, _listView.bounds.size.width, _listView.bounds.size.height) animated:NO];
}

- (void)startGetUpdates
{
    if (!_hasStartGetUpdateNumber) {
        _hasStartGetUpdateNumber = YES;
        
        if (!_updatesNumberManager) {
            self.updatesNumberManager = [VideoGetUpdatesNumberManager sharedManager];
            _updatesNumberManager.delegate = self;
            
            NSNumber *timestamp = updatesTimestamp();
            if (!timestamp) {
                VideoData *video = [_dataList objectAtIndex:0];
                timestamp = video.behotTime;
                setGetUpdatesTimestamp(timestamp);
            }
            
            _updatesNumberManager.timestamps = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                         SSLogicStringNODefault(@"vlTag"), kVideoGetUpdatesTagKey,
                                                                         timestamp, kVideoGetUpdatesTimestampKey,
                                                                         nil]];
            [_updatesNumberManager timingGetUpdatesNumber];
        }
    }
}

- (void)refreshGetUpdates
{
    if (_hasStartGetUpdateNumber) {
        [[NSNotificationCenter defaultCenter] postNotificationName:VideoMVTabUpdateBadgeNotification
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                                               forKey:kVideoMVTabUpdateBadgeNotificationValueKey]];
    }
    
    VideoData *video = [_dataList objectAtIndex:0];
    setGetUpdatesTimestamp(video.behotTime);
    if (_updatesNumberManager) {
        _updatesNumberManager.timestamps = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     SSLogicStringNODefault(@"vlTag"), kVideoGetUpdatesTagKey,
                                                                     video.behotTime, kVideoGetUpdatesTimestampKey,
                                                                     nil]];
    }
}

- (void)hideLoadMoreCell
{
    if ([[_listView.visibleCells lastObject] isKindOfClass:[SSLoadMoreCell class]]) {
        CGPoint offset = _listView.contentOffset;
        offset.y -= LoadMoreCellHeight;
        [_listView scrollRectToVisible:CGRectMake(offset.x,
                                                  offset.y,
                                                  _listView.bounds.size.width,
                                                  _listView.bounds.size.height) animated:YES];
    }
}

- (void)dataOperationRebuild:(NSNotification *)notification
{
    if (notification.object != self) {
        if (_isLoading) {
            _isLoading = NO;
            [_listNotifyBarView hide];
            [_refreshView SSRefreshScrollViewDataSourceDidFinishedLoading:_listView];
        }
    }
}

- (void)delayRefreshScrollViewDataSourceDidFinishedLoading
{
    [_refreshView SSRefreshScrollViewDataSourceDidFinishedLoading:_listView];
}

- (void)loadDataFinished:(NSNotification *)notification
{
    NSDictionary *userInfo = [[notification userInfo] objectForKey:@"userInfo"];
    
	NSDictionary *responseCondition = [userInfo objectForKey:kSSDataOperationConditionKey];
    if(([responseCondition objectForKey:kListDataConditionSortTypeKey] != [_condition objectForKey:kListDataConditionSortTypeKey]) ||
       ([responseCondition objectForKey:kListDataConditionTagKey] != [_condition objectForKey:kListDataConditionTagKey])) {
        return;
    }
    
    [_listNotifyBarView hide];
    [_refreshView SSRefreshScrollViewDataSourceDidFinishedLoading:_listView];

    self.operationContext = [[userInfo mutableCopy] autorelease];
    
    BOOL finishLoad = [[userInfo objectForKey:kSSDataOperationLoadFinishedKey] boolValue];
    BOOL getMore = [[userInfo objectForKey:kSSDataOperationLoadMoreKey] boolValue];
    BOOL isRemote = [[userInfo objectForKey:kSSDataOperationFromRemoteKey] boolValue];
    BOOL loadNewest = [[userInfo objectForKey:kVideoDataOperationLoadNewestKey] boolValue];
    BOOL loadAllLocal = [[userInfo objectForKey:kVideoDataOperationLoadAllLocalKey] boolValue];
    NSArray *newDataList = [userInfo objectForKey:kSSDataOperationInsertedDataKey];
    _canLoadMore = [[userInfo objectForKey:kSSDataOperationCanLoadMoreKey] boolValue];
    
    NSArray *tmpDataList = [userInfo objectForKey:kSSDataOperationOriginalListKey];
    if (_sortType == DataSortTypeFavorite) {
        self.dataList = [[tmpDataList mutableCopy] autorelease];
        [_dataList enumerateObjectsUsingBlock:^(VideoData *video, NSUInteger idx, BOOL *stop) {
            if ([video.downloadURL length] <= 0 && [video.downloadDataStatus intValue] != VideoDownloadDataStatusNoDownloadURL) {
                video.downloadDataStatus = [NSNumber numberWithInt:VideoDownloadDataStatusNoDownloadURL];
                [[SSModelManager sharedManager] save:nil];
            }
        }];
    }
    else {
        NSMutableArray *tmpMutableList = [tmpDataList mutableCopy];
        
        NSNumber *lastGroupID = @0;
        NSString *lastTag = @"";
        for (VideoData *video in tmpDataList) {
            // fix duplicate bug
            if (([video.groupID integerValue] == [lastGroupID integerValue]) && [video.tag isEqualToString:lastTag]) {
                [tmpMutableList removeObject:video];
            }
            // remove deadlink
            else if ([video.downloadDataStatus intValue] == VideoDownloadDataStatusDeadLink) {
//#warning test annotation
                [tmpMutableList removeObject:video];
            }
            else {
                lastGroupID = video.groupID;
                lastTag = video.tag;
            }
        }
        self.dataList = tmpMutableList;
        [tmpMutableList release];
    }
    
    NSError *error = [[notification userInfo] objectForKey:@"error"];
    NSString *messageStr = nil;
    
    if(error) {
        _isLoading = NO;
        if (getMore) {
            [self hideLoadMoreCell];
        }
        else {
            SSLog(@"load error:%@", error);
            if ((_sortType == DataSortTypeRecent || _sortType == DataSortTypeHot) && !loadNewest && loadAllLocal) {
                [self performSelector:@selector(delayRefreshScrollViewDataSourceDidFinishedLoading) withObject:nil afterDelay:2.f];
                
                messageStr = NSLocalizedString(@"PositionRecordSuccess", nil);
                [self scrollToRecordPosition];
            }
            else {
                if(error.domain == kListDataErrorDomain && error.code == kListDataNetworkError) { // 无网络
                    [self performSelector:@selector(delayRefreshScrollViewDataSourceDidFinishedLoading) withObject:nil afterDelay:2.f];
                    
                    messageStr = NSLocalizedString(@"NormalNoConnect", nil);
                    [self scrollToTopPostion];
                }
                else if (error.domain == kListDataErrorDomain && error.code == kListDataUnkownError) { // 请求成功，解析错误
                    messageStr = NSLocalizedString(@"ErrorMessageCode", nil);
                }
                else { // 请求失败等网络错误
                    if ((_sortType == DataSortTypeRecent || _sortType == DataSortTypeHot) && !loadNewest && loadAllLocal) {
                        messageStr = NSLocalizedString(@"PositionRecordSuccess", nil);
                    }
                    else {
                        messageStr = NSLocalizedString(@"NormalRequestFailed", nil);
                    }
                }
            }
        }
    }
    else {
        if (finishLoad) {
            _isLoading = NO;
            
            if (!getMore) {
                if (_sortType == DataSortTypeRecent || _sortType == DataSortTypeHot) {
                    if (!loadNewest && loadAllLocal) {
                        messageStr = NSLocalizedString(@"PositionRecordSuccess", nil);
                    }
                    else if ([newDataList count] > 0) {
                        if (_sortType == DataSortTypeRecent) {
                            messageStr = [NSString stringWithFormat:NSLocalizedString(@"RecentRequestSuccess", nil), [newDataList count]];
                        }
                        else {
                            messageStr = NSLocalizedString(@"HotRequestSuccess", nil);
                        }
                    }
                    else {
                        if (_sortType == DataSortTypeRecent) {
                            messageStr = NSLocalizedString(@"RecentRequestNoNewData", nil);
                        }
                        else {
                            messageStr = NSLocalizedString(@"HotRequestSuccess", nil);
                        }
                        
                        _listNotifyBarView.displayDuration = SSListNotifyBarViewDefaultShowTimeButtonWithTarget;
                        [_listNotifyBarView.notifyButton addTarget:self action:@selector(openRecommendViewController) forControlEvents:UIControlEventTouchUpInside];
                    }
                    
                    if (!loadNewest && loadAllLocal) {
                        [self scrollToRecordPosition];
                    }
                    else if (isRemote) {
                        [self scrollToTopPostion];
                    }
                }
                else if (_sortType == DataSortTypeFavorite) {
                    if ([newDataList count] > 0) {
                        messageStr = NSLocalizedString(@"FavoriteRequestSuccess", nil);
                    }
                    
                    if (isRemote) {
                        [self scrollToTopPostion];
                    }
                }
                
                if (_sortType == DataSortTypeRecent) {
                    if ([_dataList count] > 0) {
                        if (!isRemote) {
                            [self startGetUpdates];
                        }
                        else if (loadNewest) {
                            [self refreshGetUpdates];
                        }
                    }
                }
            }
            
            _hasGetDataList = YES;
            
            //第一次刷新返回后, 提示"想回到上次浏览的位置? 进入更多页设置吧"
            if ([self isFirstRecentRefresh] && (_sortType == DataSortTypeRecent || _sortType == DataSortTypeHot) && !getMore ) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:@"想回到上次浏览的位置?\n 进入更多页设置吧"
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                          otherButtonTitles:@"设置", nil];
                alertView.tag = kFirstRecentRefreshTag;
                [alertView show];
                [alertView release];
                [self setRecentHasRefreshed];
            }
            
            if ([_dataList count] == 0) {
                [self displayloadingView];
                _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
            }
            else {
                [_loadingView removeFromSuperview];
                _listView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                [self sendSubviewToBack:_listView];
            }
        }
        else { // not finish
            if((_sortType == DataSortTypeRecent || _sortType == DataSortTypeHot) && loadAllLocal && !getMore) {
                [self scrollToRecordPosition];
            }
        }
        
        [_listView reloadData];
    }
    
    if (messageStr && !getMore && (isRemote || loadAllLocal)) {
        CGFloat duration = [messageStr isEqualToString:NSLocalizedString(@"RecentRequestNoNewData", nil)] ? 4 : 2;
        [_listNotifyBarView showMessage:messageStr delayHide:YES duration:duration];
    }
}

#pragma mark - VideoGetUpdatesNumberDelegate

- (void)videoGetUpdatesNumberManager:(VideoGetUpdatesNumberManager *)manager didGetUpdatesNumber:(NSDictionary *)updateNumberList error:(NSError *)error
{
    if (!error && _sortType == DataSortTypeRecent) {
        NSNumber *allUpdatesNumber = [updateNumberList objectForKey:SSLogicStringNODefault(@"vlTag")];
        [[NSNotificationCenter defaultCenter] postNotificationName:VideoMVTabUpdateBadgeNotification
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObject:allUpdatesNumber
                                                                                               forKey:kVideoMVTabUpdateBadgeNotificationValueKey]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger ret = 0;
    ret = [_dataList count];
    
    if (ret > 0 && _canLoadMore) {
        if (_sortType == DataSortTypeFavorite) {
            if ([_dataList count] * SSUIFloatNoDefault(@"vuListCellHeight") > _listView.bounds.size.height) {
                ret ++;
            }
        }
        else {
            ret ++;
        }
    }
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *listCellIdentifier = @"list_cell_identifier";
    static NSString *loadCellIdentifier = @"load_cell_identifier";
    
    if (indexPath.row < [_dataList count]) {
        VideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:listCellIdentifier];
        if (cell == nil) {
            cell = [[[VideoListCell alloc] initWithStyle:UITableViewCellStyleValue1
                                         reuseIdentifier:listCellIdentifier] autorelease];
        } 
        
        VideoData *data = [_dataList objectAtIndex:indexPath.row];
        [cell setVideoData:data type:VideoListCellTypeNormal];
        cell.trackEventName = _trackEventName;
        
        [cell refreshUI];
        
        if ([_trackEventName isEqualToString:@"video_tab"]) {
            [self needTrackScanCell:cell.videoData];
        }
        
        return cell;
    }
    else {
        SSLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:loadCellIdentifier];
        if (cell == nil) {
            cell = [[[SSLoadMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadCellIdentifier] autorelease];
        }
        
        [self loadMore];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            [self unRepinData:[_dataList objectAtIndex:indexPath.row]];
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat ret = 0.f;
    
    if (indexPath.row < [_dataList count]) {
        ret = SSUIFloatNoDefault(@"vuListCellHeight");
        if ([((VideoData *)[_dataList objectAtIndex:indexPath.row]).socialActionStr length] > 0) {
            ret += SSUIFloatNoDefault(@"vuSocialActionLabelHeight") + SSUIFloatNoDefault(@"vuSocialActionLabelTopMargin");
        }
    }
    else {
        ret = LoadMoreCellHeight;
    }
    
    return ret;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_dataList count]) {
        VideoDetailViewController *controller = [[[VideoDetailViewController alloc] init] autorelease];
        controller.video = [_dataList objectAtIndex:indexPath.row];

        UINavigationController *nav = [SSCommon topViewControllerFor:self].navigationController;
        [nav pushViewController:controller animated:YES];
        
        trackEvent([SSCommon appName], _trackEventName, @"click_cell");
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_dataList count] && _sortType == DataSortTypeFavorite) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_dataList count] && _sortType == DataSortTypeFavorite) {
        return @"取消收藏";
    }
    else {
        return nil;
    }
}

#pragma mark - SSTablePullRefreshViewDelegate

- (void)SSTablePullRefreshViewDidTriggerRefresh:(SSTablePullRefreshView *)view
{
    if (_sortType == DataSortTypeRecent || _sortType == DataSortTypeHot) {
        [self loadDataFromLocal:YES fromRemote:YES loadMore:NO getStats:NO loadNewest:YES loadAllLocal:NO clearCache:YES];
    }
    else if (_sortType == DataSortTypeFavorite) {
        [self loadDataFromLocal:YES fromRemote:YES loadMore:NO getStats:NO loadNewest:YES loadAllLocal:NO clearCache:YES];
    }
    
    if (!_refreshAuto) {
        trackEvent([SSCommon appName], _trackEventName, @"refresh_pulldown");
    }
    _refreshAuto = NO;
}

- (BOOL)SSTablePullRefreshViewDataSourceIsLoading:(SSTablePullRefreshView *)view
{
    return _isLoading;
}

- (NSDate *)SSTablePullRefreshViewDataSourceLastUpdated:(SSTablePullRefreshView *)view
{
    return [NSDate date];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    [_refreshView SSRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kFirstRecentRefreshTag) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [[NSNotificationCenter defaultCenter] postNotificationName:VideoMainViewChangeViewNotification object:kVideoMainViewChangeToMoreView];
        }
    }
}

#pragma mark - DetailActionRequestManagerDelegate

- (void)detailActionRequestManager:(DetailActionRequestManager *)manager itemActionGotUserInfo:(id)userInfo error:(NSError *)error
{
    [self loadDataFromLocal:YES fromRemote:NO loadMore:NO getStats:NO loadNewest:_loadNewest loadAllLocal:NO clearCache:YES];
}

@end

