//
//  TTLiveHeaderView+Video.h
//  Article
//
//  Created by matrixzk on 8/11/16.
//
//

#import "TTLiveHeaderView.h"
#import "ExploreMovieView.h"
#import "TTChatroomMovieView.h"

///...
#import "TTLivePlayerView.h"

@interface TTLiveHeaderView () <ExploreMovieViewDelegate, TTChatroomMovieViewDelegate>
//@property (nonatomic, strong) ExploreMovieView *liveVideoView;
@property (nonatomic, assign) NSInteger refreshPlayCount;
@property (nonatomic, strong) TTChatroomMovieView *chatroomVideoView;
@property (nonatomic, strong) TTLivePlayerView *livePlayerView;
@property (nonatomic) BOOL useLiveSDK;

@end

@interface TTLiveHeaderView (Video)

- (void)setupSubviews4LiveTypeVideo;
- (void)refreshLiveVideoViewWithModel:(TTLiveStreamDataModel *)model;


- (void)playVideo;
- (void)pauseVideo;
- (void)stopVideo;

- (void)rateChanged:(NSNotification *)notification;
- (void)unknowNotification:(NSNotification *)notification;
- (void)viewWillAppear;
- (void)viewWillDisappear;

@end
