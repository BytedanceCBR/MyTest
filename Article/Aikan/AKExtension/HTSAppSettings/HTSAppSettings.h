//
//  HTSAppSettings.h
//  LiveStreaming
//
//  Created by Quan Quan on 16/11/6.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTSAppSettingsModel.h"

@interface HTSAppSettings : NSObject

+ (HTSAppSettingsModel *)modelForApp;
+ (void)fetchAppSetting;
@end
