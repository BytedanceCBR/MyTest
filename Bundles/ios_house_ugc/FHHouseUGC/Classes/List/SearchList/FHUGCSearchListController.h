//
//  FHUGCSearchListController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "FHUGCSearchBar.h"
#import "FHCommunityList.h"

@class FHUGCScialGroupDataModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCSearchCommunityItemData : NSObject
@property(nonatomic, strong) FHUGCScialGroupDataModel *model;
@property(nonatomic, assign) FHCommunityListType listType;
@end

// UGC 搜索
@interface FHUGCSearchListController : FHBaseViewController

@property (nonatomic, strong)     FHUGCSearchBar     *naviBar;

@end

NS_ASSUME_NONNULL_END
