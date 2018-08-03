
#import "TTVFeedListViewModel.h"
#import "TTVideoFeedListParameter.h"
#import "TTVideoFeedListService.h"
#import "TTVideoFeedResponse.h"
#import "SSCommonLogic.h"
#import "UIImageAdditions.h"
#import "TTServiceConfigure.h"
#import "PBModelCategory.h"
#import "TTVFeedListVideoCellHeader.h"
#import "TTVLastReadItem.h"
#import <TTPersistence/TTPersistence.h>
#import "NSArray+BlocksKit.h"
#import "TTVideoFeedListService+DataManager.h"
#import <libextobjc/extobjc.h>
#import "NSArray+BlocksKit.h"
#import <YYCache/YYCache.h>
#import "TTVideoFeedListItemCreator.h"
#import "TTVFeedListWebItem.h"
#import "TTMessageCenter.h"
#import "TTVFeedUserOpDataSyncMessage.h"
#import "TTVFeedUserOpViewSyncMessage.h"
#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedCellAction.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTVFeedItem+TTVConvertToArticle.h"
#import "TTUserSettingsManager+FontSettings.h"
#import "TTVFeedListItem.h"
#import "TTVFeedItem+ComputedProperties.h"
#import <BDTBasePlayer/TTVOwnPlayerPreloaderWrapper.h>
#import "TTVSettingsConfiguration.h"
#import "TTASettingConfiguration.h"

#define kInsertLastReadMinThreshold     5
#define kMaxLastReadLookupInterval      (24 * 60 * 60 * 1000)  //毫秒
#define kShowOldLastReadMinThreshold    60      //超过60篇旧文章后才可能显示“以下为24小时前的文章”

#define kLastReadIncreaseInterval   0.5

#define RelationActionSuccessNotification @"RelationActionSuccessNotification"
#define kRelationActionSuccessNotificationActionTypeKey @"kRelationActionSuccessNotificationActionTypeKey"
#define kRelationActionSuccessNotificationUserIDKey @"kRelationActionSuccessNotificationUserIDKey"

static NSString *const kTTVFeedListVideoPrefetchGroup = @"kTTVFeedListVideoPrefetchGroup";
static NSString *const kVideoListPlist = @"com.bytedance.kTTVVideoList";
static NSString *const kLastReadPersistKey = @"kLastReadPersistKey";

static const int FriendActionTypeFollow = 11;
static const int FriendActionTypeUnfollow = 12;

extern NSError *ttcommonlogic_handleError(NSError *error, NSDictionary *result, NSString **exceptionInfo);
extern BOOL ttsettings_shouldShowLastReadForCategoryID(NSString *categoryID);

typedef void(^Finished)();
@interface TTVFeedListViewModel() <TTVFeedUserOpDataSyncMessage>
@property (nonatomic ,strong)TTVideoFeedListService *feedListService;
@property (nonatomic ,assign)NSInteger loadMoreCount;

@property (nonatomic, assign) BOOL isFirstRefreshListAfterLaunch;
@property (nonatomic, strong) TTVLastRead *lastReadData;
@property (nonatomic, strong) YYCache *lastReadDataCache;

@end
@implementation TTVFeedListViewModel

- (void)dealloc
{
    UNREGISTER_MESSAGE(TTVFeedUserOpDataSyncMessage, self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hasMore = YES;
        _isLoading = NO;
        self.dataArr = [NSMutableArray array];
        _lastFetchRiseError = NO;
        _feedListService = [[TTVideoFeedListService alloc] init];
        REGISTER_MESSAGE(TTVFeedUserOpDataSyncMessage, self);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged) name:kSettingFontSizeChangedNotification object:nil];

    }
    return self;
}

- (void)setCategoryID:(NSString *)categoryID
{
    _categoryID = categoryID;
    self.feedListService.category = categoryID;
}

- (void)setIsVideoTabCategory:(BOOL)isVideoTabCategory
{
    _isVideoTabCategory = isVideoTabCategory;
    self.feedListService.isVideoTabCategory = isVideoTabCategory;
}

