//
//  TTVShareActionsTracker.h
//  Article
//
//  Created by lishuangyang on 2017/7/26.
//
//

#import "TTVideoCommon.h"
#import "TTMessageCenter.h"

@protocol TTVShareActionTrackMessage <NSObject>

@optional
/**
 *@params: 此方法只处理icon_seat是inside的情况
 *groupId       文章／视频 唯一标识
 *activityType  分享action动作类型
 *sectionType   按钮位置
 *fromsource    埋点event名称
 */
- (void)message_shareTrackWithGroupID:(NSString *)groupId ActivityType:(TTActivityType )activityType extraDic:(NSDictionary *)extraDic fullScreen:(BOOL )fullScreen;
/**
 * 分享渠道外露的埋点处理
 */
- (void)message_exposedShareTrackWithGroupID:(NSString *)groupId ActivityType:(TTActivityType )activityType extraDic:(NSDictionary *)extraDic fullScreen:(BOOL )fullScreen;
/**
 * activityShareManage内部的埋点3.0
 */
- (void)message_shareTrackActivityWithGroupID:(NSString *)groupId ActivityType:(TTActivityType)activityType FromSource:(NSString *)fromSource eventName:(NSString *)eventName;

/**
 * 针对dislike的广告打点1.0
 */
- (void)message_shareTrackAdEventWithAdId:(NSString *)adId logExtra:(NSString *)logExtra tag:(NSString *)tag label:(NSString *)label  extra:(NSDictionary *)extra;

@end

@interface TTVShareActionsTracker : NSObject

@property (nonatomic, copy)NSString *categoryName;
@property (nonatomic, copy)NSString *enterFrom;
@property (nonatomic, copy)NSString *groupID;   //uniqueId
@property (nonatomic, copy)NSString *itemID;
@property (nonatomic, copy)NSString *position;
@property (nonatomic, copy)NSString *platform;
@property (nonatomic, copy)NSString *source;
@property (nonatomic, copy)NSString *adId;

@property (nonatomic, copy)NSDictionary *logPb;
@property (nonatomic, copy)NSString *authorId;


/**
 *
 action
 log_pb
 enter_from
 group_id
 item_id
 category_name
 position;list/detail
 to_user_id
 media_id
 follow_type
 follow_num
 not_default_follow_num
 g_source
 card_id
 card_position
 list_entrance
 order
 profile_user_id
 is_redpacket
 fullscreen
 platform
 */

@end