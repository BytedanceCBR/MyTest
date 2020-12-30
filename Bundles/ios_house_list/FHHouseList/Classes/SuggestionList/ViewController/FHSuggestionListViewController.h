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

#define kFHSuggestionKeyboardWillHideNotification @"FHSuggestionKeyboardWillHideNotification"
#define kFHSuggestionHouseTypeDidChanged @"FHSuggestionHouseTypeDidChanged"

//特别说明：埋点逻辑和页面跳转逻辑全在子VC:FHChildSuggestionListViewController实现

NS_ASSUME_NONNULL_BEGIN

@interface FHSuggestionListViewController : FHBaseViewController

@property (nonatomic, strong)     HMSegmentedControl *segmentControl;
@property (nonatomic, strong)     FHSuggestionSearchBar     *naviBar;
@property (nonatomic, strong)     NSMutableArray *houseTypeArray;
@property (nonatomic, assign)     FHHouseType       houseType;
@property (nonatomic, strong)     TTRouteParamObj *paramObj;
@property (nonatomic, strong)     FHSuggestionCollectionView *collectionView;
@property (nonatomic, assign)     CGFloat keyboardHeight;
@property (nonatomic, assign)     BOOL isTrackerCacheDisabled;
@property (nonatomic, copy)       NSDictionary *sugWordShowtracerDic;

@property (nonatomic, assign) NSTimeInterval startMonitorTime;

- (void)scrollToIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