- (YYCache *)lastReadDataCache
{
    if (!_lastReadDataCache) {
        _lastReadDataCache = [YYCache cacheWithName:[NSString stringWithFormat:@"%@/%@", kVideoListPlist, self.isVideoTabCategory ? self.categoryID : [NSString stringWithFormat:@"tab0_%@", self.categoryID]]];
    }
    return _lastReadDataCache;
}

- (BOOL)checkSameCategory:(NSString *)categoryID complete:(void (^)())complete
{
    if (!isEmptyString(_categoryID) && ![_categoryID isEqualToString:categoryID]) {
        [self reset];
        self.error = [NSError errorWithDomain:kExploreFetchListErrorDomainKey code:kExploreFetchListCategoryIDChangedCode userInfo:nil];
        return NO;
    }
    return YES;
}

- (void)loadDataWithParameters:(TTVideoFeedListParameter *)parameter completeBlock:(void (^)())complete
{
    self.hasMore = YES;
    self.loadMoreCount = 0;
    self.categoryID = parameter.categoryID;
    int64_t startTime = [NSObject currentUnixTime];
    self.isLoading = YES;
    self.increaseNumber = 0;
    self.isFirstRefreshListAfterLaunch = self.dataArr.count == 0;
    BOOL needGetLocalFeedsOrderIndexForLastRead = self.isFirstRefreshListAfterLaunch && parameter.getRomote;
    parameter.needGetLocalFeedsOrderIndexForLastRead = needGetLocalFeedsOrderIndexForLastRead;
    NSNumber *orderIndex = [self handleLastReadBeforeRefreshIfNeeded:NO fromRemote:parameter.getRomote];
    @weakify(self);
    [self.feedListService getFeedWithParameters:parameter completion:^(TTVideoFeedResponse *response, NSArray *localItemsExceptTopWebWhenRequired, NSError *error) {
        @strongify(self);
        void (^finishedBlock)() = ^{
            @strongify(self);
            NSNumber *destOrderIndex = orderIndex;
            if (needGetLocalFeedsOrderIndexForLastRead && localItemsExceptTopWebWhenRequired.count > 0) {
                TTVFeedItem *videoFeedItem = (TTVFeedItem *)localItemsExceptTopWebWhenRequired.firstObject;
                destOrderIndex = @(videoFeedItem.behotTime * 1000);
            }
            self.isLoading = NO;
            [self insertLastReadCellAfterLoadData:NO orderIndex:destOrderIndex];
            if (complete) {
                complete();
            }
        };
        self.netData = response.originData;
        if (response.isFromLocal) {
            if (response.feedItems.count > 0) {
                for (TTVFeedListItem *item in self.dataArr) {
                    if ([item isKindOfClass:[TTVFeedListItem class]]) {
                        item.shareTracker.groupID = nil;
                        item.shareTracker = nil;
                        item.originData = nil;
                    }
                }
                [self.dataArr removeAllObjects];
                [self addCellEntityWithDataArray:response.feedItems parameter:parameter isAppendTop:YES response:response];
                [self addCellEntityWithWebCell:response.topWeb parameter:parameter];
                finishedBlock ? finishedBlock() : nil;
            }
            else
            {
                [self addCellEntityWithWebCell:response.topWeb parameter:parameter];
                if (!parameter.getRomote) {
                    finishedBlock ? finishedBlock() : nil;//不请求网络的话就结束请求.
                }
                else
                {
                    return;
                }
            }
        }
        else
        {
            self.lastFetchRiseError = error != nil ? YES : NO;
            self.error = error;
            self.isFromRemote = !response.isFromLocal;
            int64_t endTime = [NSObject currentUnixTime];
            self.requestConsumeTime = @(endTime - startTime);

            if (error) {
                self.increaseNumber = 0;
                NSError *resultError = ttcommonlogic_handleError(error, nil, nil);
                if (resultError) {
                    self.error = resultError;
                }
            }
            else
            {
                if ([response isKindOfClass:[TTVideoFeedResponse class]]) {
                    [self trackAbNormal:response parameter:parameter];
                    self.hasMore = response.originData.hasMore && response.increaseNumber > 0;
                    self.hasNew = response.originData.hasMoreToRefresh;
                    self.increaseNumber = response.increaseNumber;
                    [self.dataArr removeAllObjects];
                    if (response.feedItems.count > 0) {
                        [self addCellEntityWithDataArray:response.feedItems parameter:parameter isAppendTop:YES response:response];
                    }
                    [self addCellEntityWithWebCell:response.topWeb parameter:parameter];
                }
            }
            finishedBlock ? finishedBlock() : nil;
        }
    }];
}

