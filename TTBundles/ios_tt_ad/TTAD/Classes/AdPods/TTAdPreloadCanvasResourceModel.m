//
//  TTAdPreloadCanvasResourceModel.m
//  Article
//
//  Created by carl on 2017/5/24.
//
//

#import "TTAdPreloadCanvasResourceModel.h"

@implementation TTAdPreloadCanvasSettingModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

@end


@implementation TTAdPreloadCanvasResourceModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"ad_id"]) {
        return NO;
    }
    if ([propertyName isEqualToString:@"canvas"]) {
        return NO;
    }
    return YES;
}
@end
