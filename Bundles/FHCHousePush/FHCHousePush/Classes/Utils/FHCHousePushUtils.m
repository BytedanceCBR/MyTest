//
//  FHCHousePushUtils.m
//  FHCHousePush
//
//  Created by 张静 on 2019/4/10.
//

#import "FHCHousePushUtils.h"

@implementation FHCHousePushUtils

+ (long long)fixLongLongTypeGroupID:(long long)gIDStr
{
    long long fixedID = gIDStr;
    if (fixedID < 0) {  //逻辑修正，爱看2.7(包括)版本之前，使用int32存储groupID，溢出，新版本需要兼容负数groupID
        fixedID = fixedID + 4294967296;
    }
    return fixedID;
}

+ (NSString *)fixStringTypeGroupID:(NSString *)gIDStr
{
    long long fixedID = [self fixLongLongTypeGroupID:[gIDStr longLongValue]];
    NSString * fixedGroupIDString = [NSString stringWithFormat:@"%lli", fixedID];
    return fixedGroupIDString;
}


+ (NSNumber *)fixNumberTypeGroupID:(NSNumber *)gID
{
    long long fixedID = [self fixLongLongTypeGroupID:[gID longLongValue]];
    return @(fixedID);
}

@end
