//
//  TTVPlayerView.h
//  Pods
//
//  Created by panxiang on 2017/5/23.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerOrientationController.h"
#import "TTVPlayerControllerProtocol.h"

@class TTVPlayerStateStore;
@interface TTVPlayerView : UIView<TTVPlayerContext>
@property (nonatomic, weak) UIView *playerLayer;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, strong) UIView *logoImageView;
@property (nonatomic, strong) UIView *snapView;
@property (nonatomic, weak) UIView *waveView;
@property (nonatomic, weak) UIView *backgroundView;
@property(nonatomic, weak)UIView <TTVViewLayout> *changeResolutionView;
@property(nonatomic, weak)UIView <TTVViewLayout> *changeResolutionAlertView;
@property (nonatomic, weak) UIView<TTVPlayerViewControlView ,TTVPlayerContext> *controlView;
@property (nonatomic, weak) UIView<TTVPlayerViewTrafficView ,TTVPlayerContext> *trafficView;
@property (nonatomic, weak) UIView<TTVPlayerControlTipView ,TTVPlayerContext> *tipView;
- (void)ttv_kvo;
- (void)actionChangeCallbackWithAction:(TTVFluxAction *)action state:(id)state;
@end
