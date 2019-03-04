//
//  TTMoviePlayerControlBottomView.h
//  Article
//
//  Created by xiangwu on 2016/12/27.
//
//

#import <UIKit/UIKit.h>
#import "TTMoviePlayerControlSliderView.h"

@interface TTMoviePlayerControlBottomView : UIView

@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *timeDurLabel;
@property (nonatomic, strong) TTMoviePlayerControlSliderView *slider;
@property (nonatomic, strong) UIButton *resolutionButton;
@property (nonatomic, strong) UIView *toolView;

@property (nonatomic, strong) UIButton *prePlayBtn; // 播放上一个 按钮

//播放相册资源视频时会把playButton加到底部工具栏上
@property (nonatomic, weak) UIButton *playButton;

@property (nonatomic, assign) BOOL isFull;
@property (nonatomic, copy) NSString *resolutionString;
@property (nonatomic, assign) BOOL enableResolution;
@property (nonatomic, assign) BOOL enableResolutionClicked;
@property (nonatomic, assign) UIEdgeInsets dimAreaEdgeInsetsWhenFullScreen;

- (void)updateFrame;
- (void)updateWithCurTime:(NSString *)curTime totalTime:(NSString *)totalTime;

@end

