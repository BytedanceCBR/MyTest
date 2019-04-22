//
//  TTVPlayerTipRelatedFinished.h
//  Article
//
//  Created by lishuangyang on 2017/7/16.
//
//

#import <UIKit/UIKit.h>
#import <TTVPlayerTipFinished.h>

@class TTVVideoPlayerStateStore;
@interface TTVPlayerTipRelatedFinished : UIView<TTVPlayerTipFinished>
@property(nonatomic, assign)BOOL hasSettingRelated;
@property(nonatomic, assign)BOOL isFullScreen;
@property(nonatomic, copy)FinishAction finishAction;
@property (nonatomic, strong) TTVVideoPlayerStateStore *playerStateStore;
- (void)setDataInfo:(NSDictionary *)dataInfo;
- (void)startTimer;
- (void)pauseTimer;
@end

