//
//  TTUGCFavoriteManager.h
//  TTUGCFoundation
//
//  Created by SongChai on 2018/2/8.
//

#import <Foundation/Foundation.h>

@class Thread;

@interface TTUGCFavoriteManager : NSObject

+ (void)favoriteForThread:(Thread *)thread finishBlock:(void(^)(NSError *))finishBlock;
+ (void)unfavoriteForThread:(Thread *)thread finishBlock:(void(^)(NSError *))finishBlock;

@end
