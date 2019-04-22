
#import "VideoFeed.pbobjc.h"
#import "TTVideoFeedListParameter.h"
#import "ListDataOperationManager.h"
#import "ExploreFetchListDefines.h"

#define kExploreFetchListErrorDomainKey @"kExploreFetchListErrorDomainKey"

//记录上次“阅读到”标记的articleID or adID
#define kExploreLastReadCellKey         @"kExploreLastReadCellKey"
#define kExploreLastReadCellIDKey       @"kExploreLastReadCellIDKey"
#define kExploreLastReadCellDateKey     @"kExploreLastReadCellDateKey"
#define kExploreLastReadShowRefreshKey  @"kExploreLastReadShowRefreshKey"

#define kExploreFetchListCategoryIDChangedCode 9001

typedef void(^ExploreFetchListFinishBlock)(NSArray *  increaseItems, id operationContext,  NSError * error);

typedef NS_ENUM(NSUInteger, TTVideoFeedListNetStatus) {
    TTVideoFeedListNetStatus_Failed,
    TTVideoFeedListNetStatus_Success,
};
@class TTVTableViewItem;
@class TTVFeedListItem;
@interface TTVFeedListViewModel : NSObject
@property (nonatomic ,strong)TTVVideoFeedResponse *netData;//网络请求的原始数据,没有加工处理
@property (nonatomic ,strong)NSMutableArray<TTVTableViewItem *> *dataArr;//经过排重,过期,下架,不感兴趣等策略处理过的最终数据.
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong) NSError *error;
/** 更新文章总数 */
@property(nonatomic, assign) NSInteger increaseNumber;//经过处理的数据,少于等于originData的totalNumber
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, copy) NSString *categoryID;
@property (nonatomic, assign) BOOL isVideoTabCategory;
@property(nonatomic, assign) BOOL isFromRemote;//网络获取的数据
@property(nonatomic, assign) BOOL hasNew;//有新的数据,显示刷新的条
@property(nonatomic, strong) NSNumber *requestConsumeTime;
/**
 *  最近的一次请求是否发生了异常
 */
@property (nonatomic, assign) BOOL lastFetchRiseError;

- (void)loadDataWithParameters:(TTVideoFeedListParameter *)parameter completeBlock:(void (^)())complete;
- (void)loadMoreWithParameters:(TTVideoFeedListParameter *)parameter completeBlock:(void (^)())complete;
/**
 *  如果item存在，删除item
 *
 *  @param item 指定的item
 */
- (BOOL)removeItemIfExist:(TTVTableViewItem *)item;
- (void)removeAllItemsOnAccountChanged;
- (void)reset;
- (void)cancelRequest;
- (void)removeExpireADs;
@end
