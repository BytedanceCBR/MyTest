//
//  AWEDeviceManager.h
//  Aweme
//
//  Created by Quan Quan on 16/8/31.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTSDeviceManager : NSObject

+ (BOOL)isCameraDenied;

+ (BOOL)isMicroPhoneDenied;

+ (void)requestPhotoLibraryPermission:(void(^)(BOOL success))completion;

+ (void)presentPhotoLibraryDeniedAlert;

@end
