//
//  VideoDownloadListView.m
//  Video
//
//  Created by 于 天航 on 12-8-2.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "VideoDownloadListView.h"
#import "VideoDetailViewController.h"
#import "VideoListCell.h"
#import "SSTitleBarView.h"
#import "VideoTitleBarButton.h"
#import "SSSegmentControl.h"
#import "VideoTitleBarSegment.h"
#import "SSListNotifyBarView.h"
#import "VideoListCell.h"
#import "SSLoadMoreCell.h"
#import "UIColorAdditions.h"
#import "VideoData.h"
#import "VideoActivityIndicatorView.h"
#import "VideoMainViewController.h"

#import "VideoDownloadDataManager.h"
#import "ListDataHeader.h"
#import "VideoListDataHeader.h"
#import "VideoGetStatsOperationManager.h"

#define LoadMoreCellHeight 60.f
#define TitleSegmentControlWidth 2*SSUIFloatNoDefault(@"vuTitleBarSegmentWidth")

#define TrackDownloadTabEventName _dataListType == VideoDownloadDataListTypeDownloading ? @"downloading_tab" : @"downloaded_tab"

@interface VideoDownloadListView () <UITableViewDelegate, 
                                     UITableViewDataSource,
                                     SSSegmentControlDelegate,
                                     VideoDownloadDataManagerDelegate>
{    
    BOOL _isLoading;
    BOOL _refreshAuto;
    BOOL _hasGetDownloadedStats;
    BOOL _hasGetDownloadingStats;
    
//    BOOL _isComplete;
//    VideoListCell *_completeCell;
    
    VideoDownloadDataListType _dataListType;
}

@property (nonatomic, retain) SSTitleBarView *titleBar;
@property (nonatomic, retain) UITableView *listView;
@property (nonatomic, retain) SSListNotifyBarView *listNotifyBarView;
@property (nonatomic, retain) SSSegmentControl *titleSegmentControl;
@property (nonatomic, retain) NSArray *segments;
@property (nonatomic, assign) VideoDownloadDataManager *dataManager;
@property (nonatomic, retain) NSMutableDictionary *condition;
@property (nonatomic, retain) NSArray *dataList;
@property (nonatomic, retain) VideoTitleBarButton *editButton;
@property (nonatomic, retain) VideoTitleBarButton *bulkStartButton;
@property (nonatomic, retain) UIView *noDownloadView;

@property (nonatomic, retain) UITableView *hasDownloadListView;
@property (nonatomic, retain) UITableView *downloadingListView;

@end

@implementation VideoDownloadListView

@synthesize titleBar = _titleBar;
@synthesize listView = _listView;
@synthesize listNotifyBarView = _listNotifyBarView;
@synthesize titleSegmentControl = _titleSegmentControl;
@synthesize segments = _segments;
@synthesize dataManager = _dataManager;
@synthesize condition = _condition;
@synthesize dataList = _dataList;
@synthesize editButton = _editButton;
@synthesize bulkStartButton = _bulkStartButton;
@synthesize noDownloadView = _noDownloadView;