- (void)trackAbNormal:(TTVideoFeedResponse *)response parameter:(TTVideoFeedListParameter *)parameter
{
    if (response.increasedItems.count == 0 && !response.originData.hasMoreToRefresh) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:parameter.categoryID forKey:@"categoryID"];
        [[TTMonitor shareManager] trackService:@"feed_no_data" status:1 extra:extra];
    } else if (response.increasedItems.count < 4) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        [extra setValue:parameter.categoryID forKey:@"categoryID"];
        [[TTMonitor shareManager] trackService:@"feed_count_abnormal" status:1 extra:extra];
    }
    
}

- (void)loadMoreWithParameters:(TTVideoFeedListParameter *)parameter completeBlock:(void (^)())complete
{
    if (![self checkSameCategory:parameter.categoryID complete:complete]) {
        return;
    }
    self.isLoading = YES;
    self.categoryID = parameter.categoryID;
    int64_t startTime = [NSObject currentUnixTime];
    NSNumber *orderIndex = [self handleLastReadBeforeRefreshIfNeeded:YES fromRemote:parameter.getRomote];
    parameter.offset = 20 * self.loadMoreCount;//offset .垂直视频需要
    @weakify(self);
    [self.feedListService getFeedMoreWithParameters:parameter completion:^(TTVideoFeedResponse *response, NSError *error) {
        @strongify(self);
        void (^finishedBlock)() = ^{
            @strongify(self);
            self.isLoading = NO;
            [self insertLastReadCellAfterLoadData:YES orderIndex:orderIndex];
            if (complete) {
                complete();
            }
        };

        self.netData = response.originData;
        self.lastFetchRiseError = error != nil ? YES : NO;
        self.error = error;
        if (error) {
            NSError *resultError = ttcommonlogic_handleError(error, nil, nil);
            if (resultError) {
                self.error = resultError;
            }
            finishedBlock ? finishedBlock() : nil;
        }
        else
        {
            if ([response isKindOfClass:[TTVideoFeedResponse class]]) {
                self.loadMoreCount++;
                self.hasMore = response.originData.hasMore && response.increaseNumber > 0;
                self.isFromRemote = YES;
                self.hasNew = response.originData.hasMoreToRefresh;
                self.increaseNumber = response.increaseNumber;
                int64_t endTime = [NSObject currentUnixTime];
                self.requestConsumeTime = @(endTime - startTime);
                if (response.increasedItems.count > 0) {
                    [self addCellEntityWithDataArray:response.increasedItems parameter:parameter isAppendTop:NO response:response];
                }
            }
            finishedBlock ? finishedBlock() : nil;
        }
    }];
}

- (void)addCellEntityWithWebCell:(TTVFeedItem *)feedItem parameter:(TTVideoFeedListParameter *)parameter
{
    if ([feedItem.webCell isKindOfClass:[TTVTopWebCell class]]) {
        TTVFeedListWebItem *entity = [[TTVFeedListWebItem alloc] init];
        entity.originData = feedItem;
        entity.categoryId = parameter.categoryID;
        entity.refer = [parameter.refer unsignedIntegerValue];
        entity.cellSeparatorStyle = self.dataArr.count > 0 ? TTVFeedListCellSeparatorStyleNone : TTVFeedListCellSeparatorStyleHas;
        entity.cellHeight = feedItem.webCell.cellHeight;
        [self.dataArr insertObject:entity atIndex:0];
    }

}

