//
//  TTRNKitGeckoWrapper.m
//  AFgzipRequestSerializer
//
//  Created by renpeng on 2018/9/4.
//

#import "TTRNkitJSExceptionDelegate.h"
#import "TTRNKitGeckoWrapper.h"
#import "TTRNKit.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import <IESGeckoKit/IESGeckoKit.h>

@implementation TTRNKitGeckoWrapper
#pragma mark - Gecko
+ (void)syncWithGeckoParams:(NSDictionary *)geckoParams
                 completion:(void (^)(BOOL bundleUpdate, BOOL bundleIsLatest, NSArray *channels))completion {
    [self syncWithGeckoParams:geckoParams
                     channels:nil
                   completion:completion];
}

+ (void)syncWithGeckoParams:(NSDictionary *)geckoParams
                   channels:(NSArray *)channels
                 completion:(void (^)(BOOL, BOOL, NSArray*))completion {
    NSAssert(geckoParams, @"geckoParams can't be nil");
    NSArray *allChannels = nil;
    if (channels) {
        allChannels = channels;
    } else {
        NSString *channel = [geckoParams tt_stringValueForKey:TTRNKitGeckoChannel]; //多个channel以英文，分隔
        allChannels = [channel componentsSeparatedByString:@","];
    }
    BOOL allChannelRegisterd = YES;
    NSArray *currentMetaInfos = [IESGeckoKit currentMetaInfo];
    for (NSString *ch in allChannels) {
        if (!allChannelRegisterd) {
            break;
        }
        BOOL curChannelRegisterd = NO;
        for (IESGeckoConfigModel *model in currentMetaInfos) {
            if ([model.accessKey isEqualToString:[geckoParams tt_stringValueForKey:TTRNKitGeckoKey]]
                && [model.channelArray containsObject:ch]) {
                curChannelRegisterd = YES;
                break;
            }
        }
        allChannelRegisterd &= curChannelRegisterd;
    }
    
    if (!allChannelRegisterd) {
        [IESGeckoKit setDeviceID:[geckoParams tt_stringValueForKey:TTRNKitDeviceId]];
        [IESGeckoKit registerAccessKey:[geckoParams tt_stringValueForKey:TTRNKitGeckoKey]
                            appVersion:[geckoParams tt_stringValueForKey:TTRNKitGeckoAppVersion]
                              channels:allChannels];
    }
    void (^fetchCompletion)(BOOL succeed, IESGeckoSyncStatusDict  _Nonnull dict) =
    ^(BOOL succeed, IESGeckoSyncStatusDict  _Nonnull dict) {
        IESGeckoSyncStatus status = dict[IESGeckoChannelPlaceHolder] ?
        [dict[IESGeckoChannelPlaceHolder] integerValue] : IESGeckoSyncStatusServerPackageUnavailable;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (succeed && IESGeckoSyncStatusSuccess == status) {
                [TTRNkitJSExceptionDelegate setFallBackForChannelsInPersistence:channels];
                completion ? completion(YES, YES, channels) : nil;
            } else if (succeed) {
                completion ? completion(NO, YES, channels) : nil;
            } else {
                completion ? completion(NO, NO, channels) : nil;
            }
        });
    };
    [IESGeckoKit syncResourcesWithAccessKey:[geckoParams tt_stringValueForKey:TTRNKitGeckoKey]
                                   channels:allChannels
                                 completion:^(BOOL succeed, IESGeckoSyncStatusDict  _Nonnull dict) {
                                     fetchCompletion(succeed, dict);
                                 }];
}


@end
