//
//  FHBrowsingHistoryViewController.h
//  BDSSOAuthSDK-BDSSOAuthSDK
//
//  Created by wangxinyu on 2020/7/10.
//

#import <UIKit/UIKit.h>
#import "FHHouseType.h"
#import "FHBaseViewController.h"
#import "HMSegmentedControl.h"
#import "FHSuggestionCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

//结构参照搜索中间页
@interface FHBrowsingHistoryViewController : FHBaseViewController

@property (nonatomic, strong) FHSuggestionCollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *houseTypeArray;
@property (nonatomic, assign) FHHouseType    houseType;
@property (nonatomic, strong) HMSegmentedControl *segmentControl;
@property (nonatomic, strong) TTRouteParamObj *paramObj;

@end

NS_ASSUME_NONNULL_END