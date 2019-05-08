//
//  TTVPlayerControlBottomView.h
//  Article
//
//  Created by xiangwu on 2016/12/27.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerControllerProtocol.h"
#import "TTVPlayerControlSliderView.h"

@interface TTVPlayerControlBottomView : UIView<TTVPlayerControlBottomView,TTVPlayerContext>
@property (nonatomic, strong ,readonly) UIButton *resolutionButton;
@property (nonatomic, strong ,readonly) UIButton *fullScreenButton;
@property (nonatomic, strong ,readonly) TTVPlayerControlSliderView *slider;
@property (nonatomic, strong ,readonly) UILabel *timeLabel;
@property (nonatomic, strong ,readonly) UILabel *timeDurLabel;
@property (nonatomic, strong ,readonly) UIView *toolView;

//protocol
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, weak) id <TTVPlayerControlBottomViewDelegate> delegate;
@property (nonatomic, assign)CGFloat cacheProgress;
@property (nonatomic, assign)CGFloat watchedProgress;
@property (nonatomic, assign) UIEdgeInsets dimAreaEdgeInsetsWhenFullScreen;

- (void)updateFrame;
- (void)updateWithCurTime:(NSString *)curTime totalTime:(NSString *)totalTime;
@end
