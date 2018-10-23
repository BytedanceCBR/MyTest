//
//  TSVChannelDecoupledConfig.h
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/12/12.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, TSVChannelDecoupledStrategy) {
    TSVChannelDecoupledStrategyDisabled,
    TSVChannelDecoupledStrategyEnabled
};

@interface TSVChannelDecoupledConfig : NSObject

+ (TSVChannelDecoupledStrategy)strategy;

+ (NSInteger)numberOfExtraItemsTakenToDetailPage;

@end
