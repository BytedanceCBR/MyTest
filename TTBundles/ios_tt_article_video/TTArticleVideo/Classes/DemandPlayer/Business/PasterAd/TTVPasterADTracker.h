//
//  TTVPasterADTracker.h
//  Article
//
//  Created by Dai Dongpeng on 6/22/16.
//
//

#import <Foundation/Foundation.h>
#import "ExploreMovieViewTracker.h"

@class TTVPlayVideo, TTVPasterADModel;

@interface TTVPasterADTracker : NSObject

@property (nonatomic, strong) TTVPlayVideo *playVideo;
@property (nonatomic, strong) TTVPasterADModel *adModel;

@end

@interface TTVPasterADTracker (Convenience)

- (void)sendPlayStartEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail;

- (void)sendClickADEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail;

- (void)sendDetailClickButtonEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail;

- (void)sendDownloadClickButtonEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail;

- (void)sendPlayBreakEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail effectivePlay:(BOOL)effective;

- (void)sendPlayOverEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail;

- (void)sendSkipEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail effectivePlay:(BOOL)effective;

- (void)sendFullscreenWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail;

- (void)sendRequestDataWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail;

- (void)sendResponsErrorWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail;

- (void)sendShowOverWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail;

- (void)sendClickReplayButtonEventWithExtra:(NSDictionary *)extra duration:(NSInteger)duration isInDetail:(BOOL)isInDetail;

- (void)sendWithRealTimeDownload;

@end
