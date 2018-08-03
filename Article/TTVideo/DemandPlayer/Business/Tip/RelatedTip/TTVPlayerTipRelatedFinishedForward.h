//
//  TTVPlayerTipRelatedFinishedForward.h
//  Article
//
//  Created by panxiang on 2017/10/19.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerTipRelatedFinished.h"
#import "TTVVideoPlayerStateStore.h"
@interface TTVPlayerTipRelatedFinishedForward : UIView<TTVPlayerTipFinished>
@property(nonatomic, assign)BOOL isFullScreen;
@property(nonatomic, copy)FinishAction finishAction;
@property (nonatomic, strong) TTVVideoPlayerStateStore *playerStateStore;
@end

