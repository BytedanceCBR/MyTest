//
//  TTFeedValidator.m
//  Article
//
//  Created by SunJiangting on 15-4-28.
//
//

#import "TTFeedValidator.h"
#import "ExploreListIItemDefine.h"

@implementation TTFeedValidator

- (BOOL)isValidObject:(id)object {
    if (![object isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    NSDictionary *item = (NSDictionary *)object;
    /// 目前只验证广告类型对不对，不验证签名
    ExploreOrderedDataCellType cellType = [item[@"cell_type"] intValue];
    // 只验证应用下载广告，其他类型先不验证
//    if (cellType == ExploreOrderedDataCellTypeAppDownload) {
//        NSDictionary *image = item[@"image"];
//        if (![image isKindOfClass:[NSDictionary class]] || ![image[@"url_list"] isKindOfClass:[NSArray class]]) {
//            return NO;
//        }
//        NSArray *URLs = image[@"url_list"];
//        __block BOOL valid = YES;
//        [URLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            if (![obj isKindOfClass:[NSDictionary class]]) {
//                valid = NO;
//                *stop = YES;
//            }
//        }];
//        return valid;
//    }
    return YES;
}

@end
