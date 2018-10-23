//
//  AKAwardCoinVideoMonitorManager.h
//  Article
//
//  Created by chenjiesheng on 2018/3/12.
//


#import <Foundation/Foundation.h>
#import <TTVPlayerControllerProtocol.h>
@class TTVPlayVideo;
@class TTDetailModel;
@interface AKAwardCoinVideoMonitorManager : NSObject <TTVPlayerContext>

@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, weak)   TTDetailModel       *videoDetailModel;
+ (instancetype)shareInstance;

- (void)monitorVideoWith:(TTVPlayVideo *)playVideo;
@end
