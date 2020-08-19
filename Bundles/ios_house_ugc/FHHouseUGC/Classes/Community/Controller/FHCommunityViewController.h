//
//  FHCommunityViewController.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/5/27.
//

#import <UIKit/UIKit.h>
#import "FHBaseViewController.h"
#import "HMSegmentedControl.h"

NS_ASSUME_NONNULL_BEGIN

// 社区/邻里 主控制器
@interface FHCommunityViewController : FHBaseViewController

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) HMSegmentedControl *segmentControl;
@property(nonatomic, assign) BOOL isUgcOpen;
@property(nonatomic, assign) BOOL hasFocusTips;
@property(nonatomic, strong) UIButton *publishBtn;
@property(nonatomic, strong) NSArray *categorys;
//新的发现页面
@property(nonatomic, assign) BOOL isNewDiscovery;

- (void)hideGuideView;
- (void)hideRedPoint;
- (void)updateSpringView;
- (void)viewAppearForEnterType:(NSInteger)enterType needReportSubCategory:(BOOL)needReportSubCategory;
- (void)viewDisAppearForEnterType:(NSInteger)enterType needReportSubCategory:(BOOL)needReportSubCategory;

@end

NS_ASSUME_NONNULL_END
