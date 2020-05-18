//
//  TTArticleCategoryManager.h
//  Article
//
//  Created by Dianwei on 12-12-18.
//
//

#import <Foundation/Foundation.h>
#import "TTCategory.h"
#import "TTCategoryDefine.h"

#define kAritlceCategoryGotFinishedNotification @"kAritlceCategoryGotFinishedNotification"
#define kArticleCategoryHasChangeNotification   @"kArticleCategoryHasChangeNotification"
#define kArticleCategoryTipNewChangedNotification @"kArticleCategoryTipNewChangedNotification"
#define kArticleLocalCategoryConcernIDHasChangeNotification @"kArticleLocalCategoryConcernIDHasChangeNotification"

//用于存储category的version值
#define kArticleCategoryManagerVersionKey @"kArticleCategoryManagerVersionKey"

#define kCategoryStoreVersion 2

#define KArticleCategoryManagerHasNewTipKey [NSString stringWithFormat:@"KArticleCategoryManagerHasNewTip%i", kCategoryStoreVersion]

#define kArticleCategoryManagerUserSelectedLocalCityKey @"kArticleCategoryManagerUserSelectedLocalCityKey"
#define kArticleCategoryManagerServerLocalCityNameKey   @"kArticleCategoryManagerServerLocalCityNameKey"

extern NSString *const kTTInsertCategoryToLastPositionNotification;
extern NSString *const kTTInsertCategoryNotificationCategoryKey;
extern NSString *const kTTInsertCategoryNotificationPositionKey;

//extern NSString * const kTTMainConcernID;
//extern NSString * const kTTWeitoutiaoConcernID;


typedef BOOL(^TTArticleCategoryManagerIARBlock)(void);
typedef NSString *(^TTArticleCategoryManagerSysLocationBlock)(void);
typedef NSString *(^TTArticleCategoryManagerCityBlock)(void);

@interface TTArticleCategoryManager : NSObject

/**
 *  数据库中所有有效频道, 不包括已删除和不支持的类型
 *  左侧固定频道 + 订阅频道 + 未订阅频道
 */
@property(nonatomic, readonly)NSMutableArray *allCategories;

/**
 *  推荐频道左边的固定频道
 */
@property(nonatomic, strong, readonly)NSMutableArray *preFixedCategories;

/**
 *  已订阅的有效频道（不包含左侧固定的频道）
 */
@property(nonatomic, readonly)NSMutableArray *subScribedCategories;
/**
 *  4.3新增，为entry频道， 目前只有一个订阅号
 */
@property(nonatomic, readonly)NSMutableArray *subscribeEntryCategories;
/**
 *  所有有效的文章频道,包括订阅和未订阅的以及左侧固定的频道
 */
@property(nonatomic, readonly)NSMutableArray *articleCategories;
/**
 *  所有有效的段子频道,包括订阅和未订阅的以及左侧固定的频道
 */
@property(nonatomic, readonly)NSMutableArray *essayCatgegories;
/**
 *  所有有效的图片频道,包括订阅和未订阅的以及左侧固定的频道
 */
@property(nonatomic, readonly)NSMutableArray *imageCategories;
/**
 *  所有有效的web频道,包括订阅和未订阅的以及左侧固定的频道
 */
@property(nonatomic, readonly)NSMutableArray *webCategories;
/**
 *  本地频道
 */
@property(nonatomic, readonly)TTCategory *localCategory;
/**
 *  最近一次添加的频道的model， 可能返回nil
 */
@property(nonatomic, strong)TTCategory *lastAddedCategory;

/**
 *  请求频道回调
 */
@property(nonatomic, copy) void (^completionRequest)(BOOL isSuccess);

/**
 *  频道管理的单例
 *
 *  @return 频道管理的单例
 */
+ (TTArticleCategoryManager *)sharedManager;
/**
 *  推荐频道
 *
 *  @return 推荐频道
 */
+ (TTCategory *)mainArticleCategory;
+ (TTCategory *)newsLocalCategory;
+ (TTCategory *)categoryModelByCategoryID:(NSString *)categoryID;
+ (TTCategory *)insertCategoryWithDictionary:(NSDictionary *)dict;

