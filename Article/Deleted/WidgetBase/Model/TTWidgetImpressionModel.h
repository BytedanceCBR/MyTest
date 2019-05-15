//
//  TTWidgetImpressionModel.h
//  Article
//
//  Created by Zhang Leonardo on 14-6-23.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 impression的状态
 */
typedef NS_ENUM(NSInteger, TTWidgetImpressionStatus)
{
    TTWidgetImpressionStatusRecording,
    TTWidgetImpressionStatusEnd,
    TTWidgetImpressionStatusSuspend,
};


typedef NS_ENUM(NSUInteger, TTWidgetImpressionModelType)
{
    TTWidgetImpressionModelTypeGroup                  = 1,        //group item
    TTWidgetImpressionModelTypeAD                     = 2,        //ad item
    TTWidgetImpressionModelTypeComment                = 20,       //评论
    TTWidgetImpressionModelTypeMoment                 = 21,       //动态
    TTWidgetImpressionModelTypeSubject                = 99999,    //专题，目前和group发送的状态码一样，但是客户端发送逻辑不同，区分定义
    TTWidgetImpressionModelTypeExploreDetail          = 31,       //文章详情页
    TTWidgetImpressionModelTypeForumList              = 32,       //话题列表
    TTWidgetImpressionModelTypeThread                 = 33,       //话题帖子
    TTWidgetImpressionModelTypeThreadComment          = 34,       //帖子评论
    TTWidgetImpressionModelTypeMomoAD                 = 35,       //陌陌广告
    TTWidgetImpressionModelTypeVideoDetail            = 36,       //视频详情页相关视频
    TTWidgetImpressionModelTypeRelatedItem            = 37,       //详情页相关区域的item
    TTWidgetImpressionModelTypeConcernListItem        = 38,       //关心列表的cell
    TTWidgetImpressionModelTypeWendaListItem          = 39,       //问答回答列表的cell
    TTWidgetImpressionModelTypeWeitoutiaoListItem     = 41,       //微头条列表的cell
    TTWidgetImpressionModelTypeHouShanListItem        = 45,       //火山直播的cell
    TTWidgetImpressionModelTypeLianZaiListItem        = 46,       //小说连载的cell
    TTWidgetImpressionModelTypeLiveListItem           = 48,       //直播cell
    TTWidgetImpressionModelTypeU11CellListItem        = 49,       //U11cell
    TTWidgetImpressionModelTypeU11RecommendUserItem   = 51,     //u11推荐人
    TTWidgetImpressionModelTypeHuoShanTalentBanner    = 52,       //火山达人频道活动banner
    TTWidgetImpressionModelTypeArticleListItem        = 53,       //文章详情页订阅推荐组件Cell
    TTWidgetImpressionModelTypeVideoListItem          = 54,       //视频详情页订阅推荐组件Cell
    TTWidgetImpressionModelTypeHuoShanVideo           = 55,       //火山小视频tab上的火山cell
    TTWidgetImpressionModelTypeVideoFloat             = 60,       //视频浮层的cell
    TTWidgetImpressionModelTypeMessageNotification    = 65,       //消息通知的cell
};


@interface TTWidgetImpressionParams : NSObject
@property(nonatomic, copy) NSString *categoryID;   //频道ID
@property(nonatomic, copy) NSString *concernID;    //关心ID
@property(nonatomic, assign) NSUInteger refer;     //refer取值：1 列表处于频道(categoryID必须非空)，2 列表处于关心主页(concernID必须非空)
@property(nonatomic, assign) NSUInteger cellStyle;
@property(nonatomic, assign) NSUInteger cellSubStyle;
@property(nonatomic, copy) NSString *actionType;  //消息通知新增actionType
@end


@interface TTWidgetImpressionModel : NSObject<NSCoding>

@property(nonatomic, assign, readonly)CGFloat totalDuration;

+ (NSUInteger)sendCodeForImpressionModelType:(TTWidgetImpressionModelType)type;

///---------------------------------------
/// @name Accessing 'TTWidgetImpressionModel' Properties
///---------------------------------------

/**
 impression的状态, 此状态不用存储
 */
@property(nonatomic, assign, readonly)TTWidgetImpressionStatus impressionStatus;


/**
    列表中item id,可能是group id,也可能是comment id
 */
@property(nonatomic, strong, readonly)NSString * itemID;

/**
    item type的类型
 */
@property(nonatomic, assign, readonly)TTWidgetImpressionModelType itemType;

/**
    额外信息，按itemType解释,eg:
    itemType = TTWidgetImpressionModelTypeGroup, 如果该条group有adid，则value为adid
 */
@property(nonatomic, strong)NSString * value;

@property(nonatomic, assign)NSUInteger cellStyle;

@property(nonatomic, assign)NSUInteger cellSubStyle;

@property(nonatomic, copy)  NSString *actionType; //消息通知新增的actionType

///---------------------------------------
/// @name Initializing a `TTWidgetImpressionModel`
///---------------------------------------

/**
    实例化一个TTWidgetImpressionModel，item id 和 item type 可以唯一区分一个TTWidgetImpressionModel
    @param itemID item id
    @param itemType 区分是评论还是group或者广告等
 */
- (id)initWithItemID:(NSString *)itemID itemType:(TTWidgetImpressionModelType)itemType;


/**
 *  设置附加参数
 */
- (void)setImpressionParams:(TTWidgetImpressionParams *)params;

///---------------------------------------
/// @name recoder impression
///---------------------------------------

/**
    开始记录
    如果状态错了(当前是start状态，又被发送start状态消息)，会被清零重新记录，manager应该保证状态不能出错
 */
- (void)startRecoderInterval:(NSTimeInterval)currentTimeInterval;

/**
    停止记录， 停止记录之后有可能再次开始记录
    如果状态错误(当前是end状态，又被发送end状态消息)，则当次消息没有作用
 */
- (void)endRecoderInterval:(NSTimeInterval)currentTimeInterval;

/**
    挂起记录
    对于开始状态有效，对于end状态或者suspend调用不做任何处理
 */
- (void)suspendRecoderInterval:(NSTimeInterval)currentTimeInterval;

///---------------------------------------
/// @name TTWidgetImpressionModel fetch method & util
///---------------------------------------

/**
    model的主键，可唯一标识该model
 */
- (NSString *)primaryKey;

/**
    将model转为dictionary, key为app_log/v2/ api对应的值。
    
 */
- (NSDictionary *)parseToDict:(NSTimeInterval)currentTime;

/**
    清除记录
 */
- (void)reuseImpressionModel:(NSTimeInterval)currentTimeInterval;

/**
    生成Impression model主键
 */
+ (NSString *)genImpressionModelPrimaryKeyForItemID:(NSString *)itemID itemType:(TTWidgetImpressionModelType)itemType;

@end


