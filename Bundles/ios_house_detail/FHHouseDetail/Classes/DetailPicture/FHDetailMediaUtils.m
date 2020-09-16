//
//  FHDetailMediaUtils.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/16.
//

#import "FHDetailMediaUtils.h"

@implementation FHDetailMediaUtils

+ (NSString *)optionFromName:(NSString *)str {
    NSString *option = str;
    if ([str isEqualToString:@"图片"]) {
        option = @"picture";
    } else if ([str isEqualToString:@"户型"]) {
        option = @"house_model";
    } else if ([str isEqualToString:@"视频"]) {
        option = @"video";
    } else if ([str isEqualToString:@"house_vr_icon"]) {
        option = @"house_vr_icon";
    } else if ([str isEqualToString:@"VR"]) {
        option = @"house_vr";
    }else if ([str isEqualToString:@"样板间"]) {
        option = @"prototype";
    } else if ([str isEqualToString:@"街景"]) {
        option = @"panorama";
    }
    return option;
}

@end
