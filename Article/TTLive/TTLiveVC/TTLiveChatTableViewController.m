//
//  TTLiveChatTableViewController.m
//  Article
//
//  Created by matrixzk on 2/1/16.
//
//

#import "TTLiveChatTableViewController.h"
#import "UIScrollView+Refresh.h"
#import "TTLiveMessage.h"
#import "TTLiveMainViewController.h"
#import "TTLiveStreamDataModel.h"
#import "TTLiveMessageNormalCell.h"
#import "TTLiveMessageNormalReplyCell.h"
#import "TTLiveHostTipCell.h"
#import "TTPhotoScrollViewController.h"
#import "ALAssetsLibrary+TTImagePicker.h"
#import "UIImageView+WebCache.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "NetworkUtilities.h"
#import "TTFoldableLayoutDefinitaions.h"
#import <TTAccountBusiness.h>
#import "TTNavigationController.h"
#import "SSWebViewController.h"
#import "UIColor+TTThemeExtension.h"
#import "TTLiveRemindView.h"
#import "TTLiveTabCategoryItem.h"
#import "TTLiveMessageBox.h"
#import "NSTimer+Additions.h"

@interface NSNumber (TTLiveChat)

- (BOOL)tt_isEqualToNumber:(NSNumber *)number;

@end

@implementation NSNumber (TTLiveChat)

- (BOOL)tt_isEqualToNumber:(NSNumber *)number
{
    if (number && [number isKindOfClass:[NSNumber class]]){
        return [self isEqualToNumber:number];
    }
    return NO;
}
@end

static NSString *kTTLiveMessageNormalCellIncomingIdentifier = @"TTLiveMessageNormalCellIncomingIdentifier";
static NSString *kTTLiveMessageNormalCellOutgoingIdentifier = @"TTLiveMessageNormalCellOutgoingIdentifier";
static NSString *kTTLiveMessageNormalReplyCellIncomingIdentifier = @"TTLiveMessageNormalReplyCellIncomingIdentifier";
static NSString *kTTLiveMessageNormalReplyCellOutgoingIdentifier = @"TTLiveMessageNormalReplyCellOutgoingIdentifier";
static NSString *kTTLiveHostTipCellIdentifier = @"TTLiveHostTipCellIdentifier";

@interface TTLiveChatTableViewController () <UIViewControllerErrorHandler, TTFoldableLayoutItemDelegate, UIScrollViewDelegate, TTLiveMessageBoxDelegate>

/** 所在直播间 */
@property (nonatomic, weak) TTLiveMainViewController * _Nullable chatroom;
/** 信息数据源 */
@property (nonatomic, strong) NSMutableArray<TTLiveMessage *> * _Nonnull messageArray;

@property (nonatomic, strong) NSMutableArray *idsOfMessageToBeRemoved;
// 在另一个列表发消息后进入当前列表，若当前列表尚无数据源，则先把所发消息缓存在这里，拿到数据后追加到数据源上，一起显示。
@property (nonatomic, copy) NSArray<TTLiveMessage *> *tempMsgArray;
@property (nonatomic, strong) NSMutableArray<TTLiveMessage *> *willDisplayedMsgArray;
@property (nonatomic, assign) NSTimeInterval currentPollingInterval;

//@property (nonatomic, assign) BOOL canLoadOldMessage;
//@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

//@property (nonatomic, assign) UIEdgeInsets originInsets;

@property (nonatomic, strong) TTLoadMoreView *loadMoreView;

@property (nonatomic, strong) NSTimer *messageOutTimer;
@property (nonatomic, assign) NSUInteger messageOutTimes;
@property (nonatomic, assign) BOOL cleanHistory;
@property (nonatomic, assign) BOOL messageOneTimeOutWithoutAnimation;

@property (nonatomic, assign) NSInteger tempRunloopUnreadCount;
@property (nonatomic, assign) BOOL hasAddHostTip;//是否已经添加了主持人的cell
@property (nonatomic, assign) NSInteger cellLayout;
@end

@implementation TTLiveChatTableViewController

