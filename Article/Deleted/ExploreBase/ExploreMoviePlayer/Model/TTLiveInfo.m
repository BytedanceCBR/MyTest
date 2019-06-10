//
//  TTLiveInfo.m
//  Article
//
//  Created by Dai Dongpeng on 6/1/16.
//
//

#import "TTLiveInfo.h"

@implementation TTLiveURLInfo

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"main_play_url" : NSStringFromSelector(@selector(mainPlayURL)),
                                                       @"backup_play_url" : NSStringFromSelector(@selector(backupPlayURL))
                                                      }];
}

@end

@implementation TTLiveInfo

+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

- (NSArray *)allURL {
    NSMutableArray *array = [NSMutableArray array];
    if (!isEmptyString(self.live0.mainPlayURL)) {
        [array addObject:self.live0.mainPlayURL];
    }
    if (!isEmptyString(self.live0.backupPlayURL)) {
        [array addObject:self.live0.backupPlayURL];
    }
    if (!isEmptyString(self.live1.mainPlayURL)) {
        [array addObject:self.live0.mainPlayURL];
    }
    if (!isEmptyString(self.live1.backupPlayURL)) {
        [array addObject:self.live0.backupPlayURL];
    }
    return [array copy];
}

@end
