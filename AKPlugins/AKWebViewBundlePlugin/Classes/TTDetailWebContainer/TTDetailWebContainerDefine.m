//
//  TTDetailWebContainerDefine.m
//  TTWebViewBundle
//
//  Created by muhuai on 2017/7/30.
//  Copyright © 2017年 muhuai. All rights reserved.
//

#import "TTDetailWebContainerDefine.h"
#import <TTBaseLib/NetworkUtilities.h>
#import <TTUserSettings/TTUserSettingsManager+NetworkTraffic.h>

@implementation TTDetailWebContainerDefine

+ (NSString *)tt_loadImageJSStringKeyForType:(JSMetaInsertImageType)type
{
    NSString * keyString = nil;
    switch (type) {
        case JSMetaInsertImageTypeThumb:
            keyString = kJsMetaImageThumbKey;
            break;
        case JSMetaInsertImageTypeOrigin:
            keyString = kJsMetaImageOriginKey;
            break;
        default:
            keyString = kJsMetaImageNoneKey;
            break;
    }
    return keyString;
}

+ (JSMetaInsertImageType)tt_loadImageTypeWithImageMode:(NSNumber *)imageMode
                                    forseShowOriginImg:(BOOL)forseShowOriginImg
{
    TTNetworkTrafficSetting settingType = [TTUserSettingsManager networkTrafficSetting];
    BOOL showOriginForce = forseShowOriginImg || TTNetworkWifiConnected() || (settingType == TTNetworkTrafficOptimum) || [imageMode integerValue] == 1;
    if (showOriginForce) {
        return JSMetaInsertImageTypeOrigin;
    }
    else if (settingType == TTNetworkTrafficMedium) {
        return JSMetaInsertImageTypeThumb;
    }
    else {
        return JSMetaInsertImageTypeNone;
    }
}

@end
