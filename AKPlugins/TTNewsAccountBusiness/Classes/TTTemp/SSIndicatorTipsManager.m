//
//  SSIndicatorTipsManager.m
//  Article
//
//  Created by Huaqing Luo on 18/3/15.
//
//

#import "SSIndicatorTipsManager.h"

#define kIndicatorTipsKey @"IndicatorTipsKey"

@interface SSIndicatorTipsManager ()

@property(nonatomic, strong) NSDictionary * tipsDict;

@end

static SSIndicatorTipsManager * manager;

@implementation SSIndicatorTipsManager

@synthesize tipsDict = _tipsDict;

+ (SSIndicatorTipsManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma mark -- public

- (void)setIndicatorTipsWithDictionary:(NSDictionary *)tipsDict
{
    if (tipsDict && [tipsDict isKindOfClass:[NSDictionary class]]) {
        self.tipsDict = [tipsDict copy];
        [[NSUserDefaults standardUserDefaults] setObject:self.tipsDict forKey:kIndicatorTipsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSString *)indicatorTipsForKey:(NSString *)key
{
    id tip = [self.tipsDict valueForKey:key];
    if ([tip isKindOfClass:[NSString class]]) {
        return tip;
    }
    
    return nil;
}

#pragma mark -- Getters/Setters

- (NSDictionary *)tipsDict
{
    if (!_tipsDict) {
        _tipsDict = [[NSUserDefaults standardUserDefaults] valueForKey:kIndicatorTipsKey];
    }
    
    return _tipsDict;
}

@end
