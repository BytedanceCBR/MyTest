//
//  TTMoviePlayerControlLiveBottomView.h
//  Article
//
//  Created by xiangwu on 2016/12/27.
//
//

#import <UIKit/UIKit.h>
#import "TTMoviePlayerControlSliderView.h"

@interface TTMoviePlayerControlLiveBottomView : UIView

@property (nonatomic, strong) UIView *toolView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *timeDurLabel;
@property (nonatomic, strong) TTMoviePlayerControlSliderView *slider;
@property (nonatomic, strong) UILabel *replayLabel;
@property (nonatomic, strong) UIButton *fullScreenButton;

@property (nonatomic, assign) BOOL isFull;
@property (nonatomic, assign) BOOL isLive;

- (void)updateFrame;
- (void)updateWithCurTime:(NSString *)curTime totalTime:(NSString *)totalTime;
- (void)updateLiveWithStatusView:(UIView *)statusView numOfParticipantsView:(UIView *)numOfParticipantsView;
- (void)updateReplay;

- (void)updateRNLiveWithStatusView:(UIView*)statusView muteButton:(UIView*)muteButton;
- (void)updateRNReplayWithmuteButton:(UIView*)muteButton;
@end
