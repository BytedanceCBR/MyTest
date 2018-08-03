//
//  TTVCommodityFloatView.h
//  Article
//
//  Created by panxiang on 2017/8/8.
//
//
#import <UIKit/UIKit.h>
#import "TTVPlayerControllerProtocol.h"
#import "TTVVideoPlayerStateStore.h"

@class TTVDemandPlayer;
@interface TTVCommodityFloatView : UIView<TTVPlayerContext>
@property (nonatomic, strong) TTVVideoPlayerStateStore *playerStateStore;
@property (nonatomic, weak) TTVDemandPlayer *player;
@property (nonatomic, strong) UIView *animationToView;
@property (nonatomic, strong) UIView *animationSuperView;
- (void)setCommoditys:(NSArray *)commoditys;
- (UIView *)backgroundView;
@end

