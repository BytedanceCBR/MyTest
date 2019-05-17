//
//  TTMovieViewCacheManager.h
//  Article
//
//  Created by songxiangwu on 2016/10/19.
//
//

#import <Foundation/Foundation.h>
#import "ExploreMovieViewTracker.h"
#import "ExploreVideoSP.h"
@class ExploreMovieView;
@class ExploreMovieViewModel;


@interface TTMovieViewCacheManager : NSObject

@property (nonatomic, copy) NSString *currentPlayingVideoID;
@property (nonatomic, assign) ExploreVideoDefinitionType lastDefinitionType;
@property (nonatomic,strong) NSHashTable *registMovieViewHash;
@property (nonatomic, assign) BOOL userSelected; // 是否用户手动选择过；

+ (TTMovieViewCacheManager *)sharedInstance;
- (ExploreMovieView *)movieViewWithVideoID:(NSString *)videoID frame:(CGRect)frame type:(ExploreMovieViewType)type trackerDic:(NSDictionary *)trackerDic movieViewModel:(ExploreMovieViewModel *)movieViewModel;
- (void)cacheMovieView:(ExploreMovieView *)view forVideoID:(NSString *)videoID;
- (void)setCacheBlock:(ExploreMovieView *)movieView videoID:(NSString *)videoID;
- (BOOL)hasCachedForKey:(NSString *)videoID;

- (void)removeCacheMovieView:(ExploreMovieView *)view forVideoID:(NSString *)videoID;
@end