- (void)addCellEntityWithDataArray:(NSArray *)array parameter:(TTVideoFeedListParameter *)parameter isAppendTop:(BOOL)isAppendTop response:(TTVideoFeedResponse *)response
{
    NSMutableArray *entitys = [NSMutableArray array];
    [self prefetchAutoPlayVideoWithFeedItems:[array copy]];
    for (int i = 0; i < array.count; i ++) {
        TTVFeedItem *obj = array[i];
        TTVFeedListItem *entity = [[[self entityClassWithItem:obj] alloc] init];
        entity.originData = obj;
        entity.categoryId = parameter.categoryID;
        entity.refer = [parameter.refer unsignedIntegerValue];
        entity.cellSeparatorStyle = ttv_feedListCellSeparatorStyleByTotalAndRow(array.count, i);
        entity.cellAction = [[[self cellActionClassWithItem:obj] alloc] init];
        entity.isFirstCached = response.isFromLocal;
        if (obj.videoCell) {
            entity.followedWhenInit = obj.videoCell.userInfo.follow;
        }
        if (response.isFromLocal) {
            entity.comefrom = TTVFromOptionFile;
        } else if (parameter.reloadType == TTReloadTypePreLoadMore) {
            entity.comefrom = TTVFromOptionPullUp;
        } else if (parameter.reloadType == TTReloadTypePull) {
            entity.comefrom = TTVFromOptionPullDown;
        }
        [TTVFeedListItemCreator configureItem:entity];
        [entity calculateCellHeightWithWidth:[UIScreen mainScreen].bounds.size.width];
        [entity ttv_addShareTrcker];
        [entitys addObject:entity];
    }
    if (isAppendTop) {
        NSArray *temp = [NSArray arrayWithArray:self.dataArr];
        for (TTVFeedListItem *item in self.dataArr) {
            if ([item isKindOfClass:[TTVFeedListItem class]]) {
                item.shareTracker.groupID = nil;
                item.shareTracker = nil;
                item.originData = nil;
            }
        }
        [self.dataArr removeAllObjects];
        [self.dataArr addObjectsFromArray:entitys];
        if ([[entitys lastObject] isKindOfClass:[TTVFeedListItem class]] && temp.count > 0) {
            ((TTVFeedListItem *)[entitys lastObject]).cellSeparatorStyle = TTVFeedListCellSeparatorStyleHas;
        }
        [self.dataArr addObjectsFromArray:temp];
    }else{
        if ([[self.dataArr lastObject] isKindOfClass:[TTVFeedListItem class]] && entitys.count > 0) {
            ((TTVFeedListItem *)[self.dataArr lastObject]).cellSeparatorStyle = TTVFeedListCellSeparatorStyleHas;
        }
        [self.dataArr addObjectsFromArray:entitys];
    }
}

- (void)prefetchAutoPlayVideoWithFeedItems:(NSArray *)feedItems
{
    if (!ttas_isAutoPlayVideoPreloadEnable()) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (TTVFeedItem *item in feedItems) {
            if ([item couldAutoPlay] && !isEmptyString(item.article.videoId)) {
                HandleType handler = [[TTVOwnPlayerPreloaderWrapper sharedPreloader] preloadVideoID:item.article.videoId];
                TTAdPlayerPreloadModel *preloadModel = [[TTAdPlayerPreloadModel alloc] initWithAdId:item.adIDStr logExtra:item.logExtra handleType:handler];
                [[TTVOwnPlayerPreloaderWrapper sharedPreloader] addAdPreloadItem:preloadModel];
            }
        }
    });
}

- (Class)cellActionClassWithItem:(TTVFeedItem *)item
{
    if (item.isNormalVideo){
        return [TTVFeedCellVideoAction class];
    }else{
        if (item.adCell.hasApp) {
            return [TTVFeedCellAdAppAction class];
        }else if (item.adCell.hasWeb){
            return [TTVFeedCellWebAction class];
        }else if (item.adCell.hasPhone){
            return [TTVFeedCellAdPhoneAction class];
        }else if (item.adCell.hasForm){
            return [TTVFeedCellAdFormAction class];
        }else if (item.adCell.hasCounsel){
            return [TTVFeedCellAdCounselAction class];
        }else if (item.adCell.hasNormal){
            return [TTVFeedCellAdNormalAction class];
        }
    }
    return nil;
}