- (instancetype)initWithChannelItem:(TTLiveTabCategoryItem *)item inChatroom:(TTLiveMainViewController *)chatroom {
    self = [super init];
    if (self) {
        _channelItem = item;
        _chatroom = chatroom;
        _messageArray = [[NSMutableArray<TTLiveMessage *> alloc] init];
        _distinctArray = [[NSMutableArray alloc] init];
        _idsOfMessageToBeRemoved = [[NSMutableArray alloc] initWithCapacity:3];
        _willDisplayedMsgArray = [[NSMutableArray<TTLiveMessage *> alloc] init];
        _tempMsgArray = [[NSMutableArray<TTLiveMessage *> alloc] init];
        _firstLoad = YES;
        _cleanHistory = NO;
        _messageOneTimeOutWithoutAnimation = NO;
        _tempRunloopUnreadCount = -1;
        [self setupCellLayout];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedRowHeight = 0;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.view.backgroundColor = TTLiveChatListBGColor;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollsToTop = NO;

    self.tableView.originContentInset = self.tableView.contentInset = [self.chatroom edgeInsetsOfContentScrollView];
    
    // 注册Cell
    [self.tableView registerClass:[TTLiveMessageNormalCell class] forCellReuseIdentifier:kTTLiveMessageNormalCellIncomingIdentifier];
    [self.tableView registerClass:[TTLiveMessageNormalCell class] forCellReuseIdentifier:kTTLiveMessageNormalCellOutgoingIdentifier];
    [self.tableView registerClass:[TTLiveMessageNormalReplyCell class] forCellReuseIdentifier:kTTLiveMessageNormalReplyCellIncomingIdentifier];
    [self.tableView registerClass:[TTLiveMessageNormalReplyCell class] forCellReuseIdentifier:kTTLiveMessageNormalReplyCellOutgoingIdentifier];
    [self.tableView registerClass:[TTLiveHostTipCell class] forCellReuseIdentifier:kTTLiveHostTipCellIdentifier];
    
    _loadMoreView = [[TTLoadMoreView alloc] initWithFrame:CGRectMake(0, -kTTPullRefreshHeight, self.tableView.bounds.size.width, kTTPullRefreshHeight) pullDirection:PULL_DIRECTION_DOWN initText:@"下拉加载历史" pullText:@"马上刷新" loadingText:@"正在加载" noMoreText:@"没有更多历史消息" timeText:nil lastTimeKey:nil];
    WeakSelf;
    _loadMoreView.actionHandler = ^{
        StrongSelf;
        [self fetchLiveStreamDataSourceWithRefreshType:TTLiveMessageListRefreshTypeGetOld];
    };
    _loadMoreView.isPullUp = YES;
    [self.tableView addSubview:_loadMoreView];
    self.tableView.hasMore = YES;
    _loadMoreView.scrollView = self.tableView;
//    self.tableView.pullUpView = _loadMoreView;
    self.tableView.isDone = YES;
    _loadMoreView.isObservingContentInset = NO;
    
    self.messageOutTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 block:^{
        StrongSelf;
        if (self.cleanHistory) {
            self.cleanHistory = NO;
            self.messageOneTimeOutWithoutAnimation = NO;
            [self.messageArray removeAllObjects];
            [self.messageArray addObjectsFromArray:self.willDisplayedMsgArray];
            [self.willDisplayedMsgArray removeAllObjects];
            self.messageOutTimes = 0;
            [self scrollToBottomWithAnimation:NO];
        } else if (self.messageOneTimeOutWithoutAnimation) {
            self.messageOneTimeOutWithoutAnimation = NO;
            [self.messageArray addObjectsFromArray:self.willDisplayedMsgArray];
            [self.willDisplayedMsgArray removeAllObjects];
            self.messageOutTimes = 0;
            [self scrollToBottomWithAnimation:NO];
        } else {
            NSUInteger count = self.willDisplayedMsgArray.count;
            if (self.messageOutTimes == 0) {
                self.messageOutTimes = 1;
            }
            NSUInteger outCount = (NSUInteger)(ceil((double)count / self.messageOutTimes));
            if (outCount == 0) {
                return;
            }
            NSMutableArray<TTLiveMessage *> *outMessage = [[NSMutableArray alloc] initWithCapacity:outCount];
            NSMutableArray<TTLiveMessage *> *temp = [[NSMutableArray alloc] initWithArray:self.willDisplayedMsgArray];
            [temp enumerateObjectsUsingBlock:^(TTLiveMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx == outCount) {
                    *stop = YES;
                    return;
                }
                [self.willDisplayedMsgArray removeObject:obj];
                [outMessage addObject:obj];
            }];
            
            [self.messageArray addObjectsFromArray:outMessage];
            self.messageOutTimes--;
            [self scrollToBottomIfNeededWithAnimation:YES];
        }
    } repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.messageOutTimer forMode:NSRunLoopCommonModes];
}


