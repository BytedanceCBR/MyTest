//
//  TTVideoPasterADTracker.h
//  Article
//
//  Created by Dai Dongpeng on 6/22/16.
//
//

#import <Foundation/Foundation.h>
#import "ExploreMovieViewTracker.h"

@class ExploreMovieView, TTVideoPasterADModel;

@interface TTVideoPasterADTracker : NSObject

@property (nonatomic, strong) ExploreMovieView *movieView;
@property (nonatomic, strong) TTVideoPasterADModel *adModel;

//- (void)sendADEventWithlabel:(NSString *)label
//                       extra:(NSDictionary *)extra
//                    duration:(BOOL)duration;
@end

@interface TTVideoPasterADTracker (Convenience)

- (void)sendPlayStartEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type;

- (void)sendClickADEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type;

- (void)sendDetailClickButtonEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type;

- (void)sendDownloadClickButtonEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type;

- (void)sendPlayBreakEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type effectivePlay:(BOOL)effective;

- (void)sendPlayOverEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type;

- (void)sendSkipEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type effectivePlay:(BOOL)effective;

- (void)sendFullscreenWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type;

- (void)sendPauseWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type;

- (void)sendContinueWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type;

- (void)sendRequestDataWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type;

- (void)sendResponsErrorWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type;

- (void)sendShowOverWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type;

- (void)sendClickReplayButtonEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration viewType:(ExploreMovieViewType)type;
@end
