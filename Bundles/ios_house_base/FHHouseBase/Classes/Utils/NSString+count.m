//
//  NSString+count.m
//  FHHouseBase
//
//  Created by wangzhizhou on 2019/8/25.
//

#import "NSString+count.h"

@implementation NSString(count)

+ (NSString *)tt_formatCount: (NSInteger)count {
    NSString *ret = @"";
    if(count <= 0) {
        ret = @"";
    }
    else if(count < 10000) {
        ret = @(count).stringValue;
    } else if (count < 100000) {
        ret = [NSString stringWithFormat:(count % 10000) ? @"%.1f万" : @"%.0f万", count / 1E4];
    } else {
        ret = [NSString stringWithFormat:@"%@万", @(count / 10000)];
    }
    return ret;
}

#if DEBUG

+ (void)load {
    [self test];
}

+ (void)test {
    
    NSDictionary *testCases = @{
                                @"809": [NSString tt_formatCount:809],
                                @"1232": [NSString tt_formatCount:1232],
                                @"9999": [NSString tt_formatCount:9999],
                                @"1万": [NSString tt_formatCount:10000],
                                @"1.1万": [NSString tt_formatCount:11000],
                                @"3.8万": [NSString tt_formatCount:38000],
                                @"5万": [NSString tt_formatCount:50000],
                                @"10万": [NSString tt_formatCount:100230],
                                @"17万": [NSString tt_formatCount:170000],
                                @"20万": [NSString tt_formatCount:202300],
                                @"131万": [NSString tt_formatCount:1310000],
                                @"200万": [NSString tt_formatCount:2001230],
                                @"21万": [NSString tt_formatCount:212010],
                                @"2120万": [NSString tt_formatCount:21200120],
                                @"": [NSString tt_formatCount:-1],
                                @"": [NSString tt_formatCount:0],
                                @"": [NSString tt_formatCount:NSIntegerMin],
                                @"922337203685477万": [NSString tt_formatCount:NSIntegerMax],
                                };
    
    for(NSString *key in testCases) {
        NSString *target = testCases[key];
        NSAssert([key isEqualToString: target], [NSString stringWithFormat:@"计数格式化规则错误"]);
    }
}


#endif

@end