- (Class)entityClassWithItem:(TTVFeedItem *)item
{
    switch (item.videoBusinessType) {
        case TTVVideoBusinessType_PicAdapp:
        case TTVVideoBusinessType_PicAdweb:
        case TTVVideoBusinessType_PicAdform:
        case TTVVideoBusinessType_PicAdphone:
        case TTVVideoBusinessType_Adnormal:
            return [TTVFeedListPicAdItem class];
            break;
        case TTVVideoBusinessType_VideoAdapp:
        case TTVVideoBusinessType_VideoAdweb:
        case TTVVideoBusinessType_VideoAdform:
        case TTVVideoBusinessType_VideoAdphone:
            if (item.videoCell.article.videoDetailInfo.videoType == TTVVideoDetailInfo_VideoType_Normal) {
                return [TTVFeedListVideoAdItem class];
            }
            else if (item.videoCell.article.videoDetailInfo.videoType == TTVVideoDetailInfo_VideoType_Live){
                return [TTVFeedListLiveItem class];
            }
            break;
        case TTVVideoBusinessType_VideoNormal:
            return [self getVideoClassWithVideoItemItemInternal__:item];
            break;
        default:
            if (item.videoCell) {
                return [self getVideoClassWithVideoItemItemInternal__:item];
            }
            break;
    }

    return nil;
}

- (Class)getVideoClassWithVideoItemItemInternal__:(TTVFeedItem *)item
{
    if (item.videoCell.article.videoDetailInfo.videoType == TTVVideoDetailInfo_VideoType_Normal) {
        return [TTVFeedListVideoItem class];
    }
    else if (item.videoCell.article.videoDetailInfo.videoType == TTVVideoDetailInfo_VideoType_Live){
        return [TTVFeedListLiveItem class];
    }
    return nil;
}

- (void)reset
{
    [self cancelRequest];
    self.hasMore = YES;
    _isLoading = NO;
    _lastFetchRiseError = NO;
    [self.dataArr removeAllObjects];
    self.loadMoreCount = 0;
}

- (void)removeExpireADs
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];

    [self.dataArr enumerateObjectsUsingBlock:^(TTVTableViewItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[TTVFeedListItem class]] && ((TTVFeedListItem *)obj).originData.article.adId.longLongValue > 0) {
            TTVFeedListItem *item = (TTVFeedListItem *)obj;
            BOOL shouldRemove = !(item.originData.adInfo.expireSeconds <= 0 || item.originData.adInfo.isPreview);
            if (shouldRemove && timeInterval - item.originData.requestTime > item.originData.adInfo.expireSeconds) {
                
                [self removeItemIfExist:item];
            }
        }
    }];
}

- (void)cancelRequest
{
    [self.feedListService cancelRequest];
    _isLoading = NO;
}

- (BOOL)removeItemIfExist:(TTVTableViewItem *)item
{
    if ([self.dataArr containsObject:item]) {
        [self.dataArr removeObject:item];
        if ([item isKindOfClass:[TTVFeedListItem class]]) {
            TTVFeedListItem *itemA = (TTVFeedListItem *)item;
            [self.feedListService removeArticle:itemA.originData];
        } else if ([item isKindOfClass:[TTVLastReadItem class]]) {
            [self removeLastReadDataInCache];
        }
        return YES;
    }

    return NO;
}


- (void)removeAllItemsOnAccountChanged
{
    [self.feedListService removeAllItemsOnAccountChanged];
    [self.dataArr removeAllObjects];
}

#pragma mark - TTVFeedUserOpDataSyncMessage

- (void)ttv_message_feedCollectChanged:(BOOL)collect uniqueIDStr:(NSString *)uniqueIDStr
{
    id<TTVArticleProtocol> article = nil;
    [self feedCollectChanged:collect uniqueIDStr:uniqueIDStr forKey:@keypath(article, userRepined)];
}

- (void)ttv_message_feedDiggChanged:(BOOL)userDigg uniqueIDStr:(NSString *)uniqueIDStr
{
    id<TTVArticleProtocol> article = nil;
   [self feedCollectChanged:userDigg uniqueIDStr:uniqueIDStr forKey:@keypath(article, userDigg)];
}

