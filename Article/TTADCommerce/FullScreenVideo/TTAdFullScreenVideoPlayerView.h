//
//  TTAdFullScreenVideoPlayerView.h
//  Article
//
//  Created by matrixzk on 25/07/2017.
//
//

#import <UIKit/UIKit.h>

@interface TTAdFullScreenVideoModel : NSObject

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *coverURL;

@end


@class TTAdFullScreenVideoViewModel;
@interface TTAdFullScreenVideoPlayerView : UIView

@property (nonatomic, strong) TTAdFullScreenVideoViewModel *eventTracker;
@property (nonatomic, assign) BOOL shouldRepeat;

- (void)playVideoWithModel:(TTAdFullScreenVideoModel *)videoModel;

- (void)playVideo;
- (void)pauseVideo;
- (void)stopVideo;

- (void)videoPlayDidInterrupted;
- (void)videoPlayDidResume;

@end