- (void)dealloc {
    [_messageOutTimer invalidate];
    _messageOutTimer = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.hasMore && scrollView.contentOffset.y < 0 && _loadMoreView.state != PULL_REFRESH_STATE_LOADING) {
        UIEdgeInsets inset = self.tableView.originContentInset;
        inset.top -= kTTPullRefreshHeight;
        self.tableView.contentInset = inset;
        [_loadMoreView triggerRefresh];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // 清除缩略图(本地发送的视频所生成的封面的生成成本相对较高，且此类型极少，故不做处理)
    [self.messageArray enumerateObjectsUsingBlock:^(TTLiveMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        if (message.localSelectedVideoURL) {
            return;
        }
        message.thumbImage = nil;
        message.tempLocalSelectedImage = nil;
    }];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

// 注意！
// 这里不调用 super，禁掉 UITableViewController 自带监听 keyboard 滚动 tableView 只适应高度的特性。
- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tableView.scrollsToTop = YES;
    
    if (self.firstLoad) {
        
        self.channelItem.minCursor = @0;
        self.channelItem.maxCursor = @0;
        
        [self tt_startUpdate];
        [self fetchLiveStreamDataSourceWithRefreshType:TTLiveMessageListRefreshTypeGetNew];
    }
    [self.messageOutTimer tt_resume];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tableView.scrollsToTop = NO;
    [self.messageOutTimer tt_pause];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma Private Action
- (void)setupCellLayout{
    //只在直播tab自定义Cell
    if (_channelItem.categoryId.integerValue != 1){
        _cellLayout = 0;
        return;
    }
    if (_chatroom == nil){
        return;
    }
    
    TTLiveOverallInfoModel *overAllInfoModel = _chatroom.overallModel;
    switch (overAllInfoModel.liveType.integerValue) {
        case TTLiveTypeMatch:
            _cellLayout = TTLiveCellLayoutBubbleCoverTop | TTLiveCellLayoutBubbleWidthExtend | TTLiveCellLayoutHiddenName | TTLiveCellLayoutHiddenRoleName;
            break;
        default:
            break;
    }
}

// 在另一个列表发消息后进入当前列表，若当前列表尚无数据源，则先把所发消息缓存，拿到数据后追加到数据源上，一起显示。
- (void)appendTempMessagesIfNeeded {
    if (self.firstLoad && self.tempMsgArray.count > 0) {
        [self.willDisplayedMsgArray addObjectsFromArray:self.tempMsgArray];
        self.tempMsgArray = nil;
    }
}

#pragma mark - 获取数据(Fetch Data)
- (void)fetchLiveStreamDataSourceWithRefreshType:(TTLiveMessageListRefreshType)refreshType {
    // 是否请求历史
    self.channelItem.history = [NSNumber numberWithBool:TTLiveMessageListRefreshTypeGetOld == refreshType];
    
    WeakSelf;
    // 通过数据管理层获取数据
    [self.chatroom.dataSourceManager fetchStreamDataWithChannelItem:self.channelItem isPolling:(TTLiveMessageListRefreshTypePolling == refreshType) resultBlock:^(NSError *error, TTLiveStreamDataModel *streamDataModel) {
        StrongSelf;
        if (error) {
            if (TTLiveMessageListRefreshTypeGetOld == refreshType ||
                TTLiveMessageListRefreshTypeGetNew == refreshType) {
                [self.loadMoreView stopAnimation:NO];
                self.tableView.contentInset = self.tableView.originContentInset;
            }
            if (self.firstLoad) {
                if (self.tempMsgArray.count > 0) {
                    [self appendTempMessagesIfNeeded];
//                    [self.tableView reloadData];
                    [self tt_endUpdataData];
                } else if (self.tableView.visibleCells.count == 0) {
                    self.ttViewType = TTNetworkConnected() ? TTFullScreenErrorViewTypeLocationServiceError : TTFullScreenErrorViewTypeNetWorkError;
                    [self tt_endUpdataData:NO error:error];
                } else {
                    [self tt_endUpdataData];
                }
            }
            
            return;
        }
        
        [self tt_endUpdataData];
        if (TTLiveMessageListRefreshTypeGetOld == refreshType || TTLiveMessageListRefreshTypeGetNew == refreshType) {
            [self.loadMoreView stopAnimation:YES];
            self.tableView.contentInset = self.tableView.originContentInset;
        }
        
        if (!streamDataModel) {
            return;
        }
        
        if (self.firstLoad == YES && streamDataModel.msgRegionArray.count == 0) {
            self.firstLoad = NO;
            self.tableView.hasMore = NO;
            self.loadMoreView.hasMore = NO;
        }
        
        // 处理数据
        [streamDataModel.msgRegionArray enumerateObjectsUsingBlock:^(TTLiveMessageRegionModel * _Nonnull regionModel, NSUInteger idx, BOOL * _Nonnull stop) {
            StrongSelf;

            // 数据源是否有效
            NSInteger channel = regionModel.channel.integerValue;
            TTLiveChatTableViewController *currentChatVC = (TTLiveChatTableViewController *)[self.chatroom channelVCWithIndex:[self.chatroom tabIndexOfLiveChannelWithType:channel]];
            if (![currentChatVC isKindOfClass:[TTLiveChatTableViewController class]]) {
                return;
            }
            
            // 更新缓存的待删数据源
            if (regionModel.deleted.count > 0) {
                [currentChatVC.idsOfMessageToBeRemoved addObjectsFromArray:regionModel.deleted];
            }
            // idsOfMessageToBeRemoved 数组中可能有之前遗留的待删数据
            NSMutableArray<TTLiveMessage *> *msgsToBeRemoved;
            if (currentChatVC.idsOfMessageToBeRemoved.count > 0) {
                // 更新数据源
                msgsToBeRemoved = [[NSMutableArray<TTLiveMessage *> alloc] initWithCapacity:currentChatVC.idsOfMessageToBeRemoved.count];
                [currentChatVC.messageArray enumerateObjectsUsingBlock:^(TTLiveMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
                    [currentChatVC.idsOfMessageToBeRemoved enumerateObjectsUsingBlock:^(NSNumber * _Nonnull removeMsgId, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([message isKindOfClass:[TTLiveMessage class]] && [message.msgId tt_isEqualToNumber:removeMsgId]) {
                            [msgsToBeRemoved addObject:message];
                            *stop = YES;
                        }
                    }];
                }];
            }
            
            
            // 新消息去重处理
            NSMutableArray *duplicateMsgsFromServer = [[NSMutableArray alloc] initWithCapacity:currentChatVC.distinctArray.count];
            NSMutableArray *duplicateMsgsLocalSaved = [[NSMutableArray alloc] initWithCapacity:currentChatVC.distinctArray.count];
            [regionModel.messageArray enumerateObjectsUsingBlock:^(TTLiveMessage * _Nonnull newMsg, NSUInteger idx, BOOL * _Nonnull stop) {
                [currentChatVC.distinctArray enumerateObjectsUsingBlock:^(TTLiveMessage * _Nonnull tempMsg, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (!tempMsg.msgId) {
                        return ;
                    }
                    if ([newMsg isKindOfClass:[TTLiveMessage class]] && [newMsg.msgId tt_isEqualToNumber:tempMsg.msgId]) {
                        [duplicateMsgsFromServer addObject:newMsg];
                        [duplicateMsgsLocalSaved addObject:tempMsg];
                        *stop = YES;
                    }
                }];
            }];
            
            NSArray *newComingMsgs = regionModel.messageArray;
            if (duplicateMsgsFromServer.count > 0) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:regionModel.messageArray];
                [tempArray removeObjectsInArray:duplicateMsgsFromServer];
                newComingMsgs = [NSArray arrayWithArray:tempArray];
            }
            regionModel.unread_count = @(MAX(0, regionModel.unread_count.integerValue - duplicateMsgsFromServer.count));
            
            //检查置顶帖子
            if (currentChatVC.messageArray.count == 0){
                [self checkTopMessageWithNewMessage:newComingMsgs];
            }
            
            // 是否为当前显示的信息流
            if (currentChatVC == [self.chatroom currentChannelVC]) {
                if (TTLiveMessageListRefreshTypeGetNew == refreshType) {
                    
                    // 当前tab，要移除本地的已发数据缓存
                    if (duplicateMsgsLocalSaved.count > 0) {
                        [currentChatVC.distinctArray removeObjectsInArray:duplicateMsgsLocalSaved];
                    }
                    
                    if ([regionModel.clean_history boolValue]) {
                        currentChatVC.cleanHistory = YES;
                        [currentChatVC.willDisplayedMsgArray removeAllObjects];
                    }
                    
                    if (newComingMsgs.count > 0) {
                        // 更新数据源（追加到底部）
                        [currentChatVC.willDisplayedMsgArray addObjectsFromArray:newComingMsgs];
                        [currentChatVC appendTempMessagesIfNeeded];
                        currentChatVC.messageOneTimeOutWithoutAnimation = YES;
                    }
                    
                    // 更新红点和cursor
                    TTLiveTabCategoryItem *currentCategoryItem = [self.chatroom channelItemWithChannelId:regionModel.channel.integerValue];
                    
                    if (currentCategoryItem) {
                        // 更新红点
                        currentCategoryItem.badgeNum = 0;
                        
                        // 更新cursor
                        if (regionModel.cursor_min.integerValue < currentCategoryItem.minCursor.integerValue) {
                            currentCategoryItem.minCursor = regionModel.cursor_min;
                        }
                        
                        if (regionModel.cursor_max.integerValue > currentCategoryItem.maxCursor.integerValue) {
                            currentCategoryItem.maxCursor = regionModel.cursor_max;
                            // 第一次下拉刷新要跟新minCursor
                            if (0 == currentCategoryItem.minCursor.integerValue || [regionModel.clean_history boolValue]) {
                                currentCategoryItem.minCursor = regionModel.cursor_min;
                            }
                        }
                        
                        // minCursor 的最小值是1，此时说明已经没有history数据了。
                        if (currentCategoryItem.minCursor.integerValue <= 1) {
                            currentChatVC.tableView.hasMore = NO;
                            currentChatVC.loadMoreView.hasMore = NO;
                        } else {
                            currentChatVC.tableView.hasMore = YES;
                            currentChatVC.loadMoreView.hasMore = YES;
                        }
                    }
                    
                } else if (TTLiveMessageListRefreshTypeGetOld == refreshType) {
                    // 更新数据源(追加到底部)(不需要去重处理，也不会有重复的)
                    [currentChatVC.messageArray insertObjects:newComingMsgs atIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, newComingMsgs.count)]];

                    // 若有待删数据，在后边执行统一执行刷新列表
                    if (msgsToBeRemoved.count <= 0) {
                        [currentChatVC.tableView reloadData];
                    }
                    
                    NSInteger row = ([currentChatVC messageArray].count > newComingMsgs.count ? newComingMsgs.count : newComingMsgs.count - 1);
                    if (row >= [currentChatVC.tableView numberOfRowsInSection:0]) {
                        row = [currentChatVC.tableView numberOfRowsInSection:0] - 1;
                    } else if (row < 0) {
                        row = 0;
                    }
                    if (row > 0) {
                        NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
                        [currentChatVC.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        currentChatVC.tableView.contentOffset = CGPointMake(currentChatVC.tableView.contentOffset.x, currentChatVC.tableView.contentOffset.y - 10);
                    }
                    
                    // 更新cursor，只更新minCursor
                    TTLiveTabCategoryItem *currentCategoryItem = [self.chatroom channelItemWithChannelId:regionModel.channel.integerValue];
                    
                    if (regionModel.cursor_min.integerValue < currentCategoryItem.minCursor.integerValue) {
                        currentCategoryItem.minCursor = @(MAX(regionModel.cursor_min.integerValue, 1));
                        
                        // minCursor 的最小值是1，此时说明已经没有history数据了。
                        if (currentCategoryItem.minCursor.integerValue <= 1) {
                            //                            currentChatVC.canLoadOldMessage = NO;
                            currentChatVC.tableView.hasMore = NO;
                            currentChatVC.loadMoreView.hasMore = NO;
                            //                            currentChatVC.tableView.needPullRefresh = NO;
                        }
                    }
                } else if (TTLiveMessageListRefreshTypePolling == refreshType) {
                    if ([regionModel.clean_history boolValue]) {
                        currentChatVC.cleanHistory = YES;
                        [currentChatVC.willDisplayedMsgArray removeAllObjects];
                    }
                    
                    if (currentChatVC.firstLoad) {
                        [currentChatVC.willDisplayedMsgArray addObjectsFromArray:newComingMsgs];
                        [currentChatVC appendTempMessagesIfNeeded];
                        currentChatVC.messageOneTimeOutWithoutAnimation = YES;
                    } else {
                        [currentChatVC.willDisplayedMsgArray addObjectsFromArray:newComingMsgs];
                    }
                    TTLiveTabCategoryItem *currentCategoryItem = [self.chatroom channelItemWithChannelId:regionModel.channel.integerValue];
                    
                    if (currentCategoryItem) {
                        // 更新红点
                        currentCategoryItem.badgeNum = 0;
                        
                        // 更新cursor
                        if (regionModel.cursor_min.integerValue < currentCategoryItem.minCursor.integerValue) {
                            currentCategoryItem.minCursor = regionModel.cursor_min;
                        }
                        
                        if (regionModel.cursor_max.integerValue > currentCategoryItem.maxCursor.integerValue) {
                            currentCategoryItem.maxCursor = regionModel.cursor_max;
                            // 第一次下拉刷新要跟新minCursor
                            if (0 == currentCategoryItem.minCursor.integerValue || [regionModel.clean_history boolValue]) {
                                currentCategoryItem.minCursor = regionModel.cursor_min;
                            }
                        }
                        
                        // minCursor 的最小值是1，此时说明已经没有history数据了。
                        if (currentCategoryItem.minCursor.integerValue <= 1) {
                            currentChatVC.tableView.hasMore = NO;
                            currentChatVC.loadMoreView.hasMore = NO;
                        } else {
                            currentChatVC.tableView.hasMore = YES;
                            currentChatVC.loadMoreView.hasMore = YES;
                        }
                    }
                }
                
                // 删除要删除的数据(只有`下拉刷新`或`上拉加载历史`需要刷新列表)
                if (msgsToBeRemoved.count > 0) {
                    if (TTLiveMessageListRefreshTypeGetOld == refreshType || TTLiveMessageListRefreshTypeGetNew == refreshType) { // 下拉刷新TYPE || 上拉历史
                        
                        // 更新数据源，刷新列表 (和上边`下拉刷新`或`上拉加载历史`有新数据的reloadData只能做一次)
                        [currentChatVC.messageArray removeObjectsInArray:msgsToBeRemoved];
                        [currentChatVC.tableView reloadData];
                        
                        // 清除缓存待删数据源
                        [currentChatVC.idsOfMessageToBeRemoved removeAllObjects];
                    }
                }
                
                currentChatVC.firstLoad = NO;
            } else { // 非当前列表
                
                // 更新当前tab的红点，但cursor不变
                if (!currentChatVC.firstLoad) {
                    TTLiveTabCategoryItem *currentCategoryItem = [self.chatroom channelItemWithChannelId:regionModel.channel.integerValue];
                    currentCategoryItem.badgeNum = [regionModel.unread_count integerValue];
                } else {
                    if (currentChatVC.tempRunloopUnreadCount == -1) {
                        currentChatVC.tempRunloopUnreadCount = [regionModel.unread_count integerValue];
                    } else {
                        TTLiveTabCategoryItem *currentCategoryItem = [self.chatroom channelItemWithChannelId:regionModel.channel.integerValue];
                        NSInteger oldBadgeNumber = currentCategoryItem.badgeNum;
                        NSInteger newBadgeNumber = [regionModel.unread_count integerValue] - currentChatVC.tempRunloopUnreadCount;
                        currentCategoryItem.badgeNum = MAX(oldBadgeNumber, newBadgeNumber);
                    }
                }
                
                // 删除要删除的数据(各种refreshType都要刷新列表)
                if (msgsToBeRemoved.count > 0) {
                    // 待删数据
                    // 更新数据源，刷新列表
                    [currentChatVC.messageArray removeObjectsInArray:msgsToBeRemoved];
                    [currentChatVC.tableView reloadData];
                    
                    // 清除缓存待删数据源
                    [currentChatVC.idsOfMessageToBeRemoved removeAllObjects];
                }
            }
        }];
        
        //添加主持人cell
        [self addHostTipIfNeed];
        
        // 更新点赞
        self.chatroom.lastInfiniteLike = [streamDataModel.infinite_like unsignedIntegerValue] ?: 0;
        if ([streamDataModel.infinite_like unsignedIntegerValue] > self.chatroom.pariseCount) {
            self.chatroom.pariseCount = [streamDataModel.infinite_like unsignedIntegerValue];
        }
        
        // 飘赞
        if (refreshType == TTLiveMessageListRefreshTypeGetNew) {
            [self.chatroom firstInDig];
        } else {
            [self.chatroom othersPariseDig:([streamDataModel.infinite_like_new_display unsignedIntegerValue] ?: 0) inTime:streamDataModel.refresh_interval ?: 5];
        }
        
        // 刷新比分、在线人数
        [self.chatroom refreshRedBadgeAndOnlineUserAndScore:streamDataModel];
        
        // 调整轮询
        NSUInteger refreshInterval = streamDataModel.refresh_interval ?: 5;
        [self.chatroom.dataSourceManager adjustPollingTimerWithTimeInterval:(double)refreshInterval];
        self.messageOutTimes = refreshInterval * 2;
//        self.indicatorView.hidden = YES;
//        [self.indicatorView stopAnimating];
//        self.tableView.contentInset = self.originInsets;
    }];
}