@synthesize hasDownloadListView = _hasDownloadListView;
@synthesize downloadingListView = _downloadingListView;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _hasGetDownloadedStats = NO;
    _hasGetDownloadingStats = NO;
    
    _dataManager.delegate = nil;

    self.titleBar = nil;
    self.listView = nil;
    self.listNotifyBarView = nil;
    self.titleSegmentControl = nil;
    self.segments = nil;
    self.condition = nil;
    self.dataList = nil;
    self.editButton = nil;
    self.bulkStartButton = nil;
    self.noDownloadView = nil;
    self.hasDownloadListView = nil;
    self.downloadingListView = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    	self.dataManager = [VideoDownloadDataManager sharedManager];
        _dataManager.delegate = self;
        _dataListType = VideoDownloadDataListTypeHasDownload;
        
        self.condition = [NSMutableDictionary dictionary];
        [_condition setObject:[NSNumber numberWithInt:ListDataTypeVideo] forKey:kListDataTypeKey];
        [_condition setObject:[NSNumber numberWithInt:_dataListType] forKey:kVideoListDataDownloadDataListType];
        
        VideoTitleBarSegment *hasDownloadSegment = [VideoTitleBarSegment buttonWithType:UIButtonTypeCustom];
        [hasDownloadSegment setTitle:@"已下载" forState:UIControlStateNormal];
        
        VideoTitleBarSegment *downloadingSegment = [VideoTitleBarSegment buttonWithType:UIButtonTypeCustom];
        [downloadingSegment setTitle:@"下载中" forState:UIControlStateNormal];
        
        self.segments = [NSArray arrayWithObjects:hasDownloadSegment, downloadingSegment, nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(reportVideoDownloadTabCompleteNotification:)
//                                                     name:VideoDownloadTabCompleteNotification
//                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadDataFinished:)
                                                     name:ssGetListDataFinishedNotification
                                                   object:nil];

        [self loadView];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)loadView
{
    CGRect vFrame = self.bounds;
    CGRect tmpFrame = vFrame;
    tmpFrame.size.height = SSUIFloatNoDefault(@"vuTitleBarHeight");
    
    self.titleBar = [[[SSTitleBarView alloc] initWithFrame:tmpFrame orientation:self.interfaceOrientation] autorelease];
    _titleBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _titleBar.titleBarEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    UIImage *portraitBackgroundImage = [UIImage imageNamed:@"titlebarbg.png"];
    portraitBackgroundImage = [portraitBackgroundImage stretchableImageWithLeftCapWidth:portraitBackgroundImage.size.width/2
                                                                           topCapHeight:1.f];
    UIImageView *portraitBackgroundView = [[[UIImageView alloc] initWithImage:portraitBackgroundImage] autorelease];
    portraitBackgroundView.frame = _titleBar.bounds;
    _titleBar.portraitBackgroundView = portraitBackgroundView;
//    [_titleBar showBottomShadow];
    [self addSubview:_titleBar];
    
    tmpFrame.origin.y = CGRectGetMaxY(_titleBar.frame);
    tmpFrame.size.height = vFrame.size.height - _titleBar.frame.size.height;
    
    self.hasDownloadListView = [[[UITableView alloc] initWithFrame:tmpFrame] autorelease];
    _hasDownloadListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _hasDownloadListView.backgroundColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuBackgroundColor")];
    _hasDownloadListView.delegate = self;
    _hasDownloadListView.dataSource = self;

    self.downloadingListView = [[[UITableView alloc] initWithFrame:tmpFrame] autorelease];
    _downloadingListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _downloadingListView.backgroundColor = [UIColor colorWithHexString:SSUIStringNoDefault(@"vuBackgroundColor")];
    _downloadingListView.delegate = self;
    _downloadingListView.dataSource = self;

    if ([self.subviews containsObject:_listView]) {
        [_listView removeFromSuperview];
    }

    self.listView = _hasDownloadListView;
    [self addSubview:_listView];
    
    self.titleSegmentControl = [[[SSSegmentControl alloc] initWithFrame:CGRectMake(0,
                                                                                   0,
                                                                                   TitleSegmentControlWidth,
                                                                                   _titleBar.bounds.size.height)
                                                                   type:SSSegmentControlTypeSlide] autorelease];
    _titleSegmentControl.delegate = self;
    _titleSegmentControl.segments = _segments;
    _titleSegmentControl.slideImage = [UIImage imageNamed:@"change.png"];
    [_titleBar setCenterView:_titleSegmentControl];
    
    VideoTitleBarButton *editButton = [VideoTitleBarButton buttonWithType:VideoTitleBarButtonTypeRightNormalNarrow];
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.editButton = editButton;
    [_titleBar setRightView:editButton];
    
    VideoTitleBarButton *bulkStartButton = [VideoTitleBarButton buttonWithType:VideoTitleBarButtonTypeLeftNormalBoard];
    if (_dataManager.batchStarted) {
        [bulkStartButton setTitle:@"全部暂停" forState:UIControlStateNormal];
    }
    else {
        [bulkStartButton setTitle:@"全部开始" forState:UIControlStateNormal];
    }
    bulkStartButton.hidden = YES;
    [bulkStartButton addTarget:self action:@selector(bulkStartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.bulkStartButton = bulkStartButton;
    [_titleBar setLeftView:bulkStartButton];

//    self.listNotifyBarView = [[[SSListNotifyBarView alloc] initWithFrame:CGRectMake(0, 0, vFrame.size.width, 20.f) orientation:self.interfaceOrientation] autorelease];
//    [self addSubview:_listNotifyBarView];
    
    [self bringSubviewToFront:_titleBar];
}

- (void)didAppear   // will not be invoke in viewController's viewWillAppear method
{
    [super didAppear];
    
    [_dataManager startGetDownloadDataListByType:_dataListType];
    [_listView setEditing:NO animated:YES];
    [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    
    trackEvent([SSCommon appName], TrackDownloadTabEventName, @"enter");
}

#pragma mark - Actions

- (void)loadDataFinished:(NSNotification*)notification
{
    NSDictionary *userInfo = [[notification userInfo] objectForKey:@"userInfo"];
    
    NSDictionary *condition = [userInfo objectForKey:kSSDataOperationConditionKey];
    if([condition objectForKey:kVideoListDataDownloadDataListType] != [_condition objectForKey:kVideoListDataDownloadDataListType]) {
        return;
    }
    
    SSLog(@"download list view reloadData");
    [_listView reloadData];
}

//- (void)reportVideoDownloadTabCompleteNotification:(NSNotification *)notification
//{
//    if (_dataListType == VideoDownloadDataListTypeDownloading) {
//        
//        VideoData *video = [notification.userInfo objectForKey:kVideoDownloadTabCompleteNotificationVideoDataKey];
//        for (VideoListCell *cell in _listView.visibleCells) {
//            if (cell.videoData == video) {
//                _isComplete = YES;
//                _completeCell = cell;
//            }
//        }
//    }
//}

- (void)editButtonClicked:(id)sender
{
    [_listView setEditing:!_listView.editing animated:YES];
    trackEvent([SSCommon appName], TrackDownloadTabEventName, @"edit_button");
    
    if (_listView.editing) {
        [_editButton setTitle:@"完成" forState:UIControlStateNormal];
    }
    else {
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    }
}

- (void)bulkStartButtonClicked:(id)sender
{
    if (_dataManager.batchStarted) {
        [_dataManager batchStop];
        trackEvent([SSCommon appName], TrackDownloadTabEventName, @"pause_all");
    }
    else {
        [_dataManager batchStart];
    }
    
    if (_dataManager.batchStarted) {
        [_bulkStartButton setTitle:@"全部暂停" forState:UIControlStateNormal];
    }
    else {
        [_bulkStartButton setTitle:@"全部开始" forState:UIControlStateNormal];
        [self showNotifyMessage:@"已暂停所有下载任务"];
    }
    
    [_dataManager startGetDownloadDataListByType:_dataListType];
}

#pragma mark - private

- (void)showNotifyMessage:(NSString *)message
{
    CGRect notifyFrame = CGRectMake(0, 64, self.bounds.size.width, SSUIFloatNoDefault(@"vuListNotifyBarHeight"));
    
    UIImage *portraitNotifyBackgroundImage = [UIImage imageNamed:@"bar_syn.png"];
    portraitNotifyBackgroundImage = [portraitNotifyBackgroundImage stretchableImageWithLeftCapWidth:floorf(portraitNotifyBackgroundImage.size.width/2)
                                                                                       topCapHeight:floorf(portraitNotifyBackgroundImage.size.height/2)];
    UIImageView *portraitNotifyBackgroundImageView = [[[UIImageView alloc] initWithImage:portraitNotifyBackgroundImage] autorelease];
    portraitNotifyBackgroundImageView.frame = CGRectMake(0, 0, notifyFrame.size.width, notifyFrame.size.height);
    
    [[SSListNotifyBarView sharedView] showInRect:notifyFrame
                                         message:message
                                       textColor:SSUIStringNoDefault(@"vuStandardBlueColor")
                                 textShadowColor:SSUIStringNoDefault(@"vuStandardBlueColor")
                                textShadowOffset:CGSizeZero
                              bottomShadowHidden:YES
                          portraitBackgroundView:portraitNotifyBackgroundImageView
                         landscapeBackgroundView:nil];
}

- (void)displayNoDownloadView
{
    if (!_noDownloadView) {
        self.noDownloadView = [[[UIView alloc] init] autorelease];
        UIImageView *noDownloadImageView = [[[UIImageView alloc] init] autorelease];
        [_noDownloadView addSubview:noDownloadImageView];
    }
    
    for (UIView *v in _noDownloadView.subviews) {
        if ([v isKindOfClass:[UIImageView class]]) {
            UIImageView *noImage = (UIImageView*)v;
            switch (_dataListType) {
                case VideoDownloadDataListTypeDownloading:
                    noImage.image = [UIImage imageNamed:@"downno_loading.png"];
                    break;
                case VideoDownloadDataListTypeHasDownload:
                    noImage.image = [UIImage imageNamed:@"down_loading.png"];
                    break;
                    
                default:
                    break;
            }
            [noImage sizeToFit];
            _noDownloadView.frame = noImage.bounds;
            _noDownloadView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        }
    }
    
    [self addSubview:_noDownloadView];
    [self bringSubviewToFront:_noDownloadView];
}

- (NSString *)currentEventString
{
    switch (_dataListType) {
        case VideoDownloadDataListTypeDownloading:
            return @"downloading";
            break;
        case VideoDownloadDataListTypeHasDownload:
        {
            return @"hasDownload";
        }
        default:
        {
            return nil;
        }
            break;
    }
}

- (void)startGetStats
{
    [_condition setObject:[NSNumber numberWithInt:_dataListType] forKey:kVideoListDataDownloadDataListType];

    NSMutableDictionary *operationContext = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             _condition, kSSDataOperationConditionKey,
                                             [NSNumber numberWithBool:NO], kSSDataOperationFromLocalKey,
                                             [NSNumber numberWithBool:YES], kSSDataOperationFromRemoteKey,
                                             [NSNumber numberWithBool:NO], kSSDataOperationLoadMoreKey,
                                             [NSNumber numberWithBool:YES], kVideoDataOperationGetStatsKey,
                                             [NSNumber numberWithBool:YES], kVideoDataOperationLoadNewestKey,
                                             [NSNumber numberWithBool:NO], kVideoDataOperationLoadAllLocalKey,
                                             [NSNumber numberWithBool:YES], kVideoDataOperationClearCacheKey,
                                             _dataList, kSSDataOperationOriginalListKey, nil];
    
    VideoGetStatsOperationManager *statsManager = [VideoGetStatsOperationManager sharedOperation];
    [statsManager startExecute:operationContext];
}

#pragma mark - VideoDownloadManagerDelegate

- (void)downloadManager:(VideoDownloadDataManager *)manager didReceivedDownloadDataList:(NSArray *)dataList dataListType:(VideoDownloadDataListType)type error:(NSError *)error
{
    if (_dataListType == type) {
        if (!error) {
            self.dataList = dataList;
            [_listView reloadData];

            if (!_hasGetDownloadedStats && [_dataList count] > 0) {
                _hasGetDownloadingStats = YES;
                [self startGetStats];
            }
            
            if ([_dataList count] == 0) {
                [self displayNoDownloadView];
                _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
            }
            else {
                [_noDownloadView removeFromSuperview];
                _listView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                [self sendSubviewToBack:_listView];
            }
            
            [self updateTitleButtons];
        }
    }
}

- (void)updateTitleButtons
{
    if ([_dataList count] == 0) {
        self.bulkStartButton.hidden = YES;
        self.editButton.hidden = YES;

        [_listView setEditing:NO animated:YES];
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    }
    else {
        switch (_dataListType) {
            case VideoDownloadDataListTypeDownloading:
            {
                self.bulkStartButton.hidden = NO;
                self.editButton.hidden = NO;
            }
                break;
            case VideoDownloadDataListTypeHasDownload:
            {
                self.bulkStartButton.hidden = YES;
                self.editButton.hidden = NO;
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - SSSegmentControl

- (void)ssSegmentControl:(SSSegmentControl *)ssSegmentControl didSelectAtIndex:(NSInteger)index
{
    if ([self.subviews containsObject:_listView]) {
        [_listView removeFromSuperview];
    }
    
    switch (index) {
        case 0:
        {
            self.listView = _hasDownloadListView;

            _dataListType = VideoDownloadDataListTypeHasDownload;
        }
            break;
        case 1:
        {
            self.listView = _downloadingListView;

            _dataListType = VideoDownloadDataListTypeDownloading;
        }
            break;
        default:
            break;
    }
    
    [self updateTitleButtons];
    
    [self addSubview:_listView];
    [self sendSubviewToBack:_listView];
    
    [_dataManager startGetDownloadDataListByType:_dataListType];
    
    if (_listView.editing) {
        [_editButton setTitle:@"完成" forState:UIControlStateNormal];
    }
    else {
        [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *listCellIdentifier = @"list_cell_identifier";
    
    if (indexPath.row < [_dataList count]) {
        VideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:listCellIdentifier];
        if (cell == nil) {
            cell = [[[VideoListCell alloc] initWithStyle:UITableViewCellStyleValue1
                                         reuseIdentifier:listCellIdentifier] autorelease];
        } 
        
        VideoData *data = [_dataList objectAtIndex:indexPath.row];
        
        VideoListCellType cellType = VideoListCellTypeNormal;
        switch (_dataListType) {
            case VideoDownloadDataListTypeDownloading:
                cellType = VideoListCellTypeDownloading;
                break;
            case VideoDownloadDataListTypeHasDownload:
                cellType = VideoListCellTypeHasDownload;
                break;
            default:
                break;
        }
        [cell setVideoData:data type:cellType];
        cell.trackEventName = TrackDownloadTabEventName;
        
        [cell refreshUI];
        
        return cell;
    }
    else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            [_dataManager removeWithVideoData:[_dataList objectAtIndex:indexPath.row]];
            trackEvent([SSCommon appName], TrackDownloadTabEventName, @"delete_button");
            break;
            
        default:
            break;
    }
    
    [_dataManager startGetDownloadDataListByType:_dataListType];
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
        
        trackEvent([SSCommon appName], TrackDownloadTabEventName, @"click_cell");
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_dataList count]) {
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_dataList count]) {
        return @"删除";
    }
    else {
        return nil;
    }
}

@end


