//
//  TTVCommodityItemView.h
//  Article
//
//  Created by panxiang on 2017/8/8.
//
//

#import <UIKit/UIKit.h>
@class TTVCommodityEntity;
@protocol TTVCommodityItemViewDelegate <NSObject>

- (void)ttv_didOpenCommodityByWeb:(BOOL)isWeb;

- (void)ttv_dimissItemViewWithTargetAnimation:(BOOL )isToTarget;

@end

@interface TTVCommodityItemView : UIView
@property (nonatomic ,strong)TTVCommodityEntity *entity;
@property (nonatomic ,assign)BOOL isFullScreen;
@property (nonatomic ,assign)BOOL shouldShow;
@property (nonatomic ,assign)BOOL isAnimationing;
@property (nonatomic ,weak)NSObject <TTVCommodityItemViewDelegate> *delegate;
- (void)show;
@end
