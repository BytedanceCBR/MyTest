//
//  FRForumEntity.h
//  Forum
//
//  Created by zhaopengwei on 15/5/10.
//
//

#define kFRForumEntityFollowChangeNotification @"kFRForumEntityFollowChange"
#import "FRBaseEntity.h"


typedef NS_OPTIONS(NSUInteger, FRShowEtStatus) {
    FRShowEtStatusOfTitle       = 1 << 0,
    FRShowEtStatusOfPhone       = 1 << 1,
    FRShowEtStatusOfLocation    = 1 << 2,
    FRShowEtStatusOfPostButton  = 1 << 3,
    FRShowEtStatusOfRateView    = 1 << 4,
};

typedef NS_OPTIONS(NSUInteger, FRTabEtStatus) {
    FRTabEtStatusOfWriteButton = 1 << 0
};

typedef NS_OPTIONS(NSUInteger, FRTypeFlags) {
    FRTypeFlagsShortVideoActivity = 1 << 1, // 小视频活动话题
};

@class FRForumStructModel;
@class FRConcernForumStructModel;
@class FRForumItemStructModel;

@interface FRForumEntity : FRBaseEntity

@property (assign, nonatomic) int64_t forum_id;
@property (strong, nonatomic) NSString *forum_name;
@property (strong, nonatomic) NSString *schema;
@property (assign, nonatomic) int64_t onlookers_count;
@property (strong, nonatomic) NSString *avatar_url;
@property (assign, nonatomic) int64_t talk_count;
@property (assign, nonatomic) int64_t like_time;
@property (strong, nonatomic) NSString *forum_hot_header;
@property (strong, nonatomic) NSString *desc;
@property (assign, nonatomic) int64_t status;
@property (strong, nonatomic) NSString *banner_url;
@property (assign, nonatomic) int64_t follower_count;
@property (assign, nonatomic) int64_t read_count;
@property (assign, nonatomic) int64_t participant_count;
@property (strong, nonatomic) NSString *share_url;
@property (strong, nonatomic) NSString *introdution_url;
@property (assign, nonatomic) FRShowEtStatus showEtStatus;
@property (assign, nonatomic) int64_t article_count;
@property (assign, nonatomic) FRTypeFlags forum_type_flags;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithForumStruct:(FRForumStructModel *)item;
- (instancetype)initWithForumItemStruct:(FRForumItemStructModel *)item;
- (instancetype)initWithForumConcernForumStruct:(FRConcernForumStructModel *)item;

+ (FRForumEntity *)genForumWithForumStruct:(FRForumStructModel *)model needUpdate:(BOOL)needUpdate;
+ (FRForumEntity *)genForumWithForumItemStruct:(FRForumItemStructModel *)model needUpdate:(BOOL)needUpdate;
+ (FRForumEntity *)getForumEntityWithForumId:(int64_t)forum_id;
+ (FRForumEntity *)genForumEntityWithConcernForumStruct:(FRConcernForumStructModel *)model needUpdate:(BOOL)needUpdate;

@end
