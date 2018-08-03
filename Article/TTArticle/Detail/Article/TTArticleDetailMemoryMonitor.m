//
//  TTArticleDetailMemoryMonitor.m
//  Article
//
//  Created by xushuangqing on 30/08/2017.
//

#import "TTArticleDetailMemoryMonitor.h"
#import <AKWebViewBundlePlugin/TTDetailWebviewGIFManager.h>
#import "TTCPUMonitor.h"
#import <TTMonitor/TTMonitor.h>

typedef NS_ENUM(NSUInteger, TTArticleDetailMemoryState) {
    TTArticleDetailMemoryStateGIFNative = 1 << 0,
    TTArticleDetailMemoryStateHasGIFInTitle = 1 << 1,
};

@implementation TTArticleDetailMemoryMonitor

+ (void)monitorMemoryGrowth:(CGFloat)growthInMByte forGroupID:(int64_t)groupID title:(NSString *)title {
    if (isEmptyString(title)) {
        return;
    }
    TTArticleDetailMemoryState state = 0;
    NSString *lowerTitle = [title lowercaseString];
    NSRange containRange = [lowerTitle rangeOfString:@"gif"];
    BOOL hasGIFInTitle = (containRange.length > 0);
    if (hasGIFInTitle) {
        state |= TTArticleDetailMemoryStateHasGIFInTitle;
    }
    BOOL enabled = [TTDetailWebviewGIFManager isDetailViewGifNativeEnabled];
    if (enabled) {
        state |= TTArticleDetailMemoryStateGIFNative;
    }
    CGFloat cpu_usage = [TTCPUMonitor getCpuUsage];
    [[TTMonitor shareManager] trackService:@"tt_monitor_detail_disappear" value:@{@"status" : @(state), @"memory" : @(growthInMByte), @"cpu_usage":@(cpu_usage)} extra:@{@"gid":@(groupID)}];
}

@end
