//
//  FHUGCFollowManager.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import <Foundation/Foundation.h>
#import "FHUGCModel.h"

NS_ASSUME_NONNULL_BEGIN

// 加载关注的小区数据ok通知，数据放在followData中
static NSString *const kFHUGCLoadFollowDataFinishedNotification = @"k_fh_ugc_load_follow_data_finish";
// 关注 和 取消关注
static NSString *const kFHUGCFollowNotification = @"k_fh_ugc_follow_finish";

@interface FHUGCConfig : NSObject

+ (instancetype)sharedInstance;

// 加载config数据等
- (void)loadConfigData;

// 关注模型
@property (nonatomic, strong)   FHUGCModel       *followData;

// 关注列表
- (NSArray<FHUGCScialGroupDataModel> *)followList;

// 关注 & 取消关注 follow ：YES为关注 NO为取消关注
/*
 - status
 - -1      之前并未关注
 - 0       取消关注成功
 - 1       之前关注过，但是已经取消关注了
 - 2       其他错误
 */
- (void)followUGCBy:(NSString *)social_group_id isFollow:(BOOL)follow completion:(void (^ _Nullable)(BOOL isSuccess))completion;

@end

NS_ASSUME_NONNULL_END
