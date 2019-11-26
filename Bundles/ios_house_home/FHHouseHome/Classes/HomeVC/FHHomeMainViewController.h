//
//  FHHomeMainViewController.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import "FHBaseViewController.h"
#import <HMSegmentedControl.h>
#import <FHBaseCollectionView.h>
NS_ASSUME_NONNULL_BEGIN

@interface FHHomeMainViewController : FHBaseViewController
@property(nonatomic, strong) FHBaseCollectionView *collectionView;
@property(nonatomic, strong) UIView *containerView;
@end

NS_ASSUME_NONNULL_END
