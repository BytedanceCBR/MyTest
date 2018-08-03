//
//  TSVPrefetchVideoManager.h
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/12/25.
//

#import <Foundation/Foundation.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"

@class TTShortVideoModel;

extern NSString * const TSVVideoPrefetchShortVideoFeedCardGroup;
extern NSString * const TSVVideoPrefetchShortVideoFeedFollowGroup;
extern NSString * const TSVVideoPrefetchShortVideoTabGroup;
extern NSString * const TSVVideoPrefetchDetailGroup;

@interface TSVPrefetchVideoManager : NSObject

+ (BOOL)isPrefetchEnabled;

+ (void)startPrefetchShortVideo:(TTShortVideoModel *)model group:(NSString *)group;

+ (void)cancelPrefetchShortVideoForGroup:(NSString *)group;

+ (void)startPrefetchShortVideoInDetailWithDataFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)manager;

+ (void)cancelPrefetchShortVideoInDetail;

@end
