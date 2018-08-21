//
//  TSVPrefetchVideoConfig.h
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/9/4.
//

#import <Foundation/Foundation.h>

@interface TSVPrefetchVideoConfig : NSObject

+ (BOOL)isPrefetchEnabled;

+ (NSUInteger)prefetchSize;

@end
