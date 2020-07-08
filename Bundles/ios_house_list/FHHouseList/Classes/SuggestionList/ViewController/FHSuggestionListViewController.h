//
//  FHSuggestionListViewController.h
//  FHHouseList
//
//  Created by 张元科 on 2018/12/20.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"
#import "FHBaseViewController.h"
#import "FHHouseSuggestionDelegate.h"
#import "HMSegmentedControl.h"
#import "FHSuggestionSearchBar.h"
#import "FHSuggestionCollectionView.h"

typedef enum : NSUInteger {
    FHEnterSuggestionTypeDefault       =   0,// H5
    FHEnterSuggestionTypeHome       =   1,// 首页
    FHEnterSuggestionTypeFindTab       =   2,// 找房Tab
    FHEnterSuggestionTypeList       =   3, // 列表页
    FHEnterSuggestionTypeRenting       =   4,// 租房大类页
    FHEnterSuggestionTypeOldMain       =   5,// 二手房大类页
} FHEnterSuggestionType;

//特别说明：埋点逻辑和页面跳转逻辑全在子VC:FHChildSuggestionListViewController实现

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionListViewController : FHBaseViewController

@property (nonatomic, strong)     HMSegmentedControl *segmentControl;
@property (nonatomic, strong)     FHSuggestionSearchBar     *naviBar;
@property (nonatomic, strong)     NSMutableArray *houseTypeArray;
@property (nonatomic, assign)     FHHouseType       houseType;
@property (nonatomic, strong)     TTRouteParamObj *paramObj;
@property (nonatomic, strong)     FHSuggestionCollectionView *collectionView;

- (void)requestDeleteHistory;

@end

NS_ASSUME_NONNULL_END
