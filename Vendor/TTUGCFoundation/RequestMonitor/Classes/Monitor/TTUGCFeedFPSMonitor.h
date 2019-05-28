//
//  TTUGCFeedFPSMonitor.h
//  Article
//
//  Created by 柴淞 on 18/5/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TTUGCFeedFPSMonitor : NSObject

- (void)willDisplayCategory:(NSString *)categoryName;
- (void)endDisplayCategory:(NSString *)categoryName;

@property (nonatomic, assign) NSTimeInterval duration; // 自定义持续时长，超过该值停止监控。默认0
@property (nonatomic, assign) NSUInteger minCount; // 自定义最小统计数量。默认0
@property (nonatomic, copy) BOOL(^isEnable)(NSString *categoryName);
@property (nonatomic, copy) void(^completeBlock)(NSString *categoryName, NSNumber *fps);

@end
