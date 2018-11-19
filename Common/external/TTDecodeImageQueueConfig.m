//
//  TTDecodeImageQueueConfig.m
//  Article
//
//  Created by 邱鑫玥 on 2018/2/16.
//

#import "TTDecodeImageQueueConfig.h"
#import "TTSettingsManager.h"

@implementation TTDecodeImageQueueConfig

+ (BOOL)isDecodeImageInAnIndependentQueueEnabled
{
    return [[[TTSettingsManager sharedManager] settingForKey:@"tt_decode_image_independent_queue" defaultValue:@NO freeze:YES] boolValue];
}

@end
