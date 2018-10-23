//
//  TSVPrefetchImageManager.h
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/12/20.
//

#import <Foundation/Foundation.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"

@interface TSVPrefetchImageManager : NSObject

+ (void)prefetchDetailImageWithDataFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)manager forward:(BOOL)isForward;

@end