#pragma mark - Add new message

//本地发消息增加
- (void)addChatMessageItems:(NSArray<TTLiveMessage *> *)messageItems
{
    //下一次消息去重数组
    [self.distinctArray addObjectsFromArray:messageItems];
    
    // 解决首次切入tab时
    if (self.firstLoad) {
        self.tempMsgArray = messageItems;
        return;
    }
    
    NSInteger messageCount = messageItems.count;
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:messageItems.count];
    [messageItems enumerateObjectsUsingBlock:^(TTLiveMessage * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.messageArray addObject:message];
//        [self.messageArray insertObject:message atIndex:0];
        [indexPaths addObject:[NSIndexPath indexPathForRow:messageCount + idx inSection:0]];
    }];
    
    // 这里设为 UITableViewRowAnimationTop 和 UITableViewRowAnimationNone，是两种不同的动画效果;
    [self.tableView reloadData];
//    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self scrollToBottomWithAnimation:YES];
//    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    // NSLog(@"--- 发送消息 %@", [(TTLiveMessage *)messageItems.firstObject msgText]);
}

//添加一个主持人的提示cellh
- (void)addHostTipIfNeed{
    if (self.chatroom.topInfoModel.background_type.integerValue == TTLiveTypeMatch && self.chatroom.overallModel.liveStateNum.integerValue == TTLiveStatusPlaying && _channelItem.categoryId.integerValue == 1 && !_hasAddHostTip){
        //在直播列表
        TTLiveMessage *message = _willDisplayedMsgArray.lastObject;
        if (message){
            TTLiveMessage * tipMessage = [TTLiveMessage createMessageForHostTipWithMessage:message];
            [_willDisplayedMsgArray addObject:tipMessage];
            _hasAddHostTip = YES;
        }
    }
}

