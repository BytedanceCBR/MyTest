//
//  TTAssetCountHelper.m
//  Article
//
//  Created by 徐霜晴 on 16/11/18.
//
//

#import "TTAssetCountHelper.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+TTImagePicker.h"

@implementation TTAssetCountHelper

+ (void)saveAssetCount {
    [self getAssetCountIfAutorizedCompleted:^(BOOL succeed, NSInteger count) {
        if (succeed) {
            [[NSUserDefaults standardUserDefaults] setValue:@(count) forKey:@"NSUserDefaultsKeyAssetCount"];
        }
        else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NSUserDefaultsKeyAssetCount"];
        }
    }];
}

+ (BOOL)hasValidAssetCountSavedLastTime {
    id countObj = [[NSUserDefaults standardUserDefaults] objectForKey:@"NSUserDefaultsKeyAssetCount"];
    if (countObj) {
        return YES;
    }
    return NO;
}

+ (NSInteger)assetCountSavedLastTime {
    NSInteger assetCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"NSUserDefaultsKeyAssetCount"];
    return assetCount;
}

+ (void)getAssetCountIfAutorizedCompleted:(void(^)(BOOL succeed, NSInteger count))completed {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusAuthorized) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ALAssetsLibrary *assetsLibrary = [ALAssetsLibrary tt_defaultAssetsLibrary];
            __block NSInteger count = 0;
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    @try {
                        count += [group numberOfAssets];
                    } @catch (NSException *exception) {
                        
                    } @finally {
                        
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completed(YES, count);
                    });
                }
            } failureBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completed(NO, 0);
                });
            }];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completed(NO, 0);
        });
    }
}


@end
