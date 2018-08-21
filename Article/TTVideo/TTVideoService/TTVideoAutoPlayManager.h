//
//  TTVideoAutoPlayManager.h
//  Article
//
//  Created by 刘廷勇 on 16/3/15.
//
//

#import <Foundation/Foundation.h>
#import "ExploreCellBase.h"

@class ExploreOrderedData;
@class ExploreMovieView;
@protocol ExploreMovieViewCellProtocol;


@interface TTVideoAutoPlayManager : NSObject

+ (TTVideoAutoPlayManager *)sharedManager;

/**
 *  判断cell是否正在自动播放
 *
 *  @param cell
 *
 *  @return YES表示正在自动播放
 */
- (BOOL)cellIsAutoPlaying:(ExploreCellBase *)cell;

/**
 *  判断data是否正在自动播放
 *
 *  @param data
 *
 *  @return YES表示正在自动播放
 */
- (BOOL)dataIsAutoPlaying:(ExploreOrderedData *)data;

- (BOOL)videoUniqueIDIsAutoPlaying:(int64_t)uniqueID;

/**
 *  data中止自动播放
 *
 *  @param data
 */
- (void)dataStopAutoPlay:(ExploreOrderedData *)data;

/**
 *  在当前tableView中可见cell中，播放可播放的视频，停止需要停止的视频
 *
 *  @param tableView
 */
- (void)tryAutoPlayInTableView:(UITableView *)tableView;

/**
 *  取消已经开始的自动播放判断
 */
- (void)cancelTrying;

/**
 *  将当前的视频标记为是否暂停
 *
 *  @param isPaused;
 */
- (void)markTargetMoviePause:(BOOL)isPaused;

- (void)cacheAutoPlayingCell:(id<ExploreMovieViewCellProtocol>)cell movie:(id)movie fromView:(UITableView *)fromView;

- (BOOL)cachedAutoPlayingCellInView:(UITableView *)view;

- (void)restoreCellMovieIfCould;

- (void)clearAutoPlaying;

#pragma mark -
#pragma mark track

- (void)trackForFeedAutoOver:(ExploreOrderedData *)data movieView:(id)movieView;
- (void)trackForFeedPlayOver:(ExploreOrderedData *)data movieView:(id)movieView;
- (void)trackForFeedBackPlayOver:(ExploreOrderedData *)data movieView:(id)movieView;
- (void)trackForClickFeedAutoPlay:(ExploreOrderedData *)data movieView:(id)movieView;
- (void)trackForAutoDetailPlayOver:(ExploreOrderedData *)data movieView:(id)movieView;
@end
