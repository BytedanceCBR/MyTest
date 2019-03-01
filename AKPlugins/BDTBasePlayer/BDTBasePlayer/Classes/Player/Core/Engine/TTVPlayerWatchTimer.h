//
//  TTVPlayerWatchTimer.h
//  Article
//
//  Created by panxiang on 2017/6/2.
//
//

#import <Foundation/Foundation.h>
@class TTVPlayerStateStore;

@interface TTVPlayerWatchTimer : NSObject
@property (nonatomic, assign, readonly) NSTimeInterval total;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;

- (void)startWatch;
- (void)endWatch;
- (void)reset;
@end
