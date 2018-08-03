//
//  TTAdCanvasVideoBottomView.h
//  Article
//
//  Created by yin on 2017/9/24.
//

#import <UIKit/UIKit.h>
#import "TTVPlayerControllerProtocol.h"

@interface TTAdCanvasVideoBottomView : UIView<TTVPlayerControlBottomView,TTVPlayerContext>

@property (nonatomic, weak) id <TTVPlayerControlBottomViewDelegate> delegate;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, assign)CGFloat cacheProgress;
@property (nonatomic, assign)CGFloat watchedProgress;
@property (nonatomic, assign) UIEdgeInsets dimAreaEdgeInsetsWhenFullScreen;
- (instancetype)initWithFrame:(CGRect)frame;
- (void)updateFrame;
- (void)updateWithCurTime:(NSString *)curTime totalTime:(NSString *)totalTime;
- (void)setFullScreenButtonLogoName:(NSString *)name;

@property (nonatomic, strong ,readonly) UIButton *resolutionButton;
@property (nonatomic, strong ,readonly) UIButton *prePlayBtn;
@property (nonatomic, strong ,readonly) UIButton *fullScreenButton;

@end
