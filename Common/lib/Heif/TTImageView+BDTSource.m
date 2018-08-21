//
//  TTImageView+BDTSource.m
//  Article
//
//  Created by fengyadong on 2017/11/13.
//

#import "TTImageView+BDTSource.h"
#import "UIImageView+BDTSource.h"
#import <RSSwizzle/RSSwizzle.h>
#import "ExploreCellBase.h"
#import "TTVFeedListCell.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTImageMonitor.h"

@implementation TTImageView (BDTSource)

+ (void)load {
    RSSwizzleInstanceMethod([TTImageView class], NSSelectorFromString(@"loadNextPreviousLoadError:"), RSSWReturnType(void), RSSWArguments(NSError *error),RSSWReplacement({
        TTImageView *wrapperView = self;
        NSString *source = [wrapperView soureTagForImageView];
        if (source.length > 0) {
            wrapperView.imageView.tt_source = source;
        }
        BOOL enable = [TTImageMonitor enableHeifImageForSource:wrapperView.imageView.tt_source];
        
        //首次加载策略生效
        if (!error) {
            if (enable) {
                wrapperView.priorSuffixes = [NSSet setWithArray:@[@"heic",@"heif"]];
            } else {
                wrapperView.forbiddenSuffixes = [NSSet setWithArray:@[@"heic",@"heif"]];
            }
        }
        
        RSSWCallOriginal(error);
    }), RSSwizzleModeAlways, NULL);
    
    RSSwizzleInstanceMethod([TTImageView class], NSSelectorFromString(@"setImageWithURL:"), RSSWReturnType(void), RSSWArguments(NSURL *URL),RSSWReplacement({
        TTImageView *wrapperView = self;
        URL.tt_source = wrapperView.imageView.tt_source;
        RSSWCallOriginal(URL);
    }), RSSwizzleModeAlways, NULL);
}

- (NSString *)soureTagForImageView {
    UIView *superView = self.superview;
    BOOL onFeed = NO;
    while (superView) {
        if ([superView isKindOfClass:[ExploreCellBase class]]
            || [superView isKindOfClass:[TTVFeedListCell class]]) {
            onFeed = YES;
            break;
        } else {
            superView = superView.superview;
        }
    }
    if (onFeed) {
        return kBDTSourceFeed;
    }
    
    return nil;
}

@end