//检查置顶帖子
- (void)checkTopMessageWithNewMessage:(NSArray<TTLiveMessage *> *)messages
{
    NSString *topMessageID = self.chatroom.overallModel.topMessageID;
    if (!isEmptyString(topMessageID)){
        [messages enumerateObjectsUsingBlock:^(TTLiveMessage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.msgId.stringValue isEqualToString:topMessageID]){
                NSString *newMsgText = [NSString stringWithFormat:@"\U0000E613\n\n%@",obj.msgText];
                obj.msgText = newMsgText;
                obj.isTop = YES;
                *stop = YES;
            }
        }];
    }
}

#pragma mark - TTFoldableLayoutItemDelegate Methods

- (UIScrollView *)tt_foldableDirvenScrollView
{
    return self.tableView;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTLiveMessage *message = self.messageArray[indexPath.row];
    message.cellLayout = _cellLayout;
    if (message.isTop){
        message.cellLayout = _cellLayout | TTLiveCellLayoutIsTop;
    }
    message.disableComment = self.chatroom.topInfoModel.disableComment && [self.chatroom roleOfCurrentUserIsLeader];
    if (message.msgType == TTLiveMessageTypeHostTip){
        TTLiveHostTipCell *cell = [tableView dequeueReusableCellWithIdentifier:kTTLiveHostTipCellIdentifier];
        [cell setupViewWithHost:message];
        return cell;
    }
    
    BOOL isIncoming = ![message.userId isEqualToString:[TTAccountManager userID]];
    if (isIncoming){
        message.cellLayout = message.cellLayout | TTLiveCellLayoutIsComming;
    }

    NSString *cellIdentifier;
    if (message.replyedMessage) {
        cellIdentifier = isIncoming ? kTTLiveMessageNormalReplyCellIncomingIdentifier : kTTLiveMessageNormalReplyCellOutgoingIdentifier;
    } else {
        cellIdentifier = isIncoming ? kTTLiveMessageNormalCellIncomingIdentifier : kTTLiveMessageNormalCellOutgoingIdentifier;
    }
    
    TTLiveMessageBaseCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.delegate = self.chatroom;
    [cell setupCellWithMessage:message];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTLiveMessage *message = self.messageArray[indexPath.row];
    message.cellLayout = _cellLayout;
    if (message.isTop){
        message.cellLayout = _cellLayout | TTLiveCellLayoutIsTop;
    }
    if (message.msgType == TTLiveMessageTypeHostTip){
        return TTLivePadding(50);
    }
    
    BOOL isIncoming = ![message.userId isEqualToString:[TTAccountManager userID]];
    if (isIncoming){
        message.cellLayout = message.cellLayout | TTLiveCellLayoutIsComming;
    }
    
    CGFloat height = [TTLiveCellHelper shouldShowCellBottomLoadingProgressViewWithMessage:message] ? HeightOfLoadingProgressView() : 0;

    if (message.replyedMessage) {
        height += [TTLiveCellHelper heightOfNormalReplyedContentViewWithMessage:message];
    } else {
        height += [TTLiveCellHelper sizeOfNormalContentViewWithMessage:message].height;
    }
    
    height += kLivePaddingCellContentTop();
    
    return height;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTLiveMessage *message = self.messageArray[indexPath.row];
    message.cellLayout = _cellLayout;
    if (message.isTop){
        message.cellLayout = _cellLayout | TTLiveCellLayoutIsTop;
    }
    if (message.msgType == TTLiveMessageTypeHostTip){
        return ;
    }
    
    BOOL isIncoming = ![message.userId isEqualToString:[TTAccountManager userID]];
    if (isIncoming){
        message.cellLayout = message.cellLayout | TTLiveCellLayoutIsComming;
    }
    if (!self.chatroom.remindView.hidden && [self.chatroom.remindView.message.msgId tt_isEqualToNumber:message.msgId]) {
        self.chatroom.remindView.hidden = YES;
        [self.chatroom.view insertSubview:self.chatroom.remindView belowSubview:self.chatroom.messageBoxView];
    }
    
    // event track
    [self performSelector:@selector(eventTrack4MessageDisplayed:) withObject:message afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
}

- (void)eventTrack4MessageDisplayed:(TTLiveMessage *)message
{
    if (!isEmptyString(message.link)) {
        [self.chatroom eventTrackWithEvent:@"livecell" label:@"link" channelId:self.channelItem.categoryId];
    }
}

- (void)scrollToBottomWithAnimation:(BOOL)animation {
    [self.tableView reloadData];
    if (self.messageArray.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.messageArray.count - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animation];
    }
}

- (void)scrollToBottomIfNeededWithAnimation:(BOOL)animation {
    BOOL shouldRefreshList = self.tableView.contentOffset.y > self.tableView.contentSize.height - self.tableView.height - 10;
    [self.tableView reloadData];
    if (shouldRefreshList) {
        [self scrollToBottomWithAnimation:animation];
    } else if (self.messageArray.count > 0) {
        [self.chatroom updateRemindView:[self.messageArray lastObject]];
    }
}
#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return NO;
}

- (void)refreshData {
    //首次获取数据失败，点击刷新
    [self tt_startUpdate];
    
    [self fetchLiveStreamDataSourceWithRefreshType:TTLiveMessageListRefreshTypeGetNew];
}

@end
