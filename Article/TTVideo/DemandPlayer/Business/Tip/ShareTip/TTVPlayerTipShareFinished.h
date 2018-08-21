//
//  TTVPlayerTipShareFinished.h
//  Article
//
//  Created by lishuangyang on 2017/7/16.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerTipFinished.h"

@class TTVVideoPlayerStateStore;
@interface TTVPlayerTipShareFinished : UIView<TTVPlayerTipFinished>
@property(nonatomic, assign)BOOL isFullScreen;
@property(nonatomic, copy)FinishAction finishAction;
@property (nonatomic, strong) TTVVideoPlayerStateStore *playerStateStore;
@end
