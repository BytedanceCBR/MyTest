//
//  TTArticleDetailMemoryMonitor.h
//  Article
//
//  Created by xushuangqing on 30/08/2017.
//

#import <Foundation/Foundation.h>

@interface TTArticleDetailMemoryMonitor : NSObject

+ (void)monitorMemoryGrowth:(CGFloat)growthInMByte forGroupID:(int64_t)groupID title:(NSString *)title;

@end
