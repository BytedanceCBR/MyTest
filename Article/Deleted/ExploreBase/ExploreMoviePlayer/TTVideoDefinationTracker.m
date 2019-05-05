//
//  TTVideoDefinationTracker.m
//  Article
//
//  Created by panxiang on 2017/3/16.
//
//

#import "TTVideoDefinationTracker.h"
#import "Singleton.h"

@implementation TTVideoDefinationTracker
@synthesize definationNumber = _definationNumber;
+ (TTVideoDefinationTracker *)sharedTTVideoDefinationTracker
{
    static TTVideoDefinationTracker * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TTVideoDefinationTracker alloc] init];
    });

    return instance;
}

- (void)definationNumber:(NSInteger)definationNumber
{
    _definationNumber = definationNumber;
}

- (void)reset
{
    _definationNumber = 0;
    _clarity_change_time = 0;
}

- (NSString *)stringWithDefination:(ExploreVideoDefinitionType)defination
{
    NSString *str = @"360P";
    if (defination == ExploreVideoDefinitionTypeHD) {
        str = @"480P";
    } else if (defination == ExploreVideoDefinitionTypeFullHD) {
        str = @"720P";
    }
    return str;
}

- (NSString *)lastDefinationStr
{
    return [self stringWithDefination:self.lastDefination];
}

- (NSString *)actualDefinationtr
{
    return [self stringWithDefination:self.actual_clarity];
}

@end
