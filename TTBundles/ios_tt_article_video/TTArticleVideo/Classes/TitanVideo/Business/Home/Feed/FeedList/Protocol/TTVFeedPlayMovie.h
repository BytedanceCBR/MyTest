//
//  TTVFeedPlayMovie.h
//  skin
//
//  Created by panxiang on 15/10/11.
//  Copyright © 2015年 panxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

static BOOL canRemovMovie = YES;

static NSString *kFloatVideoCellBackgroundColor = @"0x1b1b1b";
static NSString *kVideoFloatTrackEvent = @"video_float";

typedef NS_ENUM(NSUInteger, TTVFeedListCellAction) {
    TTVFeedListCellAction_Subscribe,
    TTVFeedListCellAction_unSubscribe,
    TTVFeedListCellAction_Comment,
    TTVFeedListCellAction_Digg,
    TTVFeedListCellAction_Bury,
    TTVFeedListCellAction_Share,
    TTVFeedListCellAction_UserInfo,
    TTVFeedListCellAction_Play
};

@protocol TTVFeedPlayMovie <NSObject>

@required
- (BOOL)cell_hasMovieView;
- (BOOL)cell_isPlayingMovie;
- (BOOL)cell_isMovieFullScreen;
- (UIView *)cell_movieView;
- (id)cell_detachMovieView;
- (void)cell_attachMovieView:(id)movieView;
- (CGRect)cell_logoViewFrame;
- (BOOL)cell_isPlaying;
- (BOOL)cell_isPaused;
- (BOOL)cell_isPlayingFinished;
@optional
- (CGRect)cell_movieViewFrameRect;
@end

@protocol TTStatusButtonDelegate <NSObject>

- (void)statusButtonHighlighted:(BOOL)highlighted;

@end
