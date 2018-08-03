//
//  FRConcernEntity.h
//  Article
//
//  Created by 王霖 on 15/11/2.
//
//

#import "FRBaseEntity.h"
#import "FRApiModel.h"

#pragma mark - Notification declare
//-----------------------------------------------------------------------------------------
//
//下面的两个通知用法:外部调用FRNeedUpdateConcernEntityCareStateNotification让关心实体更新关心状态,
//                关心实体更新好状态，会发送FRConcernEntityCareStateChangeNotification通知。这两
//                个通知的userInfo的key-value都是一一对应的。
//
//-----------------------------------------------------------------------------------------


//-------------------------------------
//
//          关心状态变化通知
//
//-------------------------------------
/**
 *  关心状态变化通知，由关心实体发送。当关心实体发现自己的关心状态发生变化的时候，会发送此通知。外部需要监听此通知来及时更新界面
 */
extern NSString * const FRConcernEntityCareStateChangeNotification;

/**
 *  关心状态变化通知中带的userInfo
 */
extern NSString * const FRConcernEntityCareStateChangeConcernIDKey;//userInfo必带key，value对应关心实体id（long long）
extern NSString * const FRConcernEntityCareStateChangeConcernStateKey;//userInfo必带的key，value对应关心实体的关心状态（bool:YES关心、NO取消关心）
extern NSString * const FRConcernEntityCareStateChangeUserInfoKey;//userInfo可能带的key，value为用户自定义的（dictionary）


//-------------------------------------
//
//          通知关心实体更新关心状态
//
//-------------------------------------
/**
 *  通知关心实体更新自己的关心状态。关心状态变化后，会发送FRConcernEntityCareStateChangeNotification通知
 */
extern NSString * const FRNeedUpdateConcernEntityCareStateNotification;

/**
 *  通知中带的userInfo。Note:该通知中下面的三对key-value的value会作为通知FRConcernEntityCareStateChangeNotification的userInfo中对应key的value
 */
extern NSString * const FRNeedUpdateConcernEntityConcernIDKey;//userInfo必带key，value对应需要更新的关心实体id（long long）
extern NSString * const FRNeedUpdateConcernEntityConcernStateKey;//userInfo必带的key，value对应需要更新的关心实体的关心状态（bool:YES关心、NO取消关心）
extern NSString * const FRNeedUpdateConcernEntityCareUserInfoKey;//userInfo可能带的key，value为用户自定义的（dictionary）

#pragma mark - concern entity declare

@interface FRConcernEntity : FRBaseEntity

@property (nonatomic, strong) NSString * concern_id;  //关心ID
@property (nonatomic, strong) NSString * name; //关心对象名称
@property (nonatomic, assign) int64_t new_thread_count;   //距离上次进入此话题新增帖子数
@property (nonatomic, strong) NSString * avatar_url;   //关心对象icon url
@property (nonatomic, assign) int64_t concern_count;  //关心对象被关心次数
@property (nonatomic, assign) int64_t discuss_count;  //关心对象讨论条数
@property (nonatomic, assign) BOOL newly; //显示new标记
@property (nonatomic, assign) int64_t concern_time;   //关心时间
@property (nonatomic, assign) BOOL managing;  //是否是管理的
@property (nonatomic, strong) NSString * share_url;   //分享URL
@property (nonatomic, strong) NSString * introdution_url; //介绍页URL
@property (nonatomic, strong) NSString<Optional> *desc; //活动类关心描述文案
@property (nonatomic, strong) NSString<Optional> *desc_rich_span; //上述对应富文本
@property (nonatomic, assign) FRInnerForumType type;    //关心类型
@property (nonatomic, strong) id headInfo; //垂类关心的头部信息
@property (nonatomic, strong) FRShareStructModel * share_data;

- (instancetype)initWithConcernItemStruct:(FRConcernItemStructModel *)item NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithConcernStruct:(FRConcernStructModel *)item NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithConcernInfo:(NSDictionary *)concernInfo NS_DESIGNATED_INITIALIZER;

+ (FRConcernEntity *)getConcernEntityWithConcernId:(NSString *)concern_id;
+ (FRConcernEntity *)genConcernEntityWithConcernItemStruct:(FRConcernItemStructModel *)model needUpdate:(BOOL)needUpdate;
+ (FRConcernEntity *)genConcernEntityWithConcernStruct:(FRConcernStructModel *)model needUpdate:(BOOL)needUpdate;
+ (FRConcernEntity *)genConcernEntityWithConcernInfo:(NSDictionary *)concernInfo needUpdate:(BOOL)needUpdate;

@end
