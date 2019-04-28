//
//  TTVDetailFollowRecommendViewController.h
//  Article
//
//  Created by lishuangyang on 2017/10/24.
//

#import <TTUIWidget/SSViewControllerBase.h>
#import "TTVDetailFollowRecommendView.h"
@class TTAlphaThemedButton;
@class TTVVideoDetailNatantPGCViewModel;

typedef void(^backBUttonClickedBlock)(void);
@interface TTVDetailFollowRecommendViewController : SSViewControllerBase

@property(nonatomic, strong)TTVDetailFollowRecommendView *recommendView;
@property(nonatomic, strong)TTAlphaThemedButton *backButton;
@property(nonatomic, copy)backBUttonClickedBlock backActionFired;

- (instancetype)initWithPGCViewModel:(TTVVideoDetailNatantPGCViewModel *)pgcViewModel ViewWidth:(CGFloat)width;

@end