+ (NSString *)currentSelectedCategoryID;
+ (void)setCurrentSelectedCategoryID:(NSString *)categoryID;

/**
 *  远端更新频道
 */
- (void)startGetCategory;
- (void)startGetCategory:(BOOL)userChanged;
- (void)startGetCategoryWithCompleticon:(void(^)(BOOL isSuccess))completion;

/**
 *  更新推荐频道
 */

- (void)startGetUnsubscribedCategory;

/**
 *  按照orderIndex更新订阅列表的顺序
 */
- (void)updateSubScribedCategoriesOrderIndex;

/**
 *  订阅频道
 *
 *  @param category 待订阅的频道
 */
- (void)subscribe:(TTCategory *)category;

/**
 *  取消订阅频道
 *
 *  @param category 取消订阅频道
 */
- (void)unSubscribe:(TTCategory *)category;

//增加左侧固定频道
- (void)insertCategoryToPreFixed:(TTCategory *)category toOrderIndex:(NSInteger)toOrderIndex;

/**
 *  调整频道次序
 *
 *  @param category 要调整的频道model
 */
- (void)changeSubscribe:(TTCategory *)category toOrderIndex:(NSInteger)index;

/**
 *  讲所有频道的tip_new都设置为NO
 *
 *  @param save YES：保存， NO：不保存
 */
- (void)clearCategoryTipNewWithSave:(BOOL)save;

/**
 *  是否有需要提示的频道
 *
 *  @return YES：有需要提示New的频道
 */
+ (BOOL)hasNewTip;

/**
 *  设置是否需要有提示的频道
 *
 *  @param hasNew YES：有需要提示New的频道
 */
+ (void)setHasNewTip:(BOOL)hasNew;

/**
 *  本地频道相关
 *  记录用户手动选择过城市
 */
+ (void)setUserSelectedLocalCity;
+ (BOOL)isUserSelectedLocalCity;

/**
 *  保存频道修改，如果有变化将发送kArticleCategoryHasChangeNotification通知
 */
- (void)save;

/**
 *  保存频道修改，根据notify决定是否发送kArticleCategoryHasChangeNotification通知
 *
 *  @param notify YES:发送kArticleCategoryHasChangeNotification通知
 */
- (void)saveWithNotify:(BOOL)notify;

/**
 *  左侧固定频道以及订阅频道
 */
- (NSArray *)preFixedAndSubscribeCategories;

/**
 *  未订阅列表
 *
 *  @return 未订阅列表
 */
- (NSArray*)unsubscribeCategories;

/**
 *  是否获取过服务器的数据, 按照版本区分
 *
 *  @return YES:获取过
 */
+ (BOOL)hasGotRemoteData;

/**
 *  重置是否获取过服务器的数据, 按照版本区分
 */
+ (void)clearHasGotRemoteData;

/**
 *  使用由dataDicts生成的列表替换原来的所有列表
 */
- (void)rebuildAllCategoriesWithDataDicts:(NSArray *)dataDicts;

/**
 *  本地图片相关频道
 *
 *  @return NSArray of TTCategory
 */
- (NSArray *)localPhotoCategories;

/**
 *  服务端接口下发的频道版本号
 */
+ (void)setGetCategoryVersion:(NSString *)version;

/**
 *  挂到业务层的钩子函数
 */
- (void)setSysLocationBlock:(TTArticleCategoryManagerSysLocationBlock)block;
- (void)setIARBlock:(TTArticleCategoryManagerIARBlock)block;
- (void)setCityBlock:(TTArticleCategoryManagerCityBlock)block;

@end

////////////////////////////////////////////////////////////////////////

@interface TTArticleCategoryManager(InsertDefaultCategory)
/**
 *  插入默认数据
 *  所有版本仅能调用一次, 由外部保证仅调用一次
 */
+ (void)insertDefaultData;

/**
 *  数据库为空时使用默认数据
 */
+ (void)insertDefaultDataIfNeeded;

@end
