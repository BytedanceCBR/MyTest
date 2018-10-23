//
//  TTLivePlayerControlView.h
//  Article
//
//  Created by matrixzk on 29/09/2017.
//

#import <UIKit/UIKit.h>

#import "TTVPlayerOrientation.h"

typedef NS_ENUM(NSUInteger, TTLivePlayStatus)
{
    TTLivePlayStatusUnknown,
    TTLivePlayStatusNotStarted,
    TTLivePlayStatusEnd,
    TTLivePlayStatusLoading,
    TTLivePlayStatusPlaying,
    TTLivePlayStatusBreak,
    TTLivePlayStatusFaild
};


@class TTLivePlayerControlView;
@protocol TTLivePlayerControlViewDelegate <NSObject>

@optional
- (void)ttlivePlayerControlViewPlayButtonDidPressed:(TTLivePlayerControlView *)controlView isPlaying:(BOOL)isPlaying;
- (void)ttlivePlayerControlViewRetryButtonDidPressed:(TTLivePlayerControlView *)controlView;
- (BOOL)ttlivePlayerViewShouldRotate;

@end


@class TTVPlayerStateStore;
@interface TTLivePlayerControlView : UIView

@property (nonatomic, weak) id<TTLivePlayerControlViewDelegate> delegate;
@property (nonatomic) TTLivePlayStatus livePlayStatus;
@property (nonatomic, copy) void (^controlViewHiddenAnimationBlock)(BOOL hidden);

- (instancetype)initWithFrame:(CGRect)frame playerStateStore:(TTVPlayerStateStore *)playerStateStore rotateTargetView:(UIView *)rotateTargetView;

- (void)setStatusView:(UIView *)statusView numOfParticipantsView:(UIView *)numOfParticipantsView;
- (void)setTitle:(NSString *)title;

- (void)exitFullScreenAnimated:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;
- (void)clickPlayButtonWhenLiveIsPlaying:(BOOL)isPlaying;

@end
