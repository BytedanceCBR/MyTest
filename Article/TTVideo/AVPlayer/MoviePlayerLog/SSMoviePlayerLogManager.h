//
//  ExploreMoviePlayerLogManager.h
//  Article
//
//  Created by Zhang Leonardo on 15-3-22.
//
//

#import <Foundation/Foundation.h>

@protocol SSMovieLogReceiver;

@interface SSMoviePlayerLogManager : NSObject

@property(nonatomic,strong)id<SSMovieLogReceiver> logReceiver;

+ (SSMoviePlayerLogManager *)shareManager;

- (void)addMovieTrackerToLog:(NSDictionary *)dict needDNSInfo:(BOOL)need;

- (void)addUploadMovieTrackerToLog:(NSDictionary *)dict;

@end


@protocol SSMovieLogReceiver <NSObject>

- (void)appendLogData:(NSDictionary *)dict;

@end
