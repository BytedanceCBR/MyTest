//
//  TTVRAction.m
//  Created by panxiang on 2018/7/20.
//

#import "TTVRAction.h"

@implementation TTVRAction

@synthesize type;

@synthesize info;

+ (instancetype)actionWithType:(NSString *)type info:(NSDictionary *)info
{
    TTVRAction *action = [[[self class] alloc] init];
    action.type = type;
    action.info = info;
    return action;
}
@end
