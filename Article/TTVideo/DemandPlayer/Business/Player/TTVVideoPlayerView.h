//
//  TTVVideoPlayerView.h
//  Article
//
//  Created by panxiang on 2017/9/13.
//
//

#import "TTVPlayerView.h"
#import "TTVVideoPlayerStateStore.h"
@class TTVCommodityFloatView;
@class TTVCommodityView;
@class TTVVideoPlayerViewShareCointainerView;
@class TTVCommodityButtonView;

@interface TTVVideoPlayerView : TTVPlayerView
@property (nonatomic, strong) TTVVideoPlayerStateStore *playerStateStore;
@property (nonatomic, weak) UIView *pasterAdView;
@property (nonatomic, weak) UIView *midInsertADView;
@property (nonatomic, weak) TTVCommodityFloatView *commodityFloatView;//特卖小浮层
@property (nonatomic, weak) TTVCommodityView *commodityView;//覆盖整个播放器
@property (nonatomic, weak) TTVCommodityButtonView *commodityButton;//点击出commodityView
@property (nonatomic, weak) TTVVideoPlayerViewShareCointainerView *shareCointainerView;

@end
