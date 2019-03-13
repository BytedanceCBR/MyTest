//
//  TTVPlayerOrientation.h
//  Article
//
//  Created by panxiang on 2017/5/26.
//
//

typedef void (^TTVPlayerOrientationCompletion)(BOOL finished);


@protocol TTVPlayerOrientation <NSObject>
//@property (nonatomic, assign) BOOL enableRotate;
- (void)enterFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;
- (void)exitFullScreen:(BOOL)animated completion:(TTVPlayerOrientationCompletion)completion;

@end


@protocol TTVOrientationDelegate <NSObject>

@optional
- (BOOL)videoPlayerCanRotate;
- (void)forceVideoPlayerStop;
- (CGRect)ttv_movieViewFrameAfterExitFullscreen;

@end
