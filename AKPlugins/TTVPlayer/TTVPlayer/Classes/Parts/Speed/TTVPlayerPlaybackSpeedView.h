//
//  TTVPlayerPlaybackSpeedView.h
//  Article
//
//  Created by Chen Hong on 2018/11/26.
//

#import <UIKit/UIKit.h>

@interface TTVPlayerPlaybackSpeedView : UIView

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, strong) void (^didPlaybackSpeedChanged)(CGFloat playbackSpeed);
@property (nonatomic, assign) CGFloat currentSpeed;

- (void)showInView:(UIView *)view;
- (void)dismiss;
- (NSString *)titleForPlaybackSpeed:(CGFloat)speed;
- (NSString *)tipForPlaybackSpeed:(CGFloat)speed;
- (void)reset;

@end
