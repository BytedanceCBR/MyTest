//
//  TTFeedPreloadTask.h
//  Article
//
//  Created by 冯靖君 on 2017/9/22.
//

#import "TTStartupTask.h"

@interface TTFeedPreloadTask : TTStartupTask

+ (NSArray *)preloadedFeedItemsFromLocal;

+ (BOOL)preloadInvalid;

+ (void)setPreloadInvalid:(BOOL)invalid;

@end
