//
//  TTAShortVideoTracker.h
//  HTSVideoPlay
//
//  Created by carl on 2017/12/28.
//

#import <Foundation/Foundation.h>
#import "TTShortVideoModel.h"
#import "TTAdShortVideoModel.h"

@interface TTAShortVideoTracker : NSObject
- (instancetype)initWithModel:(TTShortVideoModel *)model;
- (void)begin;
- (void)play;
- (void)pause;
- (void)resume;
- (void)over;
- (void)stop;
- (void)end;
@end
