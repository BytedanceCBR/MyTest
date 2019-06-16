//
//  TTFeedDislikeConfig.m
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/20.
//

#import "TTFeedDislikeConfig.h"

static NSString *const kTTNewDislikeReportOptions = @"tt_new_dislike_report_options";
@implementation TTFeedDislikeConfig

+ (BOOL)enableModernStyle {
    return YES;
}

+ (NSArray<NSDictionary *> *)reportOptions {
    NSDictionary *config = [self __newDislikeReportOptions];
    NSArray<NSDictionary *> *reportOptions = config[@"new_report_options"];
    for (NSDictionary *ro in reportOptions) {
        if (![ro isKindOfClass:[NSDictionary class]]) return nil;
    }
    return reportOptions;
}

+ (NSDictionary *)textStrings {
    NSDictionary *config = [self __newDislikeReportOptions];
    NSDictionary *textStrings = config[@"text_strings"];
    if ([textStrings isKindOfClass:[NSDictionary class]]) {
        return textStrings;
    }
    return nil;
}

+ (NSDictionary *)__newDislikeReportOptions {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:kTTNewDislikeReportOptions];
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        return dict;
    }
    return nil;
}

@end
