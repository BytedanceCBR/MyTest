//
//  FHUtils.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/21.
//

#import "FHUtils.h"

@implementation FHUtils

+ (void)setContent:(id)object forKey:(NSString *)keyStr
{
    if (object && [keyStr isKindOfClass:[NSString class]]) {
        [[NSUserDefaults standardUserDefaults] setValue:object forKey:keyStr];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (instancetype)contentForKey:(NSString *)keyStr
{
    if ([keyStr isKindOfClass:[NSString class]]) {
       return  [[NSUserDefaults standardUserDefaults] valueForKey:keyStr];
    }else
    {
        return nil;
    }
}


@end
