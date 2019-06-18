//
//  TTFeedDislikeConfig.m
//  AFgzipRequestSerializer
//
//  Created by 曾凯 on 2018/7/20.
//

#import "TTFeedDislikeConfig.h"
#import "TTReportManager.h"
#import "TTAccountManager.h"

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

+ (NSArray *)operationList {
    NSArray *operationList = @[
                               @{
                                   @"id": @"1",
                                   @"title": @"举报",
                                   @"subTitle": @"广告、低俗、重复、过时",
                                   },
                               @{
                                   @"id": @"2",
                                   @"title": @"删除"
                                   }
                               ];
    return operationList;
}

+ (NSArray<FHFeedOperationWord *> *)operationWordList:(NSString *)userId {
    NSMutableArray<FHFeedOperationWord *> *items = @[].mutableCopy;
    
    NSArray *operationList = [self operationList];
    
    BOOL isShowDelete = [TTAccountManager isLogin] && [[TTAccountManager userID] isEqualToString:userId];
    
    for (NSDictionary *dict in operationList) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            FHFeedOperationWord *word = [[FHFeedOperationWord alloc] initWithDict:dict];
            if(word.type == FHFeedOperationWordTypeReport){
                word.items = [self fetchReportOptions:word.ID];
            }else{
                word.items = @[word];
            }
            
            //显示删除就不会显示举报
            if(word.type == FHFeedOperationWordTypeReport && !isShowDelete){
                [items addObject:word];
            }
            
            if(word.type == FHFeedOperationWordTypeDelete && isShowDelete){
                [items addObject:word];
            }
        }
    }
    return items;
}

+ (NSArray *)fetchReportOptions:(NSString *)reportId {
    NSArray *options = [TTReportManager fetchReportArticleOptions];
    
    NSMutableArray<FHFeedOperationWord *> *items = [NSMutableArray array];
    for (NSDictionary *option in options) {
        if ([option isKindOfClass:[NSDictionary class]]) {
            NSInteger type = [option[@"type"] integerValue];
            if(type != 0){
                FHFeedOperationWord *word = [[FHFeedOperationWord alloc] init];
                word.ID = [NSString stringWithFormat:@"%@:%@",reportId,option[@"type"]];
                word.title = option[@"text"];
                [items addObject:word];
            }
        }
    }
    
    return items;
}

@end
