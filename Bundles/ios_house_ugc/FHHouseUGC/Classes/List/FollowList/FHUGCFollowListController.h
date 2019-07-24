//
//  FHUGCFollowListController.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "FHUGCModel.h"

NS_ASSUME_NONNULL_BEGIN

// 关注小区列表 选择小区
typedef enum FHUGCFollowVCType {
    FHUGCFollowVCTypeList = 0,          // ugc_follow_communitys ：已关注小区列表 action_type = 0
    FHUGCFollowVCTypeSelectList = 1   // ugc_follow_communitys：选择小区列表 action_type = 1
}FHUGCFollowVCType;

@protocol FHUGCFollowListDelegate <NSObject>

@optional
- (void)selectedItem:(FHUGCScialGroupDataModel *)item;

@end

@interface FHUGCFollowListController : FHBaseViewController

@end

NS_ASSUME_NONNULL_END
