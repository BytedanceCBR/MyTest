//
//  TTDetailWebContainerConfig.m
//  TTWebViewBundle
//
//  Created by muhuai on 2017/9/6.
//  Copyright © 2017年 muhuai. All rights reserved.
//

#import "TTDetailWebViewContainerConfig.h"

@implementation TTDetailWebViewContainerConfig

+ (void)setEnabledWebPImage:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"tt_detail_webp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)enabledWebPImage {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"tt_detail_webp"];
}
@end
