//
//  TTPlatformSwitcher.m
//  Article
//
//  Created by xuzichao on 2017/5/16.
//
//

#import "TTPlatformSwitcher.h"
#import "NSDictionary+TTAdditions.h"

static TTPlatformSwitcher *switcher;

@interface TTPlatformSwitcher ()

@property (nonatomic,strong) NSDictionary *ABConfigDic;

@end

@implementation TTPlatformSwitcher
{
    NSDictionary * _ABConfigDic;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        switcher = [[self alloc] init];
    });
    return switcher;
}

- (void)setABConfigDic:(NSDictionary *)ABConfigDic
{
    if (ABConfigDic.allKeys.count > 0) {
        _ABConfigDic = ABConfigDic;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_ABConfigDic forKey:@"PlatFormABConfigDic"];
        [defaults synchronize];
    }
}

- (NSDictionary *)ABConfigDic
{
    if (!_ABConfigDic) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id dic = [defaults objectForKey:@"PlatFormABConfigDic"];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            _ABConfigDic  = (NSDictionary *)dic;
        }
    }
    
    return _ABConfigDic;
}

- (BOOL)isEnableForClass:(Class)className
{
    BOOL keySwitch = YES; //默认打开
    NSDictionary *dic = self.ABConfigDic;
    NSString *key = NSStringFromClass(className);
    if ([dic.allKeys containsObject:key]) {
        keySwitch = [dic tt_boolValueForKey:key];
    }
    return keySwitch;
}



@end
