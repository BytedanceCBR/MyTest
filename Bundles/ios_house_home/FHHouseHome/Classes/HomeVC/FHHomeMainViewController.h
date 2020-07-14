//
//  FHHomeMainViewController.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import "FHBaseViewController.h"
#import "HMSegmentedControl.h"
#import "FHBaseCollectionView.h"
#import "FHHomeMainTopView.h"
#import "UIViewController+Track.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeMainViewController : FHBaseViewController
@property(nonatomic, strong) FHBaseCollectionView *collectionView;
@property(nonatomic, strong) FHHomeMainTopView *topView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIView *switchCityView;
@property(nonatomic, assign) NSInteger currentTabIndex;

- (void)changeTopStatusShowHouse:(BOOL)isShowHouse;
- (void)changeTopSearchBtn:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
