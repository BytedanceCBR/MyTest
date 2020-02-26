//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FHUnreadMsgDataUnreadModel<NSObject>
@end

@interface FHUnreadMsgDataUnreadModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSNumber *timestamp;
@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSNumber *unread;
@property (nonatomic, copy , nullable) NSString *dateStr;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *lastMsgId;
@property (nonatomic, copy , nullable) NSString *icon;
@property (nonatomic, copy , nullable) NSString *lastUserAvatar;
@property (nonatomic, strong) NSNumber *interval; //本接口轮询间隔
@property (nonatomic) BOOL hasHistoryMsg; //是否有历史消息

@end

@interface FHUnreadMsgDataModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray<FHUnreadMsgDataUnreadModel> *unread;
@end

@interface FHUnreadMsgModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUnreadMsgDataModel *data ;  
@end

@interface FHUGCUnreadMsgModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUnreadMsgDataUnreadModel *data ;
@end

NS_ASSUME_NONNULL_END
//END OF HEADER
