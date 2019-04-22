//
//  TTVPlayerControllerProtocol.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerState.h"

@class TTVPlayerStateStore;
@class TTVPlayerStateAction;
@class TTVPlayerStateModel;
@protocol TTVPlayerContext <NSObject>

@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
- (void)actionChangeCallbackWithAction:(TTVPlayerStateAction *)action state:(TTVPlayerStateModel *)state;
@end

@protocol TTVPlayerViewControlView <NSObject>

@optional
@property (nonatomic, assign) UIEdgeInsets dimAreaEdgeInsetsWhenFullScreen;

@end

@protocol TTVPlayerViewTrafficView <NSObject>
- (void)setTrafficVideoDuration:(NSInteger)duration videoSize:(NSInteger)videoSize inDetail:(BOOL)inDetail ;
- (void)setContinuePlayBlock:(dispatch_block_t)continuePlayBlock;
@optional
// 免流订阅
- (void)setFreeFlowSubscribeBlock:(dispatch_block_t)subscribeBlock;
@end

@protocol TTVPlayerControlTipView <NSObject>
@property(nonatomic, assign)TTVPlayerControlTipViewType tipType;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@end



