//
//  FHCommonApi.h
//  FHHouseBase
//
//  Created by 张元科 on 2019/6/16.
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager.h>
#import <FHHouseBase/FHURLSettings.h>
#import <FHHouseBase/FHHouseType.h>
#import <FHHouseBase/FHMainApi.h>

NS_ASSUME_NONNULL_BEGIN

// 点赞类型
typedef enum FHDetailDiggType{
    FHDetailDiggTypeNone = 0,
    FHDetailDiggTypeCOMMENT = 1,    // 评论点赞
    FHDetailDiggTypeTHREAD = 2,     // 帖子点赞
    FHDetailDiggTypeREPLY = 3,      // 回复点赞
    FHDetailDiggTypeITEM = 4,       // 文章点赞
    FHDetailDiggTypeSMALLVIDEO = 6, // 小视频
    FHDetailDiggTypeVIDEO = 23,     // 视频
    FHDetailDiggTypeVote = 48,     // 投票
    FHDetailDiggTypeANSWER = 1025,  // 答案点赞
    FHDetailDiggTypeQUESTION = 1026,// 问题点赞
} FHDetailDiggType;

@interface  FHDetailDiggModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;

@end

// 当需要返回的数据只是 status & message
@interface  FHCommonModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;

@end

@class TTHttpTask;

@interface FHCommonApi : NSObject

// 点赞通用接口
// action:0 表示 取消赞 1，表示 赞
+ (TTHttpTask *)requestCommonDigg:(NSString *)group_id groupType:(FHDetailDiggType)group_type action:(NSInteger)action completion:(void (^ _Nullable)(id<FHBaseModelProtocol> model, NSError *error))completion;

// action:0 表示 取消赞 1，表示 赞 （支持给接口传参）:element_from enter_from page_type
+ (TTHttpTask *)requestCommonDigg:(NSString *)group_id groupType:(FHDetailDiggType)group_type action:(NSInteger)action tracerParam:(NSDictionary *)params completion:(void (^ _Nullable)(id<FHBaseModelProtocol> model, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
