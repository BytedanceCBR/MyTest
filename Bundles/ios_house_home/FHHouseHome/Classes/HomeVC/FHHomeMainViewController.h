//
//  FHHomeMainViewController.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import "FHBaseViewController.h"
#import <HMSegmentedControl.h>
#import <FHBaseCollectionView.h>
#import "FHHomeMainTopView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeMainViewController : FHBaseViewController
@property(nonatomic, strong) FHBaseCollectionView *collectionView;
@property (nonatomic,strong) FHHomeMainTopView *topView;
@property(nonatomic, strong) UIView *containerView;

- (void)changeTopStatusShowHouse:(BOOL)isShowHouse;
- (void)changeTopSearchBtn:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