- (void)ttv_message_feedBuryChanged:(BOOL)userBury uniqueIDStr:(NSString *)uniqueIDStr
{
    id<TTVArticleProtocol> article = nil;
   [self feedCollectChanged:userBury uniqueIDStr:uniqueIDStr forKey:@keypath(article, userBury)];
}

- (void)ttv_message_feedDiggCountChanged:(int)diggCount uniqueIDStr:(NSString *)uniqueIDStr
{
    id<TTVArticleProtocol> article = nil;
   [self feedCollectChanged:diggCount uniqueIDStr:uniqueIDStr forKey:@keypath(article, diggCount)];
}

- (void)ttv_message_feedBuryCountChanged:(int)buryCount uniqueIDStr:(NSString *)uniqueIDStr
{
    id<TTVArticleProtocol> article = nil;
   [self feedCollectChanged:buryCount uniqueIDStr:uniqueIDStr forKey:@keypath(article, buryCount)];
}

- (void)ttv_message_feedCommentCountChanged:(int)commentCount uniqueIDStr:(NSString *)uniqueIDStr
{
    id<TTVArticleProtocol> article = nil;
    [self feedCollectChanged:commentCount uniqueIDStr:uniqueIDStr forKey:@keypath(article, commentCount)];
}

- (void)feedCollectChanged:(int)status uniqueIDStr:(NSString *)uniqueIDStr forKey:(NSString *)key
{
    for (TTVTableViewItem *item in self.dataArr) {
        if (![item isKindOfClass:[TTVFeedListItem class]]) {
            continue;
        }
        TTVFeedListItem *itemA = (TTVFeedListItem *)item;
        if ([itemA.originData.uniqueIDStr isEqualToString:uniqueIDStr]) {
            [itemA.originData setValue:@(status) forKey:key];
            [itemA.originData.savedConvertedArticle setValue:@(status) forKey:key];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                int64_t fixedgroupID = [[SSCommonLogic fixStringTypeGroupID:itemA.originData.groupModel.groupID] longLongValue];
                NSString *primaryID = [Article primaryIDByUniqueID:fixedgroupID itemID:itemA.originData.groupModel.itemID adID:itemA.originData.adIDStr];
                Article *cachedArticle = [Article objectForPrimaryKey:primaryID];
                if (cachedArticle) {
                    [cachedArticle setValue:@(status) forKey:key];
                    [cachedArticle save];
                }
            });
//            SAFECALL_MESSAGE(TTVFeedUserOpViewSyncMessage, @selector(ttv_message_feedListItemChanged:), ttv_message_feedListItemChanged:itemA);
            break;
        }
    }
}

