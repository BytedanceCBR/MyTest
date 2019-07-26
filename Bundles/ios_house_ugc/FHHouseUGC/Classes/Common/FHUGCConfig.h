//
//  FHUGCFollowManager.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import <Foundation/Foundation.h>
#import "FHUGCModel.h"
#import "FHUGCConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

// 加载关注的小区数据ok通知，数据放在followData中
static NSString *const kFHUGCLoadFollowDataFinishedNotification = @"k_fh_ugc_load_follow_data_finish";
// 关注 和 取消关注
static NSString *const kFHUGCFollowNotification = @"k_fh_ugc_follow_finish";
// 发帖成功通知 数放在userinfo的：social_group_id
static NSString *const kFHUGCPostSuccessNotification = @"k_fh_ugc_post_finish";
// 删除帖子成功通知 数放在userinfo的：social_group_id
static NSString *const kFHUGCDelPostNotification = @"k_fh_ugc_del_post_finish";
// 举报帖子成功通知 数放在userinfo的：cellModel
static NSString *const kFHUGCReportPostNotification = @"k_fh_ugc_report_post_finish";

@interface FHUGCConfig : NSObject

+ (instancetype)sharedInstance;

// 加载config数据等
- (void)loadConfigData;

// 关注模型
@property (nonatomic, strong) FHUGCModel *followData;
// 配置模型
@property (nonatomic, strong) FHUGCConfigModel *configData;
// 是否已经显示出feed引导
@property (nonatomic, assign) BOOL isAlreadyShowFeedGuide;

// 关注列表
- (NSArray<FHUGCScialGroupDataModel> *)followList;

// 根据groupid去关注的列表中获取最新的关注数据信息，取消关注可能获取的数据为nil
- (FHUGCScialGroupDataModel *)socialGroupData:(NSString *)social_group_id;

// 关注变化导致的数据更新，followed为最新的关注状态 groupid要一样
- (void)updateScialGroupDataModel:(FHUGCScialGroupDataModel *)model byFollowed:(BOOL)followed;

// 发帖成功 更新帖子数 + 1
- (void)updatePostSuccessScialGroupDataModel:(FHUGCScialGroupDataModel *)model;

// 删帖成功 更新帖子数 - 1
- (void)updatePostDelSuccessScialGroupDataModel:(FHUGCScialGroupDataModel *)model;

// 关注 & 取消关注 follow ：YES为关注 NO为取消关注
/*
 - status
 - -1      之前并未关注
 - 0       取消关注成功
 - 1       之前关注过，但是已经取消关注了
 - 2       其他错误
 */
- (void)followUGCBy:(NSString *)social_group_id isFollow:(BOOL)follow completion:(void (^ _Nullable)(BOOL isSuccess))completion;
//


- (NSArray *)operationConfig;

- (NSArray *)secondTabLeadSuggest;

- (NSArray *)searchLeadSuggest;

- (NSArray *)ugcDetailLeadSuggest;

@end

NS_ASSUME_NONNULL_END