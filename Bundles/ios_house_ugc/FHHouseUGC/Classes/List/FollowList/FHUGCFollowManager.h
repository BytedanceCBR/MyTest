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

@interface FHUGCFollowManager : NSObject

+ (instancetype)sharedInstance;

// 加载UGC 关注的小区数据 数据存放在followData中 发送kFHUGCLoadFollowDataFinishedNotification通知
- (void)loadFollowData;

// 关注模型
@property (nonatomic, strong)   FHUGCModel       *followData;

// 关注 & 取消关注


@end

NS_ASSUME_NONNULL_END