- (void)followNotification:(NSNotification *)notify
{
    NSString * userID = notify.userInfo[kRelationActionSuccessNotificationUserIDKey];
    if (isEmptyString(userID)) {
        return;
    }
    NSInteger actionType = [(NSNumber *)notify.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
    for (TTVTableViewItem *item in self.dataArr) {
        if (![item isKindOfClass:[TTVFeedListItem class]]) {
            continue;
        }
        TTVFeedListItem *itemA = (TTVFeedListItem *)item;
        TTVUserInfo *userInfo = itemA.originData.videoCell.userInfo;
        if (userInfo.userId == [userID longLongValue]) {
            if (actionType == FriendActionTypeFollow) {
                userInfo.follow = YES;
            } else if (actionType == FriendActionTypeUnfollow) {
                userInfo.follow = NO;
            }
//            SAFECALL_MESSAGE(TTVFeedUserOpViewSyncMessage, @selector(ttv_message_feedListItemChanged:), ttv_message_feedListItemChanged:itemA);
            break;
        }
    }
}

#pragma mark - Last Read

- (NSNumber *)handleLastReadBeforeRefreshIfNeeded:(BOOL)getMore fromRemote:(BOOL)fromRemote {
    TTVLastRead *lastRead = self.lastReadData;
    if (self.lastReadData == nil) {
        lastRead = (TTVLastRead *)[self.lastReadDataCache objectForKey:[self getLastReadPersistKey]];
        self.lastReadData = lastRead;
    }
    NSNumber *orderIndex = nil;
    if (!self.isFirstRefreshListAfterLaunch) {
        if (!getMore) {
            orderIndex = [self getTopItemOrderIndex];
        } else {
            orderIndex = lastRead.orderIndex;
        }
    } else if (fromRemote) {
        //需要get localItems
    } else if (lastRead) {
        orderIndex = lastRead.orderIndex;
    }
    return orderIndex;
}

- (NSNumber *)getTopItemOrderIndex {
    TTVTableViewItem *item = [self.dataArr bk_match:^BOOL(TTVTableViewItem *obj) {
        return ![obj isKindOfClass:[TTVFeedListWebItem class]];
    }];
    if ([item isKindOfClass:[TTVFeedListItem class]]) {
        TTVFeedListItem *videoFeedItem = (TTVFeedListItem *)item;
        return @(videoFeedItem.originData.behotTime * 1000);
    }
    return nil;
}

- (void)insertLastReadCellAfterLoadData:(BOOL)isLoadMore orderIndex:(NSNumber *)orderIndex {
    NSNumber * nowOrderIndex = @([[NSDate date] timeIntervalSince1970] * 1000);
    if (isLoadMore) {
        if ((orderIndex == nil && !self.lastReadData && self.dataArr.count > kShowOldLastReadMinThreshold) || (orderIndex && [nowOrderIndex doubleValue] - [orderIndex doubleValue] > kMaxLastReadLookupInterval && self.dataArr.count > kShowOldLastReadMinThreshold)) {
            orderIndex = @([nowOrderIndex doubleValue] - kMaxLastReadLookupInterval);
        } else if (orderIndex) {
            //避免插入orderindex再次加0.5
            orderIndex = @([orderIndex doubleValue] - kLastReadIncreaseInterval);
        }
    }
    NSDate *recordedLastReadDate = nil;
    NSDate *lastReadFirstAppearDate = nil;
    NSDate *now = [NSDate date];
    NSDate *oneDayAgo = [NSDate dateWithTimeIntervalSinceNow:- kMaxLastReadLookupInterval/1000];
    if ([self shouldInsertLastReadCellAfterLoadData:isLoadMore orderIndex:orderIndex])
    {
        if (self.lastReadData) {
            if (isLoadMore) {
                recordedLastReadDate = self.lastReadData.lastDate;
                lastReadFirstAppearDate = self.lastReadData.refreshDate;
            }
            else{
                recordedLastReadDate = self.lastReadData.refreshDate;
                lastReadFirstAppearDate = now;
            }
        }
        else{
            if (isLoadMore) {
                recordedLastReadDate = oneDayAgo;
                lastReadFirstAppearDate = now;
            }
            else{
                recordedLastReadDate = now;
                lastReadFirstAppearDate = now;
            }
        }
        TTVLastReadItem *lastReadItem = [[TTVLastReadItem alloc] init];
        TTVLastRead *lastRead = [[TTVLastRead alloc] init];
        lastRead.refreshDate = lastReadFirstAppearDate;
        lastRead.lastDate = recordedLastReadDate;
        lastRead.showRefresh = @(YES);
        lastReadItem.lastRead = lastRead;
        NSNumber *lastReadOrderIndex = @([orderIndex longLongValue] + kLastReadIncreaseInterval);
        lastRead.orderIndex = lastReadOrderIndex;
        [self.lastReadDataCache setObject:lastRead forKey:[self getLastReadPersistKey] withBlock:nil];
        if ([self.dataArr count] > 0) {
            TTVTableViewItem *item = [self.dataArr lastObject];
            if ([item isKindOfClass:[TTVFeedListItem class]]) {
                TTVFeedListItem *videoFeedItem = (TTVFeedListItem *)item;
                int64_t lastOrderIndex = videoFeedItem.originData.behotTime * 1000;
                if (orderIndex && [lastReadOrderIndex doubleValue] > lastOrderIndex) {
                    [self insertLastReadTableItem:lastReadItem orderIndex:[lastReadOrderIndex doubleValue]];
                }
            }
        }
    }
    //TODOPY
//    else if (self.lastReadData) {
//        if (self.isFirstRefreshListAfterLaunch) {
//            recordedLastReadDate = self.lastReadData.refreshDate;
//            lastReadFirstAppearDate = now;
//            self.lastReadData.lastDate = recordedLastReadDate;
//            self.lastReadData.refreshDate = lastReadFirstAppearDate;
//            [self.lastReadDataCache setObject:self.lastReadData forKey:[self getLastReadPersistKey] withBlock:nil];
//        }
//    }
}


- (BOOL)shouldInsertLastReadCellAfterLoadData:(BOOL)isLoadMore orderIndex:(NSNumber *)orderIndex
{
#warning 用于LastRead的测试bug使用
//    if (orderIndex) {
//        NSArray *orderIndexArray = [[[self.dataArr bk_select:^BOOL(id obj) {
//            return [obj isKindOfClass:[TTVFeedListItem class]];
//        }] valueForKeyPath:@keypath(TTVFeedListItem.new, originData.behotTime)] bk_map:^id(NSNumber *obj) {
//            return @([obj longLongValue] * 1000);
//        }];
//        NSLog(@"orderIndex = %@, orderIndexArray = %@", orderIndex, orderIndexArray);
//    }
    BOOL lastReadRefreshEnabled = [[[TTSettingsManager sharedManager] settingForKey:@"last_read_refresh" defaultValue:@YES freeze:NO] boolValue];
    if (orderIndex == nil || !lastReadRefreshEnabled || !ttsettings_shouldShowLastReadForCategoryID(self.categoryID)) {
        return NO;
    }
    else {
        if (self.dataArr.count > kInsertLastReadMinThreshold) {
            TTVTableViewItem *item = self.dataArr[kInsertLastReadMinThreshold - 1];
            if ([item isKindOfClass:[TTVFeedListItem class]]) {
                TTVFeedListItem *videoFeedItem = (TTVFeedListItem *)item;
                TTVFeedItem *feed = videoFeedItem.originData;
                int64_t theFifthOrderIndex = feed.behotTime * 1000;
                if ([orderIndex longLongValue] < theFifthOrderIndex) {
                    if (isLoadMore) {
                        BOOL result = ![self lastReadItemAlreadyExist];
                        return result;
                    } else {
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (BOOL)lastReadItemAlreadyExist
{
    return [self.dataArr bk_any:^BOOL(TTVTableViewItem *obj) {
        return [obj isKindOfClass:[TTVLastReadItem class]];
    }];
}

- (void)insertLastReadTableItem:(TTVLastReadItem *)lastReadItem orderIndex:(double)orderIndex {
    if (self.dataArr.count == 0) {
        return;
    }
    __block  NSInteger destIndex = NSNotFound;
    [self.dataArr enumerateObjectsUsingBlock:^(TTVTableViewItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([item isKindOfClass:[TTVFeedListItem class]] && ((TTVFeedListItem *)item).originData.behotTime * 1000 < orderIndex) {
            destIndex = idx;
            *stop = YES;
        }
    }];
    if (destIndex != NSNotFound && destIndex >= 1 && destIndex != self.dataArr.count) {
        if (destIndex >= 0 + 1) {
            TTVFeedListItem *item = (TTVFeedListItem *)self.dataArr[destIndex - 1];
            if ([item isKindOfClass:[TTVFeedListItem class]]) {
                item.cellSeparatorStyle = TTVFeedListCellSeparatorStyleNone;
            }
        }
        [self.dataArr insertObject:lastReadItem atIndex:destIndex];
        self.lastReadData = nil;
    }
}

- (NSString *)getLastReadPersistKey
{
    return [NSString stringWithFormat:@"%@", self.categoryID];
}

- (void)removeLastReadDataInCache
{
    [self.lastReadDataCache setObject:nil forKey:[self getLastReadPersistKey] withBlock:nil];
}

- (void)fontSizeChanged
{
    
    for (int i = 0; i < self.dataArr.count; i++)
    {
        TTVTableViewItem *item = self.dataArr[i];
        if ([item isKindOfClass:[TTVFeedListItem class]]) {
            TTVFeedListItem *listItem= (TTVFeedListItem *)item;
            listItem.titleHeight = 0;
        }
    }
}


@end
